.. _nethserver-makerpms-module:

nethserver-makerpms
===================

RPM builds by Linux containers

.. image:: https://travis-ci.com/NethServer/nethserver-makerpms.svg?branch=master
    :target: https://travis-ci.com/NethServer/nethserver-makerpms


This is a simple RPM build environment based on the official CentOS Docker image.

It can build RPMs in the travis-ci.com environment, or on your local
Fedora 31+/CentOS 8 machine.

Installation/upgrade
--------------------

On Fedora 31+ and CentOS 8, run as a non-root user ::

  $ curl https://raw.githubusercontent.com/NethServer/nethserver-makerpms/master/install.sh | bash

There must be ``podman`` [#Podman]_ already installed though.

Build requirements
------------------

Requirements for building RPMs, implemented by the ``buildimage/makesrpm`` command:

- The .spec file is in the current working directory

- Source tarballs defined in the .spec file can be downloaded via ``http://`` or ``ftp://``.

- If a ``SHA1SUM`` file exists in the current working directory, the integrity of
  source tarballs is checked against it. Do not put any path in the ``SHA1SUM`` contents,
  only the tarball/source file name.

- If the current working directory contains a ``.git`` directory (thus it is a git repository workdir)
  the specfile ``source0`` can be set to ``Source: %{name}-%{version}.tar.gz``. Then git-archive
  generates a tarball of the repository itself at the HEAD commit.

- Other tarballs are downloaded automatically with ``spectool`` during the build.


Building RPMs locally
---------------------

If the previous build requirements are met, change directory to the repository root then run ::

  $ makerpms *.spec

Run without any argument to get a **brief help** ::

  $ makerpms

To build a NethServer 6 RPM pass the ``NSVER`` environment variable to ``makerpms`` ::

  $ NSVER=6 makerpms *.spec

To build a package for another distribution pass the ``DIST`` environment variable ::

  $ DIST=.el7 makerpms *.spec

If you have a custom or development builder image to test, set the ``IMAGE`` environment variable, e.g.: ::

  $ IMAGE=me/myimage:test makerpms *.spec

It is possible to override the builder command, with the ``COMMAND`` environment variable ::

  $ COMMAND="whoami" makerpms *.spec
  makerpms

Additional arguments can be passed to YUM before starting the binary build, to fetch dependencies
not tracked by ``BuildRequires``, enable additional repositories and so on... ::

  $ YUM_ARGS="--enablerepo=nethserver-testing" makerpms *.spec


Optimizations
^^^^^^^^^^^^^

To speed up the build process, the YUM cache directory contents are preserved.
Container instances share the named Podman volume ``makerpms-yum-cache``.

To clear the YUM cache run ::

  $ podman volume rm makerpms-yum-cache


Builder container images
^^^^^^^^^^^^^^^^^^^^^^^^

The builder container images are updated periodically and are available at
https://hub.docker.com/r/nethserver/makerpms.

* ``nethserver/makerpms:7`` is the default image, for ``noarch`` builds
* ``nethserver/makerpms:buildsys7`` is the image for ``x86_64`` builds (GCC 4)
* ``nethserver/makerpms:devtoolset7`` is the image for ``x86_64`` builds
  with GCC 9 (devtoolset-9 from SCLo), then run makerpms in a SCLo environment, e.g. : ::

    $ COMMAND="scl enable devtoolset-9 -- makerpms" makerpms *.spec

For more info about how to build the images locally look at ``travis/build-container.sh``.

The following command locally builds the images with Podman (instead of Docker): ::

  $ cat travis/build-container.sh  | sed s/docker/podman/  | \
  grep -v -E '\b(login|logout|push)\b'  | \
  NSVER=7 IMAGE_REPO=me/myimage bash

To test the local image run makerpms as follow: ::

  $ IMAGE=me/myimage:7 makerpms *.spec

Images for NethServer 6 are available as well: just replace ``7`` with ``6``.


Other commands
--------------

The ``install.sh`` scripts installs also the following commands:

* ``uploadrpms`` is a RPM publishing helper, specific for the NethServer community RPMs publishing policies
* ``releasetag`` is a release workflow helper, specific for the NethServer community release guidelines
* ``makesrpm`` builds just the ``.src.rpm`` package.

.. _uploadrpms-section:

uploadrpms
^^^^^^^^^^

The first time, before running ``uploadrpms`` ensure the following command works ::

  $ sftp username@packages.nethserver.org

Accept the server SSH key fingerprint when asked.

The following command uploads all the RPMs in the current working directory to the ``nethforge`` testing
repository for NethServer version ``7.8.2003``. ::

  $ uploadrpms username@packages.nethserver.org:nscom/7.8.2003/nethforge-testing *.rpm

Replace ``7.8.2003`` with the correct NS version number. Also replace ``nethforge-testing``
with the target repository name.

The command output might complain about some SFTP disabled commands. Ignore those messages.

.. _releasetag-section:

releasetag
^^^^^^^^^^

The ``releasetag`` command executes a workflow that suits only those
NethServer packages that expect a ``Version`` tag in the form ``X.Y.Z``.

Some RPMs, (notably ``nethserver-release``) require a different version schema
and ``releasetag`` does not suit their release workflow. Refer to their README
files for more information.

When ``releasetag`` is invoked:

* reads the git log history and fetches related issues from the issue
  tracker web site.
* updates the ``Version`` tag and the ``%changelog`` section in the ``.spec`` file.
* commits changes to the ``.spec`` file.
* tags the commit (with optional GPG signature).

To fetch issues from private GitHub repositories
`create a private GitHub access token <https://github.com/settings/tokens/new>`_.
Select the ``repo`` scope only.

Copy it to ``~/.release_tag_token`` and keep its content secret: ::

  chmod 600  ~/.release_tag_token

.. tip::

    The private access token is useful also for public repositories
    because authenticated requests have an higher API rate limit


The ``releasetag`` command is now ready for use. This is the help output::

  releasetag -h
  Usage: releasetag [-h] [-k KEYID] [-T <x.y.z>] [<file>.spec]

Sample invocation: ::

  releasetag -k ABCDABCD -T 1.8.5 nethserver-mail-server.spec

To force a local GPG password prompt (tested on Fedora) prepend some additional
environment variables::

  GPG_TTY=$(tty) GPG_AGENT_INFO="" releasetag  -k ABCDABCD -T 1.8.5 nethserver-mail-server.spec

Replace ``ABCDABCD`` with your signing GPG key. The ``$EDITOR``
program (or git ``core.editor``) is opened automatically to adjust the
commit message. The same text is used as tag annotation.
Usage of ``-k`` option is optional.

To push the tagged release to GitHub (and possibly trigger an automated build)
ensure to add the ``--follow-tags`` option to ``git push`` invocation. For
instance: ::

  git push --follow-tags

To make ``--follow-tags`` permanent run this command: ::

  git config --global push.followTags true



Building RPMs on github.com
------------------------------

`github.com <https://github.com/features/actions>`_ automatically builds RPMs and uploads
them to ``packages.nethserver.org``, if configured with enough environment variables
and upload secrets.

Configuration
^^^^^^^^^^^^^

To automate the RPM build process using GitHub

* create a ``.github/workflows/make-rpms.yml`` file inside the source code repository hosted on
  GitHub.

* the repository must have builds enabled and upload secrets properly set up, if the repo is inside Nethserver org, everything is already set up (as long as you have write access to the repo).
  Contact the organization maintainer on `community.nethserver.org <https://community.nethserver.org>`_ for help.

This is an example of ``.github/workflows/make-rpms.yml`` contents: ::

  name: Make RPMs
  on:
    push:
      branches:
        - master
        - main
    pull_request:
  jobs:
    make-rpm:
      runs-on: ubuntu-latest
      env:
        DEST_ID: core
        NSVER: 7
        DOCKER_IMAGE: nethserver/makerpms:7
      steps:
        - uses: actions/checkout@v3
          with:
            fetch-depth: 0
            ref: ${{ github.head_ref }}
        - name: Generate .env file
          run: |
            cat .env < EOF
              DEST_ID=${{ env.DEST_ID }}
              NSVER=${{ env.NSVER }}
              DOCKER_IMAGE=${{ env.DOCKER_IMAGE }}
              GITHUB_HEAD_REF=${{ env.GITHUB_HEAD_REF }}
              GITHUB_RUN_NUMBER=${{ env.GITHUB_RUN_NUMBER }}
              GITHUB_ACTIONS=${{ env.GITHUB_ACTIONS }}
              ENDPOINTS_PACK=${{ secrets.endpoints_pack }}
              SECRET=${{ secrets.secret }}
              SECRET_URL=${{ secrets.secret_url }}
              AUTOBUILD_SECRET=${{ secrets.autobuild_secret }}
              AUTOBUILD_SECRET_URL=${{ secrets.autobuild_secret_url }}
              GPG_SIGN_KEY=${{ secrets.gpg_sign_key }}
            EOF
        - name: Run prep-sources if present.
          run: if test -f "prep-sources"; then ./prep-sources; fi
        - name: Build RPM and publish
          run: |
            echo "Starting build..."
            docker run --name makerpms \
              --env-file .env
              --hostname $GITHUB_RUN_ID-$GITHUB_RUN_NUMBER.nethserver.org \
              --volume $PWD:/srv/makerpms/src:ro \
              $DOCKER_IMAGE \
              makerpms-github -s *.spec
            echo "Build succesful."
            echo "Checking if publish configuration exists..."
            if [[ "${{ secret.endpoints_pack }}" -a "${{ secret.secret }} ]]; then
              echo "Publish configuration exists, pushing package to repo."
              docker commit makerpms nethserver/build
              docker run \
                --env-file .env
                nethserver/build \
                uploadrpms-github
              echo "Publish complete."
            fi
            rm .env

Usage
^^^^^

Travis CI builds are triggered automatically when:

* one or more commits are pushed to the `master` branch of the NethServer repository, as
  stated in the ``.github/workflows/make-rpms.yml`` file inside the ``on.push.branches`` key

* A *pull request* is opened from a NethServer repository fork or it is updated
  by submitting new commits

After a successful build, the RPM is uploaded to ``packages.nethserver.org``,
according to the ``DEST_ID`` variable value. Supported values are ``core`` for
NethServer core packages, and ``forge`` for NethForge packages.

Pull requests are commented automatically by ``nethbot``
[#NethBot]_ with the links to available RPMs.

Also issues are commented by ``nethbot`` if the following rules are respected in git commit messages:

1. The issue reference (e.g. ``NethServer/dev#1234``) is present in the merge
   commit of pull requests

2. The issue reference is added to standalone commits (should be rarely used)


The build environment supports the following variables:

- ``NSVER``
- ``DOCKER_IMAGE``
- ``DEST_ID``

NSVER
~~~~~

``NSVER`` selects the target NethServer version for the build system. Currently
the supported version values are ``7`` and ``6``.

DOCKER_IMAGE
~~~~~~~~~~~~

The Docker build image can contain different RPMs depending on the tag:

- ``latest`` (or ``7``) contains only dependencies to build ``nethserver-*`` RPMS, like ``nethserver-base``.
  It actually installs only nethserver-devtools and a basic RPM build environment without gcc compiler.

- ``buildsys7`` is based on the previous environment. It also pulls in the dependencies for arch-dependant packages (like ``asterisk13`` or ``ns-samba``).
  It actually installs the ``buildsys-build`` package group, which provides the ``gcc`` compiler (version 4) among other packages.

- ``devtoolset7``: it extends the *buildsys7* with the devtoolset-9 SCLo packages set. It is possible to
  compile with gcc version 9, by prefixing the container entry point in the following way: ::

    docker run -ti [OPTIONS] scl enable devtoolset-9 -- makerpms-travis package.spec

  For instance, see the `sofia-sip package <https://github.com/NethServer/sofia-sip>`_.

DEST_ID
~~~~~~~

If ``DEST_ID=core``:

* Builds triggered by pull requests are uploaded to the ``autobuild`` [#Autobuild]_ repository

* Builds triggered by commits pushed to master are uploaded to the ``testing``
  [#Testing]_ repository. If a git tag is on the last available commit,
  the upload destination is the ``updates`` repository.

If ``DEST_ID=forge``:

* Pull requests are uploaded to ``nethforge-autobuild``

* Branch builds are uploaded to ``nethforge-testing``, whilst tagged builds are uploaded to ``nethforge``

.. warning::

    In any case, **the git tag must begin with a digit
    and not containing any "-" minus symbol**.
    For instance the tag ``0.1.12`` is considered
    as a tagged build whilst ``v0.1.12-1`` is not




.. rubric:: References

.. [#Podman] Podman is a daemonless Linux container engine. https://podman.io/
.. [#Autobuild] Is a particular kind of repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.com. http://packages.nethserver.org/nethserver/7.4.1708/autobuild/x86_64/Packages/
.. [#Testing] Is a repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.com started form official ``nethserver`` github repository. http://packages.nethserver.org/nethserver/7.4.1708/testing/x86_64/Packages/
.. [#NethBot] Is our bot that comments the issues and pull request with the list of automated RPMs builds. https://github.com/nethbot

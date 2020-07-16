.. _nethserver-makerpms-module:

nethserver-makerpms
===================

RPM builds by Linux containers

.. image:: https://travis-ci.org/NethServer/nethserver-makerpms.svg?branch=master
    :target: https://travis-ci.org/NethServer/nethserver-makerpms


This is a simple RPM build environment based on the official CentOS Docker image.

It can build RPMs in the travis-ci.org environment, or on your local
Fedora 31+/CentOS 8 machine.

Installation/upgrade
--------------------

On Fedora 31+ and CentOS 8, run as a non-root user ::

  $ curl https://raw.githubusercontent.com/NethServer/nethserver-makerpms/master/install.sh | bash

There must be ``podman`` already installed though.

Building RPMs locally
---------------------

Requisites to build RPMs starting from a git repository:

- The .spec file is placed at the root of the repository

- In the specfile, ``source0`` corresponds to the git archive output in
  ``tar.gz`` format (e.g. ``Source: %{name}-%{version}.tar.gz``)

- If a ``SHA1SUM`` file at the root of the repository exists, the integrity of
  additional source tarballs is checked against it

Additional missing tarballs are downloaded automatically with ``spectool``
during the build.

If the requirements are met, change directory to the repository root then run ::

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

The container images

  cd /usr/share/nethserver-makerpms/
  podman build -f Dockerfile-7 .

For more info about the image builds look at ``travis/build-container.sh``.

Images for NethServer 6 are available as well: just replace ``7`` with ``6``.


Other commands
--------------

* ``makesrpm`` builds just the ``.src.rpm`` package.
* ``releasetag`` is a release workflow helper, specific for the NethServer community release guidelines
* ``uploadrpms`` is a RPM publishing helper, specific for the NethServer community RPMs publishing policies



travis-ci.org
=============

`travis-ci.org <https://travis-ci.org>`_ automatically builds RPMs and uploads
them to ``packages.nethserver.org``.

Configuration
-------------

To automate the RPM build process using Travis CI

* create a ``.travis.yml`` file inside the source code repository hosted on
  GitHub

* the `NethServer repository <https://travis-ci.org/NethServer/>`_ must
  have Travis CI builds enabled

The list of enabled repositories is available at `NethServer page on
travis-ci.org <https://travis-ci.org/NethServer/>`_.

This is an example of ``.travis.yml`` contents: ::

  ---
  language: ruby
  services:
      - docker
  branches:
      only:
          - master
  env:
    global:
      - DEST_ID=core
      - NSVER=7
      - DOCKER_IMAGE=nethserver/makerpms:${NSVER}
      - >
          EVARS="
          -e DEST_ID
          -e TRAVIS_BRANCH
          -e TRAVIS_BUILD_ID
          -e TRAVIS_PULL_REQUEST_BRANCH
          -e TRAVIS_PULL_REQUEST
          -e TRAVIS_REPO_SLUG
          -e TRAVIS_TAG
          -e NSVER
          -e ENDPOINTS_PACK
          "
  script: >
      docker run -ti --name makerpms ${EVARS}
      --hostname b${TRAVIS_BUILD_NUMBER}.nethserver.org
      --volume $PWD:/srv/makerpms/src:ro ${DOCKER_IMAGE} makerpms-travis -s *.spec
      && docker commit makerpms nethserver/build
      && docker run -ti ${EVARS}
      -e SECRET
      -e SECRET_URL
      -e AUTOBUILD_SECRET
      -e AUTOBUILD_SECRET_URL
      nethserver/build uploadrpms-travis

Usage
-----

Travis CI builds are triggered automatically when:

* one or more commits are pushed to the `master` branch of the NethServer repository, as
  stated in the ``.travis.yml`` file above by the ``branches`` key

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


Global variables
^^^^^^^^^^^^^^^^

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

- ``latest`` or ``7``: contains only dependencies to build ``nethserver-*`` RPMS, like ``nethserver-base``.
  It actually installs only nethserver-devtools and a basic RPM build environment without gcc compiler.
- ``buildsys7``: it s based on the previous environment. It also pulls in the dependencies for arch-dependant packages (like ``asterisk13`` or ``ns-samba``).
  It actually installs the ``buildsys-build`` package group, which provides the ``gcc`` compiler among other packages.

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

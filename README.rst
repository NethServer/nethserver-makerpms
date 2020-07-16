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

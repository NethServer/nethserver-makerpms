.. _nethserver-makerpms-module:

nethserver-makerpms
===================

RPM builds by Linux containers

.. image:: https://travis-ci.org/NethServer/nethserver-makerpms.svg?branch=master
    :target: https://travis-ci.org/NethServer/nethserver-makerpms


This is a simple RPM build environment based on the official CentOS Docker image.

It can build RPMs in the travis-ci.org environment, or on your local
Fedora 29+ machine. CentOS rootless builds seem to not (still) work: as such
you must be root to make it work on NethServer 7.

Installation
------------

On Fedora 31+ ::

  $ sudo dnf install http://packages.nethserver.org/nethserver/7.8.2003/updates/x86_64/Packages/nethserver-makerpms-1.2.0-1.ns7.noarch.rpm

On NethServer 7 ::

  # yum install nethserver-makerpms

Build RPMs
----------

Requisites to build RPMs starting from a git repository:

- The .spec file is placed at the root of the repository

- In the specfile, ``source0`` corresponds to the git archive output in
  ``tar.gz`` format (e.g. ``Source: %{name}-%{version}.tar.gz``)

- If a SHA1SUM file at the root of the repository exists, the integrity of
  additional source tarballs is checked against it

Additional missing tarballs are downloaded automatically with ``spectool``
during the build.

If the requirements are met, change directory to the repository root then run ::

  $ makerpms *.spec

To build a NethServer 6 RPM pass the ``NSVER`` environment variable to ``makerpms`` ::

  $ NSVER=6 makerpms *.spec

If you have a custom or development builder image to test, set the ``IMAGE`` environment variable, e.g.: ::

  $ IMAGE=me/myimage:test makerpms *.spec

It is possible to override the builder command, with the ``COMMAND`` environment variable ::

  $ COMMAND="whoami" makerpms *.spec
  makerpms


Optimizations
-------------

To speed up the build process, the YUM cache directory contents are preserved.
Container instances share the named Podman volume ``makerpms-yum-cache``.

To clear the YUM cache run ::

  $ podman volume rm makerpms-yum-cache


Container images
----------------

The container images are built every week and are available at
https://hub.docker.com/r/nethserver/makerpms.

* ``nethserver/makerpms:7`` is the default image, for ``noarch`` builds
* ``nethserver/makerpms:buildsys7`` is the image for ``x86_64`` builds
* ``nethserver/makerpms:devtoolset7`` is the image for ``x86_64`` builds 
  with GCC 9 (devtoolset-9 from SCLo), then run makerpms in a SCLo environment, e.g. : ::

    $ COMMAND="scl enable devtoolset-9 -- makerpms" makerpms *.spec

To build the image locally run ::

  cd /usr/share/nethserver-makerpms/
  podman build -f Dockerfile-7 .

For more info about the image builds look at ``travis/build-container.sh``.

Images for NethServer 6 are available as well: just replace ``7`` with ``6``.

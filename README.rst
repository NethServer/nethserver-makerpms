===================
nethserver-makerpms
===================

Build RPMs in a Linux container

.. image:: https://travis-ci.org/NethServer/nethserver-makerpms.svg?branch=master
    :target: https://travis-ci.org/NethServer/nethserver-makerpms

Usage
=====

`Download RPMs <https://github.com/NethServer/nethserver-makerpms/releases>`_
for Fedora 26+ and install on the local system.

Create the builder image (optional)::

  sudo buildah bud -t nethserver/makerpms buildimage

Build an RPM. Move to the git repository root directory then ::

  sudo makerpms


Container image reference
=========================

Build the image
-------------------------------

With Docker ::

  docker build -t nethserver/makerpms buildimage

With buildah ::

  buildah bud -t nethserver/makerpms buildimage

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

If requirements are met, change directory to the repository root then to
start a build with **docker** run ::

  docker run --name builder --privileged=true -v $PWD:/srv/makerpms/src:ro  nethserver/makerpms
  docker cp -a builder:/srv/makerpms/rpmbuild/SRPMS .
  docker cp -a builder:/srv/makerpms/rpmbuild/RPMS .
  docker rm builder

With **buildah** ::

  builder=$(buildah from nethserver/makerpms)
  buildah run -v $PWD:/srv/makerpms/src:ro $builder -- makerpms -s \*.spec
  buildah rm $builder

Optimizations
-------------

The ``/var/yum/cache/`` directory could be volume-mounted across builds to
speed up YUM downloads.

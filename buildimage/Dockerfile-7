#
# Copyright (C) 2017 Nethesis S.r.l.
# http://www.nethesis.it - nethserver@nethesis.it
#
# This script is part of NethServer.
#
# NethServer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License,
# or any later version.
#
# NethServer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NethServer.  If not, see COPYING.
#

FROM centos:7
RUN set -e ; \
    yum -y --setopt=tsflags=nodocs install http://packages.nethserver.org/nethserver/nethserver-release-7.rpm epel-release ; \
    yum -y --setopt=tsflags=nodocs install sudo rpmdevtools yum-utils git nethserver-devtools perl sed openssl expect ; \
    yum clean all ; \
    rm -rf /var/cache/yum/*

COPY makerpms makesrpm uploadrpms makerpms-travis uploadrpms-travis /usr/local/bin/
COPY buildimage /usr/local/sbin/
RUN useradd -m -d /srv/makerpms -r makerpms
RUN buildimage

USER makerpms
WORKDIR /srv/makerpms
RUN rpmdev-setuptree -d; echo '%url_prefix http://github.com/NethServer' >> /srv/makerpms/.rpmmacros

CMD ["bash"]
ENTRYPOINT []
WORKDIR /srv/makerpms/src

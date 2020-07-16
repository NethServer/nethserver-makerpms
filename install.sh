#
# Copyright (C) 2020 Nethesis S.r.l.
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

#
# Install script for Fedora 31+/CentOS 8. It downloads and installs
# makerpms commands under ~/bin of the current user.
#

set -e

if [[ ! -d ~/bin ]]; then
    echo "[ERROR] the ~/bin directory does not exist"
    exit 1
fi

cd ~/bin

baseurl="https://raw.githubusercontent.com/NethServer/nethserver-makerpms/master/src/bin"

for F in issuerefs makerpms makesrpm releasetag uploadrpms; do
    curl "${baseurl}/$F" > $F
    chmod -c +x $F
    if ! which $F &>/dev/null; then
        echo "[ERROR] Cannot find $F in \$PATH. Ensure \$PATH includes ~/bin."
        exit 1
    else 
        echo "[NOTICE] Installed command $F in " ~/bin
    fi
done

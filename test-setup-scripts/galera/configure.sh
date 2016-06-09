#!/bin/bash
#
# This file is distributed as part of MariaDB Manager.  It is free
# software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation,
# version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2012-2014 SkySQL Corporation Ab
#
# Author: Marcos Amaral
# Date: July 2013
# Author: Massimo Siani
# Date: May 2014: fixes for Debian/Ubuntu, user creation checks.
#
# This script does the necessary configuration steps to have the node ready for
# command execution.
#

set -x

rep_username="repl"
rep_password="repl"
db_username="skysql"
db_password="skysql"

sudo /etc/init.d/mysql restart --wsrep-cluster-address=gcomm://

sleep 100

sudo mysql -u root -e "DELETE FROM mysql.user WHERE user = ''; \
GRANT ALL PRIVILEGES ON *.* TO $rep_username@'%' IDENTIFIED BY '$rep_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $db_username@'%' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $rep_username@'localhost' IDENTIFIED BY '$rep_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $db_username@'localhost' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO maxskysql@'%' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO maxskysql@'localhost' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
FLUSH PRIVILEGES;"


sudo /etc/init.d/mysql stop

chkconfig --del mysql
update-rc.d -f mysql remove
echo "done"

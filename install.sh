# Installed CentOS-7-x86_64-Minimal-1503-01.iso with minimal install configuration.

# Created Users
# root / Cyb3rDr0p!!
# admin / Cyb3rDr0p!!



# Get Wireless Working and Run Install Script
# -----------------------
# wpa_supplicant -B -dd -i wlp2s0 -c <(wpa_passphrase Chad Suncatcher2012) && dhclient wlp2s0 -v
# bash <(curl -s https://raw.githubusercontent.com/cyberdrop/install/master/install.sh)





# Add CyberDrop User
# -----------------------
useradd cyberdrop





# Install Dependencies
# -----------------------
yum install -y autoconf gcc-c++ zlib-devel perl-devel openssl-devel glib2-devel ntp yajl-devel libxml2-devel device-mapper-devel libpciaccess-devel libnl-devel
yum update -y










# Install Git
# ------------------------
mkdir /usr/git && curl https://codeload.github.com/git/git/tar.gz/v2.5.0 | tar -xvz -C /usr/git
cd /usr/git/git-2.5.0 && make configure && ./configure && make all && make install
ln -s /usr/git/git-2.5.0 /opt/git










# Install Node
# -------------------------
mkdir /usr/node && curl https://nodejs.org/dist/v4.4.0/node-v4.4.0.tar.gz | tar -xvz -C /usr/node
cd /usr/node/node-v4.4.0 && ./configure && make && make install
ln -s /usr/node/node-v4.4.0 /opt/node










# Install SCONS
# -------------------------
mkdir /usr/scons && curl http://iweb.dl.sourceforge.net/project/scons/scons/2.4.1/scons-2.4.1.tar.gz | tar -xvz -C /usr/scons
cd /usr/scons/scons-2.4.1 && python setup.py install
ln -s /usr/scons/scons-2.4.1 /opt/scons










# Install Mongo
# --------------------------
mkdir /usr/mongo && curl https://fastdl.mongodb.org/src/mongodb-src-r3.2.4.tar.gz | tar -xvz -C /usr/mongo
cd /usr/mongo/mongodb-src-r3.2.4 && scons -j 8 mongod mongo mongos && scons --prefix=/usr/local install
ln -s /usr/mongo/mongodb-src-r3.2.4 /opt/mongo
useradd mongod
mkdir /var/lib/mongo && chown mongod:mongod /var/lib/mongo
mkdir /var/log/mongodb && touch /var/log/mongodb/mongod.log && chown mongod:mongod /var/log/mongodb/mongod.log

read -d '' out <<"EOL"
#!/bin/bash

# mongod - Startup script for mongod

# chkconfig: 35 85 15
# description: Mongo is a scalable, document-oriented database.
# processname: mongod
# config: /etc/mongod.conf
# pidfile: /var/run/mongodb/mongod.pid

. /etc/rc.d/init.d/functions

# things from mongod.conf get there by mongod reading it


# NOTE: if you change any OPTIONS here, you get what you pay for:
# this script assumes all options are in the config file.
CONFIGFILE="/etc/mongod.conf"
OPTIONS=" -f \$CONFIGFILE"
SYSCONFIG="/etc/sysconfig/mongod"

PIDFILEPATH=\`awk -F'[:=]' -v IGNORECASE=1 '/^[[:blank:]]*(processManagement\.)?pidfilepath[[:blank:]]*[:=][[:blank:]]*/{print $2}' "$CONFIGFILE" | tr -d "[:blank:]\\"'"\`

mongod=${MONGOD-/usr/local/bin/mongod}

MONGO_USER=mongod
MONGO_GROUP=mongod

if [ -f "$SYSCONFIG" ]; then
    . "$SYSCONFIG"
fi

PIDDIR=\`dirname $PIDFILEPATH\`

# Handle NUMA access to CPUs (SERVER-3574)
# This verifies the existence of numactl as well as testing that the command works
NUMACTL_ARGS="--interleave=all"
if which numactl >/dev/null 2>/dev/null && numactl $NUMACTL_ARGS ls / >/dev/null 2>/dev/null
then
    NUMACTL="numactl $NUMACTL_ARGS"
else
    NUMACTL=""
fi

start()
{
  # Make sure the default pidfile directory exists
  if [ ! -d $PIDDIR ]; then
    install -d -m 0755 -o $MONGO_USER -g $MONGO_GROUP $PIDDIR
  fi

  # Recommended ulimit values for mongod or mongos
  # See http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings
  #
  ulimit -f unlimited
  ulimit -t unlimited
  ulimit -v unlimited
  ulimit -n 64000
  ulimit -m unlimited
  ulimit -u 64000

  echo -n $"Starting mongod: "
  daemon --user "$MONGO_USER" --check $mongod "$NUMACTL $mongod $OPTIONS >/dev/null 2>&1"
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/mongod
}

stop()
{
  echo -n $"Stopping mongod: "
  mongo_killproc "$PIDFILEPATH" $mongod
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/mongod
}

restart () {
        stop
        start
}

# Send TERM signal to process and wait up to 300 seconds for process to go away.
# If process is still alive after 300 seconds, send KILL signal.
# Built-in killproc() (found in /etc/init.d/functions) is on certain versions of Linux
# where it sleeps for the full $delay seconds if process does not respond fast enough to
# the initial TERM signal.
mongo_killproc()
{
  local pid_file=$1
  local procname=$2
  local -i delay=300
  local -i duration=10
  local pid=\`pidofproc -p "${pid_file}" ${procname}\`

  kill -TERM $pid >/dev/null 2>&1
  usleep 100000
  local -i x=0
  while [ $x -le $delay ] && checkpid $pid; do
    sleep $duration
    x=$(( $x + $duration))
  done

  kill -KILL $pid >/dev/null 2>&1
  usleep 100000

  checkpid $pid # returns 0 only if the process exists
  local RC=$?
  [ "$RC" -eq 0 ] && failure "${procname} shutdown" || rm -f "${pid_file}"; success "${procname} shutdown"
  RC=$((! $RC)) # invert return code so we return 0 when process is dead.
  return $RC
}

RETVAL=0

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart|reload|force-reload)
    restart
    ;;
  condrestart)
    [ -f /var/lock/subsys/mongod ] && restart || :
    ;;
  status)
    status $mongod
    RETVAL=$?
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
    RETVAL=1
esac

exit $RETVAL
EOL
echo "${out}" > /etc/init.d/mongod

read -d '' out <<"EOL"
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Where and how to store data.
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1  # Listen to local interface only, comment to listen on all interfaces.


#security:

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
EOL
echo "${out}" > /etc/mongod.conf

read -d '' out <<"EOL"
# TODO: add relevant configuration stuff here.
EOL
echo "${out}" > /etc/sysconfig/mongod

chmod 644 /etc/mongod.conf
chmod 644 /etc/sysconfig/mongod
chmod +x /etc/init.d/mongod
chkconfig --add mongod
chkconfig mongod off
chkconfig mongod --level 345 on










# MongoDB Optimizations
# (https://docs.mongodb.org/manual/tutorial/transparent-huge-pages/)
# (https://docs.mongodb.org/manual/reference/ulimit/)
sed -i 's/*          soft    nproc     4096/*          soft    nproc     32000/' /etc/security/limits.d/20-nproc.conf

read -d '' out <<"EOL"
#!/bin/sh
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    unset thp_path
    ;;
esac
EOL
echo "${out}" > /etc/init.d/disable-transparent-hugepages

chmod 755 /etc/init.d/disable-transparent-hugepages
chkconfig --add disable-transparent-hugepages
mkdir /etc/tuned/no-thp

read -d '' out <<"EOL"
[main]
include=virtual-guest

[vm]
transparent_hugepages=never
EOL
echo "${out}" > /etc/tuned/no-thp/tuned.conf

chmod 644 /etc/tuned/no-thp/tuned.conf
tuned-adm profile no-thp










# Install QEMU
# sed statements apply patch
# ---------------------------
mkdir /usr/qemu && curl http://iweb.dl.sourceforge.net/project/kvm/qemu-kvm/1.2.0/qemu-kvm-1.2.0.tar.gz | tar -xvz -C /usr/qemu
sed -i 's/LIBS+=-lz $(LIBS_TOOLS)/LIBS+=-lz -lrt $(LIBS_TOOLS)/' /usr/qemu/qemu-kvm-1.2.0/Makefile
sed -i 's/qemu-ga\$(EXESUF): LIBS = \$(LIBS_QGA)/qemu-ga\$(EXESUF): LIBS = \$(LIBS_QGA) -lrt/' /usr/qemu/qemu-kvm-1.2.0/Makefile
sed -i '/STPFILES=/a\\nLIBS+=-lrt' /usr/qemu/qemu-kvm-1.2.0/Makefile.target
cd /usr/qemu/qemu-kvm-1.2.0 && ./configure && make && make install










# sudo Permissions
# ---------------------------
echo -e "cyberdrop\tALL=(ALL)\tNOPASSWD: /usr/local/bin/qemu-system-x86_64" >> /etc/sudoers.d/cyberdrop









# Install Libvirt
# ---------------------------
# mkdir /usr/libvirt && curl http://libvirt.org/sources/libvirt-1.3.2.tar.gz | tar -xvz -C /usr/libvirt
# cd /usr/libvirt/libvirt-1.3.2 && ./configure && make && make install










# Install Virt-Manager
# ---------------------------
# mkdir /usr/virt-manager && curl https://fedorahosted.org/released/virt-manager/virt-manager-1.2.1.tar.gz | tar -xvz -C /usr/virt-manager










# Set Server Timezone
# --------------
timedatectl set-timezone America/New_York
systemctl start ntpd
systemctl enable ntpd










# Enable Swap File
# --------------
echo "Creating 32GB Swap File, this will take a few mins..."
dd if=/dev/zero of=/mnt/swap bs=1024 count=33554432
echo "Finished Creating Swap File"
chmod 600 /mnt/swap
mkswap /mnt/swap
swapon /mnt/swap
sh -c 'echo "/mnt/swap none swap sw 0 0" >> /etc/fstab'










# Clear Bash History
# --------------
cat /dev/null > ~/.bash_history && history -c










# Restart
# --------------
shutdown -h now -r










# Run Tests
# --------------
# wpa_supplicant -B -dd -i wlp2s0 -c <(wpa_passphrase Chad Suncatcher2012) && dhclient wlp2s0 -v
# bash <(curl -s https://raw.githubusercontent.com/cyberdrop/install/master/test.sh)
#!/bin/bash
## 
## Create Raspberry Pi SD card image via debootstrap
## 
## Need packages: parted qemu-user-static binfmt-support debootstrap
## 
## Copyright (c) 2020 Robert Ryszard Paciorek <rrp@opcode.eu.org>
## 
## MIT License
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
set -e

# build config
localconfig="build-rpi-image.conf"
imgfile="rpi.img"
mountdir="/mnt/rpi"

logWrite() { echo "$@"; }
waitBeforeUmount=true

relesae="buster"
mirror="http://archive.raspbian.org/raspbian/"

bootsize=150M
imagesize=1789

# local stuff config
piuser="pi"
hostname="rpi"
configureLOCAL() { :; }

# this settings can be overwrite in ${localconfig} file:
if [ -f ${localconfig} ]; then
	logWrite "load LOCAL config from ${localconfig} file"
	. ${localconfig}
else
	logWrite "can't find LOCAL config file: ${localconfig}"
fi

logWrite "create image file"
dd if=/dev/zero of=${imgfile} bs=1M count=${imagesize}
device=`losetup --partscan --find --show ${imgfile}`

echo "create partitions in image file"
parted ${device} "mklabel msdos"
parted ${device} "mkpart primary fat32 1 ${bootsize}B"
parted ${device} "mkpart primary ext4 ${bootsize}B 100%"

logWrite "create filesystems"
mkfs.vfat ${device}p1
mkfs.ext4 ${device}p2

logWrite "mount filesystems in ${mountdir}"
mkdir -p ${mountdir}
mount ${device}p2 ${mountdir}
mkdir ${mountdir}/boot
mount ${device}p1 ${mountdir}/boot


logWrite "install ${relesae} via qemu-debootstrap"
qemu-debootstrap --no-check-gpg --arch armhf ${relesae} ${mountdir} ${mirror}

logWrite "configure apt and lang on target system"
echo 'LANG="C.UTF-8"' > ${mountdir}/etc/default/locale;
echo 'set -a; . /etc/default/locale; set +a' > ${mountdir}/etc/profile.d/locale.sh
echo 'perl -e exit 2>&1 | grep "Setting locale failed" 2>&1 > /dev/null && export LC_ALL=C.UTF-8' >> ${mountdir}/etc/profile.d/locale.sh
echo 'Apt::Install-Recommends "false";' > ${mountdir}/etc/apt/apt.conf.d/13norecommends

logWrite "do general post install fix on target system"
chroot ${mountdir} apt -y install aptitude vim xxd less wget screen tmux gawk sudo procps psmisc lsof picocom bash-completion \
                                  openssh-server openssh-client sshguard ntpdate nftables curl python3 sendemail
chroot ${mountdir} apt -y purge   vim-tiny mawk nano tasksel tasksel-data paxctld libident debconf-i18n gdbm-l10n


logWrite "install and configure R-PI stuff"
echo "deb ${mirror} buster main contrib non-free rpi" > ${mountdir}/etc/apt/sources.list
echo "deb http://archive.raspberrypi.org/debian/ buster main" >> ${mountdir}/etc/apt/sources.list
wget 'http://archive.raspberrypi.org/debian/raspberrypi.gpg.key' -O - | chroot ${mountdir} apt-key add -q
chroot ${mountdir} apt update
chroot ${mountdir} apt -y install raspberrypi-bootloader raspberrypi-kernel i2c-tools
chroot ${mountdir} apt clean

cat > ${mountdir}/etc/fstab <<EOF
/dev/mmcblk0p1  /boot/  vfat  defaults     0 1
/dev/mmcblk0p2  /       ext4  defaults,ro  0 1
EOF

cat > ${mountdir}/boot/cmdline.txt <<EOF
root=/dev/mmcblk0p2 rootfstype=ext4 fsck.repair=yes rootwait console=tty1 elevator=deadline dwc_otg.lpm_enable=0
EOF

cat > ${mountdir}/boot/config.txt <<EOF
# enable and configure i2c
# dtparam=i2c_arm=on,i2c_arm_baudrate=400000
dtparam=i2c_arm=on
dtoverlay=i2c-bcm2708

# # always start HDMI (even when monitor is not connected)
# hdmi_force_hotplug=1
# 
# # get EDID info from /boot/edid.dat file (useful when monitor is not connected)
# # file can be created via command:
# #   /opt/vc/bin/tvservice -d /boot/edid.dat
# hdmi_edid_file=1
# 
# # disable overscan (black border of unused pixels)
# disable_overscan=1

# for more options see http://elinux.org/RPi_config.txt
# and https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README
EOF


logWrite "move logs and tmp to /run"

cat > ${mountdir}/etc/tmpfiles.d/on_tmpfs.conf <<EOF
d  /run/tmp       1777 root root -
L+ /tmp           -    -    -    -  /run/tmp
L+ /var/tmp       -    -    -    -  /run/tmp

d  /run/log       0755 root root -
L+ /var/log       -    -    -    -  /run/log

d  /run/dhcp      0755 root root -
L+ /var/lib/dhcp  -    -    -    -  /run/dhcp
EOF
rm -fr ${mountdir}/tmp/ ${mountdir}/var/tmp ${mountdir}/var/log/ ${mountdir}/var/lib/dhcp/
mkdir ${mountdir}/run/tmp ${mountdir}/run/log ${mountdir}/run/dhcp
ln -s ${mountdir}/run/tmp ${mountdir}/tmp;
ln -s ${mountdir}/run/tmp ${mountdir}/var/tmp;
ln -s ${mountdir}/run/log ${mountdir}/var/log;
ln -s ${mountdir}/run/dhcp ${mountdir}/var/lib/dhcp;

sed -e 's@^.*Storage=.*@Storage=volatile@' -i ${mountdir}/etc/systemd/journald.conf


logWrite "setup network and enable /etc/rc.local"
cat > ${mountdir}/etc/rc.local <<EOF
#!/bin/bash

for i in \`ip l | awk '/^[0-9]/ {print \$2}' | tr -d :\`; do
	ifconfig \$i up
	ip link set dev \$i
done

EOF
cat > ${mountdir}/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF
chmod +x ${mountdir}/etc/rc.local
chroot ${mountdir} systemctl enable rc-local

cat > ${mountdir}/etc/network/interfaces.d/lo0 <<EOF
auto lo
iface lo inet loopback
EOF

cat > ${mountdir}/etc/network/interfaces.d/lan0 <<EOF
auto lan0
iface lan0 inet6 auto
	up  /etc/network/firewall_ipv6.sh || true
iface lan0 inet  dhcp
	up  /etc/network/firewall_ipv4.sh || true
EOF

cat > ${mountdir}/etc/network/firewall_ipv4.sh <<EOF
#!/sbin/iptables-restore

*filter
:INPUT DROP
:FORWARD ACCEPT
:OUTPUT ACCEPT
:sshguard -
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state ESTABLISHED -j ACCEPT
-A INPUT -m state --state INVALID -j REJECT

## SSH
-A INPUT -p tcp --dport ssh -s 0.0.0.0/0 -j sshguard
-A INPUT -p tcp --dport ssh -s 0.0.0.0/0 -j ACCEPT

## ICMP
-A INPUT -p icmp --icmp-type timestamp-request -j REJECT
-A INPUT -p icmp --icmp-type address-mask-request -j REJECT
-A INPUT -p icmp -j ACCEPT

## RESZTA
-A INPUT -j REJECT

COMMIT
EOF

cat > ${mountdir}/etc/network/firewall_ipv6.sh <<EOF
#!/sbin/ip6tables-restore

*filter
:INPUT DROP
:FORWARD ACCEPT
:OUTPUT ACCEPT
:sshguard -
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state ESTABLISHED -j ACCEPT
-A INPUT -m state --state INVALID -j REJECT

## SSH
-A INPUT -p tcp --dport ssh -s fe80::/64 -j ACCEPT
-A INPUT -p tcp --dport ssh -s ::/0 -j sshguard
-A INPUT -p tcp --dport ssh -s ::/0 -j ACCEPT

## ICMP
-A INPUT -p ipv6-icmp -j ACCEPT

## RESZTA
-A INPUT -j REJECT

COMMIT
EOF

chmod +x ${mountdir}/etc/network/firewall_*.sh

cat > ${mountdir}/etc/systemd/network/10-lan.link <<EOF
[Match]
Driver=smsc95xx
#Property=ID_MODEL=ec00 ID_VENDOR=0424

[Link]
NamePolicy=
Name=lan0
EOF

# create own /etc/systemd/network/99-default.link to disable
# Debian overwrite of systemd rules for USB network devices
# (/lib/udev/rules.d/73-usb-net-by-mac.rules)
cat > ${mountdir}/etc/systemd/network/99-default.link <<EOF
[Link]
NamePolicy=keep kernel path database onboard slot mac
MACAddressPolicy=persistent
EOF

echo '13 * * * * root /usr/bin/sleep 120 && /usr/sbin/ntpdate-debian >/dev/null 2>&1' > ${mountdir}/etc/cron.d/ntpdate


logWrite "create admin user (${piuser}) and set hostname (${hostname})"
chroot ${mountdir} adduser --disabled-password --gecos "" ${piuser}
echo "${piuser}  ALL=(ALL:ALL) NOPASSWD:ALL" > ${mountdir}/etc/sudoers.d/${piuser}
mkdir ${mountdir}/home/${piuser}/.ssh
touch ${mountdir}/home/${piuser}/.ssh/authorized_keys ${mountdir}/home/${piuser}/.bash_history
chown -R ${piuser}:${piuser} ${mountdir}/home/${piuser}/.ssh ${mountdir}/home/${piuser}/.bash_history

echo ${hostname} > ${mountdir}/etc/hostname


logWrite "install LOCAL stuff"
configureLOCAL

if [ ! -s ${mountdir}/home/${piuser}/.ssh/authorized_keys ]; then
	logWrite "${mountdir}/home/${piuser}/.ssh/authorized_keys is empty !!!"
	logWrite "You can't login into r-pi system !!!"
	waitBeforeUmount=true
fi

if $waitBeforeUmount; then
	echo "You can personalize r-pi system via \`chroot ${mountdir}\` now"
	while read -p "Umount r-pi image? (y or yes): " f; do
		[ "$f" == "y" -o "$f" == "yes" ] && break;
	done
fi


logWrite "umount filesystems from image"
umount ${mountdir}/boot
umount ${mountdir}
losetup -d ${device}

logWrite "Image is ready in ${imgfile}"
logWrite " use \`dd bs=10MB status=progress if=${imgfile} oflag=sync of=PATH_TO_SD_CARD\` to copy on SD card"

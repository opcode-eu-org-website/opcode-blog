#!/bin/bash

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

CHROOT_DIR="/opt/games"

CHROOT_ENV=$(tr -d '\n' << EOF
	PATH=~$USER/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
	LANG=pl_PL.UTF-8
	
	DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/games_chroot_dbus.sock"
	STEAM_DEFAULT_OPTIONS="-offline -offlinemode -silent -nochatui -nofriendsui"
	
	PRESSURE_VESSEL_FILESYSTEMS_RW=/games
	PROTONPATH=/games/steam/compatibilitytools.d/UMU-Proton-10.0-4
	UMU_RUNTIME_UPDATE=0
	PROTON_DLL_COPY=__NONE__
	WINEPREFIX=/WINEPREFIX/must/be/set/to/correct/value
EOF
)

NEW_PWD=$(realpath  --relative-base="$CHROOT_DIR" .)

exec sudo /usr/bin/unshare -m /bin/sh -c "
	mount --bind   '$CHROOT_DIR'      '$CHROOT_DIR'
	
	mount -t proc  proc               '$CHROOT_DIR/proc'
	mount -t sysfs sysfs              '$CHROOT_DIR/sys'
	mount -o rbind /dev               '$CHROOT_DIR/dev'
	mount -o rbind /dev/pts           '$CHROOT_DIR/dev/pts'
	mount -o rbind /dev/shm           '$CHROOT_DIR/dev/shm'
	mount -o rbind /run               '$CHROOT_DIR/run'
	mount -o rbind /run/dbus          '$CHROOT_DIR/run/dbus'
	mount -o rbind /run/lock          '$CHROOT_DIR/run/lock'
	mount -o rbind /run/shm           '$CHROOT_DIR/run/shm'
	mkdir -p '$CHROOT_DIR/run/user/$UID'
	mount -o rbind /run/user/$UID     '$CHROOT_DIR/run/user/$UID'
	mount -o rbind /tmp               '$CHROOT_DIR/tmp'
	
	cd '$CHROOT_DIR'
	pivot_root . root
	cd /
	umount -l root
	cd '$NEW_PWD'
	
	if [ \$# -lt 1 ]; then
		set -- /bin/bash
	fi
	
	exec su --pty -s /bin/sh $USER -c  'export $CHROOT_ENV; exec \"\$@\"'  _ \"\$@\"
" _ "$@"

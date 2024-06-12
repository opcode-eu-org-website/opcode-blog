if grep ^/dev/mapper/srv /proc/mounts > /dev/null; then
	echo /srv arledy mounted
	exit
fi

crypt_mount() {
	tmpfile=`mktemp -p /dev/shm`
	ret=1
	echo -e "SETDESC Please enter the passphrase to unlock /srv.\nSETPROMPT Passphrase:\nGETPIN" |
		pinentry-gtk-2 -g | grep '^D ' | cut -c3- > $tmpfile

	if [ -s $tmpfile ]; then
		cat $tmpfile |
			sudo cryptsetup open /dev/lvm-b29-main/srv srv &&
			#sudo cryptdisks_start srv &&
			mount /srv && ret=0
	fi

	rm $tmpfile
	return $ret
}

while ! crypt_mount; do :; done
zenity --info --no-wrap --text="/srv mounted OK"


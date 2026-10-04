install() {
	cd /games/epic-games/
	
	if [ -e "$1" ]; then
		echo "$1 istnieje"
		#return
	fi
	
	mkdir "$1"
	cd "$1"
	
	legendary install --base-path=/games/epic-games/ --game-folder "$PWD/bin/" "$1"
	
	cat <<- EOF > Run.sh
		#!/bin/bash
		
		cd "\$(dirname "\$0")"
		command -V games_chroot >&/dev/null && exec games_chroot "./\$(basename "\$0")"
		
		export PROTONPATH=/games/steam/compatibilitytools.d/UMU-Proton-10.0-4
		export WINEPREFIX=/games/epic-games/$1/pfx/
		
		cd "/games/epic-games/$1"
		# legendary launch --wine umu-run  "$1"  --skip-version-check
	EOF
	legendary launch --wine umu-run  "$1"  --offline --dry-run 2>&1 | sed -n '/Launch parameters/{s#\[cli\] INFO: Launch parameters: ##;p}' >> Run.sh
	chmod +x Run.sh
	
	./Run.sh
	
	sleep 5
	echo ""
	echo "Enter user_data location:"
	read ud
	if [ -e "$ud" ]; then
		ln -s "$ud" user_data
	else
		mkdir "$ud"
		if [ -e "$ud" ]; then
			ln -s "$ud" user_data
		else
			echo "$ud nie istnieje"
		fi
	fi
	
	/games/proton_dedup_pfx.sh pfx
	
	( cd /games/@Games; ln -s ../epic-games/$1 . )
	echo "Links for Playnite:"
	echo "   Run  ->  http://RUN_GAME/@Games/$1/Run.sh"
	echo "   Open Game Directory  ->  http://OPEN_DIR/@Games/$1/"
}

u() {
	ln -s "$1" user_data
}

if [ ${0##*/} = "legendary-install.sh" ]; then
	install $@
fi

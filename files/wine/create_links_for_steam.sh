STEAM=.

for bin_path in $STEAM/steamapps/common/*; do
	[ -d "$bin_path" ] || continue
	
	bin_name=$(basename "$bin_path")
	dir_name=${bin_name^}
	dir_name=${dir_name// /_}
	
	id=$(grep -l 'installdir"[^"]*"'"$bin_name"'"' $STEAM/steamapps/appman*acf)
	id=${id#*appmanifest_}
	id=${id%.acf}
	
	if [ "$id" = "" ]; then
		echo "no ID for \"$bin_name\" ... skip"
		continue
	fi
	
	mkdir -p "$dir_name"
	[ ! -e "$dir_name/bin" ] && ln -sr "$bin_path" "$dir_name/bin"
	[ ! -e "$dir_name/pfx" -a -e $STEAM/steamapps/compatdata/$id ] && ln -sr $STEAM/steamapps/compatdata/$id "$dir_name/pfx"
	[ ! -e "$dir_name/mods" -a -e $STEAM/steamapps/workshop/$id ] && ln -sr $STEAM/steamapps/workshop/$id "$dir_name/mods"
	[ ! -e "$dir_name/user" -a -e $STEAM/userdata/97455279/$id ] && ln -sr $STEAM/userdata/97455279/$id "$dir_name/user"
	[ ! -e "$dir_name/Run.sh" ] && cat > "$dir_name/Run.sh" <<- EOF
		#!/bin/bash
		
		cd "\$(dirname "\$0")"
		command -V games_chroot >&/dev/null && exec games_chroot "./\$(basename "\$0")"
		
		steam \$STEAM_DEFAULT_OPTIONS steam://rungameid/$id
	EOF
	chmod +x "$dir_name/Run.sh"
done

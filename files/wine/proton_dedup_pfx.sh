if [ $# -eq 1 ]; then
	cd "$1"
fi

if ! [ -f config_info ]; then
	echo "Invalid proton prefix in $PWD" >&2
	exit
fi

proton_files=$(dirname "$(sed -ne 3p config_info)")

if ! [ -d "$proton_files/share/default_pfx/" ]; then
	echo "Detected proton path ($proton_files) is not valid" >&2
	exit
fi

echo "Dedup proton prefix \"$PWD\" by symlinking to $proton_files"

find pfx/drive_c -type f -a \( -name '*.dll' -o -name '*.exe' -o -name '*.nls' \)  | while read target_path; do
	target_name=$(basename "$target_path")
	source_candidates=$(find "$proton_files" -name "$target_name")
	if [ "$source_candidates" != "" ]; then
		target_sum=$(md5sum "$target_path" | cut -f1 -d' ')
		echo "$source_candidates" | while read source_path; do
			source_sum=$(md5sum "$source_path" | cut -f1 -d' ')
			if [ "$target_sum" = "$source_sum" ]; then
				rm "$target_path"
				ln -s "$source_path" "$target_path"
				break
			fi
		done
	fi
done

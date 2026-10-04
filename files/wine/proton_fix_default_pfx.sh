cd files/share/default_pfx
find . -type f -a \( -name '*.dll' -o -name '*.exe' -o -name '*.nls' \) | while read path; do
	dir_path=$(dirname "$path")
	file_name=$(basename "$path")
	mkdir -p "../pfx_lib/$dir_path"
	mv "$path" "../pfx_lib/$dir_path"
	rp=$(realpath "../pfx_lib/$dir_path/$file_name")
	ln -s "$rp" "$path"
done;

sudo chown -R root:root '../pfx_lib'
sudo chmod -R a=rX '../pfx_lib'

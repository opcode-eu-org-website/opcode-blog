cd ~/.local/share/umu/

ln -s /opt/steam/steamapps/common/SteamLinuxRuntime_soldier/ steamrt2
ln -s /opt/steam/steamapps/common/SteamLinuxRuntime_sniper/ steamrt3
ln -s /opt/steam/steamapps/common/SteamLinuxRuntime_4/ steamrt4



cd ~/.local/share/Steam/compatibilitytools.d/compatibilitytools.d/UMU-Proton-10.0-4/

patch -p1 << EOF
diff -ur a/proton b/proton
--- a/proton	2026-07-21 15:56:26.351228885 +0000
+++ b/proton	2026-07-21 18:48:55.925383852 +0000
@@ -270,6 +270,11 @@
             dst = os.path.join(dst, os.path.basename(src))
 
         if file_exists(dst, follow_symlinks=False):
+            from pathlib import Path
+            dst_path = Path(dst)
+            if dst_path.is_symlink() and dst_path.resolve() == Path(src).resolve():
+                log(f'Do NOT replace symlink {dst} by it target {src}')
+                return
             os.remove(dst)
         elif track_file and prefix is not None:
             track_file.write(os.path.relpath(dst, prefix) + '\n')
diff -ur a/protonfixes/__init__.py b/protonfixes/__init__.py
--- a/protonfixes/__init__.py	2026-07-21 16:00:40.867686331 +0000
+++ b/protonfixes/__init__.py	2026-07-20 09:22:52.394082487 +0000
@@ -34,7 +34,7 @@
 
 
 # This is needed for protonfixes
-os.environ['PROTON_DLL_COPY'] = '*'
+#os.environ['PROTON_DLL_COPY'] = '*'
 
 
 def check_conditions() -> bool:
EOF

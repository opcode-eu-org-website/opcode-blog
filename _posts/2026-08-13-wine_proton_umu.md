---
layout: post
title: Wine, Proton i UMU
author: Robert Paciorek
tags:
- wine
---

Są to dość luźne zapiski z mojej migracji z lutris + epic uruchamiany via wine-ge na umu-run z własnymi skryptami uruchamiającymi daną grę i indywidualnymi prefixami wine per gra + legendary.

### założenia:

* gry „żyją” we własnym pseudo-chroocie (zobacz [games_chroot.sh](/files/wine/games_chroot.sh))
* do zarządzania grami z wielu bibliotek (lista gier, stan ukończenia, uwagi, etc) używany jest [*Playnite*](https://github.com/JosefNemec/Playnite/),
  dzięki [własnej usłudze dbus](/2026/08/15/custom_dbus.html) otwiera on strony www w przeglądarce na głównym systemie oraz może obsługiwać akcje  uruchomienia gry i otwarcia jej katalogu
* uporządkowana struktura katalogowa dla gier:
	* gry instalowane są w `$CHROOT_DIR/games/$GAME_LIB/$GAME`, gdzie `$GAME_LIB` katalog danej bibliotelki gier / launcher (osobne np. dla epic i steam) a $GAME to katalog gry
		* wewnątrz znajduje się:
			* katalog `bin` – pliki gry
			* katalog `pfx` – prefix wine dedykowany danej grze
			* skrypt `Run.sh` - skrypt uruchamiający daną grę wewnątrz chroot'a ([przykład](/files/wine/sample_run.sh))
			* link symboliczny `user_data` prowadzący do katalogu z danymi użytkownika (zapisy, logi, mody) danej gry (może ich byc kilka jeżeli gra tyrzyma te dane w różnych miejscach)
		* aby utrzymać to dla steam tworzymy strukturę z użyciem symlinków - patrz [create_links_for_steam.sh](/files/wine/create_links_for_steam.sh)
	* wszystkie gry dolinkowywane są w wspólnym katalogu `$CHROOT_DIR/games/@Games` (z niego korzysta m.im. konfiguracja *Playnite*
* gry instalowane są z użyciem:
	* [*legendary*](https://github.com/legendary-gl/legendary) – gry z Epic (dodatkowy [skrypt](/files/wine/legendary-install.sh) automatyzujący/standaryzujący instalację)
	* [*lgogdownloader*](https://github.com/Sude-/lgogdownloader) – gry z GOG
	* linuxowego klienta Steam – gry z tej platformy
* gry uruchamiane są bezpośrednio z użyciem [*umu-run*](https://github.com/Open-Wine-Components/umu-launcher/) a jeżeli nie jest to możliwe (np. ze względu na DRM):
	* gry z Epic nie uruchamiające się offline → poprzez legendary
	* gry ze Steam → poprzez Steam


### minimalizacja zajętości dysku przez prefixy wine

Sam wine dość niekonsekwentnie używa linkowania ws kopiowania plików do prefixu, powodując niepotrzebny wzrost rozmiaru prefixu.
Sytuację jeszcze bardziej pogarsza proton dostarczany z umu, który wymusza kopiowanie zamiast linkowania dla wielu komponentów.

Zachowanie umu może być zmienione poprzez edycję jego skryptu. Skrypt [umu_fix.sh](/files/wine/umu_fix.sh) wykonuje stosowną modyfikację oraz linkuje zainstalowane środowiska uruchamiające ze Steam do katalogu umu aby zapobiec ich duplikacji.

Rozmiar prefixu może zostać zmniejszony poprzez wykrycie duplikacji i zastąpienie jej linkowaniem.
Odpowiadają za to skrypty [proton_dedup_pfx.sh](/files/wine/proton_dedup_pfx.sh) i [proton_fix_default_pfx.sh](/files/wine/proton_fix_default_pfx.sh).
W związku z migracją z legendary w celu sprawnej deduplikacji tworzonych przez neigo prefixów w `games/steam/compatibilitytools.d/UMU-Proton-10.0-4/files/lib-lutris-runtime/` zostały umieszczone runtime'y: d3d_extras, dgvoodoo2, dxvk, dxvk-cache-tool, dxvk-nvapi, vkd3d.

Podobnie można postępować z prefixami tworzonymi przez Steam. Wymaga to modyfikacji używanych przez nie wersji proton w analogiczny sposób jak umu. Sama deduplikacja wymaga to odnalezienia wspólnych plików i ich przeniesienia np. do `games/steam/steamapps/common/$PROTON_VERSION/files/share/extra_lib/` przed użyciem skryptu deduplikującego. Alternatywnie można używać wcześniej przygotowanego *UMU-Proton* w samym Steam (czasami działa nawet lepiej niż oryginalny Proton w zbliżonej wersji).

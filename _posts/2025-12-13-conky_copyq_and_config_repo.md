---
layout: post
title: Conky, CopyQ i repo konfiguracji
author: Robert Paciorek
tags:
- debian
- x11
---

[**Conky**](https://github.com/brndnmtthws/conky) jest konfigurowalnym monitorem systemowym. Pozwala na wypisywanie informacji tekstowych oraz korzystanie z elementów graficznych takich jak wykresy.

W [dedykowanym repozytorium](https://bitbucket.org/OpCode-eu-org/ConkyPanel/) zamieszczam przykładową konfigurację umieszczającą conky w prawym dolnym rogu ekranu (jako rozszerzenie dla lxpanel).

Panel zawiera:

* monitorowanie temperatury
* wykres zajętości pamięci
* wykres odczytu/zapisu na dysku
* wykres obciążenia procesora
* wykres zużycia energii przez GPU
* wykres pobierania/wysyłania danych przez sieć
* zegar

Panel jest interaktywny i wspiera obsługę myszy dla:

* przełączania stref czasowych za pomocą kółka przewijania
* otwieranie okna kalendarza (za pomocą yad) poprzez kliknięcie zegara
* podpowiedzi dla każdego elementu
* <s>zmiany rozmiaru okna poprzez kliknięcie</s> (czasowo wyłączone)

(wymaga to starszej wersji conky ze względu na [bug w 1.22](https://github.com/brndnmtthws/conky/issues/2288))

Aby zapewnić wyższą rozdzielczość niektórych danych (np. ułamkowego obciążenia procesora i niskiej prędkości sieci), skrypty odczytują dane bezpośrednio z katalogów `/proc` i `/sys`.
Powoduje to brak kompatybilności z systemami innymi niż Linux, ale można to zmienić, edytując funkcje zbierania danych zawarte w plikach `*_read.lua`.

Dane dostępne w hwmon są konfigurowane za pomocą skryptu `hwmon_config.sh`, który jest uruchamiany podczas uruchamiania panelu.
Jego konstrukcja umożliwia niezależność od zmian w numeracji katalogów hwmon, lecz ze względu na swoją naturę pozostaje zależny od sprzętu.

[**CopyQ**](https://hluk.github.io/CopyQ/) jest konfigurowalnym managerem schowka i wydaje się dobrym zamiennikiem dla parcellite.
Główną jego wadą jest brak podtrzymania zawartości po zamknięciu aplikacji która ją udostępniała (patrz [bug 1413](https://github.com/hluk/CopyQ/issues/1413)), można to jednak rozwiązać przy pomocy skryptu:

	function overrideFunction(fn) {
		const oldFn = global[fn];
		global[fn] = function() {
			var selection = str(data(mimeClipboardMode)) == "selection"
			if (!hasData()) {
				if (selection) {
					tab('_s');
					copySelection(getItem(0));
				} else {
					tab('_c');
					copy(getItem(0));
				}
			} else {
				if (selection) {tab('_s'); } else {tab('_c');}
				var item = {}
				dataFormats().forEach(t => {item[t] = data(t)});
				if (size() > 0) {remove(0)}
				add(item)
				tab(config('clipboard_tab'));
				oldFn();
			}
		}
	}
	
	overrideFunction('onClipboardChanged');

Innym problemem jest brak ikony systray w pewnych przypadkach - rozwiązaniem jest usunięcie zmiennych środowiskowych `DBUS_SESSION_BUS_ADDRESS` `XDG_RUNTIME_DIR` i `QT_QPA_PLATFORMTHEME` ze środowiska uruchamiającego copyq.


**Repo konfiguracji**

Konfiguracja środowiska pracy prezentowana tutaj w różnych wpisach została zebrana we własnym repo - [https://bitbucket.org/OpCode-eu-org/DesktopConfig/](https://bitbucket.org/OpCode-eu-org/DesktopConfig/)

Aby uniknąć traktowania całego $HOME z wszystkimi podkatalogami jako repozytorium git w Dolphin (oraz innych narzędziach wykrywających `.git`) można `.git` tego repozytorium przenieść na `.config_git` i używać do jego obsługi `cgit` zdefiniowanego następująco:

	cgit() {
		work_tree=$( find_work_tree() { if [ -d .config_git ]; then echo $PWD; elif [ "$PWD" != "/" ]; then cd ..; find_work_tree; fi; }; find_work_tree )
		git --git-dir=$work_tree/.config_git --work-tree=$work_tree "$@"
	}

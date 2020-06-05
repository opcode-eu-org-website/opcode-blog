---
layout: post
title: Tworzenie kopii systemu z użyciem tar
author: Robert Paciorek
tags:
- debian
---

Do tworzenia kopii zapasowej lub przenoszenia systemu na inną maszynę (klonowania) wykorzystywane są często narzędzia takie jak `cp -a`, `rsync -raAHX`, `tar`, `dd`.
Trzy pierwsze służą do kopiowania systemów plików (zawartych w nich plików wraz z ich atrybutami, właściwościami, itd).
Natomiast `dd` wykorzystywany jest do tworzenia obrazów, kopii urządzeń blokowych, takich jak wolumeny LVM, partycje, dyski
(obraz taki może zawierać wiele partycji, a nawet wolumentów LVM, więcej o używaniu takich obrazów w artykule [Własny Debian LiveUSB](http://www.opcode.eu.org/LiveUSB.xhtml)).

Tar działający z prawami root'a nie wymaga podawania opcji związanych z zachowaniem standardowych atrybutów plików.
Jednak od momentu, gdy dystrybucje zaczęły używać właściwości jądra zamiast zwykłego SUID dla niektórych programów (np. `ping` – zobacz `getcap /bin/ping`),
konieczne jest dodawanie w wywołaniu tar (zarówno tworzącym jak i rozpakowującym archiwum) opcji `--xattrs --xattrs-include='*.*'`.

Polecenie tworzące archiwum z rootfs naszego systemu może wyglądać następująco:

	tar -czf - --xattrs --xattrs-include='*.*' --one-file-system --exclude="./tmp/*" /

Natomiast polecenie rozpakowujące takie archiwum do katalogu `$TARGET` następująco:

	tar -xzf - --xattrs --xattrs-include='*.*' --numeric-owner -C $TARGET

Opcja `--one-file-system` wymusza ignorowanie plików z zamontowanych systemów plików (m.in. takich jak `/proc`, `/sys`, `/dev`, `/run`),
  a `--exclude="./tmp/*"` ignorowanie plików z katalogu `/tmp` nawet jeżeli jest on na tym samym systemie plików co rootfs.
Opcja `--numeric-owner` powoduje korzystanie z numerycznych UIDów i GIDów co jest istotne gdy wypakowujemy archiwum na systemie mającym inne wartości UIDów w /etc/passwd niż system wypakowywany.


W obu wypadkach podana została opcja `-f -` która powoduje zapis/czytanie archiwum do/z standardowego wejścia. Pozwala to na łatwa przesłanie takiego archiwum na inną maszynę poprzez ssh – np.:

	tar -czf - --xattrs --xattrs-include='*.*' --one-file-system --exclude="./tmp/*" /  |  ssh user@host 'cat > archiwum.tgz'

lub pobranie go z maszyny zdalnej:

	ssh user@host 'archiwum.tgz'  |  tar -xzf - --xattrs --xattrs-include='*.*' --numeric-owner -C $TARGET

Możliwe jest także bezpośrednie rozpakowywanie na maszynie zdalnej, bezpośrednie kopiowanie pomiędzy lokalnymi systemami plików a także przekierowanie do pliku poprzez (w tych wypadkach oczywiście zamiast przekierowania strumienia można podać od razu ścieżkę do pliku w opcji `-f`):

	tar -czf - --xattrs --xattrs-include='*.*' --one-file-system --exclude="./tmp/*" /  >  archiwum.tgz

lub

	tar -xzf - --xattrs --xattrs-include='*.*' --numeric-owner -C $TARGET  <  archiwum.tgz

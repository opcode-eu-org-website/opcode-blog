---
layout: post
title: Własna prosta paczka deb
author: Robert Paciorek
tags:
- debian
---

Może się zdarzyć że chcemy zainstalować jakieś własne oprogramowanie w sposób systemowy (np. na kilku maszynach) lub wymusić coś związanego z zależnościami.
W takich przypadkach przydatne może być utworzenie własnego pakietu `.deb`. Najprostsze w realizacji jest utworzenie tzw. pakietu binarnego z użyciem `dpkg-deb` i `fakeroot`.

Za przykład posłuży przygotowanie pakietu `fake-python2`, który dostarczy pakiet `python` w oparciu o `python3`, bez instalowania w systemie Pythona w wersji 2.
Bywa to sensowne, gdyż część paczek zależnych od pakietu `python` działa całkowicie poprawnie z Pythonem w wersji 3.
Jednak pozostaje to pewnym oszustwem więc każdy kto to zrobi robi to na własną odpowiedzialność (część pakietów może naprawdę potrzebować python2 i nie działać poprawnie.

<pre>
# pobieramy nazwę użytkownika (z passwd) i adres mailowy (z konfigu git'a)
# można te zmienne ustawić manualnie ...
USER=$(getent passwd `whoami` | awk -F'[,:]' '{print $5}')
MAIL=$(git config --get user.email)

# tworzymy katalog paczki i podkatalog z plikami kontrolnymi dla paczki
mkdir -p fake-python2/DEBIAN

# konfigurujemy paczkę
cat << EOF > fake-python2/DEBIAN/control
Package: fake-python2
Version: 1.0.0
Section: python
Priority: optional
Architecture: all
Maintainer: $USER <$MAIL>
Depends: python3
Conflicts: python, python2, python2.7
Provides: python
Description: Fake python package
 Provide python package without installing python2.
EOF

# budujemy paczkę deb w oparciu o wcześniej przygotowany katalog
# z plikami do zainstalowania oraz konfiguracj
fakeroot dpkg-deb -b fake-python2
</pre>

Gotowe. Otrzymaliśmy plik `fake-python2.deb`, który możemy zainstalować przy pomocy `dpkg -i fake-python2.deb`.
Dostarcza on pakiet `python`, będąc w konflikcie z pakietami `python`, `python2` i `python2.7` a wymagający pakietu `python3`.

Jeżeli chcemy aby nasza paczka zawierała jakieś pliki to dodajemy je do katalogu z którego jest budowana (w powyższym przykładzie `fake-python2`), traktując go jako root. 
Na przykład jeżeli przed `fakeroot dpkg-deb -b fake-python2` wykonalibyśmy `mkdir fake-python2/etc; echo konfig > fake-python2/etc/MojKonfig.txt` paczka zainstalowałaby w systemie plik `/etc/MojKonfig.txt` z zawartością `konfig`.

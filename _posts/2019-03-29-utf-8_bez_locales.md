---
layout: post
title: Wsparcie UTF-8 bez instalowania locali
author: Robert Paciorek
tags:
- debian
- unicode
- git
---

Jeżeli instalujemy system, którego nie mamy potrzeby lokalizować, albo wręcz tego nie chcemy,
możemy aktywować jedynie systemowe wsparcie dla Unicode w postaci obsługi kodowania UTF-8.
Aby tego dokonać należy zadbać aby zmienna środowiskowa `LANG` była ustawiona na `C.UTF-8`.

W Debianie w tym celu wpisujemy `LANG="C.UTF-8"` do pliku `/etc/default/locale`:

	echo 'LANG="C.UTF-8"' > /etc/default/locale;

oraz zapewniamy jej wczytanie i wyeksportowanie przy uruchamianiu powłoki logowania,
poprzez utworzenie stosownego pliku w `/etc/profile.d/`:

	echo 'set -a; . /etc/default/locale; set +a' > /etc/profile.d/locale.sh

Problemem pozostaje sytuacja, gdy użytkownik logujący się do takiego systemu ma ustawione jakieś niedostępne locale.
Może tak się zdarzyć np. przy dostępie przez ssh, które ustawia te zmienną zmienne środowiskowe zgodnie z systemem z którego jest wykonywane połączenie.
Aby się przed tym zabezpieczyć można w wspomnianym pliku /etc/profile.d/locale.sh dodać weryfikację poprawności ustawień i w razie potrzeby nadpisać je zmienną `LC_ALL`:

	info=`perl -e exit 2>&1`
	if echo "$info" | grep 'Setting locale failed' >& /dev/null; then
		if [ -n "$BASH_VERSION" -a -n "$PS1" ]; then
			echo -n "Make \`export LC_ALL=$LANG\` due to missing some locales,"
			echo    " your settings are:"
			echo "$info" | grep -P '^\t' | grep -Pv ' = \(unset\)'
		fi
		export LC_ALL=$LANG
	fi

Jeżeli nasz system nie będzie posiadać innych locali, możemy także zablokować ustawianie tych zmiennych w konfiguracji serwera ssh,
 poprzez wyrzucenie ich z opcji `AcceptEnv`


## Zapiski luźno powiązane z tematem ...

### UTF-8 w ścieżkach w repozytoriach git

Aby git w wyjściu swoich poleceń (takich jak np. `git status`) wyświetlał normalnie znaki nie ASCI (zamiast zapisywać je hexalnie) konieczne jest ustawienie zmiennej konfiguracyjnej `core.quotepath` na `off`.

Można to zrobić na poziomie konfigu użytkownika:

	git config --global core.quotepath off

Lub całego systemu:

	git config --system core.quotepath off

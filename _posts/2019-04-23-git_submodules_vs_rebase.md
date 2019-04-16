---
layout: post
title: Submoduły git'a, a git commit --amend
author: Robert Paciorek
tags:
- git
---

Niekiedy możemy spotkać się z potrzebą wymuszenia zresetowania stanu gitowego submodułu do wersji dostępnej w zdalnym repozytorium.
Może tak sie zdażyć np. gdy na repozytorium, które jest wykorzystywane w innym jako submoduł, wykonaliśmy operację rebase lub commit z opcją `--amend`.
Możemy do tego użyć następującej funkcji bashowej:

	submoduleReset() {
		subModule=$1
		chmod 700 $subModule; # na wypadek gdybyśmy niemieli prawa czytania katalogu submodułu
		rm -fr "`git rev-parse --show-toplevel`/.git/modules/$subModule" "$subModule";
		git submodule update --init;
		( cd $subModule && git checkout master ); # na wypadek zainicjowania w "detached HEAD"
		( cd $subModule && git reset --hard; );
		git add $subModule;
	}

Argumentem funkcji jest ścieżka do submodułu.
Funkcja powinna być wykonana w katalogu roboczym wewnątrz repozytorium.
Reinicjalizacja użyje adresu submodułu z pliku `.git/config` a nie z `.gitmodules`.

Można dodatkowo wymusić odświeżyć wszystkie submoduły (w resetowanym nic to nie powinno zmienić, ale jest metoda na sprawdzenie czy wszystko poszło OK):

	git submodule foreach git pull origin master
	git submodule foreach git checkout -f .

Jeżeli submoduły traktujemy jako read only możemy chieć utrudnić ich modyfikowanie przez proste zabronienie listowania zawartości poprzez:

	chmod 111 `git submodule | awk '{print $$2}'`


## Zapiski luźno powiązane z tematem ...

### zmiana daty commitu

Wspomniany `--amend`, domyślnie nie zmienia daty commitu. Możemy ją jednak zmienić (np. na obecną) przy pomocy:

	( export GIT_COMMITTER_DATE="$(date)"; git commit -a --amend --no-edit --date "$GIT_COMMITTER_DATE" )

### sprawdzenie stanu repozytoriów git w podkatalogach

	for f in *; do [ -e $f/.git ] && (echo -e "\\033[1;33;41m  $f  \\033[0m"; cd $f && git fetch --all >&/dev/null && git branch -av && git status ); done

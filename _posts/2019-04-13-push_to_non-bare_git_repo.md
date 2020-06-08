---
layout: post
title: Git push do repozytorium z kopią roboczą
author: Robert Paciorek
tags:
- git
---

Standardowo git odmawia wykonania push do repozytorium na którym utworzona jest kopia robocza.
Dzieje się tak ze względu na to, iż wykonanie go spowoduje niespójność kopii roboczej i indeksu ze stanem repozytorium (najnowszym commitem).

Git pozwala na włączenie możliwości wykonywania takich operacji push poprzez odpowiednie ustawienie flagi w konfiguracji zdalnego repozytorium (tego do którego wykonujemy push) za pomocą polecenia:

	git config receive.denyCurrentBranch ignore

spowoduje to wpisanie do pliku konfiguracyjnego `.git/config`:

	[receive]
		denyCurrentBranch = ignore

Standardowo git nie utrzymuje jednak aktualności kopii roboczej na takich repozytoriach.
Po operacji push należy manualnie wykonać `git reset --hard` po stronie zdalnej aby zaktualizować stan kopii roboczej do stanu repozytorium.
Polecenie to spowoduje utratę wszystkich zmian wprowadzonych w kopii roboczej w śledzonych przez repozytorium plikach.

Możemy zapewnić automatyczne utrzymywanie aktualności kopii roboczej poprzez wykorzystanie `post-receive` hook'a.
W tym celu należy utworzyć plik `.git/hooks/post-receive` na przykład z następującą zawartością ([plik do pobrania](/files/post-receive.sh)):

<pre>{{ site.includeRaw(site.source + "/files/post-receive.sh") }}</pre>

i nadać mu praw wykonywalności.

Należy zwrócić uwagę na konieczność zmiany ścieżki.
W testowanej wersji git'a (2.11.0) bieżący katalog w ramach wykonywania tego hook'a jest ustawiony na podkatalog `.git` a nie na katalog roboczy repozytorium.
Dzieje się tak pomimo, iż flaga `bare` w pliku `.git/config` jest ustawiona na `false`, a dokumentacja stwierdza, że dla repozytoriów *non-bare* ma to być *working tree*.

Powyżej zaprezentowany skrypt wykonuje także kilka dodatkowych testów związanych ze zmianą katalogu oraz dodatkowo uruchamia:

	git clean -df

usuwający z kopii roboczej pliki nieobecne w aktualnej wersji repozytorium (a nie będące plikami pominiętymi poprzez ujęcie ich w .gitignore).

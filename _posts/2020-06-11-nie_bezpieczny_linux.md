---
layout: post
title: (Nie)bezpieczny Linux
author: Robert Paciorek
tags:
- debian
---

Linux uważany jest powszechnie za raczej bezpieczny system. Oczywiście co pewien czas zdarzają się błędy pozwalające na eskalację uprawnień czy nie autoryzowany dostęp, więc nie należy zapominać o regularnym instalowaniu poprawek bezpieczeństwa. W ramach tego wpisu nie będę obalać twierdzeń że Linux jest bezpieczny ani omawiać ostatnich czy tez najbardziej znanych dziur, za to przedstawie kilka aspektów które błędami nie są, ale źle rozumiane mogą prowadzić do dziur bezpieczeństwa.

## system chroniony hasłem

Może się wydawać że skoro do naszego komuputera musimy się zalogować przy pomocy hasła to jest on zabezpieczony przed dostępem osób trzecich.
Jednak należy mieć świadamość że **fizyczny dostęp do maszyny (z nieszyfrowanym dyskiem), oznacza posiadanie root'a na tej maszynie**.

Aby po uruchomieniu systemu dostać powłokę działającą na prawach root'a wystarczy do opcji rozruchowych jądra dodać parametr `init` wskazujący na porządaną powłokę, np.:

	init=/bin/bash

W tak uruchomionym systemie zamontowany jest jedynie główny system plików (rootfs) i na ogół tylko do odczytu, nie ma uruchomionej sieci, itd.
Jednak to wszystko możemy bezproblemowo zrobić samodzielnie – przemontować rootfs w tryb `rw`, czy też zamontować dowolne inne systemy plików pomocy polecenia `mount`, ręcznie skonfigurować/uruchomić sieć, itd.

Rozwiązania typu hasło na biosie czy bootloaderze jedynie tylko trochę utrudniają taki dostęp.
Do zdjęcia hasła BIOS na ogół wystarczy śrubokręt i wyjęcie bateryjki lub przełączenie odpowiedniej zworki na płycie głównej.
W przypadku hasła na bootloaderze wystarczy bootowalny pendrive lub inny nośnik.


## prawo wykonywalności pliku

Wydawać by się mogło że skoro system plików obsługuje coś takiego jak prawo wykonywalności to pliku bez takiego prawa nie da się uruchomić.
W rzeczywistości do uruchomienia pliku wystarczy prawo czytania tego pliku.

W przypadku skryptów uruchomienia można dokonać podająć plik jako argument wywołania odpowiedniego interpretera – np. `bash /sciezka/do_pliku_sh`.
W przypadku plików binarnych rolę takiego interpretera pełnić może biblioteka *ld-linux* - np. `/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2  /sciezka/do/binarki_amd64`.

Warto znaczyć że sam fakt prawa czytania pliku daje nam prawo jego skopiowania, a zatam stania się jego właścicielem i nadania mu prawa wykonywalności – pozwala to także na uruchomienie programów z systemów plików montowanych jako *noexec* (pod warunkiem że mamy prawo zapisu na jakimś systemie bez tego ustawienia).


## chroot nie służy celom bezpieczeństwa

Mechanizm *chroot* pozwala na zmianę (dla uruchamianego procesu i jego potomków) położenia korzenia systemu plików (czyli `/`) na wskazany katalog.
Jest to użyteczne np. gdy potrzebujemy dla jakiegoś programu zestawu bibliotek niekompatybilnych z znajdującym się w naszym systemie lub chcemy przetestować rozwijaną aplikację w „czystym” środowisku.

Mogłoby się wydawać że rozwiązanie takie pozwoli też podnieść bezpieczeństwo poprzez odseparowanie jakiejś aplikacji od reszty systemu.
Jednak *chroot* nie został w tym celu stworzony i nie powinien być w tym celu używany, gdyż możliwe jest wydostanie się z niego.

Najprostszym przykładem ucieczki z chroot'a jest wykonanie w nim:

	mount -t proc proc /proc
	chroot /proc/1/root

W wielu przypadkach montowanie `/proc` nie będzie potrzebne, gdyż jest on już zamontowany wewnątrz chroo'a.
Co prawda metoda ta wymaga posiadania praw root'a w chroocie, jednak to chyba właśnie przed czymś takim miał zabezpieczyć nas ten chroot
(przed poruszaniem się zwykłego użytkownika po systemie plików można się zabezpieczyć także uprawnieniami rx).

Root w chroocie ma również pełny dostęp do wszystkich urządzeń widzianych przez jądro – może np. czytać i pisać po urządzeniach blokowych.


## fork bomba

Domyślnie skonfigurowane systemy Linux są w większości podatne na ich całkowite zablokowanie (zawieszenie) z użyciem [fork-bomby](https://pl.wikipedia.org/wiki/Fork-bomba).
Polega ona na wykonywaniu `fork` (utworzeniu potomka) w nieskończonej pętli, dzięki czemu każdy potomek także wykonuje koleje rozgałęzienia procesu w ramach nieskończonej pętli, co prowadzi do zapełnienia pamięci / tablicy procesów i niemożliwości utworzenia żadnego nowego procesu (a to jest potrzebne aby np. móc zalogować się na system i ubić fork-bombę).

Kod fork-bomby w C:

	#include <unistd.h>
	int main() {
		while(1) { fork(); }
	}

Kod fork-bomby w bashu (celowo zastosowany „orginalny” zapis – `:` jest tu po prostu nazwą funkcji):

	:(){ :|:& };:

Aby uniemożliwić zawieszenie systemu na skutek uruchomienia fork-bomby można ograniczyć ilość procesów które mogą należec do pojedynczego uzytkownika.

W tym celu należy w pliku `/etc/security/limits.conf` dodać linijkę typu `* hard nproc 500` (gdzie 500 to limit ilości procesów dla pojedynczego użytkownika) i w konfiguracji PAM'a (np. `/etc/pam.d/common-session`) dodać: `session required pam_limits.so` powodującą uwzględnianie konfiguracji z `limits.conf`.

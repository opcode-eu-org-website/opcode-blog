---
layout: post
title: Zapiski na temat konfiguracji exim i dovecot
author: Robert Paciorek
tags:
- debian
- poczta
---

## Exim – Konfiguracja w jednym pliku

Debian standardowo używa konfiguracji exim4 rozłożonej na wiele plików znajdujących się w `/etc/exim4/conf.d/`.
Jeżeli układ taki lub korzystanie z domyślnych plików konfiguracyjnych nam nie odpowiada wystarczy utworzyć plik `/etc/exim4/exim4.conf` zawierający pełną konfigurację exim'a.
Spowoduje to ignorowanie konfiguracji w `/etc/exim4/conf.d/`.

## Exim – Pełnoprawny serwer pocztowy

[Przykład pliku konfiguracyjnego](/files/email-configs/exim4.conf) `/etc/exim4/exim4.conf` dla serwera pocztowego o pełnej funkcjonalności (wysyłanie poczty do świata, odbiór poczty ze świata, możliwość działa jako reley dla innych hostów, etc).

Konfiguracja przedstawiona w tym pliku:

* korzysta z aliasów wyłącznie z pliku `/etc/mail/virtusertable` (plik `/etc/aliases` jest ignorowany)
* korzysta z wirtualnych użytkowników procmaila (w oparciu o pliki w `/etc/mail/procmail_users/`)
* pozwala na używanie *greylistd* do greylisowania poczty
* pozwala na stosowanie *spamassassin* i *clamav* jako filtrowania antyspamowego i antywirusowego na etapie kopertowym
* realizuje dostarczanie poczty (po uprzednim zapisaniu kopii zapasowej w `/home/mail/kopie`) poprzez:
	* *procmail* (gdy użytkownik ma plik `~/.procmailrc`)
	* *dovecot* (z możliwością używania sieve, gdy użytkownik ma `.dovecot.sieve`)
	* bezpośrednie dostarczanie do maildir'a `~/MAIL/INBOX`
* pozwala na stosowanie plików `~/.forward` oraz `~/exim_vacation.msg`

Oprócz głównego pliku konfiguracyjnego wykorzystywane są pomocnicze pliki konfiguracyjne:

* [`/etc/exim4/procmail.sh`](/files/email-configs/procmail.sh) i [`/etc/exim4/procmail.rc`](/files/email-configs/procmail.rc) dla centralnej konfiguracji dostarczania z użyciem *procmail*
* `/etc/mail/procmail_users` – katalog z plikami typu *procmailrc*, gdy exim otrzyma wiadomość do użytkownika `XYZ` i istnieje plik `/etc/mail/procmail_users/XYZ` zostanie uruchomiony procmail dla tej wiadomości z tym plikiem konfiguracyjnym; nazwy plików nie powinny pokrywać się z rzeczywistymi użytkownikami.
* `/etc/mail/virtusertable` – tablica aliasów uwzględniających domeny, plik złożony z linii postaci: `wyrażenie regularne : użytkownik lub adres`
	* `^abc.*@.*        : user1` – skieruje pocztę adresowana na dowolny adres zaczynający się od `abc` w dowolnej domenie obsługiwanej przez ten serwer do użytkownika `user1`
	* `xyz@example.org  : user2` – skieruje pocztę adresowana na `xyz@example.org` (`example.org` musi być domeną obsługiwanej przez ten serwer) do użytkownika `user2`
	* `^root@.*         : user@example.net`  – skieruje pocztę adresowana do użytkownika root  w dowolnej domenie obsługiwanej przez ten serwer na adres `user@example.net` (może to być adres obsługiwany przez ten serwer poczty lub zewnętrzny adres na jakimś innym serwerze)
* `/etc/mail/from-addresses-map` – tablica mapowań adresów nadawcy, plik złożony z linii postaci: `stary@adres.pocztowy: nowy@adres.pocztowy` (użyteczne jeżeli robimy za relay dla hostów używających dziwnych, niewłaściwych adresów nadawcy; typowo pusta)

* `/etc/mail/local_domains` – lista domen (jedna na linię) obsługiwanych przez ten serwer, wpisy typu localhost sa bezpośrednio w exim4.conf
* `/etc/mail/relay_to_domains` – podobnie jak `local_domains` ale dla tych domen odbierzemy pocztę i będziemy chcieli ją przekazać dalej (do innego naszego serwera pocztowego), a nie dostarczyć do użytkownika / skrzynki na tym serwerze
* `/etc/mail/relay_from_hosts` – lista hostów (ip lub nazwy domenowe, jeden wpis na linię) uprawnionych do wysyłania poczty przez ten serwer bez dodatkowej autoryzacji (typowo pusta)
* `/etc/mail/users_no_filter` – lista użytkowników (nie adresów - bez małpy i nazwy domenowej, jedn na linię) dla których nie filtrujemy poczty antywirusowo i antyspamowo (typowo pusta)
* `/etc/mail/users_no_graylist` – (opcjonalna) lista użytkowników wyłączonych z grey listowania
* `/etc/greylistd/whitelist-hosts` – (opcjonalna) lista hostów wyłączonych z grey listowania

## Dovecot

Dovecot jest serwerem IMAP i POP3. Może zapewniać on także obsługę filtrów sieve (w tym ich zdalnego konfigurowania).
Dostosowanie jego konfiguracji do naszych potrzeb można wykonać w pliku `/etc/dovecot/local.conf` – [przykład](/files/email-configs/dovecot-local.conf).

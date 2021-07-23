---
layout: post
title: Limitowanie SSH
author: Robert Paciorek
tags:
- debian
- network
---

Niekiedy zachodzi potrzeba nałożenia pewnych ograniczeń na to co mogą robić użytkownicy którym dajemy dostęp poprzez ssh i pochodne.

## Wybrane komendy

Jednym z takich ograniczeń może być dostęp tylko przez klucze do jakiejś wskazanej komendy – wymaga to utworzenia użytkownika baz hasła (w `/etc/shadow` dajemy coś co na pewno nie jest hash-em hasła) oraz utworzeniu wpisu w jego `~/.ssh/authorized_keys` postaci:

	command="svnserve -t",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty ssh-rsa __KLUCZ__ __ID_KLUCZA__

podana w przykładzie `svnserve -t` pozwala na dostęp do svn poprzez ssh - `svn ls svn+ssh://serwer/repo/path`.

## Tunele

Powyższy wpis w authorized_keys zabrania także tworzenia tuneli (które domyślnie dostępne jest nawet dla użytkowników z `/bin/false`).
Modyfikując go możemy ograniczać tunele do danych typów, itd.
Tunele możemy także ograniczać wpisami w `/etc/ssh/sshd_config` (patrz przykład z SFTP).

### tylko tunele

Jeżeli danemu użytkownikowi chcemy dać jedynie prawo tworzenia tuneli to możemy po prostu ustawić powłokę `/bin/false`.

## SFTP

Innym ograniczeniem jest dostęp tylko do SFTP bez możliwości zalogowania się do shella, uzyskać to można poprzez ustawienie powłoki użytkownika w `/etc/passwd` na `/usr/lib/openssh/sftp-server`.

### chroot SFTP

Jednak aby użytkownik nie tylko nie miał dostępu do shella, ale także nie mógł wyjść poza swój katalog trzeba zastosować chroot.
Serwer OpenSSH pozwala na łatwe ograniczenie użytkownika tylko do dostępu sftp, z jednoczesnym zamknięciem go w ramach chroot'a.
W tym celu konfiguracja w `/etc/ssh/sshd_config` (na końcu tego pliku) powinna wyglądać następująco:

	Match User ftplim1
		ChrootDirectory /home/sftp/
		AllowTCPForwarding no
		X11Forwarding no
		ForceCommand internal-sftp

Natomiast w `/etc/passwd` katalog domowy takiego użytkownika musi wskazywać na coś wewnątrz `/home/sftp/`, a powłoka może być ustawiona na `/dev/null`:

	ftplim1:x:1002:1002::/home/sftp/ftplim1:/bin/false

Użytkownik taki ma możliwość dostępu do plików jedynie wewnątrz `/home/sftp/` przy pomocy poleceń `sftp` i `sshfs`, ale nie z użyciem polecenia `scp`.
Nie ma też prawa tworzenia tuneli. Jego klucze ssh możemy konfigurować w `/home/sftp/ftplim1/.ssh/authorized_keys`.

Wpisanie `session optional pam_lastlog.so` w `/etc/pam.d/sshd` spowoduje logowanie wszystkich połączeń ssh (np. połączeń sftp) w pliku wtmp (podobnie można uczynić z /etc/pam.d/su).

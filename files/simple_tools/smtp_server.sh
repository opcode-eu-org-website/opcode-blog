#!/bin/bash
## 
## Copyright (c) 2005-2021 Robert Ryszard Paciorek <rrp@opcode.eu.org>
## 
## MIT License
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## 
## 
## prosty serwer SMTP (wykorzystujący do nasłuchu netcat'a)
## umożliwia sterowanie (wykonywanie zdalnych poleceń przy pomocy odpowiednio spreparowanych maili)
## 
## wywołanie: while true; do netcat -l -p 25 -e smtp.sh; done
## 
## wymagania: busybox z netcatem potrafiącym odpalić skrypt w -e
## na openwrt trzeba było jako /bin/sh dać basha bo busybox chciał odpalać tylko komendy wbudowane

DOMAIN="example.org"

IS_DATA=false; SENDER=""; RECEIVER="";
echo "220 $DOMAIN SMTP server by RRP `date -R`"

while read line; do
	echo "Q (data=$IS_DATA): Y $line" >> /tmp/smtp-log.txt
	
	if $IS_DATA; then
		if echo "$line" | tr -d '\r' | awk '$0=="." {exit 0;} {exit 1}'; then
			IS_DATA=false
			echo -en "250 OK\r\n"
			continue
		fi
		
		##########################
		# WŁAŚCIWA TREŚĆ SKRYPTU #
		##########################
		# jest to powtarzane dla każdej linii przesyłanej jako treść maila (łącznie z nagłówkami)
		# możemy sprawdzać nadawcę kopertowego: "$SENDER"
		# możemy sprawdzać adresata kopertowego: "$RECEIVER"
		# możemy sprawdzać aktualną linię z maila: "$line" tak jak to pokazano poniżej:
		
		echo "$line" | tr -d '\r' | awk '
			$1=="action" {
				cmd=sprintf("make_action.sh %s %s", $2, $3);
			}
			$1=="stop" {
				cmd=sprintf("killall .... ");
			}
			END {
				system(cmd);
			}
		' > /dev/null 2> /dev/null &
		# UWAGA: musi to być wyciszone i przechodzić w tło
		
	else
		echo "$line" | tr -d '\r' | awk -v DOMAIN="$DOMAIN" '
		BEGIN {
			IGNORECASE=1
			FS="[ :\t]+"
		}
		$1 ~ "^(HE)|(EH)LO$" {
			printf("250 %s Hello %s, pleased to meet you\r\n", DOMAIN, $2);
			system( sprintf("echo \"R: 250 %s Hello %s, pleased to meet you\" >> /tmp/smtp-log.txt", DOMAIN, $2) );
			exit 0;
		}
		$1 ~ "^MAIL$" && $2 ~ "^FROM$" && $3 != "" {
			printf("250 OK\r\n");
			system( sprintf("echo \"R: 250 OK\" >> /tmp/smtp-log.txt") );
			exit 1;
		}
		$1 ~ "^RCPT$" && $2 ~ "^TO$" && $3 != "" {
			printf("250 OK\r\n");
			system( sprintf("echo \"R: 250 OK\" >> /tmp/smtp-log.txt") );
			exit 2;
		}
		$1 ~ "^DATA$" {
			printf("354 Enter message, ending with \".\" on a line by itself\r\n");
			system( sprintf("echo \"R: 354 Enter message, ending with \".\" on a line by itself\" >> /tmp/smtp-log.txt") );
			exit 3;
		}
		$1 ~ "^QUIT$" {
			printf("221 %s closing connection\r\n", DOMAIN);
			system( sprintf("echo \"R: 221 %s closing connection\" >> /tmp/smtp-log.txt", DOMAIN) );
			exit 4;
		}
		{
			printf("500 unrecognized command\r\n");
			system( sprintf("echo \"R: 500 unrecognized command (%s)\" >> /tmp/smtp-log.txt", $1) );
			exit 0;
		}
		'
		case $? in
			1) SENDER=`echo $line | tr -d '\r' | awk 'BEGIN {FS="[ :\t<>]+"} {print $3}'` ;;
			2) RECEIVER=`echo $line | tr -d '\r' | awk 'BEGIN {FS="[ :\t<>]+"} {print $3}'` ;;
			3) IS_DATA=true ;;
			4) exit ;;
		esac
	fi
done;

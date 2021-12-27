#!/bin/bash

# Skrypt wykorzystujący narzędzia z "BACnet Stack" (http://bacnet.sourceforge.net/)
# do odczytu wartości z urządzenia i wysłania ich do serwera zabbix
# z użyciem `zabbix_sender`. Skrypt przeznaczony do uruchamiania przez cron.
#
# Copyright (c) 2010-2021 Robert Ryszard Paciorek <rrp@opcode.eu.org>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

DEVNUM=22
PATH=/srv/BMS/bacnet-bin:/usr/local/bin:/usr/bin:/bin
cd /srv/BMS/bacnet-cache

export BACNET_IP_PORT=0

readBACNET() {
	type=$1
	case $type in
	"ai")  type=0;;
	"ao")  type=1;;
	"av")  type=2;;
	"bi")  type=3;;
	"bo")  type=4;;
	"bv")  type=5;;
	esac

	val=`bacrp $DEVNUM $type $2 85 | tr -d '\n\r'`
	if [ "$val" == "inactive" ]; then
			val=0
	elif [ "$val" == "active" ]; then
			val=1
	fi

	echo AUS2 $3 $val
}
readALL() {
	# odczyt wejścia cyfrowego 19
	readBACNET bi 19  klimatyzator_alarm
	# odczyt wejść analogowych 5, 3 i 2
	readBACNET ai 5  klimatyzator_unit_temp
	readBACNET ai 3  klimatyzator_unit_mode
	readBACNET ai 2  klimatyzator_unit_fan_speed
}
readALL | zabbix_sender -z 127.0.0.1 -i - | grep 'Failed [^0]'

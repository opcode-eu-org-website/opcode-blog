#!/bin/bash
## 
## Check and fix IPv6 on Orange FunBox 3.0
## 
## Copyright (c) 2020 Robert Ryszard Paciorek <rrp@opcode.eu.org>
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
exec >> /dev/shm/check_ipv6.log 2>&1
LOCK_FILE='/dev/shm/check_ipv6.lock'

#
# settings
#

ROUTER=192.168.6.1                # router IPv4
PASSWORD=''                       # router password
LOGIN=''                          # PPPoE login (...@neostrada.pl)
IP_CHECK_1="2001:4860:4860::8888" # external IPv6 to check
IP_CHECK_2="2620:0:ccc::2"        # other external IPv6 to check
NAME_CHECK_1="ip1"                # name for $IP_CHECK_2 (only for log)
NAME_CHECK_2="ip2"                # name for $IP_CHECK_2 (only for log)

[ ! -e /etc/network/check_ipv6.cfg ] && exit
. /etc/network/check_ipv6.cfg

#
# router configure function
#

fix_ipv6() {
	# logowanie
	cookie=`mktemp /dev/shm/curl.XXXXXXXXXX`
	res=`curl "http://$ROUTER/authenticate?username=admin&password=$PASSWORD" --cookie-jar "$cookie" --data '' 2>/dev/null`
	context=`python3 -c 'import json; d = json.loads("""'"$res"'"""); print(d["data"]["contextID"])'`

	# aktywacja IPv6
	curl -s "http://$ROUTER/sysbus/NMC/IPv6:set"   -H "X-Context: $context" --cookie "$cookie" --data '{"parameters":{"IPv4UserRequested":false}}'
	curl -s "http://$ROUTER/sysbus/NMC:setWanMode" -H "X-Context: $context" --cookie "$cookie" --data '{"parameters":{"WanMode":"GPON_PPP","Username":"bez_ochrony-'"$LOGIN"'/ipv6"}}'
	
	# sprzatanie
	rm "$cookie"
}

#
# check and run ...
#

# check lock
lock=`cat $LOCK_FILE 2>/dev/null`
let lock--
if [ $lock -ge 0 ]; then
	echo $lock > $LOCK_FILE
	exit
fi

# check connections and try fix it
ping6 -c 1 $IP_CHECK_1 >& /dev/null && exit
date +"%F %H:%M"
echo "  - $NAME_CHECK_1 is unavailable"
echo 1 > $LOCK_FILE # temporary lock for next ping

ping6 -c 1 $IP_CHECK_2 >& /dev/null && exit
echo "  - $NAME_CHECK_2 is unavailable"
echo 3 > $LOCK_FILE # long temporary lock for restart networking
systemctl restart networking

sleep 30 # wait for recheck after restart networking

ping6 -c 1 $IP_CHECK_1 >& /dev/null && exit
ping6 -c 1 $IP_CHECK_2 >& /dev/null && exit
echo "  - hosts are still unavailable after restart networking"
echo 10 > $LOCK_FILE # final lock for fix ipv6 on funbox
fix_ipv6
echo ""

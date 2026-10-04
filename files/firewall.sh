#!/usr/sbin/nft -f
flush ruleset
table bridge filter {
 chain prerouting {
  type filter hook prerouting priority dstnat; policy accept;

  # do not redirect packets from world to bridge
  iif eno1 accept

  # redirect some packets from internal bridge ports to proxy
  #  routed based on mark to tun1 (via ip r config in /etc/network/interfaces.d/br0)
  #  for usage with: mitmweb --mode tun:tun1  --set block_global=false
  tcp dport {80, 443} jump to_proxy
 }
 chain to_proxy {
  meta mark set 1
  meta pkttype set host
  meta broute set 1
 }
 chain forward {
  type filter hook forward priority 0; policy drop;

  # arp icmp
  ether type arp accept
  meta l4proto {icmp, ipv6-icmp, igmp} accept

  # dhcp and dns
  udp sport {53, 67, 68} accept
  udp dport {53, 67, 68} accept

  # bridge internal port -> world: all accepted
  oif eno1 accept

  # world-> bridge internal port: only established
  ct state {established, related} accept
  iif eno1 drop
 }
}

table inet filter {
 chain FORWARD {
  type filter hook forward priority 0; policy drop;

  # allow froward toi/from tun1
  oif tun1 accept
  iif tun1 accept
 }
 chain INPUT {
  type filter hook input priority 0; policy drop;

  # lo and established / invalid connections
  iifname "lo" accept
  ct state {established, related} accept
  ct state invalid reject
  
  # icmp, igmp
  meta l4proto icmp icmp type timestamp-request reject
  meta l4proto {icmp, ipv6-icmp, igmp} accept
  
  # ssh
  tcp dport ssh jump sshguard

  # reject all other packets with ICMP error
  reject
 }
 
 chain sshguard {
  # adresy wyłączne ze sprawdzania przez sshguard
  ip  saddr 192.168.6.0/24 accept
  ip6 saddr fe80::/64 accept
  # blokowanie dodanych do odpowiednich set'ów przez sshguard
  ip  saddr @sshguard_blocked_ipv4 drop
  ip6 saddr @sshguard_blocked_ipv6 drop
  # akceptacja niezablokowanych przez sshguard
  accept
 }
 
 set sshguard_blocked_ipv6 {
  type ipv6_addr; flags interval
 }
 
 set sshguard_blocked_ipv4 {
  type ipv4_addr; flags interval
 }
}

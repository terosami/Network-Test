# Network-Test
Diverse Netzwerk-Teste-Tool für Linux-Systeme
## Beschreibung
Diese Scripte wurden für verschiedene kleinere Projekte erstellt.
Die Scripte werden immer wieder weiterentwickelt.
# speedtest_curl.sh
Dieses Script ist ein einfacher Speedtest mit festen Variabelen.
## Benutzung
``` bash
bash speedtest_curl.sh
#or
./speedtest_curl.sh
```
## Dummydaten erstellen
Die Dummydaten können auf den Server wie folgt erstellt werden:
``` bash
dd if=/dev/zero of=dummy.100m bs=1M count=100
dd if=/dev/urandom of=dummy.100m bs=1M count=100
```
# speedtest.sh
Dieses Script ist eine Weiterentwicklung des Script `speedtest_curl.sh` welche ohne Feste Variabelen auskommt.
# ping_test.sh
Mit diesem Script kann man einen Random Ping-Test mit entsprechenden Ausswertung.
# Roadmap
* Basisfunktionen für `speedtest.sh` erstellen
* 'speedtest_curl.sh' als Debianpaktet erstellen
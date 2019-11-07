#/bin/bash
#Beschreibung
#Speedtest mittels Curl
#by Gregor holzfeind <gholzfeind@heiniger-ag.ch>
#Version: 0.3
#Datum: 2019.11.05

#History
#0.1	2019.11.05	Start des Scripts
#0.2	2019.11.06	Erweiterung um Iperf und Anpassungen
#0.3	2019.11.06	Test der Funktionen und kleinst Anpassungen

#Variablen
g1_datei="ftp://ftpuser:cnet2020@speed.heiniger.lab/dummy/dummy.1g" #1024MB grosse Dummy-Datei
m500_datei="ftp://ftpuser:cnet2020@speed.heiniger.lab/dummy/dummy.500m" #500MB grosse Dummy-Datei
m100_datei="ftp://ftpuser:cnet2020@speed.heiniger.lab/dummy/dummy.100m" #100MB grosse Dummy-Datei
m10_datei="ftp://ftpuser:cnet2020@speed.heiniger.lab/dummy/dummy.10m" #10MB grosse Dummy-Datei
m1_datei="ftp://ftpuser:cnet2020@speed.heiniger.lab/dummy/dummy.1m" #1MB grosse Dummy-Datei
iperf3_server="speed.heiniger.lab" #Iperf3-Server
anzahl_1G="2" #Anzahl Testläufe mit 1024MB Dummy-Datei
anzahl_500M="2" #Anzahl Testläufe mit 500MB Dummy-Datei
anzahl_100M="5" #Anzahl Testläufe mit 100MB Dummy-Datei
anzahl_10M="10" #Anzahl Testläufe mit 10MB Dummy-Datei
anzahl_1M="45" #Anzahl Testläufe mit 1MB Dummy-Datei
anzahl_iperf="2" #Anzahl Iperf-Test
log="speed.log"


#Funktionen

function func_speed_1g_down() {
        curl $g1_datei --output "/dev/null"  --write-out '%{time_starttransfer},%{time_total}' --silent > speed.tmp.$$
        func_time
        size="1073741824" # Umrechnung in Byt in Bit (1024 * 1024 *1024 *8)
        speed_1G_down=$(echo 'scale=2;' "($size / $totaltime)*8/1024/1024"| bc -l)
}

function func_speed_500m_down() {
        curl $m500_datei --output "/dev/null"  --write-out '%{time_starttransfer},%{time_total}' --silent > speed.tmp.$$
        func_time
        size="524288000" # Umrechnung in Byt in Bit (500 * 1024 *1024 *8)
        speed_500m_down=$(echo 'scale=2;' "($size / $totaltime)*8/1024/1024"| bc -l)
}

function func_speed_100M_down() {
        curl $m100_datei --output "/dev/null"  --write-out '%{time_starttransfer},%{time_total}' --silent > speed.tmp.$$
        func_time
        size="104849408" # Umrechnung in Byt in Bit (100 * 1024 *1024 *8)
        speed_100m_down=$(echo 'scale=2;' "($size / $totaltime)*8/1024/1024"| bc -l)
}

function func_speed_10M_down() {
        curl $m10_datei --output "/dev/null"  --write-out '%{time_starttransfer},%{time_total}' --silent > speed.tmp.$$
        func_time
        size="10485760" # Umrechnung in Byt in Bit (10 * 1024 *1024 *8)
        speed_10m_down=$(echo 'scale=2;' "($size / $totaltime)*8/1024/1024"| bc -l)
}

function func_speed_1M_down() {
        curl $m1_datei --output "/dev/null"  --write-out '%{time_starttransfer},%{time_total}' --silent > speed.tmp.$$
        func_time
        size="1048576" #du -b
        speed_1m_down=$(echo 'scale=2;' "($size / $totaltime)*8/1024/1024"| bc -l)
}

function func_time(){
        starttime=$(cut -d"," -f1-2 speed.tmp.$$ | tr , .)
        endtime=$(cut -d"," -f3-4 speed.tmp.$$ | tr , .)
        totaltime=$(echo $endtime - $starttime | bc)
}

function func_clean() {
        rm speed.tmp.$$
}

function func_speed_down() {
        anzahl="0"
        speed_final="0"
        echo "Durchlauf;Speed in MBit/s" > $log
        echo "Test 1GiB" >> $log
        echo "Test mit 1GiB läuft"
        while [ $anzahl -lt $anzahl_1G ]
        do
                func_speed_1g_down
                speed_final=$( echo 'scale=2;' "$speed_1G_down + $speed_final" | bc)
                sleep 2
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_1G_down" >> $log
        done
        speed_1G_down=$( echo 'scale=2;' "$speed_final / $anzahl_1G" | bc -l)
        echo "Durchschnitt;$speed_1G_down" >> $log
        anzahl="0"
        speed_final="0"
        clear
        echo "Test 500MiB" >> $log
        echo "Test mit 500MiB läuft"
        while [ $anzahl -lt $anzahl_500M ]
        do
                func_speed_500m_down
                speed_final=$( echo 'scale=2;' "$speed_500m_down+$speed_final" | bc -l)
                sleep 2
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_500m_down" >> $log
        done
        speed_500m_down=$( echo 'scale=2;' "$speed_final / $anzahl_500M" | bc -l)
        echo "Durchschnitt;$speed_500m_down" >> $log
        anzahl="0"
        speed_final="0"
        clear
        echo "Test 100MiB" >> $log
        echo "Test mit 100 MiB läuft"
        while [ $anzahl -lt $anzahl_100M ]
        do
                func_speed_100M_down
                speed_final=$( echo 'scale=2;' "$speed_100m_down+$speed_final" | bc -l)
                sleep 2
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_100m_down" >> $log
        done
        speed_100m_down=$( echo 'scale=2;' "$speed_final / $anzahl_100M" | bc -l)
        echo "Durchschnitt;$speed_100m_down" >> $log
        anzahl="0"
        speed_final="0"
        clear
        echo "Test 10MiB" >> $log
        echo "Test mit 10 MiB läuft"
        while [ $anzahl -lt $anzahl_10M ]
        do
                func_speed_10M_down
                speed_final=$( echo 'scale=2;' "$speed_10m_down+$speed_final" | bc -l)
                sleep 2
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_10m_down" >> $log
        done
        speed_10m_down=$( echo 'scale=2;' "$speed_final / $anzahl_10M" | bc -l)
        echo "Durchschnitt;$speed_10m_down" >> $log
        anzahl="0"
        speed_final="0"
        clear
        echo "Test mit 1 MiB läuft"
        echo "Test 1MiB" >> $log
        while [ $anzahl -lt $anzahl_1M ]
        do
                func_speed_1M_down
                speed_final=$( echo 'scale=2;' "$speed_1m_down+$speed_final" | bc -l)
                sleep 2
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_1m_down" >> $log
        done
        speed_1m_down=$( echo 'scale=2;' "$speed_final / $anzahl_1M" | bc -l)
        echo "Durchschnitt;$speed_1m_down" >> $log
}

function func_end() {
        clear
        func_iperf
        echo "Downloadspeed bei 1GiB: $speed_1G_down MB/s"
        echo "Downloadspeed bei 500MiB: $speed_500m_down MB/s"
        echo "Downloadspeed bei 100MiB: $speed_100m_down MB/s"
        echo "Downloadspeed bei 10MiB: $speed_10m_down MB/s"
        echo "Downloadspeed bei 1MiB: $speed_1m_down MB/s"
        func_clean
}

function func_iperf() {
        anzahl="0"
        speed_final="0"
        echo "Iperf-Test" >> $log
        echo "Test mit Iperf3 läuft"
        while [ $anzahl -lt $anzahl_iperf ]
        do
                iperf3 -c $iperf3_server > speed.tmp.$$
                speed_iperf=$(grep "receiver" speed.tmp.$$ | awk '{print $7}')
                anzahl=$[$anzahl+1]
                echo "$anzahl;$speed_iperf" >> $log
                speed_final=$(echo 'scale=2;' "$speed_iperf + $speed_final" | bc -l)
        done
        speed_iperf=$(echo 'scale=2;' "$speed_final / $anzahl_iperf" | bc -l)
        echo "Durchschnitt;$speed_iperf" >> $log
}

#Programm
func_speed_down
func_end
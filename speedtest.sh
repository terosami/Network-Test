#/bin/bash
#Beschreibung
#Speedtest mittels Curl und Iperf
#by Gregor holzfeind <gregor@holzfeind.ch>
#Version: 0.1
#Datum: 2019.11.07

#History
#0.1	2019.11.07	Start des Scripts

#Fixe Variablen
version="0.1"
whiptail_backtitle="Speedtest v$version"


#Funktionen

function func_interaktiv() { #Funktion Intaktive
	whiptail \
	--msgbox "Willkommen bei Speedtest\n\nDies ist die Intaktive Führung" \
	--backtitle "$whiptail_backtitle" \
	9 35 #Einleitung
}

function func_speedtest() { #Funktion Speedtest
	curl $file_source \
	--output "/dev/null"  \
	--write-out '%{time_starttransfer},%{time_total},%{size_download}' \
	--silent > speed.tmp.$$ #Download Testdatei
	func_time #Funktion Zeitberechnung aufrufen
	size_download=$(cat -d"," -f5 speed.tmp.$$) #Download-Grösser ermittelen
	speed_download=$(echo 'scale=2;' "($size_download / $totaltime)*8/1024/1024"| bc -l) #Speed berechnen
}

function func_time(){ #Funktion Zeitberechnung
        starttime=$(cut -d"," -f1-2 speed.tmp.$$ | tr , .) #Startzeit um ermittelen und Tasuch von Komma
        endtime=$(cut -d"," -f3-4 speed.tmp.$$ | tr , .) #Endzeit um ermittelen und Tasuch von Komma
        totaltime=$(echo $endtime - $starttime | bc) #Zeitdifferenz berechnen
}



func_config() {
	config="$zusatz1"
	if [ ! -f "$config" ]
	then
		whiptail \
		--msgbox "Datei nicht gefunden" \
		--backtitle "$whiptail_backtitle" \
		9 35
		exit
	fi
}

function func_help() { #Hilfsfunktion
	echo "Usage: speedtest.sh [OPTION]"
	echo "Tool für einen Speedtest"
}
#Programm
OPTS=`getopt -o c:his:r: --long config:,help,interactiv,source:,rounds:  -n 'speedtest' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"


while true; do
  case "$1" in
    -c | --config ) 
		config_file="$2"
		;;
    -h | --help )
		func_help
		;;
    -i | --interactiv )
		func_interaktiv
		;;
    -s | --source ) 
		$file_source="$2"
		;;
	-r | --rounds ) 
		$anzahl="$2"
		;;
    -- ) 
		func_help
		;;
    * ) 
		func_help
		;;
  esac
done
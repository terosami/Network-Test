#/bin/bash
#Beschreibung
#Speedtest mittels Curl und Iperf
#by Gregor holzfeind <gregor@holzfeind.ch>
#Version: 0.2.1
#Datum: 2019.11.07

#History
#0.1.0	2019.11.07	Start des Scripts
#0.2.0	2019.11.14	Einbau Getops
#0.2.1	2019.11.21	Arbeiten an dem Intaktiven Teil

#Fixe Variablen
version="0.2.1"
whiptail_backtitle="Speedtest V.$version"

#Startvarablen
speed_source=""


#Funktionen

function func_interactiv() { #Funktion Intaktive
	whiptail \
	--msgbox "Willkommen bei Speedtest\n\nDies ist die Intaktive Führung" \
	--backtitle "$whiptail_backtitle" \
	9 35 #Einleitung
	func_interactiv_source
}
function func_interactiv_source() {
	touch file_source.tmp.$$
	while $source = true
	do
		input=$(whiptail \
		--inputbox "Quelle für den Test" \
		--backtitle "$whiptail_backtitle" \
		$speed_source \
		9 35 3>&1 1>&2 2>&3)
		exitstatus=$?
		if [ $exitstatus = 0 ]
		then
			func_input_check
		else
			func_canel
		fi
	done
}

function func_input_check() { #Funktion Input Überprüfung
	whiptail \
	--yesno "Stimmt diese Eingabe:\n\n$input" \
	--backtitle "$whiptail_backtitle" \
	12 35
	exitstatus=$?
	if [ $exitstatus = 0 ]
	then
		func_interactiv_more
	fi
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
	exit
}
#Programm
OPTS=`getopt -o c:his:r: --long config:,help,interactiv,source:,rounds:  -n 'speedtest' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"
eval set -- "$OPTS"


while true
do
  case "$1" in
    -c | --config ) 
		config_file="$2"
		;;
    -h | --help )
		func_help
		;;
    -i | --interactiv )
		func_interactiv
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
#/bin/bash
#Beschreibung
# Script für Randome Ping Test
#by Gregor holzfeind <gholzfeind@heiniger-ag.ch>
#Version: 0.2
#Datum: 2018-04-16

#History
#0.1 2018.04.16
#	* Basisfunktionen erstellt
#	* Umstellung auf whiptail
#	* Funktionstest mit Endzeit und Durchgängen
#0.2 2018.04.17
#	* Sleep mit Fortschrittsbalken erweitert
#	* Funktionstest mit Dauer
#	* Ping mit Fortschrittsbalken erweitert


# Funktionen
function func_sleep_cale() {
	start_d=$(date +%s)
	zufall=$(echo $(($RANDOM % $wait + 1)))
	end_s=$(echo "$start_d +$zufall" | bc)
	func_check
}

function func_sleep() {
	sleep=$(echo "scale=5; $zufall / 100" | bc )
	{
		for ((i = 0 ; i <= 100; i+=1)); do
			sleep $sleep
			echo $i
		done
	} | whiptail --backtitle "Ping-Performant-Test" --gauge "Speer für den nächsten Test\nBitte warten..." 8 50 0
	func_ping_gaug & func_ping
}

function func_start() {
	TERM=vt220 whiptail --backtitle "Ping-Performant-Test" --infobox "Willkommen zum Ping-performant-Tests\n\nEs werden nun die benötigten Informationen eingestellt" 8 78
	sleep 2
	type=$(whiptail --backtitle "Ping-Performant-Test"  --radiolist "Bitte Wählen Sie die Ziel-Bedinungen" 20 78 3 "Run" "Anzahl Durchgänge" ON	"Date" "Datum und Uhrzeit" OFF "Time" "Nach gewissen Zeitdauer" OFF 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]
	then
		func_cancel
	fi
	case $type in
		Run) 
			max_run=$(whiptail --inputbox "Bitte Anzahl Durchgänge angeben" 8 78 10 --backtitle "Ping-Performant-Test"  3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
			;;
		Date)
			date_a=$(date +%Y.%m.%d)
			time_a=$(date +%H:%M)
			end_date=$(whiptail --inputbox "Bitte Endatum angeben\nNach dem Muster YYYY.MM.DD" 8 78 $date_a --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
			end_time=$(whiptail --inputbox "Bitte Enzeit angeben\nNach dem Muster HH:MM" 8 78 $time_a --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
			end_date=$(echo $end_date | tr . -)
			end_date=$(date --date="$end_date $end_time" +%s)
			;;
		Time) 
			time_r=$(whiptail --inputbox "Bitte Laufzeit in Minuten angeben" 8 78 10 --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
			exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
			time_s=$(date +%s)
			time_r=$(echo "$time_r * 60 + $time_s" | bc)
			;;
	esac
	ip_add=$(whiptail --inputbox "Bitte IP-Adresse angegebn" 8 78 192.168.1.1 --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
	exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
	log=$(whiptail --inputbox "Bitte Log-Datei angeben" 8 78 ping_test.log --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
	exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
	wait=$(whiptail --inputbox "Bitte max. Wartezeit (in Minuten)" 8 78 60 --backtitle "Ping-Performant-Test" 3>&1 1>&2 2>&3)
	exitstatus=$?
			if [ $exitstatus != 0 ]
			then
				func_cancel
			fi
	wait=$(echo "$wait * 60" | bc)
	echo "Datum;Uhrzeit;Gesendet;Empfangen;Verloren;min. Dauer; max. Dauer;durchschnittliche Dauer" > $log
	func_ping_gaug & func_ping
}

function func_ping() {
	zufall=$(echo $(($RANDOM % 20 + 1)))
	ping -c $zufall $ip_add > temp.$$
	date=$(date +%x)
	time=$(date +%X)
	send=$(cat temp.$$ | tail -n2 | head -n1 | cut -d"," -f1 | cut -d" " -f1)
	rec=$(cat temp.$$ | tail -n2 | head -n1 | cut -d"," -f2 | cut -d" " -f2)
	lost=$(cat temp.$$ | tail -n2 | head -n1 | cut -d"," -f3 | cut -d" " -f2)
	max=$(cat temp.$$ | tail -n1 | cut -d"=" -f2 | cut -d"/" -f3)
	min=$(cat temp.$$ | tail -n1 | cut -d"=" -f2 | cut -d" " -f2 | cut -d"/" -f1)
	avg=$(cat temp.$$ | tail -n1 | cut -d"=" -f2 | cut -d"/" -f2)
	echo "$date;$time;$send;$rec;$lost;$min;$max;$avg" >> $log
	rm temp.$$
}

function func_ping_gaug() {
	{
	for ((i = 0 ; i <= 100; i+=5)); do
		sleep 0.5
		echo $i
	done
	} | whiptail --backtitle "Ping-Performant-Test" --gauge "Ping wird durchgeführt\nBitte warten..." 8 50 0
	func_sleep_cale
}

function func_check() {
	if [ "$type" == "Date" ]
	then
		if [ "$end_s" -ge "$end_date" ]
		then
			func_end
		else
			func_sleep
		fi
	elif [ "$type" == "Run" ]
	then
		if [ "$max_run" -eq "1" ]
		then
			func_end
		else
			max_run=$(echo "$max_run - 1" | bc)
			func_sleep
		fi
	elif [ "$type" == "Time" ]
	then
		if [ "$end_s" -ge "$time_r" ]
		then
			func_end
		else
			func_sleep
		fi
	fi
}

function func_end() {
	TERM=vt220 whiptail --infobox "Die Test sind abgeschlossen\nEs wurde folgende Log-Datei erstellt: $log" --backtitle "Ping-Performant-Test"   8 78
	sleep 5
	clear
	exit
}

function func_cancel() {
	TERM=vt220 whiptail --infobox "Das Programm wurde abgebrochen\nEs werden alle vorhanden Daten gelöscht." --backtitle "Ping-Performant-Test"   8 78
	sleep 5
	clear
	rm -f temp.$$ $log
	exit
}

func_start

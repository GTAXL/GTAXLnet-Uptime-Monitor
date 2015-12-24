#!/bin/bash
# GTAXLnet Uptime Monitor - smtp.sh Version: 1.00
# A checker module to check Mail server's SMTP service such as postfix, exim, etc.
# This script doesn't just probe the TCP port, we connect to the SMTP server and issue
# mail commands to make sure it is functioning properley and can accept e-mail for the specified e-mail address
# DO NOT add this script to a cronjob. This script is to be executed by the main.sh script if this monitor meets
# the expectations. The SMTP checks you want should be added in the checks folder with a file named smtp.txt
# and the format of the file should be:
# Name of the check, can include spaces;Host or IP of mail server;Port of SMTP service, usually 25 or 587;An E-Mail address to check against said e-mail server, must be an address accepted by said system;An e-mail address to notify you of alerts, please make it a different e-mail than the mail server in question
# Example: GTAXLnet Mail [ATL1];mail.gtaxl.net;25;gtaxl@gtaxl.net;7403583183@tmomail.net
# By: Victor Coss (GTAXL) vic@likeacoss.com DEC/23/2015

date=$(date)
doesexist=$(wc -l /home/gtaxl/uptimemon/checks/smtp.txt | awk '{print $1}')

if [[ -a "/home/gtaxl/uptimemon/checks/smtp.txt" && "$doesexist" -gt "0" ]]; then
IFS=';'
cat /home/gtaxl/uptimemon/checks/smtp.txt | while read name host port email notify; do
	checksmtp() { 
    echo "EHLO excession.server.gtaxl.net"
	sleep 2
    echo "MAIL FROM:<uptimecheck@gtaxl.net>"
    echo "RCPT TO:<$email>"
    echo "QUIT"
    }
	result=$(checksmtp | openssl s_client -connect $host:$port -starttls smtp -ign_eof -quiet 2>> debug.txt | grep "250 2.1.5" | awk '{print $2}')
	if [ "$result" = "2.1.5" ]; then
		touch "/home/gtaxl/uptimemon/status/SMTP-$name"
		togglenotify=$(cat /home/gtaxl/uptimemon/status/SMTP-$name)
		if [ "$togglenotify" == "DOWN" ] ; then 
			echo "UP" > /home/gtaxl/uptimemon/status/SMTP-$name
			echo -e "$name is back up at $date\nCheck Type: SMTP\nHost/IP: $host\nPort: $port\nChecked E-Mail: $email" | mail -a "From: GTAXLnet Uptime Monitor <uptimemonitor@gtaxl.net>" -s "GTAXLnet Uptime Monitor" $notify
			if [ ! -f "/home/gtaxl/uptimemon/tallies/SMTP-$name" ]; then 
				echo "0 0 0" > /home/gtaxl/uptimemon/tallies/SMTP-$name 
			fi
			pulluptally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $1}')
			pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $2}')
			uptally=$(echo "$pulluptally+1" | bc)
			totaltally=$(echo "$pulltotaltally+1" | bc)
			percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
			echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/SMTP-$name
				else 
					echo "UP" > /home/gtaxl/uptimemon/status/SMTP-$name
					if [ ! -f "/home/gtaxl/uptimemon/tallies/SMTP-$name" ]; then 
						echo "0 0 0" > /home/gtaxl/uptimemon/tallies/SMTP-$name 
					fi
					pulluptally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $1}')
					pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $2}')
					uptally=$(echo "$pulluptally+1" | bc)
					totaltally=$(echo "$pulltotaltally+1" | bc)
					percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
					echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/SMTP-$name					
				fi
			else
				touch "/home/gtaxl/uptimemon/status/SMTP-$name"
				togglenotify=$(cat /home/gtaxl/uptimemon/status/SMTP-$name)
				if [ "$togglenotify" == "UP" ] ; then 
					echo "DOWN" > /home/gtaxl/uptimemon/status/SMTP-$name
					echo -e "$name is DOWN at $date\nCheck Type: SMTP\nHost/IP: $host\nPort: $port\nChecked E-Mail: $email" | mail -a "From: GTAXLnet Uptime Monitor <uptimemonitor@gtaxl.net>" -s "GTAXLnet Uptime Monitor" $notify
					if [ ! -f "/home/gtaxl/uptimemon/tallies/SMTP-$name" ]; then 
						echo "0 0 0" > /home/gtaxl/uptimemon/tallies/SMTP-$name  
					fi
					pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $2}')
					uptally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $1}')
					totaltally=$(echo "$pulltotaltally+1" | bc)
					percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
					echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/SMTP-$name
						else
							echo "DOWN" > /home/gtaxl/uptimemon/status/SMTP-$name
							if [ ! -f "/home/gtaxl/uptimemon/tallies/SMTP-$name" ]; then 
								echo "0 0 0" > /home/gtaxl/uptimemon/tallies/SMTP-$name 
							fi
							pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $2}')
							uptally=$(cat /home/gtaxl/uptimemon/tallies/SMTP-$name | awk '{print $1}')
							totaltally=$(echo "$pulltotaltally+1" | bc)
							percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
							echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/SMTP-$name
						fi
			fi
done
else
	echo "Checker file not found."
	exit
fi

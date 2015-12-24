#!/bin/bash
# GTAXLnet Uptime Monitor - main.sh Version: 1.00
# This main code checks if this monitor has Internet against CloudFlare and OpenDNS anycast systems
# and if the monitor does have Internet will execute all the individual checker type scripts
# A remote backup monitor will check the Internet on this monitor and will kick in if this monitor goes down
# ADD THIS SCRIPT TO CRONTAB! * * * * * /home/youruser/uptimemon/main.sh
# This script will run the uptime checkers in 1 minute intervals for high accuracy.
# TODO: Compute given uptime for a check in a given month, I can do this by dividing current minute tallies
# by the amount of minutes in a given month to compute a percentage of uptime.
# By: Victor Coss (GTAXL) vic@likeacoss.com DEC/21/2015

date=$(date)
testnet1=$(ping 208.67.222.222 -c 4 -i 0.3 -W 1 | grep "transmitted" | awk '{print $4}')
testnet2=$(ping 198.41.214.162 -c 4 -i 0.3 -W 1 | grep "transmitted" | awk '{print $4}')

runcheckers() { 
	/home/gtaxl/uptimemon/tcp-port.sh >> debug.txt 2>&1
	/home/gtaxl/uptimemon/http.sh >> debug.txt 2>&1
	/home/gtaxl/uptimemon/smtp.sh >> debug.txt 2>&1
	/home/gtaxl/uptimemon/localservices.sh >> debug.txt 2>&1
}

if [ "$testnet1" = "4" ]; then
	runcheckers
        else
            if [ "$testnet2" = "4" ]; then
				runcheckers
			else
				echo "Internet detected DOWN at $date" >> /home/gtaxl/uptimemon/uptime.log
				exit
			fi			
        fi

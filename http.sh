#!/bin/bash
# GTAXLnet Uptime Monitor - http.sh Version: 1.00
# A checker module that will check a website's availability via HTTP or HTTPS.
# This checker doesn't just probe the TCP port, but rather does a complete GET request to assure the webserver/httpd
# is fully functioning. If you put an https:// address it will also make sure the SSL certificate is valid.
# DO NOT add this script to a cronjob. This script is to be executed by the main.sh script if this monitor meets
# the expectations. The HTTP/HTTPS checks you want should be added in the checks folder with a file named http.txt
# and the format of the file should be:
# Name of the check, can include spaces;Full URL address, can be http or https;Port to use, for http 80, https 443, but some httpds are on custom ports;Put yes if you are using an Invalid SSL certificate, no if you have a legit cert;E-Mail address to notify you
# Example: GTAXLnet Website;https://gtaxl.net;443;no;gtaxl@gtaxl.net
# Example: Knox County Career Center;http://knoxcountycc.org;80;no;7403583183@tmomail.net
# Example: ZNC Bouncer HTTPd;https://bnc1.gtaxl.net;8080;yes;mastergta2@gmail.com
# By: Victor Coss (GTAXL) vic@likeacoss.com DEC/23/2015

date=$(date)
doesexist=$(wc -l /home/gtaxl/uptimemon/checks/http.txt | awk '{print $1}')

if [[ -a "/home/gtaxl/uptimemon/checks/http.txt" && "$doesexist" -gt "0" ]]; then
	IFS=';'
	cat /home/gtaxl/uptimemon/checks/http.txt | while read name address port invalidssl notify; do
	checkhttp() {
	if [ "$invalidssl" == "yes" ]; then
		curl --connect-timeout 3 --referer https://gtaxl.net -I -X GET $address:$port -k -A "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
			else
				curl --connect-timeout 3 --referer https://gtaxl.net -I -X GET $address:$port -A "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
			fi
	}
	statuscode=$(checkhttp 2>/dev/null | head -1 | awk '{print $2}')
	serverhttpd=$(checkhttp 2>/dev/null | grep "Server:" | awk '{print $2}')
	if [[ "$statuscode" == "200" || "$statuscode" == "300" || "$statuscode" == "301" || "$statuscode" == "302" || "$statuscode" == "304" ]]; then
	touch "/home/gtaxl/uptimemon/status/HTTP-$name"
	togglenotify=$(cat /home/gtaxl/uptimemon/status/HTTP-$name)
	if [ "$togglenotify" == "DOWN" ] ; then
		echo "UP" > /home/gtaxl/uptimemon/status/HTTP-$name
		echo -e "$name is back up at $date\nCheck Type: HTTP\nURL: $address\nPort: $port\nInvalid SSL: $invalidssl\nHTTPd: $serverhttpd" | mail -a "From: GTAXLnet Uptime Monitor <uptimemonitor@gtaxl.net>" -s "GTAXLnet Uptime Monitor" $notify
		if [ ! -f "/home/gtaxl/uptimemon/tallies/HTTP-$name" ]; then 
			echo "0 0 0" > /home/gtaxl/uptimemon/tallies/HTTP-$name 
		fi
		pulluptally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $1}')
		pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $2}')
		uptally=$(echo "$pulluptally+1" | bc)
		totaltally=$(echo "$pulltotaltally+1" | bc)
		percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
		echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/HTTP-$name
		else 
			echo "UP" > /home/gtaxl/uptimemon/status/HTTP-$name
			if [ ! -f "/home/gtaxl/uptimemon/tallies/HTTP-$name" ]; then 
				echo "0 0 0" > /home/gtaxl/uptimemon/tallies/HTTP-$name 
			fi
			pulluptally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $1}')
			pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $2}')
			uptally=$(echo "$pulluptally+1" | bc)
			totaltally=$(echo "$pulltotaltally+1" | bc)
			percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
			echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/HTTP-$name					
		fi
		else
			touch "/home/gtaxl/uptimemon/status/HTTP-$name"
			togglenotify=$(cat /home/gtaxl/uptimemon/status/HTTP-$name)
			if [ "$togglenotify" == "UP" ] ; then 
				echo "DOWN" > /home/gtaxl/uptimemon/status/HTTP-$name
				echo -e "$name is DOWN at $date\nCheck Type: HTTP\nURL: $address\nPort: $port\nInvalid SSL: $invalidssl" | mail -a "From: GTAXLnet Uptime Monitor <uptimemonitor@gtaxl.net>" -s "GTAXLnet Uptime Monitor" $notify
				if [ ! -f "/home/gtaxl/uptimemon/tallies/HTTP-$name" ]; then 
					echo "0 0 0" > /home/gtaxl/uptimemon/tallies/HTTP-$name  
				fi
				pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $2}')
				uptally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $1}')
				totaltally=$(echo "$pulltotaltally+1" | bc)
				percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
				echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/HTTP-$name
					else
						echo "DOWN" > /home/gtaxl/uptimemon/status/HTTP-$name
						if [ ! -f "/home/gtaxl/uptimemon/tallies/HTTP-$name" ]; then 
							echo "0 0 0" > /home/gtaxl/uptimemon/tallies/HTTP-$name 
						fi
						pulltotaltally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $2}')
						uptally=$(cat /home/gtaxl/uptimemon/tallies/HTTP-$name | awk '{print $1}')
						totaltally=$(echo "$pulltotaltally+1" | bc)
						percentup=$(echo "scale=3;$uptally/$totaltally" | bc)
						echo "$uptally $totaltally $percentup" > /home/gtaxl/uptimemon/tallies/HTTP-$name
					fi
		fi
	done
		else
			echo "Checker file not found."
			exit
fi

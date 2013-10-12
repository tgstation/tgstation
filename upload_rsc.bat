# Script to easily upload tgstation.rsc to your FTP-server so that clients download it from an
#	external webserver instead of from your connection when joining your game server.
# Run this script every time you have compiled your code, otherwise joining players will get errors.
#
# Replace USERNAME with your FTP username
# Replace PASSWORD with your FTP password
# Replace FOLDER/FOLDER with the folder on the FTP server where you want to store tgstation.rsc, for example: cd www/rsc
# Replace FTP.DOMAIN.COM with the IP-address or domain name of your FTP server
# Add the URL to the location of tgstation.rsc on your webserver into data\external_rsc_urls.txt
@echo off
echo user USERNAME> ftpcmd.dat
echo PASSWORD>> ftpcmd.dat
echo bin>> ftpcmd.dat
echo cd FOLDER/FOLDER>> ftpcmd.dat
echo put tgstation.rsc>> ftpcmd.dat
echo quit>> ftpcmd.dat
ftp -n -s:ftpcmd.dat FTP.DOMAIN.COM
del ftpcmd.dat
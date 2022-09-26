#!/bin/bash
####################################################################
# Decription: Skeleton for script with output screen and log file
# Author: Gilles Mouchet (gilles.mouchet@gmail.com)
# Creation Date: 18-Jun-2022
# Version: 1.0
# Sources:
#    https://www.computerhope.com/unix/bash/getopts.ht
#
# Changelog:
#    V1.0 - 18-Jun-2022 - GMo
#      Added
#      - Creation of script from scratch
#
#####################################################################

#####################################################################
# variables
#####################################################################
version=0.1
scriptName=`basename $0`

# variables for display the results on the screen and in log file
progName=`echo $0 | sed -e 's|.*/||g' | cut -f1 -d.`
dayOfWeek=`/bin/date +%a`
daySuffix="_$dayOfWeek"
tempOutputPath=/tmp
tempOutputFile=$tempOutputPath/$progName.$$
logPath=/tmp
logFile=$logPath/$progName$daySuffix.log

# Color
RED='\033[0;31m' # Red
GREEN='\033[0;32m' # Green
YELLOW='\033[1;33m' # Yellow
NC='\033[0m' # No Color

#####################################################################
# functions
#####################################################################
# write log
writeLog() {
  dateEvent=`date +"%h %d %T"`
  echo -e "$dateEvent - $1"
  echo -e "\n--------------------\n$dateEvent - $1" >> $logFile
}

writeSuccess() {
  dateEvent=`date +"%h %d %T"`
  echo -e "$dateEvent - $1 - ${GREEN}Success${NC}"
  echo -e "$dateEvent - $1 - ${GREEN}Success${NC}" >> $logFile
}

writeError() {
  dateEvent=`date +"%h %d %T"`
  echo -e "$dateEvent - $1 - ${RED}Error${NC}"
  echo -e "$dateEvent - $1 - ${RED}Error${NC}" >> $logFile
}
writeWarning() {
  dateEvent=`date +"%h %d %T"`
  echo -e "$dateEvent - $1 - ${YELLOW}Warning${NC}"
  echo -e "$dateEvent - $1 - ${YELLOW}Warning${NC}" >> $logFile
}

writeResult() {
  if [ "$1" != "0" ]; then
      writeError "$2"
      echo -e "\nVoir le fichier de log $tempOutputFile"
      exit 1
  else
      writeSuccess "$2"
  fi
}

# Trick to display the results on the screen and in log file at the same time
# 1) Creation of a temporary file
# 2) Running a tail -f command on this file in the background
# 3) Retrieving the tail process ID, so that it can be killed at the end of the script
#4 ) Redirect standard output to file
#5 ) Redirect errors to standard output

# 1)
#cat /dev/null > $tempOutputFile
# 2)
#tail -f $tempOutputFile &
# 3)
#tailJob=$!
# 4)
#exec >> $tempOutputFile
# 5)
#exec 2>&1

#####################################################################
# main
#####################################################################

# mise à jour de rocky
#msg="Mise à jour de Rocky 8"
#writeLog "$msg. Be patient ..."
#sudo dnf -y update >> $logFile 2>&1
#writeResult "$?" "$msg"

# install python
msg="python3.8 installation"
writeLog "$msg. Be patient ..."
sudo dnf -y install python3 >> $logFile 2>&1
writeResult "$?" "$msg"

# set python3.8
#msg="set python3.8 default"
#writeLog "$msg"
#sudo update-alternatives --set python /usr/bin/python3.8
#writeResult "$?" "$msg"

# mise à jour de pip
msg="pip upgrade"
writeLog "$msg"
pip3.8 install --user --upgrade pip >> $logFile 2>&1
writeResult "$?" "$msg" 

# installation ansible
msg="ansible installation"
writeLog "$msg. Be patient ..."
pip3.8 install ansible >> $logFile 2>&1
writeResult "$?" "$msg" 

# generate ssh key
msg="generate ssh key"
writeLog "$msg"
ssh-keygen -f ~/.ssh/id_rsa -q -N "" <<< y >> $logFile 2>&1
writeResult "$?" "$msg" 

# copy ssh key in authorized_keys
msg="copy ssh key in authorized_keys"
writeLog "$msg"
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
writeResult "$?" "$msg" 

# copy ssh key into known_hosts
msg="put ssh key in known_hosts"
writeLog "$msg"
ssh-keyscan -t rsa localhost >> ~/.ssh/known_hosts
writeResult "$?" "$msg"

# execute ansible playbook
msg="execute playbook"
writeLog "$msg"
ansible-playbook -i inventory main.yml 
writeResult "$?" "$msg"

## Installation  du repo epel

#dnf -y install epel-release
#writeResult "$?" "Installation du repository EPEL"

## Installation des pacakges
#dnf -y --enablerepo=powertools install vim glances htop bind-utils tcptraceroute telnet lsof elinks rsync lynx postfix man mlocate mutt mailx wget yum-utils bash-completion git 
#####################################################################
# cleanups
#####################################################################
# copy the tmpfile to logFile
#cat $tempOutputFile > $logFile

#sleep 2
# end of printing at the console
#kill -9 $tailJob > /dev/null
# Deleting the standard output redirection temporary file
#rm -f $tempOutputFile

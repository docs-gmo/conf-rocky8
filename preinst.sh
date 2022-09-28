#!/bin/bash
####################################################################
# Decription: post-install Rocky 9
# Author: Gilles Mouchet (gilles.mouchet@gmail.com)
# Creation Date: 18-Sep-2022
# Version: 1.0
# Changelog:
#    V1.0 - 18-Sep-2022 - GMo
#      Added
#      - Creation of script from scratch
#
#####################################################################

#####################################################################
# variables
#####################################################################
version=1.0
scriptName=`basename $0`

# variables for display the results on the screen and in log file
progName=`echo $0 | sed -e 's|.*/||g' | cut -f1 -d.`
dayOfWeek=`/bin/date +%a`
daySuffix="_$dayOfWeek"
#tempOutputPath=/tmp
#tempOutputFile=$tempOutputPath/$progName.$$
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

#####################################################################
# main
#####################################################################
# install python
msg="pip installation"
writeLog "$msg"
sudo dnf -y install python3-pip >> $logFile 2>&1
writeResult "$?" "$msg"

# mise à jour de pip
msg="pip upgrade"
writeLog "$msg"
pip install --user --upgrade pip >> $logFile 2>&1
writeResult "$?" "$msg" 

# installation ansible
msg="ansible installation"
writeLog "$msg. Be patient ..."
pip install ansible >> $logFile 2>&1
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
ansible-playbook -i inventory main.yml -e the_user=$LOGNAME
writeResult "$?" "$msg"

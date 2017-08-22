#!/bin/bash
#################################################
#Cycle mysql service on multiple PCs via cygwin #
#################################################

#Color Variables
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

#Make sure the user is oracle
if [[ `id -un` != "oracle" ]];then
  echo "${red}This must be run as the oracle user${reset}"
  exit 1
fi

function usage {
        echo "  Usage: If single PC"
        echo "          ./`basename $0` <pc_name>"
        echo "  Usage: If more than one PC"
        echo "          ./`basename $0` <pc_name> <pc_name> <pc_name>"
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ];then
        usage
        exit 0
fi

#Accepts PCs into the array from CLI args
argsPCs=( "$@" )
#SSH user to use
sshuser=SvcCOPSSH

#Will cycle mysql
function mysql_cycle {
service="mysql"
for pc in ${argsPCs[@]}
do
  ssh $sshuser@$pc sc stop $service
  sleep 7
  ssh $sshuser@$pc sc start $service
  sleep 5
  ssh $sshuser@$pc sc query $service
done
}

#Will cycle goldengate manager
function ggsmgr_cycle {
service="ggsmgr"
for pc in ${argsPCs[@]}
do
  ssh $sshuser@$pc sc stop $service
  sleep 7
  ssh $sshuser@$pc sc start $service
  sleep 5
  ssh $sshuser@$pc sc query $service
done
}

read -p "Would you like to cycle mysql on the PC? (y/n)" -n 1 answermysql
echo ""
read -p "Would you like to cycle ggsmgr as well? (y/n)" -n 1 answerggsmgr
echo ""
if [ $answermysql == "y" ] && [ $answerggsmgr == "y" ];
then
        mysql_cycle
        ggsmgr_cycle
        echo "${green}Service cycle complete${reset}"

elif [ $answermysql == "y" ] && [ $answerggsmgr == "n" ]
then
        mysql_cycle
        echo ""
        echo "${green}MYSQL cycle complete${reset}"
        echo "${red}GGSMGR will not be cycled${reset}"

elif [ $answermysql == "n" ] && [ $answerggsmgr == "y" ];
then
        ggsmgr_cycle
        echo ""
        echo "${green}GGSMGR cycle complete${reset}"
        echo "${red}MYSQL will not be cycled${reset}"
else [ $answermysql == "n" ] && [ $answerggsmgr == "n" ];
        echo ""
        echo "${green}No Services will be cycled${reset}"
        echo "Why did you run this if you ain't cycling anything"
fi

exit 0
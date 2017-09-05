#!/bin/bash
######################################################
#Cycle PC services on one or multiple PCs via cygwin #
######################################################

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
  ssh $sshuser@$pc << EOF
  sc stop $service
  sleep 7
  sc start $service
  sleep 5
  sc query $service
  EOF
done
}

#Will cycle goldengate manager
function ggsmgr_cycle {
service="ggsmgr"
for pc in ${argsPCs[@]}
do
  ssh $sshuser@$pc << EOF
  sc stop $service
  sleep 7
  sc start $service
  sleep 5
  sc query $service
  EOF
done
}

read -p "Would you like to cycle MYSQL on the PC? (y/n)" -n 1 answermysql
echo "" #For formmatting purposes
read -p "Would you like to cycle GGSMGR as well? (y/n)" -n 1 answerggsmgr
echo "" #For formmatting purposes
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

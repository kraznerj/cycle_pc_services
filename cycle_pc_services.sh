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

#Check Status of mysql
function mysql_status {
  #statements
  service="mysql"
  get_state=`sc query $service | grep -E STATE`
  set -- $get_state
  service_status=`echo $4`

  for pc in ${argsPCs[@]}
  do
    echo "Current Status: "$service_status
  done
  echo "Current Status: "$service_status
}


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

COLUMNS=7
#PS3='What Services would you like to cycle? '
options=("Check MySQL Status" "Check GGSMGR Status" "Check Both MySQL & GGSMGR Status" "Cycle MySQL" "Cycle GGSMGR" "Cycle Both GGSMGR & MySQL" "Quit")
select opt in "${options[@]}"
do
	case $opt in
    "Check MySQL Status")
      mysql_status
      echo ""
      break
      ;;

    "Check GGSMGR Status")
      echo ""
      break
      ;;

    "Check Both MySQL & GGSMGR Status")
      echo ""
      break
      ;;

		"Cycle MySQL")
			mysql_cycle
        		echo "${green}MySQL cycle complete${reset}"
			      echo ""
            break
			;;
		"Cycle GGSMGR")
			ggsmgr_cycle
			echo "${green}GGSMGR cycle complete${reset}"
			echo ""
      break
			;;
		"Cycle Both GGSMGR & MySQL")
			mysql_cycle
			ggsmgr_cycle
			echo ""
			echo "${green}Service cycle complete${reset}"
			echo ""
      break
			;;
		"Quit")
			echo "${green}No Services will be cycled${reset}"
			echo "Why did you run this if you ain't cycling anything"
			break
			;;
		*) echo "invalid option";;
	esac
done

exit 0

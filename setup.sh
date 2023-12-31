#! /bin/bash

# This is a script to install the ThingsIX Forwarder to a VPS or HomeLab Server.

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#paths
dir_path="/etc/thingsix-forwarder"
local_id="/etc/thingsix-forwarder/unknown_gateways.yaml"


function install() {
# Use Docker Convenience Script to install Docker Engine
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sleep 5

echo -e "${GREEN}Module: Install ThingsIX Forwarder${NC}"
	echo -e "${YELLOW}================================================================${NC}"
	if [[ "$USER" != "root" ]]; then
		echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
		echo -e "${CYAN}Please switch to the root account use command 'sudo su -'.${NC}"
		echo -e "${YELLOW}================================================================${NC}"
		echo -e "${NC}"
		exit
	fi

mkdir /etc/thingsix-forwarder
# start the forwarder container
docker run -d --name thingsix-forwarder -p 1685:1680/udp --restart unless-stopped -v /etc/thingsix-forwarder:/etc/thingsix-forwarder ghcr.io/thingsixfoundation/packet-handling/forwarder:latest --net=main
echo -e "${GREEN}Run the same command again to onboard your Device if you have setup on Browan Dashboard${NC}"
}

function onboard() {
    echo -e "${GREEN}Module: Onboarding ThingsIX${NC}"
    echo -e "${CYAN}Now we will onboard your device onto the ThingsIX Network${NC}"
	echo -e "${YELLOW}================================================================${NC}"
    if [[ "$USER" != "root" ]]; then
		echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
		echo -e "${CYAN}Please switch to the root account use command 'sudo su -'.${NC}"
		echo -e "${YELLOW}================================================================${NC}"
		echo -e "${NC}"
		exit
	fi
    sleep 3

    if whiptail --yesno "You need to go into the WebUI of your Browan Miner now and configure the forwarder. Have you done so?" 14 60; then
            id=$(grep -Po 'local_id: \K.*' $local_id)
            echo -e "${CYAN}Please enter your Polygon Wallet address to onboard this device to your Wallet${NC}"
            read wallet
    else
        echo "Aborted"
        exit
    fi

    docker exec thingsix-forwarder ./forwarder gateway onboard-and-push $id $wallet

}

function firewall() {
	echo -e "${GREEN}Active Firewall UFW and Fail2ban${NC}"
	echo -e "${YELLOW}Now we will add the rules to UFW${NC}"
	# add ufw rules
	sudo ufw allow ssh
	sudo ufw allow 1685
	sudo apt install fail2ban
	sleep 3
	sudo systemctl enable fail2ban now
}

function watchtower() {
    echo -e "${GREEN}Module: Watchtower ThingsIX${NC}"
    echo -e "${CYAN}Now we will automate your device to update ThingsIX Forwarder every time there is an update${NC}"
	echo -e "${YELLOW}================================================================${NC}"
    if [[ "$USER" != "root" ]]; then
		echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
		echo -e "${CYAN}Please switch to the root account use command 'sudo su -'.${NC}"
		echo -e "${YELLOW}================================================================${NC}"
		echo -e "${NC}"
		exit
	fi
    sleep 3

    docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 43200 --cleanup --monitor-only thingsix-forwarder

}


if ! figlet -v > /dev/null 2>&1; then
	sudo apt-get update -y > /dev/null 2>&1
	sudo apt-get install -y figlet > /dev/null 2>&1
fi


if ! wget --version > /dev/null 2>&1 ; then
	sudo apt install -y wget > /dev/null 2>&1 && sleep 2
fi

if ! whiptail -v > /dev/null 2>&1; then
	sudo apt-get install -y whiptail > /dev/null 2>&1
fi

clear
sleep 1
echo -e "${BLUE}"
figlet -f slant "Toolbox"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${GREEN}OS: Ubuntu 16/18/19/20, Debian 9/10 ${NC}"
echo -e "${GREEN}Created by: WantClue${NC}"
echo -e "${GREEN}Special thanks to hekopath ${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${CYAN}1  - Installation of ThingsIX forwarder${NC}"
echo -e "${CYAN}2  - Onboarding of ThingsIX Gateway${NC}"
echo -e "${CYAN}3  - Active Firewall UFW and fail2ban${NC}"
echo -e "${CYAN}4  - Install update automation${NC}"
echo -e "${CYAN}5  - Abort${NC}"
echo -e "${YELLOW}================================================================${NC}"

read -rp "Pick an option and hit ENTER: "
case "$REPLY" in
 1)  
		clear
		sleep 1
		install
 ;;
 2) 
		clear
		sleep 1
		onboard
 ;;
 3) 
		clear
		sleep 1
		firewall
 ;;
 4) 
		clear
		sleep 1
		watchtower
 ;;
 5) 
		clear
		sleep 1
		exit
 ;;
esac

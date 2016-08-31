#!/bin/bash

# Stop on the first sign of trouble
set -e
# sudo check unnecessary on Edison
# if [ $UID != 0 ]; then
#     echo "ERROR: Operation not permitted. Forgot sudo?"
#     exit 1
#  fi

VERSION="spi for Intel Edison on Arduino"
#if [[ $1 != "" ]]; then VERSION=$1; fi not needed since ve do not support USB version

echo "The Things Network Gateway installer"
echo "Version $VERSION"
#Check that Intel Edison is present and has Yocto Linux flashed
if [[ $(find /usr/i586-poky-linux 2>&1 | grep "/usr/i586-poky-linux") == "" ]]; then
  echo "[TTN Gateway]: Either this is not an Intel Edison,"
  echo "[TTN Gateway]: or you don't have Yocto flashed, aborting ..."
  exit 1
fi

#Check if the Edison is mounted on an Arduino board, not on the mini breakout board -deprecated
# if [[ $(cat /sys/kernel/debug/gpio | grep "Arduino Shield") == "" ]]; then
#  echo "[TTN Gateway]: Arduino Shield not present, aborting..."
#  exit 1
# fi

# Update the gateway installer to the correct branch
echo "Updating installer files..."
OLD_HEAD=$(git rev-parse HEAD)
git fetch
git checkout -q spi #changed to point directly to spi branch, since there is no USB support
git pull
NEW_HEAD=$(git rev-parse HEAD)

if [[ $OLD_HEAD != $NEW_HEAD ]]; then
     echo "New installer found. Restarting process..."
     exec "./install.sh" # "$VERSION" removed since there is no USB support
  else
     echo "All set!"
fi

# Request gateway configuration data - WORKS with wlan0 ON EDISON
# There are two ways to do it, manually specify everything
# or rely on the gateway EUI and retrieve settings files from remote (recommended)
echo "Gateway configuration:"

# Try to get gateway ID from MAC address
# First try eth0, if that does not exist, try wlan0 (for RPi Zero AND Edison)
GATEWAY_EUI_NIC="eth0"
if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    GATEWAY_EUI_NIC="wlan0"
fi

if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    echo "ERROR: No network interface found. Cannot set gateway ID."
    exit 1
fi

GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^} # toupper

echo "Detected EUI $GATEWAY_EUI from $GATEWAY_EUI_NIC"
read -r -p "Do you want to use remote settings file? [y/N]" response
response=${response,,} # tolower

if [[ $response =~ ^(yes|y) ]]; then
    NEW_HOSTNAME="ttngtw"
    REMOTE_CONFIG=true
else
    printf "       Host name [ttngtw]:"
    read NEW_HOSTNAME
    if [[ $NEW_HOSTNAME == "" ]]; then NEW_HOSTNAME="ttngtw"; fi

    printf "       Descriptive name [ttn-Edison+ic880a]:"
    read GATEWAY_NAME
    if [[ $GATEWAY_NAME == "" ]]; then GATEWAY_NAME="ttn-Edison+ic880a"; fi

    printf "       Contact email: "
    read GATEWAY_EMAIL

    printf "       Latitude [0]: "
    read GATEWAY_LAT
    if [[ $GATEWAY_LAT == "" ]]; then GATEWAY_LAT=0; fi

    printf "       Longitude [0]: "
    read GATEWAY_LON
    if [[ $GATEWAY_LON == "" ]]; then GATEWAY_LON=0; fi

    printf "       Altitude [0]: "
    read GATEWAY_ALT
    if [[ $GATEWAY_ALT == "" ]]; then GATEWAY_ALT=0; fi
fi


# Change hostname if needed
CURRENT_HOSTNAME=$(hostname)

if [[ $NEW_HOSTNAME != $CURRENT_HOSTNAME ]]; then
    echo "Updating hostname to '$NEW_HOSTNAME'..."
    hostname $NEW_HOSTNAME
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
fi

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="/opt/ttn-gateway"
if [ -d "$INSTALL_DIR" ]; then 
rm -R $INSTALL_DIR
mkdir $INSTALL_DIR
fi
pushd $INSTALL_DIR

# Remove WiringPi built from source (older installer versions). Not necessary with Edison 
# if [ -d wiringPi ]; then
#     pushd wiringPi
#     ./build uninstall
#     popd
#     rm -rf wiringPi
# fi 

# Build LoRa gateway app
if [ -d lora_gateway ]; then rm -R lora_gateway; fi
git clone https://github.com/mihaimiculescu/lora_gateway.git
pushd lora_gateway

sed -i -e 's/PLATFORM= kerlink/PLATFORM= imst_edison/g' ./libloragw/library.cfg #Modified to include imst_edison.h

make

popd

# Build packet forwarder
if [ -d packet_forwarder ]; then rm -R packet_forwarder ; fi
git clone https://github.com/TheThingsNetwork/packet_forwarder.git
pushd packet_forwarder

make

popd

# Symlink poly packet forwarder
if [ ! -d bin ]; then mkdir bin; fi
if [ -f ./bin/poly_pkt_fwd ]; then rm ./bin/poly_pkt_fwd; fi
ln -s $INSTALL_DIR/packet_forwarder/poly_pkt_fwd/poly_pkt_fwd ./bin/poly_pkt_fwd
cp -f ./packet_forwarder/poly_pkt_fwd/global_conf.json ./bin/global_conf.json

LOCAL_CONFIG_FILE=$INSTALL_DIR/bin/local_conf.json

# Remove old config file
if [ -e $LOCAL_CONFIG_FILE ]; then rm $LOCAL_CONFIG_FILE; fi;

if [ "$REMOTE_CONFIG" = true ] ; then
    # Get remote configuration repo
    if [ ! -d gateway-remote-config ]; then
        git clone https://github.com/ttn-zh/gateway-remote-config.git # to be discussed with Gonzalo
        pushd gateway-remote-config
    else
        pushd gateway-remote-config
        git pull
        git reset --hard
    fi

    ln -s $INSTALL_DIR/gateway-remote-config/$GATEWAY_EUI.json $LOCAL_CONFIG_FILE

    popd
else
    echo -e "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GATEWAY_EUI\",\n\t\t\"servers\": [ { \"server_address\": \"router.eu.thethings.network\", \"serv_port_up\": 1700, \"serv_port_down\": 1700, \"serv_enabled\": true } ],\n\t\t\"ref_latitude\": $GATEWAY_LAT,\n\t\t\"ref_longitude\": $GATEWAY_LON,\n\t\t\"ref_altitude\": $GATEWAY_ALT,\n\t\t\"contact_email\": \"$GATEWAY_EMAIL\",\n\t\t\"description\": \"$GATEWAY_NAME\" \n\t}\n}" >$LOCAL_CONFIG_FILE
fi

popd

echo "Gateway EUI is: $GATEWAY_EUI"
echo "Check status updates on API: http://thethingsnetwork.org/api/v0/gateways/$GATEWAY_EUI/"
echo
echo "Installation completed."

# Start packet forwarder as a service
cp ./start.sh $INSTALL_DIR/bin/
cp ./ttn-gateway.service /lib/systemd/system/
systemctl enable ttn-gateway.service

echo "The system will reboot in 5 seconds..."
sleep 5
reboot # replaces shutdown -r now

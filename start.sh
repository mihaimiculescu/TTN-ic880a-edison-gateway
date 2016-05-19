#! /bin/bash

# Set Edison IO10-13 pins for SPI mode and use IO9 pin to drive iC880A-SPI's Reset pin 
# Note: I10-13 are mandatory, IO9 is by choice, simply because it is the next available pin ...
# Edion convention: 1=high=out
echo 111 > /sys/class/gpio/export # you might get an error at this line, don't mind it
echo 115 > /sys/class/gpio/export
echo 114 > /sys/class/gpio/export
echo 109 > /sys/class/gpio/export
echo 263 > /sys/class/gpio/export
echo 240 > /sys/class/gpio/export
echo 262 > /sys/class/gpio/export
echo 241 > /sys/class/gpio/export
echo 242 > /sys/class/gpio/export
echo 243 > /sys/class/gpio/export
echo 258 > /sys/class/gpio/export
echo 259 > /sys/class/gpio/export
echo 260 > /sys/class/gpio/export
echo 261 > /sys/class/gpio/export
echo 226 > /sys/class/gpio/export
echo 227 > /sys/class/gpio/export
echo 228 > /sys/class/gpio/export
echo 229 > /sys/class/gpio/export
echo 257 > /sys/class/gpio/export
echo 225 > /sys/class/gpio/export
echo 214 > /sys/class/gpio/export #this is the tri-state-all control - default out. You might get an error also at this line,
ignore it
echo in > /sys/class/gpio/gpio214/direction #put it in the tri-state status
echo out > /sys/class/gpio/gpio263/direction
echo out > /sys/class/gpio/gpio240/direction
echo out > /sys/class/gpio/gpio262/direction
echo out > /sys/class/gpio/gpio241/direction
echo out > /sys/class/gpio/gpio242/direction
echo out > /sys/class/gpio/gpio243/direction
echo out > /sys/class/gpio/gpio258/direction
echo out > /sys/class/gpio/gpio259/direction
echo in > /sys/class/gpio/gpio260/direction
echo out > /sys/class/gpio/gpio261/direction
echo out > /sys/class/gpio/gpio257/direction
echo in > /sys/class/gpio/gpio225/direction
echo in > /sys/class/gpio/gpio226/direction
echo in > /sys/class/gpio/gpio227/direction
echo in > /sys/class/gpio/gpio228/direction
echo in > /sys/class/gpio/gpio229/direction
echo mode1 > /sys/kernel/debug/gpio_debug/gpio111/current_pinmux
echo mode1 > /sys/kernel/debug/gpio_debug/gpio115/current_pinmux
echo mode1 > /sys/kernel/debug/gpio_debug/gpio114/current_pinmux
echo mode1 > /sys/kernel/debug/gpio_debug/gpio109/current_pinmux
echo mode0 > /sys/kernel/debug/gpio_debug/gpio183/current_pinmux
echo out > /sys/class/gpio/gpio214/direction 
# End Edison settings

# Reset iC880A-SPI
TODO
# End reset iC880A-SPI

## Reset iC880a PIN Pi style
# SX1301_RESET_BCM_PIN=25
# echo "$SX1301_RESET_BCM_PIN"  > /sys/class/gpio/export 
# echo "out" > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/direction 
# echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value 
# sleep 0.1  
# echo "1"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value 
# sleep 0.1  
# echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
# sleep 0.1
# echo "$SX1301_RESET_BCM_PIN"  > /sys/class/gpio/unexport 
## End Reset iC880a PIN Pi style

# Test the connection, wait if needed.
while [[ $(ping -c1 google.com 2>&1 | grep " 0% packet loss") == "" ]]; do
  echo "[TTN Gateway]: Waiting for internet connection..."
  sleep 30
  done

# If there's a remote config, try to update it
if [ -d ../gateway-remote-config ]; then
    # First pull from the repo
    pushd ../gateway-remote-config/
    git pull
    git reset --hard
    popd

    # And then try to refresh the gateway EUI and re-link local_conf.json

    # Same eth0/wlan0 fallback as on install.sh
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

    echo "[TTN Gateway]: Use Gateway EUI $GATEWAY_EUI based on $GATEWAY_EUI_NIC"
    INSTALL_DIR="/opt/ttn-gateway"
    LOCAL_CONFIG_FILE=$INSTALL_DIR/bin/local_conf.json

    if [ -e $LOCAL_CONFIG_FILE ]; then rm $LOCAL_CONFIG_FILE; fi;
    ln -s $INSTALL_DIR/gateway-remote-config/$GATEWAY_EUI.json $LOCAL_CONFIG_FILE

fi

# Fire up the forwarder.
./poly_pkt_fwd

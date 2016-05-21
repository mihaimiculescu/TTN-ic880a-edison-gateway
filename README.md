# The Things Network: Intel Edison + iC880a - based gateway
## - work in progress -
Reference setup for [The Things Network](http://thethingsnetwork.org/) gateways based on the iC880a SPI concentrator with a Intel® Edison Kit for Arduino as host.

This installer targets the **SPI version** of the board.

## Setup
Connect the iC880a-SPI board to the Arduino [as shown in this picture](images/Connexions.jpg)
Note: If you want to use also the [Grove base shield](http://www.seeedstudio.com/wiki/Base_shield_v2), do NOT use the Grove connector D8, as it is connected to the iC880!
Detailed instructions will follow soon. 

## Installation NOT COMPLETE YET
- Login as root - this gives you all the necessary rights. No sudo available on Edison
- Clone the installer and start the installation

        # git clone https://github.com/ttn-zh/ic880a-gateway.git ~/ic880a-gateway
        # cd ~/ic880a-gateway
        # ./install.sh spi

## Update - NOT COMPLETE YET

If you have a running gateway and want to update, simply run the installer again:

        # cd ~/ic880a-gateway
        # ./install.sh spi

# Credits - NOT COMPLETE YET

These scripts are largely based on the awesome work by [Ruud Vlaming](https://github.com/devlaam) on the [Lorank8 installer](https://github.com/Ideetron/Lorank).

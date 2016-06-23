# The Things Network: Intel Edison + iC880a - based gateway
## - work in progress - do NOT attempt to use yet
Reference setup for [The Things Network](http://thethingsnetwork.org/) gateways based on the iC880a SPI concentrator with a Intel® Edison Kit for Arduino as host.

This installer targets the **SPI version** of the board. The **USB** version is **not supported**

## Setup
Connect the iC880a-SPI board to the Arduino [as shown in this picture](images/Connexions.jpg)
Note: If you want to use also the [Grove base shield](http://www.seeedstudio.com/wiki/Base_shield_v2), do NOT use the Grove connector D8, as it is connected to the iC880! Also i2c functionality is disabled.
Detailed instructions will follow soon. 

## Installation
##### 1. If you haven't done so already:
 - 1.1 Flash your Edison with the latest Yocto image [as explained here] (http://www.intel.com/content/www/us/en/support/boards-and-kits/000005795.html)
 - 1.2 install git [as explained here](https://github.com/w4ilun/edison-guides/wiki/Installing-Git-on-Intel-Edison)
 - 1.3 Login as root - this gives you all the necessary rights. No sudo available on Edison

##### 2. Clone the installer and start the installation

      # git clone https://github.com/mihaimiculescu/TTN-ic880a-edison-gateway.git/ ~/TTN-ic880a-edison-gateway
      # cd ~/TTN-ic880a-edison-gateway
      # git checkout spi
      # ./install.sh

## Update

If you have a running gateway and want to update, simply run the installer again:

        # cd ~/TTN-ic880a-edison-gateway
        # ./install.sh

# Credits

###### These scripts are largely based on the awesome work by [Ruud Vlaming](https://github.com/devlaam) on the [Lorank8 installer](https://github.com/Ideetron/Lorank) and [Gonzalo Casas](https://github.com/gonzalocasas) on the [ic880A + Raspberry Pi installer](https://github.com/ttn-zh/ic880a-gateway)

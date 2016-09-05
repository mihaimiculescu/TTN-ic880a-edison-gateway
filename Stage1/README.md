Repos used:
1.
https://github.com/mihaimiculescu/TTN-ic880a-edison-gateway/tree/spi/ for installer files<br>
2.
https://github.com/mihaimiculescu/lora_gateway/ for SPI driver.
It contains a slightly modified [loragw_spi.native.c](https://github.com/mihaimiculescu/lora_gateway/blob/master/libloragw/src/loragw_spi.native.c) file to accomodate
the overrides provided by the [imst_edison.h](https://github.com/mihaimiculescu/lora_gateway/blob/master/libloragw/inc/imst_edison.h) file
3.
https://github.com/TheThingsNetwork/packet_forwarder. for the packets forwarding software

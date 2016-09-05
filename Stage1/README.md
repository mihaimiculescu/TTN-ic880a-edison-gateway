Repos used:<br>
1.<br>
https://github.com/mihaimiculescu/TTN-ic880a-edison-gateway/tree/spi/ for installer files<br>
2.<br>
https://github.com/mihaimiculescu/lora_gateway/ for SPI driver.<br>
It contains a slightly modified [loragw_spi.native.c](https://github.com/mihaimiculescu/lora_gateway/blob/master/libloragw/src/loragw_spi.native.c) file to accomodate the overrides provided by the [imst_edison.h](https://github.com/mihaimiculescu/lora_gateway/blob/master/libloragw/inc/imst_edison.h) file<br>
3.<br>
https://github.com/TheThingsNetwork/packet_forwarder. for the packets forwarding software<br>

/*
 * imst_edison.h
 *
 *  Created on: May 26, 2016
 *      Author: mihaimiculescu
 */

#ifndef _IMST_EDISON_H_
#define _IMST_EDISON_H_

/* Human readable platform definition */
#define DISPLAY_PLATFORM "IMST + Edison on Arduino"

/* parameters for native spi */
#define SPI_SPEED		8000000
#define SPI_DEV_PATH	"/dev/spidev5.1"
#define SPI_CS_CHANGE_KO   0 // it affects lines 273 and 327 in https://github.com/mihaimiculescu/lora_gateway/blob/master/libloragw/src/loragw_spi.native.c
#define SPI_CS_CHANGE   0

/* parameters for a FT2232H - unnecesary as long as USB is not supported */
#define VID		        0x0403
#define PID		        0x6014 

#endif /* _IMST_EDISON_H_ */

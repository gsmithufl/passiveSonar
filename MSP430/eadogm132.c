/*
 * Written by: Garrett Smith
 * University of Florida: ECE Design II
 * Fall 2015
 */

#include <msp430f235.h>
#include <stdint.h>

void spiWrite(int volatile p_data) {
	int volatile temp = UCB0RXBUF;
	while (!(IFG2 & UCB0TXIFG)) {
	};
	UCB0TXBUF = p_data;
	while (UCB0STAT & UCBUSY) {
	};
}

void dogmCMDWrite(int volatile p_data) {
	P6OUT &= ~BIT4; //a0 low
	P6OUT &= ~BIT5; //cs low
	spiWrite(p_data);
	P6OUT |= BIT5;
}

void dogmDataWrite(int volatile p_data) {
	P6OUT &= ~(BIT5); // /CS1 = 0, A0 = 1
	P6OUT |= BIT4;
	spiWrite(p_data);
	P6OUT |= BIT5 | BIT4;   // /CS1, A0 = 1
}

void dogmConfig(void) {
	P6DIR |= BIT5 | BIT4;
	P3DIR |= BIT5;
	P3OUT &= ~BIT5; //rst
	P3OUT |= BIT5;
	P6OUT &= ~BIT5; // /CS1, A0 = 0
	P6OUT &= ~BIT4;
	dogmCMDWrite(0x40); //diplay start line 0
	dogmCMDWrite(0xA1); //ADC reverse
	dogmCMDWrite(0xC0); //normal com0 - com31
	dogmCMDWrite(0xA6); //display normal
	dogmCMDWrite(0xA2); //set bias 1/9 (duty 1/33)
	dogmCMDWrite(0x2F); //booster, regulator, follower on
	dogmCMDWrite(0xF8); //set booster to 3x/4x
	dogmCMDWrite(0x00); //set booster to 3x/4x
	dogmCMDWrite(0x27); //contrast set
	dogmCMDWrite(0x81); //contrast set
	dogmCMDWrite(0x0F); //contrast set
	dogmCMDWrite(0xAD); //no indicator
	dogmCMDWrite(0x00); //no indicator
	dogmCMDWrite(0xAF); //display on
	dogmCMDWrite(0xB0); //page 0 locn set
	dogmCMDWrite(0x10); //hi nibble addr
	dogmCMDWrite(0x00); //low byte addr
	dogmCMDWrite(0xA4); //all on

	P6OUT |= BIT5 | BIT4;   // /CS1, A0 = 1
	int volatile i = 0;
	for(i; i< 0xFF; i++){
		dogmDataWrite(i); //all on
	}
	//dogmDataWrite(0xA4); //all on
}

/*
 * Written by: Garrett Smith
 * University of Florida: ECE Design II
 * Fall 2015
 */

#include <msp430f235.h>
#include <stdint.h>
#include <math.h>
#define MAIN_FILE
#include "globals.h"
#include "initialization.h"
#include "eadogm132.h"

void calculateWaveOffset() {
	int volatile xCoord = ADCValue1 / 455;
	int volatile yCoord = ADCValue2 / 455;
	int volatile zCoord = ADCValue3 / 455;
	int32_t volatile index = LUTArray[xCoord][yCoord][zCoord];

	waveOffset1 = index;
	waveOffset2 = index >> 8;
	waveOffset3 = index >> 16;
	angleOfDeclination = index >> 24;
	angleOfAttack = LUTAngleArray[xCoord][yCoord][zCoord];
}

/*
 * This ISR writes to the DACs on timer A interrupt.
 */
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A(void) {
	if (counter == WAVE_ARRAY_END_INDEX) {
		counter = WAVE_ARRAY_START_INDEX;
	}
	unsigned int volatile wOff1 = counter + waveOffset1;
	unsigned int volatile wOff2 = counter + waveOffset2;
	unsigned int volatile wOff3 = counter + waveOffset3;
	P6OUT &= ~(BIT5 | BIT4);         //a0 a1 = 0
	P3OUT &= ~BIT7;                  //write active low
	//data
	P4OUT = waveArray[counter];
	P5OUT = waveArray[counter] >> 8;
	P1OUT = waveArray[wOff1];
	P2OUT = waveArray[wOff1] >> 8;
	P6OUT |= (BIT5 | BIT4);          //a0 a1 = 1
	//data
	P4OUT = waveArray[wOff2];
	P5OUT = waveArray[wOff2] >> 8;
	P1OUT = waveArray[wOff3];
	P2OUT = waveArray[wOff3] >> 8;
	P3OUT |= BIT7 + BIT6;            //wr & ldac high
	P3OUT &= ~BIT6;                  //ldac low
	counter++;
}

#pragma vector=TIMER0_B0_VECTOR
__interrupt void Timer_B(void) {
	//turn timers off
	CCTL0 &= ~CCIE;
	TBCCTL0 &= ~CCIE;
	if (TBCCR0 == WAVE_OFF_TIME) {
		TBCCR0 = WAVE_ON_TIME;
		counter = WAVE_ARRAY_START_INDEX; //reset wave
		ADC12CTL0 |= ~ENC;                //disable conv
		ADC12CTL0 |= ~ADC12SC;            //stop conv
		CCTL0 |= CCIE;                    //enable timerA
		TBCCTL0 |= CCIE;                  //enable timerB
	} else {
		TBCCR0 = WAVE_OFF_TIME;
		ADC12CTL0 |= ENC;                 //enable conv
		ADC12CTL0 |= ADC12SC;             //start convn
		P3OUT &= ~BIT5;                   // DAC rst low
		P3OUT |= BIT5;                    // DAC rst high
		TBCCTL0 |= CCIE;                  //enable timerB
	}
}

#pragma vector=ADC12_VECTOR
__interrupt void ADC12ISR(void) {
	ADCValue1 = ADC12MEM0; // Move A0 results, IFG is cleared
	ADCValue2 = ADC12MEM1; // Move A1 results, IFG is cleared
	ADCValue3 = ADC12MEM2; // Move A2 results, IFG is cleared
	ADCValue4 = ADC12MEM3;
	ADC12CTL0 &= ~ENC;     //disable conv
	ADC12CTL0 &= ~ADC12SC; //stop convn
	calculateWaveOffset();
	//output to lcd
	//read from spi
}

#pragma vector=USCIAB0RX_VECTOR
__interrupt void USCIA0RX_ISR(void) {
	static int MST_Data = 0xAA;

	while (!(IFG2 & UCB0TXIFG)) {
	};              // USCI_B0 TX buffer ready?

}

int main(void) {
	WDTCTL = WDTPW | WDTHOLD; //stop watchdog timer

	configSysClk();
	//configDAC();
	//configADC();
	configSPI();
	dogmConfig();
	//configPulseOutTimer();
	//configWaitTimer();

	__bis_SR_register(GIE);   //interrupt

	while (1) {

	}

	return 0;
}

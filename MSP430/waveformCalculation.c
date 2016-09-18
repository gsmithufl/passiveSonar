/*
 * Written by: Garrett Smith
 * University of Florida: ECE Design II
 * Fall 2015
 */

#include <math.h>
#include <stdlib.h>
#include "globals.h"

#define PI 3.14159
#define SPEED_SOUND 1482
#define HYDROPHONE_SPACING 0.28 //around max for 25 seg resolution //0.0254 - 25k
#define FREQUENCY 5800

void calculateWavePhases(void);
void xyzFromADC(float *p_x, float *p_y, float *p_z);
float arrivalAngle(float *p_x, float *p_z);
float declinationAngle(float *p_y, float *p_z);
void calculateVectorProjections(float *p_aoa, float *p_ada, float *p_x,
		float *p_y, float *p_z, float *p_H1Y, float *p_H1Z, float *p_H2Z,
		float *p_H3X);
float vectorMag(float *p_a, float *p_b, float *p_c);
float absDistToHydrophone(float *p_a, float *p_b);
void determineLagLead(float *p_x, float *p_y, float *p_z, float *p_h1_d,
		float *p_h2_d, float *p_h3_d);
float differenceAngle(float *p_a);

void calculateWavePhases(void) {
	float *p_x = malloc(sizeof(*p_x)); //
	float *p_y = malloc(sizeof(*p_y)); //
	float *p_z = malloc(sizeof(*p_z)); //
	float *p_aoa = malloc(sizeof(*p_aoa)); //
	float *p_ada = malloc(sizeof(*p_ada)); //
	float *p_H1Y = malloc(sizeof(*p_H1Y)); //
	float *p_H1Z = malloc(sizeof(*p_H1Z)); //
	float *p_H2Z = malloc(sizeof(*p_H2Z)); //
	float *p_H3X = malloc(sizeof(*p_H3X)); //
	xyzFromADC(p_x, p_y, p_z);
	*p_aoa = arrivalAngle(p_x, p_z);
	*p_ada = declinationAngle(p_y, p_z);
	calculateVectorProjections(p_aoa, p_ada, p_x, p_y, p_z, p_H1Y, p_H1Z, p_H2Z,
			p_H3X);
	free(p_aoa);
	free(p_ada);
	float *p_mag_h0 = malloc(sizeof(*p_mag_h0));
	*p_mag_h0 = vectorMag(p_x, p_y, p_z);
	float *p_mag_h1 = malloc(sizeof(*p_mag_h1));
	*p_mag_h1 = vectorMag(p_x, p_H1Y, p_H1Z);
	float *p_mag_h2 = malloc(sizeof(*p_mag_h2));
	*p_mag_h2 = vectorMag(p_x, p_y, p_H2Z);
	float *p_mag_h3 = malloc(sizeof(*p_mag_h3));
	*p_mag_h3 = vectorMag(p_H3X, p_y, p_z);
	free(p_H1Y);
	free(p_H1Z);
	free(p_H2Z);
	free(p_H3X);
	float h1_d = absDistToHydrophone(p_mag_h0, p_mag_h1);
	float h2_d = absDistToHydrophone(p_mag_h0, p_mag_h2);
	float h3_d = absDistToHydrophone(p_mag_h0, p_mag_h3);
	free(p_mag_h0);
	free(p_mag_h1);
	free(p_mag_h2);
	free(p_mag_h3);
	determineLagLead(p_x, p_y, p_z, &h1_d, &h2_d, &h3_d);
	free(p_x);
	free(p_y);
	free(p_z);
	waveOffset1 = differenceAngle(&h1_d);
	waveOffset2 = differenceAngle(&h2_d);
	waveOffset3 = differenceAngle(&h3_d);
}

void xyzFromADC(float *p_x, float *p_y, float *p_z) {
	*p_x = (ADCValue1 - 2048) / 100;
	*p_z = (ADCValue2 - 2048) / 100;
	*p_y = (ADCValue3 - 2048) / 100;
}

float arrivalAngle(float *p_x, float *p_z) {
	float num1 = *p_x * *p_x;
	float num2 = *p_z * *p_z;
	float num3 = num1 + num2;
	float sqrtXSqPlusZSq = sqrtf(num3);
	float arcCosAns = acosf(*p_x / sqrtXSqPlusZSq);
	if (arcCosAns < 0) {
		arcCosAns = -arcCosAns;
	}
	float aoa = 0.5 * PI - arcCosAns;
	if (aoa < 0) {
		aoa = -aoa;
	}
	if (*p_x > 0 && *p_z < 0)     //4th quadrant
		aoa = aoa + (1.5 * PI);
	else if (*p_x < 0 && *p_z < 0) //3rd quadrant
		aoa = aoa + PI;
	else if (*p_x < 0 && *p_z > 0) //2nd quadrant
		aoa = aoa + (0.5 * PI);
	else
		aoa = aoa;
	return aoa;
}

float declinationAngle(float *p_y, float *p_z) {
	float sqrtYSqPlusZSq = sqrtf(*p_y * *p_y + *p_z * *p_z);
	float arcCosAns = acosf(*p_y / sqrtYSqPlusZSq);
	if (arcCosAns < 0) {
		arcCosAns = -arcCosAns;
	}
	float ada = 0.5 * PI - arcCosAns;
	if (ada < 0) {
		ada = -ada;
	}
	if (*p_y < 0) {
		ada = -ada;
	}
	return ada;
}

void calculateVectorProjections(float *p_aoa, float *p_ada, float *p_x,
		float *p_y, float *p_z, float *p_H1Y, float *p_H1Z, float *p_H2Z,
		float *p_H3X) {
	float spCC = HYDROPHONE_SPACING * cosf(*p_aoa) * cosf(*p_ada);
	if (*p_x < 0) {
		*p_H3X = *p_x - spCC;
	} else if (*p_x > 0) {
		*p_H3X = *p_x + spCC;
	} else {
		*p_H3X = *p_x;
	}
	if (*p_y < 0) {
		*p_H1Y = *p_y - spCC;
	} else if (*p_y > 0) {
		*p_H1Y = *p_y + spCC;
	} else {
		*p_H1Y = *p_y;
	}
	if (*p_z < 0) {
		*p_H1Z = *p_z + spCC;
		*p_H2Z = *p_z - spCC;
	} else if (*p_z > 0) {
		*p_H1Z = *p_z - spCC;
		*p_H2Z = *p_z + spCC;
	} else {
		*p_H1Z = *p_z;
		*p_H2Z = *p_z;
	}
}

float vectorMag(float *p_a, float *p_b, float *p_c) {
	return sqrtf(*p_a * *p_a + *p_b * *p_b + *p_c * *p_c);
}

float absDistToHydrophone(float *p_a, float *p_b) {
	float volatile num = *p_a - *p_b;
	if (num < 0) {
		num = -num;
	} else {
		num = num;
	}
	return num;
}

void determineLagLead(float *p_x, float *p_y, float *p_z, float *p_h1_d,
		float *p_h2_d, float *p_h3_d) {
	if (*p_y > 0) {
		*p_h1_d = -*p_h1_d;
	}
	if (*p_x > 0 && *p_z < 0) { //quadrant 4
		*p_h3_d = -*p_h3_d;
	} else if (*p_x <= 0 && *p_z < 0) { //quadrant 3

	} else if (*p_x <= 0 && *p_z > 0) { //quadrant 2
		*p_h2_d = -*p_h2_d;
	} else if (*p_x > 0 && *p_z > 0) { //quadrant 1
		*p_h3_d = -*p_h3_d;
		*p_h2_d = -*p_h2_d;
	}
}

float differenceAngle(float *p_a) {
	volatile float num = 360.00 * FREQUENCY * *p_a;
	return num / SPEED_SOUND;
}

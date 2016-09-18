/*
 * Written by: Garrett Smith
 * University of Florida: ECE Design II
 * Fall 2015
 */

#ifndef WAVEFORMCALCULATION_H_
#define WAVEFORMCALCULATION_H_

void calculateWavePhases(void);
void xyzFromADC(float *p_x, float *p_y, float *p_z);
float arrivalAngle(float *p_x, float *p_z);
float declinationAngle(float *p_y, float *p_z);
void calculateVectorProjections(float *p_aoa, float *p_ada, float *p_x,
		float *p_y, float *p_z, float *p_H1Y, float *p_H1Z, float *p_H2Z,
		float *p_H3X);
float vectorMag(float *p_a, float *p_b, float *p_c);
float absDistToHydrophone(float *p_a, float *p_b);
void determineLagLead(float *p_x, float *p_y, float *p_z, float *p_h1_d, float *p_h2_d,
		float *p_h3_d);
float differenceAngle(float *p_a);

#endif /* WAVEFORMCALCULATION_H_ */

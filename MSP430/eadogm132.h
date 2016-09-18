/*
 * eadogm132.h
 *
 *  Created on: Nov 23, 2015
 *      Author: Garrett
 */

#ifndef EADOGM132_H_
#define EADOGM132_H_

void spiWrite(int volatile p_data);
void dogmCMDWrite(int volatile p_data);
void dogmDataWrite(int volatile p_data);
void dogmConfig(void);

#endif /* EADOGM132_H_ */

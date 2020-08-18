/*
 * sim808.h
 * A library for DFRobot's SIM808 GPS/GPRS/GSM Shield
 *
 * @copyright	[DFRobot](http://www.dfrobot.com), 2016
 *
 * @author [Jason](jason.ling@dfrobot.com)
 * @version  V1.0
 * @date  2016-09-23
 
 * The MIT License (MIT)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef __SIM808_H__
#define __SIM808_H__

#include <Arduino.h>
#include <SoftwareSerial.h>

#define DEFAULT_TIMEOUT     		 5   //seconds
#define DEFAULT_INTERCHAR_TIMEOUT 1500   //miliseconds

enum DataType {
    CMD     = 0,
    DATA    = 1,
};
void  sim808_init(void * uart_device, char num );
//void  sim808_init(void * uart_device, uint32_t baud);
int   sim808_check_readable();
int   sim808_wait_readable(int wait_time);
void  sim808_flush_serial();
void  sim808_read_buffer(char* buffer,int count,  unsigned int timeout = DEFAULT_TIMEOUT, unsigned int chartimeout = DEFAULT_INTERCHAR_TIMEOUT);
void  sim808_clean_buffer(char* buffer, int count);
void  sim808_send_byte(uint8_t data);
void  sim808_send_char(const char c);
void  sim808_send_cmd(const char* cmd);
void  sim808_send_cmd(const __FlashStringHelper* cmd);
void  sim808_send_cmd_P(const char* cmd);
boolean  sim808_send_AT(void);
void  	  sim808_send_End_Mark(void);
boolean  sim808_wait_for_resp(const char* resp, DataType type, unsigned int timeout = DEFAULT_TIMEOUT, unsigned int chartimeout = DEFAULT_INTERCHAR_TIMEOUT);
boolean  sim808_check_with_cmd(const char* cmd, const char *resp, DataType type, unsigned int timeout = DEFAULT_TIMEOUT, unsigned int chartimeout = DEFAULT_INTERCHAR_TIMEOUT*5);
boolean  sim808_check_with_cmd(const __FlashStringHelper* cmd, const char *resp, DataType type, unsigned int timeout = DEFAULT_TIMEOUT, unsigned int chartimeout = DEFAULT_INTERCHAR_TIMEOUT);

#endif

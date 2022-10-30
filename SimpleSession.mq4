//+------------------------------------------------------------------+
//|                                                SimpleSession.mq4 |
//|                                     Copyright 2022, Ahmad Thahir |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Ahmad Thahir"
#property link      "https://www.mql5.com"
#property version   "0.0.1"
string v="0.0.1";
#property strict

/**
* Input Parameter
*/

extern bool Open_Sell=true;
extern bool Open_Buy=true;
extern bool do_monitoring=true;
extern bool auto_restart=false;

//CHECK TIME SESSION
extern int hour_session_start=0;
extern int hour_session_end=0;



/**
 * Return true if there is an order opened
 *
 * 
 */
bool isPositionOpened() {
   bool result=true;
   //select order only from the same day
   
   //return true if there is an order opened
   return result;
}

/**
 * Get highest value from session
 */
int getHighest () {
   int result=0;
   //Code to return highest price 
   return result;
}

/**
 * Get lowest value from session
 */
int getLowest () {
   int result=0;
   //Code to return lowest price
   return result;
}

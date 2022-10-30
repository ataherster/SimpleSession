//+------------------------------------------------------------------+
//|                                                SimpleSession.mq4 |
//|                                     Copyright 2022, Ahmad Thahir |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Ahmad Thahir"
#property link      "https://www.mql5.com"
#property version   "1.0"
string v="1.0";
#property strict

/**
* Input Parameter
*/
extern double lot_size=0.01;
extern bool Open_Sell=true;
extern bool Open_Buy=true;
extern bool do_monitoring=true;
extern bool auto_restart=false;

//CHECK TIME SESSION
extern int hour_session_start=0;
extern int hour_session_end=0;

int      calp;
double   pt;
double   minlot;
double   stoplevel;
int      prec=0;

/**
 * The Init event is generated immediately after an Expert Advisor or an indicator is downloaded; The OnInit() function is used for initialization. 
 * If OnInit() has the int type of the return value, the non-zero return code means unsuccessful initialization, 
 * and it generates the Deinit event with the code of deinitialization reason REASON_INITFAILED.
 * OnInit() function execution result is analyzed by the terminal's runtime subsystem only if the program has been compiled using #property strict.
 * To optimize input parameters of an Expert Advisor, it is recommended to use values of the ENUM_INIT_RETCODE enumeration as the return code.. 
 * During initialization of an Expert Advisor before the start of testing you can request information about the configuration and resources using the 
 * TerminalInfoInteger() function.
 */

int OnInit() {

   if(Digits==3 || Digits==5) {
      pt=10*Point;
      calp=10000;
   } else {
      pt=Point;
   }
      
   minlot = MarketInfo(Symbol(),MODE_MINLOT);
   stoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(lot_size<minlot) Print("lotsize is to small.");
   if(minlot==0.01) prec=2;
   if(minlot==0.1)  prec=1;
   
   //start handle EventSetTimer(1)
   int count=0;
   bool timerset=false;      
   while(!timerset && count<5) {
      timerset=EventSetTimer(1);
      if(!timerset){
         printf("Cannot set timer, error %s. Set trying %d...",(string)_LastError,count);
         EventKillTimer();
         Sleep(200);
         timerset=EventSetTimer(1);
         count++;
      }   
   }
   if(!timerset){
      Alert("Cannot set timer");
      return INIT_FAILED;
   } else {
      printf("%s success on setting timer.",Symbol());
   }
   //end handle EventSetTimer(1)
   
   return(0);
}
  
/**
 * The OnDeinit() function is called during deinitialization and is the Deinit event handler. It must be declared as the void type and should have one parameter 
 * of the const int type, which contains the code of deinitialization reason. If a different type is declared, the compiler will generate a warning, 
 * but the function will not be called.
 */
void OnDeinit (const int reason) {
   EventKillTimer();
   
}  

void OnTick () {
   if (IsTesting()) {
      OnTimer();
   }
}

void OnTimer() {
   RunRobot();
}
      
void RunRobot() {
   //
}


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

//+------------------------------------------------------------------+
//|                                                SimpleSession.mq4 |
//|                                     Copyright 2022, Ahmad Thahir |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property   copyright "Copyright 2022, Ahmad Thahir"
#property   link      "https://www.mql5.com"
#property   version   "1.0"
string      v="1.0";
#property   strict

/**
* Input Parameter
*/
extern string     GENERAL="#######################";
extern double     lot_size=0.01;
extern bool       Open_Sell=true;
extern bool       Open_Buy=true;
extern int        max_spread=40;
extern bool       do_monitoring=true;
extern bool       terminal_close_on_rto=false;

//CHECK TIME SESSION
extern int        hour_session_start=0;
extern int        hour_session_end=0;

extern string     ETC="#######################";
extern int        rto_close_delay=20;

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

   datetime gmtTime = TimeGMT();
   datetime localTime = TimeLocal();
   datetime serverTime = TimeCurrent();
   int      gapTime = gmtTime - serverTime;
   int      localHour = TimeHour(localTime); 
   int      localMinute = TimeMinute(localTime);
   int      localSecond = TimeSeconds(localTime);
   int      serverMinute = Minute();
   int      serverSecond = Seconds();
   double   spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   Comment (
      "+++++++++++++++++++++++++++"
      + "\nVersion  : " + v
      + "\nLot Size : " + DoubleToString(lot_size,2)
      + "\n+++++++++++++++++++++++++++"
   );
   
   if (closeOnRTO(isRtoReminded(gmtTime, serverTime, localTime))) return;
   holidayReminded=isHoliday(gmtTime);
   if (holidayReminded) return; 
   if (spread>max_spread) return;
   if ((gmtTime - serverTime)>60) return;
   
   /*
   {
      check time to start trading
   }
   */
   
   
   
}

/**
 * return true when it's a holiday and send notification
 */
bool holidayReminded=false;
bool isHoliday (datetime t) {
   string msg="";
   if (((TimeDayOfWeek(t)==5 && (TimeHour(t)>20 && TimeHour(t)<=23)) ||
         (TimeDayOfWeek(t)==6) ||
         (TimeDayOfWeek(t)==0 && TimeHour(t)<=22))) {
      if (!holidayReminded) {
         msg="Liburan bosss....";
         Print(msg);
         SendNotification(msg);
         return true;
      }
   }
   return false;
}

/**
 * return true
 */
bool rtoReminded=false;
bool conReminded=false;
bool isRtoReminded (datetime gt, datetime st, datetime lt) {
   int gaptime = (gt - st);
   string msg="";
   int max_gap_time;
   if (TimeHour(gt)>=20 && TimeHour(gt)<=23) {
      max_gap_time=300;
   } else {
      max_gap_time=100;
   }
   if (gaptime>=max_gap_time && !rtoReminded) {
      msg="WARNING!! max_gap_time : " + IntegerToString(max_gap_time) + ", now is : " + IntegerToString(lt) + " , close terminal in " + IntegerToString(restartIn) + " detik";
      Print(msg);
      SendNotification(msg);
      rtoReminded=true;
      conReminded=false;
      return true;
   } else if (gaptime<max_gap_time && !conReminded) {
      msg= "V:" + v + ", tick tock.., last tick : " + IntegerToString(st);
      Print(msg);
      SendNotification(msg);
      conReminded=true;
      rtoReminded=false;
   }
   return false;
}

/**
 * Close terminal when there's no ticks in 
 */
int restartIn=rto_close_delay;
bool closeOnRTO (bool rto_reminded) {
   if (rto_reminded) {
      restartIn--;
      if (restartIn==0) {
         if (terminal_close_on_rto) TerminalClose(100);
      }
      return true;
   }
   
   restartIn=rto_close_delay;
   return false;
}

/**
 * Return true if there is an order opened
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

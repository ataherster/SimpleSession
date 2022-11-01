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
extern bool       OPM15=true;
extern bool       OPM30=true;
extern bool       OPM60=true;
extern int        max_spread=40;
extern bool       do_monitoring=true;

extern string     SL_TP_ORDER_PROPS="#######################";
extern bool       open_sl_tp_order=true;

extern string     HOUR_SETTINGS="#######################";
extern int        hour_session_start=0;
extern int        hour_session_end=7;
extern int        hour_start_trading=8;
extern int        hour_end_trading=0;

extern string     ETC="#######################";
extern int        rto_close_delay=20;
extern bool       terminal_close_on_rto=false;

int      calp;
double   pt;
double   minlot;
double   stoplevel;
int      prec=0;

int orderType=-1;

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
   if (!IsTesting()) {
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
   }  else {
      timerset=true;
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
      
int runningLocalSecond=0;
void RunRobot() {

   datetime gmtTime = TimeGMT();
   datetime localTime = TimeLocal(); //Please ensure the Operating System (Windows or Linux) to use GMT Time
   datetime serverTime = TimeCurrent();
   int      gapTime = gmtTime - serverTime;
   int      localHour = TimeHour(localTime); 
   int      localMinute = TimeMinute(localTime);
   int      localSecond = TimeSeconds(localTime);
   int      serverMinute = Minute();
   int      serverSecond = Seconds();
   double   spread = MarketInfo(Symbol(), MODE_SPREAD);
   bool     orderOpenedTheSameDateExist=NULL;
   
   Comment (
      "+++++++++++++++++++++++++++"
      + "\nVersion  : Simple Session " + v
      + "\nLot Size : " + DoubleToString(lot_size,2)
      + "\n+++++++++++++++++++++++++++" 
      + "\nH Price : " + highestPrice
      + "\nL Price : " + lowestPrice
      + "\nOrder Type " + orderType
      + "\nLocal Minute : " + localMinute + ":" + localSecond + " RUnning : " + runningLocalSecond
   );
   
   if (localSecond<2) {
      orderOpened[PERIOD_M15]=false;
      orderOpened[PERIOD_M30]=false;
      orderOpened[PERIOD_H1]=false;
   }
   
   if (isHoliday(localTime)) {
      if (!holidayReminded) {
         string msg="";
         msg="Liburan bosss....";
         Print(msg);
         SendNotification(msg);
         holidayReminded=true;
      }
      return;
   }
   holidayReminded=false;
   
   if (hour_start_trading>0 && localHour<hour_start_trading) return;
   if (hour_end_trading>0 && localHour>hour_end_trading) return;
 
   //if (closeOnRTO(isRtoReminded(gmtTime, serverTime, localTime))) return;
   if (spread>max_spread) return;
   if (gapTime>60) return;
   
   
   
   if ((localMinute==13 || localMinute==28 || localMinute==43 || localMinute==58)) {
      if (localSecond<2) {
         if (orderOpenedTheSameDateExist) orderOpenedTheSameDateExist=NULL;
         if (highestPrice!=0) highestPrice=0;
         if (lowestPrice!=0) lowestPrice=0;
         if (orderType!=-1) orderType=-1;
      } else if (localSecond>=2) {
         if (orderOpenedTheSameDateExist==NULL) orderOpenedTheSameDateExist=isOrderOpenedTheSameDateExist(localTime);
         if (highestPrice==0 || lowestPrice==0) setHighestAndLowest(localTime, hour_session_start, hour_session_end, highestPrice, lowestPrice);
         if (orderOpenedTheSameDateExist) return;
         if (orderType==-1) orderType = getExecutionRecomentation(highestPrice, lowestPrice);
         if (orderType==-1) return;
      } 
   }
   
   runningLocalSecond = (IsTesting()) ? 38 : 55 ;
   if (localMinute==14 || localMinute==44) Print ("sama ini bos "); //#########################################################################################
   if (((localMinute==14 || localMinute==44) && localSecond>=runningLocalSecond)) {
      Print ("orderan boss");
      if (!orderOpened[PERIOD_M15] && OPM15) orderOpened[PERIOD_M15]=openPosition(orderType, PERIOD_M15);
   }
   if ((localMinute==29 && localSecond>=runningLocalSecond)) {
      if (!orderOpened[PERIOD_M30] && OPM30) orderOpened[PERIOD_M30]=openPosition(orderType, PERIOD_M30);
      if (!orderOpened[PERIOD_M30]) {
         if (!orderOpened[PERIOD_M15] && OPM15) orderOpened[PERIOD_M15]=openPosition(orderType, PERIOD_M15);
      }                                                    
      
   }
   if ((localMinute==59 && localSecond>=runningLocalSecond)) {
      if (!orderOpened[PERIOD_H1] && OPM60) orderOpened[PERIOD_H1]=openPosition(orderType, PERIOD_H1);
      
      if (!orderOpened[PERIOD_H1]) {
         if (!orderOpened[PERIOD_M30] && OPM30) orderOpened[PERIOD_M30]=openPosition(orderType, PERIOD_M30);
         
         if (!orderOpened[PERIOD_M15]) {
            if (!orderOpened[PERIOD_M15] && OPM15) orderOpened[PERIOD_M15]=openPosition(orderType, PERIOD_M15);
         }
         
      }
   }
   
}

/**
 * Return true, when the execution of order is success
 */
int orderOpened[61]; //[15] for PERIOD_M15 ; [30] for PERIOD_M30 ; [60] for PERIOD_H1 ;
int SL_TP_ORDER=1; 
bool openPosition(int orderType, int TimeFrame) {
   bool result=false;
   
   //test open order;
   Print("Open : " + orderType + ", TimeFrame : " + TimeFrame);
   
   return result;
}

/**
 * Return Order Properties :
 * -1           No Recomendation
 *  0 OP_BUY    Buy operation
 *  1 OP_SELL   Sell operation
 */
int getExecutionRecomentation (double highest, double lowest) {
   int result=-1;
   double close=iClose(NULL, PERIOD_M15, 0);
   if (close>highest) {
      return OP_BUY;
   } else if (close<lowest) {
      return OP_SELL;
   }
   return result;
}

/**
 * return true when it's a holiday and send notification
 */
bool holidayReminded=false;
bool isHoliday (datetime t) {
   if (((TimeDayOfWeek(t)==5 && (TimeHour(t)>20 && TimeHour(t)<=23)) ||
         (TimeDayOfWeek(t)==6) ||
         (TimeDayOfWeek(t)==0 && TimeHour(t)<=22))) {
         return true;
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
      msg="WARNING!! max_gap_time : " + IntegerToString(max_gap_time) + ", now is : " + IntegerToString(lt) + " , close terminal in " + IntegerToString(closeIn) + " detik";
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
int closeIn=rto_close_delay;
bool closeOnRTO (bool rto_reminded) {
   if (rto_reminded) {
      closeIn--;
      if (closeIn==0) {
         if (terminal_close_on_rto) TerminalClose(100);
      }
      return true;
   }
   
   closeIn=rto_close_delay;
   return false;
}

/**
 * Return true if there is an active order
 */
//@Deprecated
bool isActiveOrderExist() {
   bool result=false;
   //select order only from the same day
   
   //return true if there is an order opened
   return result;
}

/**
 * Return true if there is an opened order in hisory in the same date
 */
bool isOrderOpenedTheSameDateExist (datetime Today) {
   bool result=false;
   
   //Check open - opened order that it's in the same date
   for (int i=0; i<OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber()==0)continue;
      string nowDate    =TimeToString(Today, TIME_DATE);
      string orderDate  =TimeToString(OrderOpenTime(), TIME_DATE);
      if (nowDate==orderDate) return true;
   }
   
   //Check closed order that it's in the same date
   for (int i=0; i<OrdersHistoryTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber()==0)continue;
      string nowDate    =TimeToString(Today, TIME_DATE);
      string orderDate  =TimeToString(OrderOpenTime(), TIME_DATE);
      if (nowDate==orderDate) return true;
   }
   
   return result;
}

/**
 * Set the highest and lowest value to the input parameters
 */
double highestPrice=0;
double lowestPrice=0;
void setHighestAndLowest (datetime today, int startSessionHour, int endSessionHour, double &highest, double &lowest) {
   datetime todayStartSession =  StrToTime(IntegerToString(TimeYear(today)) + "." + IntegerToString(TimeMonth(today)) + 
                                 "." + IntegerToString(TimeDay(today)) + " " + IntegerToString(startSessionHour) + ":00");
   datetime todayEndSession   =  StrToTime(IntegerToString(TimeYear(today)) + "." + IntegerToString(TimeMonth(today)) + "." + 
                                 IntegerToString(TimeDay(today)) + " " + IntegerToString(endSessionHour) + ":00");
   
   int      startShift=iBarShift(NULL,PERIOD_H1,todayStartSession);
   int      endShift=iBarShift(NULL,PERIOD_H1,todayEndSession);
   int      highestIndex=iHighest(NULL,PERIOD_H1,MODE_HIGH,startShift-endShift,endShift);
   int      lowestIndex=iLowest(NULL,PERIOD_H1,MODE_LOW,startShift-endShift,endShift);
   
   if (highestIndex!=-1) highest=iHigh(NULL, PERIOD_H1, highestIndex);
   if (lowestIndex!=-1) lowest=iLow(NULL, PERIOD_H1, lowestIndex);
}

/**
 * Get highest value from session
 */
//@Deprecated
int getHighest (int startHour, int endHour) {
   int result=0;
   //Code to return highest price 
   return result;
}

/**
 * Get lowest value from session
 */
//@Deprecated
int getLowest (int startHour, int endHour) {
   int result=0;
   //Code to return lowest price
   return result;
}

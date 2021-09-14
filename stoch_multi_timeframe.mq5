//+------------------------------------------------------------------+
//|                                                      MyStoch.mq5 |
//|                                           Copyright 2021, phanet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, phanet"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   string signal="";

//arry for k-line and d-line
   double KArray[];
   double DArray[];

//sort the array from the current candle downwards
   ArraySetAsSeries(KArray,true);
   ArraySetAsSeries(DArray,true);

//defind EZ, current candle, 3 candles, save result
   int StochasticDefinition=iStochastic(_Symbol,PERIOD_CURRENT,8,3,3,MODE_SMA,STO_LOWHIGH);

//fill the array with price data
   CopyBuffer(StochasticDefinition,0,0,3,KArray);
   CopyBuffer(StochasticDefinition,1,0,3,DArray);

//calculate value for current candle
   double KValue0=KArray[0];
   double DValue0=DArray[0];

//calculate the value for the last candle
   double KValue1=KArray[1];
   double DValue1=DArray[1];

//buy signal

//if the K value has crossed the D value from below
   if((KValue0 > DValue0) && (KValue1<DValue1))
     {

      //if has position with current currency than close position


      //if both values are below 20
      if(KValue0 < 20 && DValue0 < 20)
        {
         signal="buy";
        }

     }

// if the k-value has crossed the d-value from above
   if((KValue0<DValue0) && (KValue1>DValue1))
     {
     
     //if has position with curent currency than close position
     
     
     
      //if both values are above 80
      if(KValue0>80 && DValue0>80)
        {
        signal="sell";
        }
     }
     
     

  }
//+------------------------------------------------------------------+


string CheckSignal(){


}
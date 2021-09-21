//+------------------------------------------------------------------+
//|                                                      MyStoch.mq5 |
//|                                           Copyright 2021, phanet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, phanet"
#property link "https://www.mql5.com"
#property version "1.00"

#include <Trade\Trade.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---

  //---
  return (INIT_SUCCEEDED);
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

  Comment("M5 : " + CheckSignal(PERIOD_M5) + "\n" +
          "M15 : " + CheckSignal(PERIOD_M15) + "\n");

  //get signal by specific timeframe
  string M5 = CheckSignal(PERIOD_M5);
  string M15 = CheckSignal(PERIOD_M15);

  //check for close
  Close(M5); // change from hard code to select on UI

  //check for buy/sell
  BuySell(M5, M15);

  //update the strategy of those are complete and working fine with it
  //next strategy we apply Moving Average (MA)
  //next strategy we apply RSI
}

//method to return the signal by specific timeframe
string CheckSignal(ENUM_TIMEFRAMES timeframe)
{

  string signal = "";

  //arry for k-line and d-line
  double KArray[];
  double DArray[];

  //sort the array from the current candle downwards
  ArraySetAsSeries(KArray, true);
  ArraySetAsSeries(DArray, true);

  //defind EZ, current candle, 3 candles, save result
  int StochasticDefinition = iStochastic(_Symbol, timeframe, 8, 3, 3, MODE_SMA, STO_LOWHIGH);

  //fill the array with price data
  CopyBuffer(StochasticDefinition, 0, 0, 3, KArray);
  CopyBuffer(StochasticDefinition, 1, 0, 3, DArray);

  //calculate value for current candle
  double KValue0 = KArray[0];
  double DValue0 = DArray[0];

  //calculate the value for the last candle
  double KValue1 = KArray[1];
  double DValue1 = DArray[1];

  //buy signal

  //if the K value has crossed the D value from below
  if ((KValue0 > DValue0) && (KValue1 < DValue1))
  {

    //if has position with current currency than close position

    //if both values are below 20
    if (KValue0 < 20 && DValue0 < 20)
    {
      signal = "buy";
    }
  }

  // if the k-value has crossed the d-value from above
  if ((KValue0 < DValue0) && (KValue1 > DValue1))
  {

    //if has position with curent currency than close position

    //if both values are above 80
    if (KValue0 > 80 && DValue0 > 80)
    {
      signal = "sell";
    }
  }

  return signal;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySell(string M5, string M15)
{
  //trade.PositionClose(_Symbol);

  double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
  double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

  //check for buy
  if (M5 == "buy" && M15 == "buy")
  {
    //if there is no position of current currency
    bool hasPositioned = false;
    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol)
      {
        hasPositioned = true;
        break;
      }
    }

    if (!hasPositioned)
    {
      trade.Buy(0.01, _Symbol, Ask, 0, 0, NULL);
    }
  }
  else

      //check for sale
      if (M5 == "sale" && M15 == "sale")
  {
    //if there is no position of current currency
    bool hasPositioned = false;
    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol)
      {
        hasPositioned = true;
        break;
      }
    }

    if (!hasPositioned)
    {
      trade.Sell(0.01, _Symbol, Bid, 0, 0, NULL);
    }
  }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Close function is used for check condition to close the position |
//+------------------------------------------------------------------+
void Close(string period)
{

  for (int i = 0; i < PositionsTotal(); i++)
  {
    if (PositionGetSymbol(i) == _Symbol)
    {
      if (period == "")
      {
        trade.PositionClose(_Symbol);
      }
      else
      {
        continue;
      }
      ENUM_POSITION_TYPE pType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if (pType == POSITION_TYPE_BUY && period == "sell")
      {
        trade.PositionClose(_Symbol);
      }

      if (pType == POSITION_TYPE_SELL && period == "buy")
      {
        trade.PositionClose(_Symbol);
      }
    }
  }
}
//+------------------------------------------------------------------+

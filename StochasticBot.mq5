//+------------------------------------------------------------------+
//|                                                   Stochastic.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2020, MetaQuotes Software Corp."
#property link "http://www.mql5.com"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
#property indicator_style2 STYLE_DOT
//--- input parameters
input int InpKPeriod = 8; // K period
input int InpDPeriod = 3; // D period
input int InpSlowing = 3; // Slowing
//--- indicator buffers
double ExtMainBuffer[];
double ExtSignalBuffer[];
double ExtHighesBuffer[];
double ExtLowesBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ExtMainBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, ExtSignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ExtHighesBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(3, ExtLowesBuffer, INDICATOR_CALCULATIONS);
    //--- set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, 2);
    //--- set levels
    IndicatorSetInteger(INDICATOR_LEVELS, 2);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 20);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 80);
    //--- set maximum and minimum for subwindow
    IndicatorSetDouble(INDICATOR_MINIMUM, 0);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 100);
    //--- name for DataWindow and indicator subwindow label
    string short_name = StringFormat("Stoch(%d,%d,%d)", InpKPeriod, InpDPeriod, InpSlowing);
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, "Main");
    PlotIndexSetString(1, PLOT_LABEL, "Signal");
    //--- sets first bar from what index will be drawn
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpKPeriod + InpSlowing - 2);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpKPeriod + InpDPeriod);
}
//+------------------------------------------------------------------+
//| Stochastic Oscillator                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    int i, k, start;
    //--- check for bars count
    if (rates_total <= InpKPeriod + InpDPeriod + InpSlowing)
        return (0);
    //---
    start = InpKPeriod - 1;
    if (start + 1 < prev_calculated)
        start = prev_calculated - 2;
    else
    {
        for (i = 0; i < start; i++)
        {
            ExtLowesBuffer[i] = 0.0;
            ExtHighesBuffer[i] = 0.0;
        }
    }

    //--- calculate HighesBuffer[] and ExtHighesBuffer[]
    for (i = start; i < rates_total && !IsStopped(); i++)
    {
        double dmin = 1000000.0;
        double dmax = -1000000.0;
        for (k = i - InpKPeriod + 1; k <= i; k++)
        {
            if (dmin > low[k])
                dmin = low[k];
            if (dmax < high[k])
                dmax = high[k];
        }
        ExtLowesBuffer[i] = dmin;
        ExtHighesBuffer[i] = dmax;
    }

    //--- %K
    start = InpKPeriod - 1 + InpSlowing - 1;
    if (start + 1 < prev_calculated)
        start = prev_calculated - 2;
    else
    {
        for (i = 0; i < start; i++)
            ExtMainBuffer[i] = 0.0;
    }

    //--- main cycle
    for (i = start; i < rates_total && !IsStopped(); i++)
    {
        double sum_low = 0.0;
        double sum_high = 0.0;
        for (k = (i - InpSlowing + 1); k <= i; k++)
        {
            sum_low += (close[k] - ExtLowesBuffer[k]);
            sum_high += (ExtHighesBuffer[k] - ExtLowesBuffer[k]);
        }
        if (sum_high == 0.0)
            ExtMainBuffer[i] = 100.0;
        else
            ExtMainBuffer[i] = sum_low / sum_high * 100;
    }

    //--- signal
    start = InpDPeriod - 1;
    if (start + 1 < prev_calculated)
        start = prev_calculated - 2;
    else
    {
        for (i = 0; i < start; i++)
            ExtSignalBuffer[i] = 0.0;
    }
    for (i = start; i < rates_total && !IsStopped(); i++)
    {
        double sum = 0.0;
        for (k = 0; k < InpDPeriod; k++)
            sum += ExtMainBuffer[i - k];
        ExtSignalBuffer[i] = sum / InpDPeriod;
    }






    //my testing to compare
//    if (ExtMainBuffer[rates_total-1] > ExtSignalBuffer[rates_total-1])
//     {
//         Comment("Buy"+"\n"+"Level : "+ ExtMainBuffer[rates_total-1]);
//     }else
//        {
//         Comment("Sell"+"\n"+"Level : "+ ExtSignalBuffer[rates_total-1]);
//        }
    
    



    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
}
//+------------------------------------------------------------------+

void BuySellAI(double main, double signal)
{
    //check over buy (20) in M5 and signal above main
    //check over buy (20) in M1 and signal above main
    //if current currency have no positioned than place buy 0.01

    //check over sell (80) in M5 and signal below main
    //check over sell (80) in M1 and signal below main
    //if current currency have no positioned than place sell 0.01
}

void StopLossTakeProfitAI()
{
    //if current currency have positioned < 1 than do nothing or not continue
    //if current possitioned is sell and M5 signal below main than close
    //if current possitioned is buy and M5 signal above main than close
}

//  bool UpDown(ENUM_TIMEFRAMES time){
    //true is up
    //false is down

//     return true;
//  }




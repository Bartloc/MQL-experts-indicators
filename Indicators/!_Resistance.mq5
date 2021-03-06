
//------------------------------------------------------------------
#property copyright   "© locurej, 2020"
#property link        "locurej@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   8

#property indicator_label1  "Upper Resistance"
#property indicator_label2  "Lower Resistance"
#property indicator_label3  "Upper"
#property indicator_label4  "Lower"
#property indicator_label5  "Upper Resistance Margin"
#property indicator_label6  "Lower Resistance Margin"
#property indicator_label7  "Upper Resistance Margin"
#property indicator_label8  "Lower Resistance Margin"

#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE

#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Green
#property indicator_color4  clrGold
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  Orange
#property indicator_color7  clrViolet
#property indicator_color8  clrFireBrick


#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID 
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_DASH 
#property indicator_style6 STYLE_DASH
#property indicator_style7 STYLE_DASHDOTDOT 
#property indicator_style8 STYLE_DASHDOTDOT

#include<Helpers\arrows.mqh>

color ShortColor=C'224,185,41';
color LongColor=C'41,224,109';
//
//
//
input int                LongPeriod          = 20;   //Long (Długi trend)
//input int                MediumPeriod        = 20;   //Medium (Średni trend)
input int                ShortPeriod         =  2;   //Short (Krótki trend)
input double             Margin              = 0.01;  //Margines1
//input double             Margin2             = 0.02;  //Margines2
input double             Gravity             = 0.01;  //Gravity (Grawitacja)
//input double             Channel             = 0.2;   //Channel (Kanał)
//input int                Tracker             = 5;    //Traker (Traker)
input bool              ShowSignals     =true; 
//
//
//
double Margin2=Margin/3;
double Channel=0;
int Tracker=0;
int MediumPeriod=(int)LongPeriod/3;

double valmax[],valmin[],valupper[],vallower[],valmaxMargin[],valminMargin[],valmaxMargin2[],valminMargin2[],valSignal[]; 
double oldSignal=0;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,valmax,INDICATOR_DATA);
   SetIndexBuffer(1,valmin,INDICATOR_DATA);
   SetIndexBuffer(2,valupper,INDICATOR_DATA);
   SetIndexBuffer(3,vallower,INDICATOR_DATA);
   SetIndexBuffer(4,valmaxMargin,INDICATOR_DATA);
   SetIndexBuffer(5,valminMargin,INDICATOR_DATA);
   SetIndexBuffer(6,valmaxMargin2,INDICATOR_DATA);
   SetIndexBuffer(7,valminMargin2,INDICATOR_DATA);
   SetIndexBuffer(8,valSignal,INDICATOR_CALCULATIONS);
   
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
  for (int k=0;k<LongPeriod;k++) {
      valmin[k]=low[k];
      valmax[k]=high[k];
      vallower[k]=low[k];
      valupper[k]=high[k];
      valmaxMargin[k]=high[k];
      valmaxMargin2[k]=high[k];
      valminMargin[k]=low[k];
      valminMargin2[k]=low[k];
   }
   int limit;
   if (prev_calculated<LongPeriod) {limit=LongPeriod;} else {limit=prev_calculated-1;}
   int TriggerLow=0;
   int TriggerHigh=0;

   //int limit=LongPeriod;
   double LongMax,LongMin,MediumMax,MediumMin,ShortMax,ShortMin;
   
   //for (int k=0;k<=LongPeriod;k++) {
   //}
   
  
   for(int i=limit; i<rates_total; i++)
   {
      LongMax=high[i];
      LongMin=low[i];
      
      for (int j=0;j<LongPeriod;j++) {
         if (LongMax<high[i-j]) {LongMax=high[i-j];}
         if (LongMin>low[i-j]) {LongMin=low[i-j];}
      }
      
     
      
      MediumMax=high[i];
      MediumMin=low[i];
      
      for (int j=0;j<MediumPeriod;j++) {
         if (MediumMax<high[i-j]) {MediumMax=high[i-j];}
         if (MediumMin>low[i-j]) {MediumMin=low[i-j];}
      }
      
      if (LongMax==MediumMax) {valmax[i]=LongMax;} else {valmax[i]=valmax[i-1];}
      if (LongMin==MediumMin) {valmin[i]=LongMin;} else {valmin[i]=valmin[i-1];}
      
    
      ShortMax=0;
      ShortMin=0;
      if (ShortPeriod==1) {
      ShortMax=high[i];
      ShortMin=low[i];
      } else
      for (int j=0;j<ShortPeriod;j++) {
         //if (ShortMax<high[i-j]) {ShortMax=high[i-j];}
         //if (ShortMin>low[i-j]) {ShortMin=low[i-j];}
         ShortMax +=(ShortPeriod-j-1)*high[i-j]/((ShortPeriod*(ShortPeriod-1)/2));
         ShortMin +=(ShortPeriod-j-1)*low[i-j]/((ShortPeriod*(ShortPeriod-1)/2));
      }
      valupper[i]=ShortMax;
      vallower[i]=ShortMin;
      
     
      
      valminMargin[i]=valmin[i]*(1+Margin/100);
      valmaxMargin[i]=valmax[i]*(1-Margin/100);
      
      valminMargin2[i]=valmin[i]*(1+Margin2/100);
      valmaxMargin2[i]=valmax[i]*(1-Margin2/100);
      
      if (Gravity>0) {
         if (valmaxMargin[i]>valupper[i]) {valmax[i]=valmax[i-1]-(valmax[i-1]-valmin[i-1])*Gravity/10;}
         if (valminMargin[i]<vallower[i]) {valmin[i]=(valmax[i-1]-valmin[i-1])*Gravity/10+valmin[i-1];}
      }
      
      if (valupper[i]>valmax[i]) {valmax[i]=valupper[i];}
      if (vallower[i]<valmin[i]) {valmin[i]=vallower[i];}
      
      valminMargin[i]=valmin[i]*(1+Margin/100);
      valmaxMargin[i]=valmax[i]*(1-Margin/100);
      
      valminMargin2[i]=valmin[i]*(1+Margin2/100);
      valmaxMargin2[i]=valmax[i]*(1-Margin2/100);
  
      
      valSignal[i]=0;
      if ((((valmax[i]-valmin[i])/valmin[i])>Channel/100)||(Channel==0)) {
      
         if ((vallower[i]<=valminMargin2[i])) {
             if ((ShowSignals)&&(valSignal[i-1]!=4)) ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],LongColor);
             //ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],ShortColor);
             valSignal[i]=4;
         
         }
        
         
       if ((valupper[i]>=valmaxMargin2[i])) {
             if ((ShowSignals)&&(valSignal[i-1]!=8)) ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],ShortColor);
             //ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],LongColor);
             valSignal[i]=8;
         
         }
      
      
       else if (valmaxMargin[i]>valminMargin[i]) {
         if ((vallower[i-1]<valminMargin[i-1])&&(vallower[i]>=valminMargin[i])&&(valmin[i-Tracker]<=valmin[i])) {
             if (ShowSignals) ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Sell_"+(string)i,0,time[i],high[i],LongColor);
             if (ShowSignals) ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Buy_"+(string)i,0,time[i],high[i],ShortColor);
             valSignal[i] =9;
         
         }
         
        if ((valupper[i-1]>valmaxMargin[i-1])&&(valupper[i]<=valmaxMargin[i])&&(valmax[i-Tracker]>=valmax[i])) {
             if (ShowSignals) ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Sell_"+(string)i,0,time[i],high[i],ShortColor);
             if (ShowSignals) ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Buy_"+(string)i,0,time[i],high[i],LongColor);
             valSignal[i] =6;
         
         }
       } 
           
        
      
      
      }
      /*
      if ((valmin[i-Tracker]>valmin[i])&&(TriggerHigh==0)) {
          ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],LongColor);
          TriggerHigh=1;
      }
      
      if ((valmax[i-Tracker]<valmax[i])&&(TriggerLow==0)) {
          ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],ShortColor);
          TriggerLow=1;
      }
      */
      /*
      
      
      if ((valupper[i-1]<valmaxMargin[i-1])&&(TriggerHigh==1)) {
            ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],ShortColor);
            ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],LongColor);
            valSignal[i]=-3;
            TriggerHigh=0;
      }
      */
      /*  
      if ((vallower[i-1]>valminMargin[i-1])&&(TriggerLow==1)) {
            ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],LongColor);
            ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],ShortColor);
            valSignal[i]=3;
            TriggerLow=0;
      }
      */  
      /*  
      if ((TriggerHigh==1)&&(valupper[i]<valmaxMargin[i])) {
             ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],LongColor);
            ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],ShortColor);
            valSignal[i]=-3;
            TriggerHigh=0;
      }
      
       if ((TriggerLow==0)&&(vallower[i]>valminMargin[i])) {
            ArrowCreate(0,OBJ_ARROW_SELL,"Arrow_Sell_"+(string)i,0,time[i],high[i],ShortColor);
            ArrowCreate(0,OBJ_ARROW_BUY,"Arrow_Buy_"+(string)i,0,time[i],high[i],LongColor);
            valSignal[i]=3;
            TriggerLow=0;
      }
        */
     
   
      
   }
   return(rates_total);
}

template <typename T>
double getPrice(ENUM_APPLIED_PRICE price, T& open, T& high, T& low, T& close)
{
   switch (price)
   {
      case PRICE_CLOSE:    return(close);
      case PRICE_HIGH:     return(high);
      case PRICE_LOW:      return(low);
      case PRICE_OPEN:     return(open);
      case PRICE_MEDIAN:   return((high+low)/2.0);
      case PRICE_TYPICAL:  return((high+low+close)/3.0);
      case PRICE_WEIGHTED: return((high+low+close+close)/4.0);
   }            
   return(0);
}

void OnDeinit(const int reason)
  {
       ObjectsDeleteAll(0); 
   }
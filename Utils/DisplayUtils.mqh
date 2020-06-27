

class DisplayUtils {

  public :

  bool ChartBackColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the chart background color
    if(!ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartForeColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of axes, scale and OHLC line
    if(!ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartGridColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set chart grid color
    if(!ChartSetInteger(chart_ID,CHART_COLOR_GRID,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartVolumeColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set color of volumes and market entry levels
    if(!ChartSetInteger(chart_ID,CHART_COLOR_VOLUME,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartUpColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of up bar, its shadow and border of body of a bullish candlestick
    if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartDownColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of down bar, its shadow and border of bearish candlestick's body
    if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartLineColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set color of the chart line and Doji candlesticks
    if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_LINE,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartBullColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of bullish candlestick's body
    if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartBearColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of bearish candlestick's body
    if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartBidColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of Bid price line
    if(!ChartSetInteger(chart_ID,CHART_COLOR_BID,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartAskColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set the color of Ask price line
    if(!ChartSetInteger(chart_ID,CHART_COLOR_ASK,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartLastColorSet(const color clr,const long chart_ID=0)
  {
    //--- reset the error value
    ResetLastError();
    //--- set color of the last performed deal's price line (Last)
    if(!ChartSetInteger(chart_ID,CHART_COLOR_LAST,clr))
    {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
    }
    //--- successful execution
    return(true);
  }

  bool ChartShowPeriodSepapatorSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_SHOW_PERIOD_SEP,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

  bool ChartForegroundSet(const bool value,const long chart_ID=0)
    {
  //--- reset the error value
     ResetLastError();
  //--- set property value
     if(!ChartSetInteger(chart_ID,CHART_FOREGROUND,0,value))
       {
        //--- display the error message in Experts journal
        Print(__FUNCTION__+", Error Code = ",GetLastError());
        return(false);
       }
  //--- successful execution
     return(true);
    }

  void DrawBoxWindows(int xCorner, int yCorner, int boxLenght, int boxHeightArg, string titleName, bool windowsReduced, bool drawOpenCloseButton){

     if(!windowsReduced){
        RectLabelCreate(0,"rectOrders",0,xCorner,yCorner,boxLenght, boxHeightArg,clrAliceBlue,BORDER_FLAT,CORNER_LEFT_UPPER,clrSteelBlue,STYLE_SOLID,2,false,false,true,0);
     }
     RectLabelCreate(0,"rectTitle",0,xCorner,yCorner,boxLenght,32,clrSteelBlue,BORDER_FLAT,CORNER_LEFT_UPPER,clrSteelBlue,STYLE_SOLID,0,false,false,true,0);
     LabelCreate(0, "lblTitle", 0, xCorner+5, yCorner+5, CORNER_LEFT_UPPER, titleName, "Arial Black", 12, clrWhite, 0.0, ANCHOR_LEFT_UPPER, false, false, true, 0);

     if(drawOpenCloseButton){
       if(!windowsReduced){
       addButtonOnChart("openCloseButton", "Reduce", xCorner + boxLenght - 90, yCorner + 7, 60, 20, clrWhite, clrBlue);
     } else {
       addButtonOnChart("openCloseButton", "Expand",  xCorner + boxLenght - 90, yCorner + 7,60, 20, clrWhite, clrBlue);
     }
     }
   }


  void deleteBoxWindows(){
    ObjectDelete("rectOrders");
    ObjectDelete("rectTitle");
    ObjectDelete("lblTitle");
    ObjectDelete("openCloseButton");
  }

  void addButtonOnChart(string name, string text, int x, int y, int width, int height, color fontColor, color backgroundColor){

    long              chart_ID=0;               // chart's ID
    ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER; // chart corner for anchoring
    string            font="Verdana";       // font
    int               font_size=10;             // font size
    bool              back=false;               // in the background

    ObjectDelete(name);
    //Print("ObjectDelete(\""+name+"\");");

    ObjectCreate(chart_ID,name,OBJ_BUTTON,0,0,0);
    ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
    ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
    ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
    ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,fontColor);
    ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
    ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
  }


  bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                       const string           name="RectLabel",         // label name
                       const int              sub_window=0,             // subwindow index
                       const int              x=0,                      // X coordinate
                       const int              y=0,                      // Y coordinate
                       const int              width=50,                 // width
                       const int              height=18,                // height
                       const color            back_clr=C'236,233,216',  // background color
                       const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                       const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                       const color            clr=clrRed,               // flat border color (Flat)
                       const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                       const int              line_width=1,             // flat border width
                       const bool             back=false,               // in the background
                       const bool             selection=false,          // highlight to move
                       const bool             hidden=true,              // hidden in the object list
                       const long             z_order=0)                // priority for mouse click
    {
  //--- reset the error value
     ResetLastError();
  //--- create a rectangle label
     if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)){
        return(false);
     }

     //Print("ObjectDelete(\""+name+"\");");
  //--- set label coordinates
     ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
     ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
  //--- set label size
     ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
     ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
  //--- set background color
     ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
  //--- set border type
     ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
  //--- set the chart's corner, relative to which point coordinates are defined
     ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
  //--- set flat border color (in Flat mode)
     ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
  //--- set flat border line style
     ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
  //--- set flat border width
     ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
  //--- display in the foreground (false) or background (true)
     ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
  //--- enable (true) or disable (false) the mode of moving the label by mouse
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
  //--- hide (true) or display (false) graphical object name in the object list
     ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
  //--- set the priority for receiving the event of a mouse click in the chart
     ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
  //--- successful execution
     return(true);
  }

  bool LabelCreate(const long              chart_ID=0,               // chart's ID
                   const string            name="Label",             // label name
                   const int               sub_window=0,             // subwindow index
                   const int               x=0,                      // X coordinate
                   const int               y=0,                      // Y coordinate
                   const ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER, // chart corner for anchoring
                   const string            text="Label",             // text
                   const string            font="Arial",             // font
                   const int               font_size=10,             // font size
                   const color             clr=clrWhite,               // color
                   const double            angle=0.0,                // text slope
                   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                   const bool              back=false,               // in the background
                   const bool              selection=false,          // highlight to move
                   const bool              hidden=true,              // hidden in the object list
                   const long              z_order=0)                // priority for mouse click
    {
  //--- reset the error value
     ResetLastError();
  //--- create a text label
     if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)){
        return(false);
     }
     //Print("ObjectDelete(\""+name+"\");");
  //--- set label coordinates
     ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
     ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
  //--- set the chart's corner, relative to which point coordinates are defined
     ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
  //--- set the text
     ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
  //--- set text font
     ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
  //--- set font size
     ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
  //--- set the slope angle of the text
     ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
  //--- set anchor type
     ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
  //--- set color
     ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
  //--- display in the foreground (false) or background (true)
     ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
  //--- enable (true) or disable (false) the mode of moving the label by mouse
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
  //--- hide (true) or display (false) graphical object name in the object list
     ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
  //--- set the priority for receiving the event of a mouse click in the chart
     ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
  //--- successful execution
     return(true);
  }

  void addTitleValueTextOnChart(string nameObjectArg, string nameTitleArg, string valueArg, double xTitleArg, double xValueArg, double yArg, color labelColorArg, color textColorArg){
    ObjectCreate("title_"+nameObjectArg, OBJ_LABEL, 0, 0, 0);
    //Print("ObjectDelete(\"title_"+nameObjectArg+"\");");
    ObjectSetText("title_"+nameObjectArg,nameTitleArg,9, "Verdana", labelColorArg);
    ObjectSet("title_"+nameObjectArg, OBJPROP_CORNER, 0);
    ObjectSet("title_"+nameObjectArg, OBJPROP_XDISTANCE, xTitleArg);
    ObjectSet("title_"+nameObjectArg, OBJPROP_YDISTANCE, yArg);
    //-------
    ObjectCreate("value_"+nameObjectArg, OBJ_LABEL, 0, 0, 0);
    Print("ObjectDelete(\"value_"+nameObjectArg+"\");");
    ObjectSetText("value_"+nameObjectArg,valueArg,9, "Verdana", textColorArg);
    ObjectSet("value_"+nameObjectArg, OBJPROP_CORNER, 0);
    ObjectSet("value_"+nameObjectArg, OBJPROP_XDISTANCE, xValueArg);
    ObjectSet("value_"+nameObjectArg, OBJPROP_YDISTANCE, yArg);
  }

  bool Create_OpenWindowButton(const long              chart_ID=0,               // chart's ID
                      const string            name="Button_Buy",        // button name
                      const int               x=0,                      // X coordinate
                      const int               y=20,// Y coordinate
                      const int               width=60,                 // button width
                      const int               height=20,                // button height
                      const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                      const string            text="Open",               // text
                      const string            font="Courier New",       // font
                      const int               font_size=10,             // font size
                      const color             clr=clrBlack,             // text color
                      const color             back_clr=clrGray,         // background color
                      const bool              back=false                // in the background
                      )
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   ObjectCreate(chart_ID,name,OBJ_BUTTON,0,0,0);
   //Print("ObjectDelete(\""+name+"\");");
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- successful execution
   return(true);
  }

  void drawOrMoveHorizontalLine(string nameLineArg, double priceLevelArg, color colorArg){  //      #define WINDOW_MAIN 0
    if(!ObjectMove(nameLineArg, 0, Time[0], priceLevelArg)){
      ObjectCreate(nameLineArg, OBJ_HLINE, 0, 0, priceLevelArg);
      ObjectSet(nameLineArg, OBJPROP_COLOR, colorArg );
    }
  }

  void drawOrMoveVerticalLine(string nameLineArg, color colorArg, bool movable){  //      #define WINDOW_MAIN 0
    datetime timeNow = TimeCurrent();
    VLineCreate(0,nameLineArg,0,timeNow ,colorArg,STYLE_DASH,1,false,
              movable,true,0);
  }

  //+------------------------------------------------------------------+
  //| Create the vertical line                                         |
  //+------------------------------------------------------------------+
  bool VLineCreate(const long            chart_ID=0,        // chart's ID
                   const string          name="VLine",      // line name
                   const int             sub_window=0,      // subwindow index
                   datetime              time=0,            // line time
                   const color           clr=clrRed,        // line color
                   const ENUM_LINE_STYLE style=STYLE_DASH, // line style - STYLE_SOLID STYLE_DASH
                   const int             width=1,           // line width
                   const bool            back=false,        // in the background
                   const bool            selection=true,    // highlight to move
                   const bool            hidden=true,       // hidden in the object list
                   const long            z_order=0)         // priority for mouse click
    {
  //--- if the line time is not set, draw it via the last bar
     if(!time)
        time=TimeCurrent();
  //--- reset the error value
     ResetLastError();
  //--- create a vertical line
     if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
       {
        Print(__FUNCTION__,
              ": failed to create a vertical line! Error code = ",GetLastError());
        return(false);
       }
  //--- set line color
     ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
  //--- set line display style
     ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
  //--- set line width
     ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
  //--- display in the foreground (false) or background (true)
     ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
  //--- enable (true) or disable (false) the mode of moving the line by mouse
  //--- when creating a graphical object using ObjectCreate function, the object cannot be
  //--- highlighted and moved by default. Inside this method, selection parameter
  //--- is true by default making it possible to highlight and move the object
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
     ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
  //--- hide (true) or display (false) graphical object name in the object list
     ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
  //--- set the priority for receiving the event of a mouse click in the chart
     ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
  //--- successful execution
     return(true);
    }

};

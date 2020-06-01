#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/CustomIndicatorsAcces.mqh>

class GridStrategyCoverWinner : public GridStrategy {

  private :

  datetime lastInitIndicatorsTime;
  double hmaBlue1;
  double hmaBlue2;
  double hmaRed1;
  double hmaRed2;

  void initIndicators(string currencyArg, int timeFrameArg){
    if(Time[0] != lastInitIndicatorsTime){
      hmaBlue1 = CustomIndicatorsAcces::getHMAHullMABlueLine(currencyArg, timeFrameArg, 1);
      hmaBlue2 = CustomIndicatorsAcces::getHMAHullMABlueLine(currencyArg, timeFrameArg, 2);
      hmaRed1 = CustomIndicatorsAcces::getHMAHullMARedLine(currencyArg, timeFrameArg, 1);
      hmaRed2 = CustomIndicatorsAcces::getHMAHullMARedLine(currencyArg, timeFrameArg, 2);
      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyCoverWinner(){

  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    //this.newOrderOpeningType =  ClassicGridSytem;
    this.updateAction = OnNewBar;
    lastInitIndicatorsTime = Time[0];
  }

  void onEachTick(){

  }

  void onNewBar(){
    initIndicators(Symbol(), Period());

    if(this.gridBasketsManager.getNbrSellBaskets() == 0){ // && hmaRed1 != EMPTY_VALUE
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(this.gridBasketsManager.getNbrBuyBaskets() == 0){ //&& hmaBlue1 != EMPTY_VALUE
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignal = false;
    initIndicators(symbolToTrade, timeFrame);

    return hmaBlue1 != EMPTY_VALUE && hmaRed2 != EMPTY_VALUE;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignal = false;
    initIndicators(symbolToTrade, timeFrame);

    return hmaBlue2 != EMPTY_VALUE && hmaRed1 != EMPTY_VALUE;
  }

  bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }

  bool isClosingCoverOrderSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }

};

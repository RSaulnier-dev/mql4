#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/UnsustainableIndicator.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>

class GridStrategyUnsustainable : public GridStrategy {

  private :

  double greenLineOut1;
  double greenLineOut2;

  double greenLineIn1;
  double redLineIn1;
  double greenLineIn2;
  double redLineIn2;

  double redLineOut1;
  double redLineOut2;

  double openCandle2;
  double closeCandle2;
  double closeCandle1;

  BandsIndicator *bandsIndicator;
  UnsustainableIndicator *unsustainableIndicator;

  void initIndicators(string currencyArg, int timeFrameArg){
    bandsIndicator.recalculate();

    openCandle2 = iOpen(currencyArg, timeFrameArg, 2);
    closeCandle2 = iClose(currencyArg, timeFrameArg, 2);
    closeCandle1 = iClose(currencyArg, timeFrameArg, 1);
  }

  public :

  GridStrategyUnsustainable(){

  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    if(this.doubleValue1 == 0){
      this.doubleValue1 = 25;
    }
    if(this.intValue1 == 0){
      this.intValue1 = 1;
    }
    bandsIndicator = new BandsIndicator(this.doubleValue1);
    unsustainableIndicator = new UnsustainableIndicator();

    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    //For checking actions on New Tick : this.updateAction = OnNewTick / For checking action on new Bar :   this.updateAction = OnNewBar
    this.updateAction = OnNewTick;
  }

  void onEachTick(){
    //Add here what happens at each tick
  }

  void onNewBar(){
    //Add here what happens when a new bar appears. Depend of the timeframe of the EA
    if(this.gridBasketsManager.getNbrSellBaskets() < intValue1 && isSellingSignal(OP_SELL, OP_SELL, 0)){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(this.gridBasketsManager.getNbrBuyBaskets() < intValue1 && isBuyingSignal(OP_BUY, OP_BUY, 0)){
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;

    //Add here the strategy for opening a new Buying position - Only if GridNewOrderOpeningType = OpenPositionIfNewSignal
    if(unsustainableIndicator.isBuyingSignal(0)){
        isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;

    if(unsustainableIndicator.isSellingSignal(0)){
        isSignalForNewPosition = true;
    }
    //Add here the strategy for opening a new Selling position - Only if GridNewOrderOpeningType = OpenPositionIfNewSignal

    return isSignalForNewPosition;
  }

  bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    if(orderTypeArg == OP_BUY){

      initIndicators(currencyArg, timeFrameArg);
      redLineOut1 = bandsIndicator.getRedOutLine(1);
      redLineOut2 = bandsIndicator.getRedOutLine(2);
      redLineIn1 = bandsIndicator.getRedInLine(1);
      redLineIn2 = bandsIndicator.getRedInLine(2);

      //openCandle2 > redLineIn2 &&
      //openCandle2 > redLineOut2 &&
      if(((openCandle2 > redLineIn2 &&closeCandle2 > redLineIn2) && closeCandle1 < redLineIn1)
      || ((openCandle2 > redLineOut2 &&closeCandle2 > redLineOut2) && closeCandle1 < redLineOut1)){
        isClosing = true;
      }
    } else if(orderTypeArg == OP_SELL){

      initIndicators(currencyArg, timeFrameArg);
      greenLineOut1 = bandsIndicator.getGreenOutLine(1);
      greenLineOut2 = bandsIndicator.getGreenOutLine(2);
      greenLineIn1 = bandsIndicator.getGreenInLine(1);
      greenLineIn2 = bandsIndicator.getGreenInLine(2);

      //openCandle2 < greenLineIn2 &&
      //openCandle2 < greenLineOut2 &&
      if(((openCandle2 < greenLineIn2 && closeCandle2 < greenLineIn2) && closeCandle1 > greenLineIn1)
      || ((openCandle2 < greenLineOut2 &&closeCandle2 < greenLineOut2) && closeCandle1 > greenLineOut1)){
        isClosing = true;
      }
    }

    return isClosing;
  }

  bool isClosingCoverOrderSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }
};

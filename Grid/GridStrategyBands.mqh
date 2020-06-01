#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>
#include <Strategy/Indicators/BacktestingBandsIndicator.mqh>

class GridStrategyBands : public GridStrategy {

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

  double macdMain1;
  double macdMain2;

  double macdSignal1;
  double macdSignal2;

  double tenkanSen1;
  double tenkanSen2;
  double kijunSen1;
  double kijunSen2;

  double lastOpenValue;
  int nbrBarsSinceLastOpening;
  int closeIchiAfterXCandles;
  bool hasIchiReachStep1;
  bool hasIchiReachStep2;
  bool waitIchiStep2;

  BandsIndicator *bandsIndicator;
  BacktestingBandsIndicator *backtestingBandsIndicator;

  int nbrCandleSinceLastCalculations;
  double bestValue;

  public :

  GridStrategyBands(){
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){

    nbrBarsSinceLastOpening = 0;
    closeIchiAfterXCandles = 30;
    hasIchiReachStep1 = false;
    hasIchiReachStep2 = false;
    waitIchiStep2 = false;

    if(this.doubleValue1 == 0){
      this.doubleValue1 = 25;
    }
    if(this.intValue1 == 0){
      this.intValue1 = 1;
    }
    bandsIndicator = new BandsIndicator(this.doubleValue1);
    backtestingBandsIndicator = new BacktestingBandsIndicator(2000);
    bestValue = backtestingBandsIndicator.findBestValue(1, 15,5,60);
    bandsIndicator.setBandSpace(bestValue);
    bandsIndicator.recalculate();
    nbrCandleSinceLastCalculations = 0;
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    //this.takeProfitCalcultationType = OnStrategySignal;
    //this.nbrOrdersMax = 3;
  }

  void onEachTick(){
    //Add here what happens at each tick

  }

  void onNewBar(){
    //Add here what happens when a new bar appears. Depend of the timeframe of the EA
    ++nbrCandleSinceLastCalculations;

    if(nbrBarsSinceLastOpening > 0){
      ++nbrBarsSinceLastOpening;
    }

    if(nbrCandleSinceLastCalculations == 5){
      bestValue = backtestingBandsIndicator.findBestValue(0, 15,5,60);
      Print(bestValue);
      bandsIndicator.setBandSpace(bestValue);
      nbrCandleSinceLastCalculations = 0;
    }
    bandsIndicator.recalculate();

    if(isSellingSignal(OP_SELL, OP_SELL, 0) && (this.gridBasketsManager.getNbrSellBaskets()+this.gridBasketsManager.getNbrBuyBaskets()) < intValue1){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0) && (this.gridBasketsManager.getNbrSellBaskets()+this.gridBasketsManager.getNbrBuyBaskets()) < intValue1){
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
  }

  bool isBuyingSignal(string currencyArg, int timeFrameArg){
    bool isSignalForNewPosition = false;

    //Add here the strategy for opening a new Buying position
    greenLineOut1 = bandsIndicator.getGreenOutLine(1);
    greenLineOut2 = bandsIndicator.getGreenOutLine(2);

    if(Close[2] < greenLineOut2 && Close[1] > greenLineOut2){
      isSignalForNewPosition = true;
      lastOpenValue = Open[0];
      nbrBarsSinceLastOpening = 1;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(string currencyArg, int timeFrameArg){
    bool isSignalForNewPosition = false;

    //Add here the strategy for opening a new Selling position
    redLineOut1 = bandsIndicator.getRedOutLine(1);
    redLineOut2 = bandsIndicator.getRedOutLine(2);

    if(Close[2] > redLineOut2 && Close[1] < redLineOut1){
      isSignalForNewPosition = true;
      lastOpenValue = Open[0];
      nbrBarsSinceLastOpening = 1;
    }

    return isSignalForNewPosition;
  }

  bool isMACDCloseBuy(){
    bool signal = false;

    //macdMain1 > 0 && macdSignal1 > 0 &&
    if(macdMain2 >= macdSignal2 && macdMain1 < macdSignal1) {
      signal  = true;
    }

    return signal;
  }

  bool isMACDCloseSell(){
    bool signal = false;

    //macdMain1 < 0 && macdSignal1 < 0 &&
    if(macdMain2 <= macdSignal2 && macdMain1 > macdSignal1) {
      signal  = true;
    }

    return signal;
  }

  void initIchimokuSignal(){
    nbrBarsSinceLastOpening = 0;
    hasIchiReachStep1 = false;
    hasIchiReachStep2 = false;
    waitIchiStep2 = false;
  }

  bool isIchimokuCloseBuy(){
    bool signal = false;

    if(hasIchiReachStep1 == false &&  kijunSen2 >= tenkanSen2 && kijunSen1 <  tenkanSen1){
      hasIchiReachStep1 = true;
    }

    if((hasIchiReachStep1 == true  && kijunSen2 <= tenkanSen2 && kijunSen1 >  tenkanSen1) ||
       (hasIchiReachStep1 == false && nbrBarsSinceLastOpening > closeIchiAfterXCandles)) {
      hasIchiReachStep2 = true;
      signal = true;
    }

    return signal;
  }

  bool isIchimokuCloseSell(){
    bool signal = false;

    if(hasIchiReachStep1 == false &&  kijunSen2 <= tenkanSen2 && kijunSen1 > tenkanSen1){
      hasIchiReachStep1 = true;
    }

    if((hasIchiReachStep1 == true  && kijunSen2 >= tenkanSen2 && kijunSen1 <  tenkanSen1) ||
       (hasIchiReachStep1 == false && nbrBarsSinceLastOpening > closeIchiAfterXCandles)) {
      hasIchiReachStep2 = true;
      signal = true;
    }

    return signal;
  }

  void initValues(string currencyArg, int timeFrameArg){
    openCandle2 = iOpen(currencyArg, timeFrameArg, 2);
    closeCandle2 = iClose(currencyArg, timeFrameArg, 2);
    closeCandle1 = iClose(currencyArg, timeFrameArg, 1);
    macdMain1 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    macdMain2 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
    macdSignal1 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
    macdSignal2 = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);
    tenkanSen1 = iIchimoku(NULL,0,9,26,52,MODE_TENKANSEN,1);
    tenkanSen2 = iIchimoku(NULL,0,9,26,52,MODE_TENKANSEN,2);
    kijunSen1 = iIchimoku(NULL,0,9,26,52,MODE_KIJUNSEN,1);
    kijunSen2 = iIchimoku(NULL,0,9,26,52,MODE_KIJUNSEN,2);
  }

  bool isClosingSignal(string currencyArg, int timeFrameArg, bool orderTypeArg){
    bool isClosing = false;

    if(orderTypeArg == OP_BUY){
      redLineOut1 = bandsIndicator.getRedOutLine(1);
      redLineOut2 = bandsIndicator.getRedOutLine(2);
      redLineIn1 = bandsIndicator.getRedInLine(1);
      redLineIn2 = bandsIndicator.getRedInLine(2);
      initValues(currencyArg, timeFrameArg);

      if(waitIchiStep2){
        if(kijunSen2 <= tenkanSen2 && kijunSen1 >  tenkanSen1){
          isClosing = true;
          initIchimokuSignal();
        }
      } else if(isIchimokuCloseBuy() || isMACDCloseBuy() || (((openCandle2 > redLineIn2 &&closeCandle2 > redLineIn2) && closeCandle1 < redLineIn1)
      || ((openCandle2 > redLineOut2 &&closeCandle2 > redLineOut2) && closeCandle1 < redLineOut1))){
        if(hasIchiReachStep1 == true && hasIchiReachStep2 == false && Close[1] < lastOpenValue){
          waitIchiStep2 = true;
        } else {
          isClosing = true;
          initIchimokuSignal();
        }
      }
    } else if(orderTypeArg == OP_SELL){
      greenLineOut1 = bandsIndicator.getGreenOutLine(1);
      greenLineOut2 = bandsIndicator.getGreenOutLine(2);
      greenLineIn1 = bandsIndicator.getGreenInLine(1);
      greenLineIn2 = bandsIndicator.getGreenInLine(2);
      initValues(currencyArg, timeFrameArg);

      if(waitIchiStep2){
        if(kijunSen2 >= tenkanSen2 && kijunSen1 <  tenkanSen1){
          isClosing = true;
          initIchimokuSignal();
        }
      } else if(isIchimokuCloseSell() || isMACDCloseSell() || (((openCandle2 < greenLineIn2 && closeCandle2 < greenLineIn2) && closeCandle1 > greenLineIn1)
      || ((openCandle2 < greenLineOut2 &&closeCandle2 < greenLineOut2) && closeCandle1 > greenLineOut1))){
        if(hasIchiReachStep1 == true && hasIchiReachStep2 == false && Close[1] > lastOpenValue){
          waitIchiStep2 = true;
        } else {
          isClosing = true;
          initIchimokuSignal();
        }
      }
    }

    return isClosing;
  }

  bool isClosingCoverOrderSignal(string currencyArg, int timeFrameArg, bool orderTypeArg){
    bool isClosing = false;

    return isClosing;
  }
};

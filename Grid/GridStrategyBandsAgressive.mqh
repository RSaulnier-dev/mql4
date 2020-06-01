#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>

class GridStrategyBandsAgressive : public GridStrategy {

  private :

  double greenLineOut1;
  double greenLineOut2;

  double greenLineIn;
  double redLineIn;

  double redLineOut1;
  double redLineOut2;

  double greySupLine1;
  double greyInfLine1;
  double yellowLine1;

  BandsIndicator *bandsIndicator;

  datetime lastInitIndicatorsTime;

  void initIndicators(){
    if(Time[0] != lastInitIndicatorsTime){
      bandsIndicator.recalculate();

      greenLineOut1 = bandsIndicator.getGreenOutLine(1);
      greenLineOut2 = bandsIndicator.getGreenOutLine(2);

      redLineOut1 = bandsIndicator.getRedOutLine(1);
      redLineOut2 = bandsIndicator.getRedOutLine(2);

      yellowLine1 = bandsIndicator.getYellowMiddleLine(1);
      greySupLine1 = bandsIndicator.getGraySupLine(1);
      greyInfLine1 = bandsIndicator.getGrayInfLine(1);

      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyBandsAgressive(){
    bandsIndicator = new BandsIndicator(30,  doubleValue1, 100);
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){
    //Add here what happens at each tick

  }

  void onNewBar(){
    initIndicators();

    if(isSellingSignal(OP_SELL, OP_SELL, 0) && this.gridBasketsManager.getNbrSellBaskets() == 0){
      //this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0, MathAbs(orderUtils.convertQuotedPriceInNbrPip(MarketInfo(Symbol(),MODE_ASK) - greyInfLine1)));
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0) && this.gridBasketsManager.getNbrBuyBaskets() == 0){
      //this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0, MathAbs(orderUtils.convertQuotedPriceInNbrPip(greySupLine1 - MarketInfo(Symbol(),MODE_BID))));
    }
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(Close[2] < greenLineOut2 && Close[1] > greenLineOut2){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(Close[2] > redLineOut2 && Close[1] < redLineOut1){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
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

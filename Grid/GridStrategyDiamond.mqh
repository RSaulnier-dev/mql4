#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>

class GridStrategyDiamond : public GridStrategy {

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

  bool isDiamondBuyingSignal;
  bool isDiamondSellingSignal;

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

      isDiamondBuyingSignal = iCustom(Symbol(),Period(), "Reversal Diamond", 0, 1) != EMPTY_VALUE ? true : false;
      isDiamondSellingSignal = iCustom(Symbol(),Period(), "Reversal Diamond", 1, 1) != EMPTY_VALUE ? true : false;

      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyDiamond(){
    bandsIndicator = new BandsIndicator(30,  25, 100);
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){
  }

  void onNewBar(){
    initIndicators();
    double nbrPips = 0;

    if(isSellingSignal(OP_SELL, OP_SELL, 0) && this.gridBasketsManager.getNbrSellBaskets() == 0){
      //this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
      nbrPips = MathAbs(orderUtils.convertQuotedPriceInNbrPip(MarketInfo(Symbol(),MODE_ASK) - yellowLine1));
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0, nbrPips);
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0) && this.gridBasketsManager.getNbrBuyBaskets() == 0){
      //this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
      nbrPips =  MathAbs(orderUtils.convertQuotedPriceInNbrPip(yellowLine1 - MarketInfo(Symbol(),MODE_BID)));
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0,nbrPips);
    }
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(isDiamondBuyingSignal){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(isDiamondSellingSignal){
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

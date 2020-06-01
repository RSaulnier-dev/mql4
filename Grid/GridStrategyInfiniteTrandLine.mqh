#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/WaveIndicator.mqh>
#include <Strategy/Indicators/CustomIndicatorsAcces.mqh>

class GridStrategyInfiniteTrandLine : public GridStrategy {

  private :

  bool isBuySignal;
  bool isSellSignal;
  double tp1;
  double tp2;
  double tp3;
  double sl;

  datetime lastInitIndicatorsTime;


  void initIndicators(string currencyArg, int timeFrameArg){
    if(Time[0] != lastInitIndicatorsTime){
      isBuySignal = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 7, 1) > 0 ? true : false;
      isSellSignal = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 8, 1) > 0 ? true : false;
      sl = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 9, 1);
      tp1 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 10, 1);
      tp2 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 11, 1);
      tp3 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 12, 1);
      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyInfiniteTrandLine(){
    HideTestIndicators(true);
  }

  void releaseStrategy(){
  }

  void setSpecificValues(){
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    lastInitIndicatorsTime = Time[0];
  }

  void onEachTick(){

  }

  void onNewBar(){
    //equityLossGainPourcent = NormalizeDouble(100 - ((AccountEquity() * 100) / AccountBalance()), 2);
    initIndicators(Symbol(), Period());

    if(isSellingSignal(OP_SELL, OP_SELL, 0)){
      if(this.gridBasketsManager.getNbrBuyBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_BUY, OP_BUY, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_BUY, OP_BUY, 0);
      }

      if(this.gridBasketsManager.getNbrSellBaskets() == 0){
        this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0, tp3);
      } else {
        //Reajust nbr pips
      }
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0)){
      if(this.gridBasketsManager.getNbrSellBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_SELL, OP_SELL, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_SELL, OP_SELL, 0);
      }

      if(this.gridBasketsManager.getNbrBuyBaskets() == 0){
          this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0, tp3);
      } else {
        //Reajust nbr pips
      }
    }
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){

  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){

  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignal = false;
    initIndicators(Symbol(), Period());

    if(isBuySignal){
      isSignal = true;
    }

    return isSignal;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignal = false;
    initIndicators(Symbol(), Period());

    if(isSellSignal){
      isSignal = true;
    }

    return isSignal;
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

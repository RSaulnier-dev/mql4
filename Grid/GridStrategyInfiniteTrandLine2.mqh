#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/WaveIndicator.mqh>
#include <Strategy/Indicators/CustomIndicatorsAcces.mqh>

class GridStrategyInfiniteTrandLine2 : public GridStrategy {

  private :

  bool isBuySignal;
  bool isSellSignal;
  double tp1;
  double tp2;
  double tp3;
  double sl;
  double newTp;

  double tpChoosen;
  bool security;

  int chooseTP;

  datetime lastInitIndicatorsTime;


  void initIndicators(string currencyArg, int timeFrameArg){
    if(Time[0] != lastInitIndicatorsTime){
      isBuySignal = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 7, 1) > 0 ? true : false;
      isSellSignal = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 8, 1) > 0 ? true : false;
      sl = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 9, 1);
      tp1 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 10, 1);
      tp2 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 11, 1);
      tp3 = iCustom(currencyArg,timeFrameArg, "Market/Infinity TrendLine", 12, 1);
      if(chooseTP == 1){
        tpChoosen = tp1;
      } else if(chooseTP == 2){
        tpChoosen = tp2;
      } else if(chooseTP == 3){
        tpChoosen = tp3;
      } else {
        tpChoosen = tp2;
      }
      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyInfiniteTrandLine2(){
    HideTestIndicators(true);
  }

  void releaseStrategy(){
  }

  void setSpecificValues(){
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    if(this.intValue1 != 0){
      chooseTP = this.intValue1;
    } else {
      chooseTP = 2;
    }

    security = this.boolValue1;

    lastInitIndicatorsTime = Time[0];
  }

  void onEachTick(){

  }

  void onNewBar(){
    //equityLossGainPourcent = NormalizeDouble(100 - ((AccountEquity() * 100) / AccountBalance()), 2);
    initIndicators(Symbol(), Period());


    if(isSellingSignal(OP_SELL, OP_SELL, 0)){

      if(this.gridBasketsManager.getNbrSellBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_SELL, OP_SELL, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_SELL, OP_SELL, 0);
      }

      if(this.gridBasketsManager.getNbrBuyBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_BUY, OP_BUY, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_BUY, OP_BUY, 0);
      }

      if(this.gridBasketsManager.getNbrSellBaskets() == 0){
        this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0, orderUtils.convertQuotedPriceInNbrPip(MarketInfo(Symbol(),MODE_ASK) - tpChoosen));
      } else {
        //Reajust nbr pips
        if(security){
          newTp = 2;
        } else {
          newTp = orderUtils.convertQuotedPriceInNbrPip(MarketInfo(Symbol(),MODE_ASK) - tpChoosen);
        }
        this.gridBasketsManager.reajustTPSpecificBasket(OP_SELL, OP_SELL, 0, newTp);
      }
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0)){
      if(this.gridBasketsManager.getNbrSellBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_SELL, OP_SELL, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_SELL, OP_SELL, 0);
      }

      if(this.gridBasketsManager.getNbrBuyBaskets() > 0 && this.gridBasketsManager.isSpecificBasketWinning(OP_BUY, OP_BUY, 0)){
        this.gridBasketsManager.closeSpecificBasket(OP_BUY, OP_BUY, 0);
      }

      if(this.gridBasketsManager.getNbrBuyBaskets() == 0){
          this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0, orderUtils.convertQuotedPriceInNbrPip(tpChoosen - MarketInfo(Symbol(),MODE_BID)));
      } else {
        //Reajust nbr pips
        if(security){
          newTp = 2;
        } else {
          newTp = orderUtils.convertQuotedPriceInNbrPip(tpChoosen - MarketInfo(Symbol(),MODE_BID));
        }
        this.gridBasketsManager.reajustTPSpecificBasket(OP_SELL, OP_SELL, 0, newTp);
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

#include <Strategy/Grid/GridStrategy.mqh>

class GridStrategyHedgingSystem : public GridStrategy {

  private :

  int wavePeriod;
  int avgPeriod;

  WaveIndicator *waveIndicator;

  public :

  GridStrategyHedgingSystem(){
    HideTestIndicators(true);
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;
    this.nbrOrdersMaxBeforeSecurity = 1;
    this.coverType = Type7;
    this.coverOrdersSLSecurityRatio = 1;
    this.gridCoverInPips = this.TPNbrPips;
    this.coverLotCalulation = NbrLotsInBasket;

    if(this.intValue1 != 0){
      wavePeriod = this.intValue1;
    } else {
      wavePeriod = 10;
    }

    if(this.intValue2 != 0){
      avgPeriod = this.intValue2;
    } else {
      avgPeriod = 21;
    }

    waveIndicator = new WaveIndicator(wavePeriod, avgPeriod, 100, symbolToTrade, Period());
  }

  void onEachTick(){
    if(this.gridBasketsManager.getNbrSellBaskets() == 0 && this.gridBasketsManager.getNbrBuyBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
    // else if((this.gridBasketsManager.getNbrSellBaskets() == 1 && this.gridBasketsManager.getNbrBuyBaskets() == 0)
    //   || (this.gridBasketsManager.getNbrSellBaskets() == 0 && this.gridBasketsManager.getNbrBuyBaskets() == 1)){
    //
    // }
  }

  void onNewBar(){
    waveIndicator.recalculate();
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    return waveIndicator.isBuyingSignalStrategy1(0);
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    return waveIndicator.isSellingSignalStrategy1(0);
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

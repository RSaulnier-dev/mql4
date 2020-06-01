#include <Strategy/Grid/GridStrategy.mqh>

class GridStrategyXXX : public GridStrategy {

  private :

  datetime lastInitIndicatorsTime;
  bool isBuyingIndicatorSignal;
  bool isSellingIndicatorSignal;

  void initIndicators(){
    if(Time[0] != lastInitIndicatorsTime){

      //isBuyingIndicatorSignal = iCustom(Symbol(), PERIOD_M15, "trend-wave-oscillator", 2, 1);
      //isSellingIndicatorSignal = iCustom(Symbol(), PERIOD_M15, "trend-wave-oscillator", 2, 1);

      lastInitIndicatorsTime = Time[0];
    }
  }


  public :


  GridStrategyXXX(){

  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  ClassicGridSytem;
    //For checking actions on New Tick : this.updateAction = OnNewTick / For checking action on new Bar :   this.updateAction = OnNewBar
    this.updateAction = OnNewTick;

    isBuyingIndicatorSignal = false;
    isSellingIndicatorSignal = false;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){
    //Add here what happens at each tick
    initIndicators();

    if(this.gridBasketsManager.getNbrSellBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(this.gridBasketsManager.getNbrBuyBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
  }

  void onNewBar(){
    //Add here what happens when a new bar appears. Depend of the timeframe of the EA
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
    //Add here what happens when a position is close
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
    //Add here what happens when a new position is open
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();
    //Add here the strategy for opening a new Buying position - Only if GridNewOrderOpeningType = OpenPositionIfNewSignal

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    //Add here the strategy for opening a new Selling position - Only if GridNewOrderOpeningType = OpenPositionIfNewSignal

    return isSignalForNewPosition;
  }

  bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    //Add here the strategy for closing all basket - Only if GridTakeProfitCalcultationType = OnStrategySignal

    return isClosing;
  }

  bool isClosingCoverOrderSignal(int orderCoverTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }
};

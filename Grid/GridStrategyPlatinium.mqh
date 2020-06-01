#include <Strategy/Grid/GridStrategy.mqh>

class GridStrategyPlatinium : public GridStrategy {

  private :

  datetime lastInitIndicatorsTime;
  bool isBuyingIndicatorSignal;
  bool isSellingIndicatorSignal;

  bool isQMPUp;
  bool isQMPDown;

  bool isPlatiniumUp;
  bool isPlatiniumDown;

  bool isOutsideMM;

  double platiniunUp;
  double platiniunDown;

  bool hasPlatimiumSignal;

  double mm50;
  double mm100;
  double mm240;

  void initIndicators(){
    if(Time[0] != lastInitIndicatorsTime){

      isQMPUp = iCustom(symbolToTrade, Period(), "QMP Filter", 0, 1) != EMPTY_VALUE ? true : false;
      isQMPDown = iCustom(symbolToTrade, Period(), "QMP Filter", 1, 1) != EMPTY_VALUE ? true : false;
      hasPlatimiumSignal = false;
      isBuyingIndicatorSignal = false;
      isSellingIndicatorSignal = false;
      isOutsideMM = false;

      if(isQMPUp && isMMUp(1)){
          for(int i = 0; i < 8 ;++i){
            platiniunUp = iCustom(symbolToTrade, Period(), "MACD_Platinum", 2, 1 - i);
            isPlatiniumUp = platiniunUp != EMPTY_VALUE && platiniunUp < 0 ? true : false;
            setMM(1 - i);
            //isOutsideMM = iClose(symbolToTrade, Period(), 1 - i) > mm50 &&  iOpen(symbolToTrade, Period(), 1 - i) > mm50;
            isOutsideMM = true;
            if(isPlatiniumUp && isMMUp(1 - i) && isOutsideMM){
              isBuyingIndicatorSignal = true;
              break;
            }
          }
      } else if(isQMPDown  && isMMDown(1)){
        for(int j = 0; j < 8 ;++j){
          platiniunDown = iCustom(symbolToTrade, Period(), "MACD_Platinum", 3, 1 - j);
          isPlatiniumDown = platiniunDown != EMPTY_VALUE && platiniunDown > 0 ? true : false;
          setMM(1 - j);
          //isOutsideMM = iClose(symbolToTrade, Period(), 1 - j) < mm50 &&  iOpen(symbolToTrade, Period(), 1 - j) < mm50;
          isOutsideMM = true;
          if(isPlatiniumDown && isMMDown(1 - j) && isOutsideMM){
            isSellingIndicatorSignal = true;
            break;
          }
        }
      }
      //isBuyingIndicatorSignal = iCustom(Symbol(), PERIOD_M15, "trend-wave-oscillator", 2, 1);
      //isSellingIndicatorSignal = iCustom(Symbol(), PERIOD_M15, "trend-wave-oscillator", 2, 1);

      lastInitIndicatorsTime = Time[0];
    }
  }

  void setMM(int posArg){
    mm50 = iMA(symbolToTrade, Period(), 50,0,MODE_EMA,PRICE_CLOSE,posArg);
    mm100 = iMA(symbolToTrade, Period(), 100,0,MODE_EMA,PRICE_CLOSE,posArg);
    mm240 = iMA(symbolToTrade, Period(), 240,0,MODE_EMA,PRICE_CLOSE,posArg);
  }

  bool isMMUp(int posArg){
    setMM(posArg);
    return mm50 > mm100 && mm100 > mm240;
  }

  bool isMMDown(int posArg){
    setMM(posArg);
    return mm50 < mm100 && mm100 < mm240;
  }

  public :


  GridStrategyPlatinium(){

  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    //newOrderOpeningType must have one of these values : OpenPositionIfNewSignal or ClassicGridSytem
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    //For checking actions on New Tick : this.updateAction = OnNewTick / For checking action on new Bar :   this.updateAction = OnNewBar
    this.updateAction = OnNewBar;

    isBuyingIndicatorSignal = false;
    isSellingIndicatorSignal = false;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){
    //Add here what happens at each tick

  }

  void onNewBar(){
    //Add here what happens when a new bar appears. Depend of the timeframe of the EA
    initIndicators();

    if(isSellingSignal(OP_SELL, OP_SELL, 0) && this.gridBasketsManager.getNbrSellBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0) && this.gridBasketsManager.getNbrBuyBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
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

    if(isBuyingIndicatorSignal){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(isSellingIndicatorSignal){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    initIndicators();
    if(orderTypeArg == OP_SELL){
      if(isBuyingIndicatorSignal){
        isClosing = true;
      }
    } else if(orderTypeArg == OP_BUY){
      if(isSellingIndicatorSignal){
        isClosing = true;
      }
    }

    //Add here the strategy for closing all basket - Only if GridTakeProfitCalcultationType = OnStrategySignal

    return isClosing;
  }

  bool isClosingCoverOrderSignal(int orderCoverTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }
};

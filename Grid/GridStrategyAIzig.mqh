#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>

class GridStrategyAIzig : public GridStrategy {

  private :

  bool isBuyingVertexSignal;
  bool isSellingVertexSignal;

  bool isUp;
  bool isDown;

  bool iPrevioussUp;
  bool isPreviousDown;

  bool hasBlueReachMax;
  bool hasRedReachMax;

  double vertexBlue;
  double vertexRed;
  double previousVertexBlue;
  double previousVertexRed;
  double limit;

  int nbrBlueOrders;
  int nbrRedOrders;

  int tradingWay;
  int previousTradingWay;

  datetime lastInitIndicatorsTime;

  void initIndicators(){
    if(Time[0] != lastInitIndicatorsTime){

      // isBuyingVertexSignal = iCustom(Symbol(),Period(), "AIzig", 2, 1) != EMPTY_VALUE ? true : false;
      // isSellingVertexSignal = iCustom(Symbol(),Period(), "AIzig", 3, 1) != EMPTY_VALUE ? true : false;

      limit = iCustom(Symbol(),Period(), "Vertex", 0, 1);
      vertexRed = iCustom(Symbol(),Period(), "Vertex", 2, 1);
      vertexBlue = iCustom(Symbol(),Period(), "Vertex", 1, 1);
      previousVertexRed= iCustom(Symbol(),Period(), "Vertex", 2, 2);
      previousVertexBlue = iCustom(Symbol(),Period(), "Vertex", 1, 2);

      isBuyingVertexSignal = false;
      isSellingVertexSignal = false;

      if(tradingWay == OP_SELL && previousVertexRed > 0 && vertexBlue > 0) {
        tradingWay = -1;
      }

      if(tradingWay == OP_BUY && previousVertexBlue > 0 && vertexRed > 0) {
        tradingWay = -1;
      }

      if(vertexBlue > limit) {
        tradingWay = -1;
        nbrBlueOrders++;
        if(vertexBlue >= 0.8){
          hasBlueReachMax = true;
        }
      } else {
        if(nbrBlueOrders >= 3 && vertexBlue < 0.15 && hasBlueReachMax == true){
          isSellingVertexSignal = true;
          tradingWay = OP_SELL;
          previousTradingWay = OP_SELL;
          nbrBlueOrders = 0;
          hasBlueReachMax = false;
        }

        if(nbrBlueOrders > 0 && nbrBlueOrders < 3) {
          nbrBlueOrders = 0;
          hasBlueReachMax = false;
          //tradingWay = previousTradingWay;
        }
      }

      if(vertexRed > limit) {
        tradingWay = -1;
        nbrRedOrders++;
        if(vertexRed >= 0.8){
          hasRedReachMax = true;
        }
      } else {
        if(nbrRedOrders >= 3 && vertexRed < 0.15 && hasRedReachMax == true){
          isBuyingVertexSignal = true;
          tradingWay = OP_BUY;
          previousTradingWay = OP_BUY;
          nbrRedOrders = 0;
          hasRedReachMax = false;
        }

        if(nbrBlueOrders > 0 && nbrRedOrders < 3) {
          nbrRedOrders = 0;
          hasRedReachMax = false;
          //tradingWay = previousTradingWay;
        }
      }

      //isUp = iCustom(Symbol(),Period(), "STI_Trend Hunter", 5, 1) != EMPTY_VALUE ? true : false;
      //isDown = iCustom(Symbol(),Period(), "STI_Trend Hunter", 6, 1) != EMPTY_VALUE ? true : false;
      //
      // iPrevioussUp = iCustom(Symbol(),Period(), "STI_Trend Hunter", 5, 2) != EMPTY_VALUE ? true : false;
      // isPreviousDown = iCustom(Symbol(),Period(), "STI_Trend Hunter", 6, 2) != EMPTY_VALUE ? true : false;

      // isUp = true;
      // isDown = true;

      //iPrevioussUp = true;
      //isPreviousDown = true;

      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyAIzig(){
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    nbrBlueOrders = 0;
    nbrRedOrders = 0;

    tradingWay =  -1;
    previousTradingWay = -1;
    hasBlueReachMax = false;
    hasRedReachMax = false;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){

  }

  void onNewBar(){
    initIndicators();

    if(this.gridBasketsManager.getNbrSellBaskets() == 0 && tradingWay == OP_SELL){ //isSellingSignal(OP_SELL, OP_SELL, 0)
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
    }
    if(this.gridBasketsManager.getNbrBuyBaskets() == 0 && tradingWay == OP_BUY){ //isBuyingSignal(OP_BUY, OP_BUY, 0)
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
    }
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(isBuyingVertexSignal){
      isSignalForNewPosition = true;
    }

    return isSignalForNewPosition;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isSignalForNewPosition = false;
    initIndicators();

    if(isSellingVertexSignal){
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

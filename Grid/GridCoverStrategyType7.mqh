#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType7 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType7(){

  }

  GridCoverType getCoverType(){
    return Type7;
  }

  bool isClassicTrailingCoverStop(){
    return false;
  }

  bool isGridSystemTrailingCoverStop(){
    return false;
  }

  bool isNonStopEdging(){
    return true;
  }

  bool closeOnNewOrder(){
    return false;
  }

  bool isTrailingAction(){
    return false;
  }

  bool isBreakHeavenAction(){
    return false;
  }

  double getNbrLots(){
    return getDefaultNbrLots() * 1.2;
  }

  double getStopLoss(){
    double closingPrice = orderUtils.getPriceForClosingOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), (gridBasket.getTakeProfitLevel()-closingPrice));

    return closingPrice + stopLossAdding;
  }

  double getTakeProfit(){
    double closingPrice = orderUtils.getPriceForClosingOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double takeProfitAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType() == OP_BUY ? orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()) : -orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()));

    return closingPrice + takeProfitAdding;
  }

  bool displayTP(){
    return true;
  }

  double getNextCoverOrderLevel(){
    return 0;
  }

  double getCurrentCoverOrderLevel(){
    return 0;
  }

};

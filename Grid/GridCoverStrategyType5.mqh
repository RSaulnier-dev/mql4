#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType5 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType5(){

  }

  GridCoverType getCoverType(){
    return Type5;
  }

  bool isClassicTrailingCoverStop(){
    return false;
  }

  bool isGridSystemTrailingCoverStop(){
    return true;
  }

  bool isNonStopEdging(){
    return false;
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
    return getDefaultNbrLots();
  }

  double getStopLoss(){
    double closingPrice = orderUtils.getPriceForClosingOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType() == OP_BUY ? -orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()) : orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()));

    return closingPrice + gridBasket.getCoverOrdersSLSecurityRatio() * stopLossAdding;
  }

  double getTakeProfit(){
    double currentCoverOrderLevel = orderUtils.getPriceForOpeningOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType() == OP_BUY ? -orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()) : orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()));

    return currentCoverOrderLevel - gridBasket.getCoverOrdersTPRatio() * stopLossAdding;
  }

  bool displayTP(){
    return true;
  }

  double getNextCoverOrderLevel(){
    double currentCoverOrderLevel = orderUtils.getPriceForOpeningOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType() == OP_BUY ? -orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()) : orderUtils.convertNbrPipInQuotedPrice(gridBasket.getGridCoverInPips()));

    return currentCoverOrderLevel - stopLossAdding;
  }

  double getCurrentCoverOrderLevel(){
    return orderUtils.getPriceForOpeningOrder(symbolToTrade, gridBasket.getBasketCoverOrderType());
  }

};

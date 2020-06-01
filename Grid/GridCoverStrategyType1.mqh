#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType1 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType1(){

  }

  GridCoverType getCoverType(){
    return Type1;
  }

  bool isClassicTrailingCoverStop(){
    return true;
  }

  bool isGridSystemTrailingCoverStop(){
    return false;
  }

  bool isNonStopEdging(){
    return false;
  }

  bool closeOnNewOrder(){
    return false;
  }

  bool isTrailingAction(){
    return true;
  }

  bool isBreakHeavenAction(){
    return false;
  }

  double getNbrLots(){
    return getDefaultNbrLots();
  }

  double getStopLoss(){
    double closingPrice = orderUtils.getPriceForClosingOrder(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType());
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), (gridBasket.getTakeProfitLevel()-closingPrice) / gridBasket.getCoverOrdersSLSecurityRatio());

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

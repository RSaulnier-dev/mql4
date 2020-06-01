#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType2 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType2(){

  }

  GridCoverType getCoverType(){
    return Type2;
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
    return true;
  }

  bool isTrailingAction(){
    return false;
  }

  bool isBreakHeavenAction(){
    return true;
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
    double takeProfitAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), gridBasket.getBasketCoverOrderType() == OP_BUY ? orderUtils.convertNbrPipInQuotedPrice(gridBasket.getTPNbrPips()) : -orderUtils.convertNbrPipInQuotedPrice(gridBasket.getTPNbrPips()));

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

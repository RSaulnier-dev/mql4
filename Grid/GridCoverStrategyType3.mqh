#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType3 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType3(){

  }

  GridCoverType getCoverType(){
    return Type3;
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
    double stopLossAdding = orderUtils.getAndAdjustStopLossOrTakeProfitLevel(gridBasket.getSymbolToTrade(), (gridBasket.getTakeProfitLevel()-closingPrice) / gridBasket.getCoverOrdersSLSecurityRatio());

    return closingPrice - stopLossAdding * 2;
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

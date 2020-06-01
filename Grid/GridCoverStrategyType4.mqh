#include <Strategy/Grid/GridCoverStrategy.mqh>

class GridCoverStrategyType4 : public GridCoverStrategy {

  private :

  public :

  GridCoverStrategyType4(){

  }

  GridCoverType getCoverType(){
    return Type4;
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
    return false;
  }

  double getNbrLots(){

    double nbrLots = 0;

    if(gridBasket.getNbrPositionsOpenForThisBasket() == 1){
      nbrLots = gridBasket.getQuantityFromTakeProfitLevel(gridBasket.getTakeProfitLevel());
    } else {
      nbrLots = gridBasket.getNbrLotsInThisBasket() - gridBasket.getLastOrderNbrLots() * gridBasket.getCoverOrdersQuantityRatio();
    }

    return nbrLots;
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

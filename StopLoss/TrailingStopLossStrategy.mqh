#include "../Utils/PriceUtils.mqh"
#include "../Utils/OrderUtils.mqh"

class TrailingStopLossStrategy {

  protected :

  PriceUtils *priceUtils;
  OrderUtils *orderUtils;

  public :

  TrailingStopLossStrategy(){
    priceUtils = new PriceUtils();
    orderUtils = new OrderUtils();
  }

  virtual bool update(int ticket){return false;};
};

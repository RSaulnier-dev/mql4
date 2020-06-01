#include "TrailingStopLossStrategy.mqh"

class FollowDistanceInPipsStopLossStrategy : public TrailingStopLossStrategy {

  private :

  double stopLossDistanceInPips;

  public :

  FollowDistanceInPipsStopLossStrategy(){
    stopLossDistanceInPips = 40;
  }

  FollowDistanceInPipsStopLossStrategy(double stopLossDistanceInPipsArg){
    stopLossDistanceInPips = stopLossDistanceInPipsArg;
  }

  virtual bool update(int ticket){

    bool successfulOperation = true;
    double stopLossDistanceInUnits = priceUtils.getPriceFromPips(stopLossDistanceInPips);
    bool res = OrderSelect(ticket, SELECT_BY_TICKET);

    if(res == true)
    {
       if(OrderType() == OP_BUY)
       {
          if(Bid - OrderStopLoss() > stopLossDistanceInUnits)    //adjust stop loss if it is too far
          {
            successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Bid - stopLossDistanceInUnits));
         }
       }

       if(OrderType() == OP_SELL)
       {
          if(OrderStopLoss() - Ask > stopLossDistanceInUnits)    //adjust stop loss if it is too far
          {
            successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Ask + stopLossDistanceInUnits));
          }
       }
    }

    return successfulOperation;
  }

};

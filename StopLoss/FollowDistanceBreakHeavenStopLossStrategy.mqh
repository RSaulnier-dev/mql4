#include "TrailingStopLossStrategy.mqh"

class FollowDistanceBreakHeavenStopLossStrategy : public TrailingStopLossStrategy {

  private :

  double stopLossDistanceInPips;

  public :

  FollowDistanceBreakHeavenStopLossStrategy(){
    stopLossDistanceInPips = 40;
  }

  FollowDistanceBreakHeavenStopLossStrategy(double stopLossDistanceInPipsArg){
    stopLossDistanceInPips = stopLossDistanceInPipsArg;
  }

  virtual bool update(int ticket){

    bool successfulOperation = true;
    bool res = OrderSelect(ticket, SELECT_BY_TICKET);

    double stopLossDistanceInUnits = priceUtils.getPriceFromPips(stopLossDistanceInPips);

    if(res == true)
    {
       if(OrderType() == OP_BUY)
       {
         if(Bid - OrderStopLoss() > stopLossDistanceInUnits * 2){
           successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Bid - stopLossDistanceInUnits));
         }
       }

       if(OrderType() == OP_SELL)
       {
          if(OrderStopLoss() - Ask > stopLossDistanceInUnits * 2)    //adjust stop loss if it is too far
          {
            successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Ask + stopLossDistanceInUnits));
          }
       }
    }

    return successfulOperation;
  }

};

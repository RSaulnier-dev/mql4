#include "TrailingStopLossStrategy.mqh"


class SimulateTakeProfitStopLossStrategy : public TrailingStopLossStrategy {

  private :

  double simulatedTakeProfit;
  double stopLossDistanceInPips;

  public :

  SimulateTakeProfitStopLossStrategy(){
    simulatedTakeProfit = 40;
    stopLossDistanceInPips = 20;
  }

  SimulateTakeProfitStopLossStrategy(double simulatedTakeProfitArg, double stopLossDistanceInPipsArg){
    simulatedTakeProfit = simulatedTakeProfitArg;
    stopLossDistanceInPips = stopLossDistanceInPipsArg;
  }

  virtual bool update(int ticket){

    bool successfulOperation = true;
    bool res = OrderSelect(ticket, SELECT_BY_TICKET);

    double simulatedTakeProfitInUnits = priceUtils.getPriceFromPips(simulatedTakeProfit);
    double stopLossDistanceInUnits = priceUtils.getPriceFromPips(stopLossDistanceInPips);
    double deltaPrice = priceUtils.getPriceFromPips(2);

    if(res == true)
    {
       if(OrderType() == OP_BUY)
       {
         if(Bid - deltaPrice > OrderOpenPrice() + simulatedTakeProfitInUnits){
           if(OrderStopLoss() < OrderOpenPrice()){
             successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(OrderOpenPrice() + simulatedTakeProfitInUnits));
           } else if (Bid - OrderStopLoss() > stopLossDistanceInUnits){
             successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Bid - stopLossDistanceInUnits));
           }
         }
       }

       if(OrderType() == OP_SELL)
       {
          if(Ask + deltaPrice < OrderOpenPrice() - simulatedTakeProfitInUnits)
          {
            if(OrderStopLoss() > OrderOpenPrice()){
              successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(OrderOpenPrice() - simulatedTakeProfitInUnits));
            } else if (OrderStopLoss() - Ask > stopLossDistanceInUnits){
              successfulOperation = orderUtils.changeStopLossInUnits(ticket, priceUtils.normalizePrice(Ask + stopLossDistanceInUnits));
            }
          }
       }
    }

    return successfulOperation;
  }

};

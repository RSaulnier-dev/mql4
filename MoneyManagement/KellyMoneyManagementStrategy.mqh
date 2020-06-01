#include "ClassicMoneyManagementStrategy.mqh"
#include "KellyCalculator.mqh"

class KellyMoneyManagementStrategy : public ClassicMoneyManagementStrategy {

  private :

  double winningChance;
  double ratioLoseProfit;

  public :

  KellyMoneyManagementStrategy(){
    this.winningChance = 0.7;
    this.ratioLoseProfit = 2;
    amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
  }

  KellyMoneyManagementStrategy(double winningChanceArg, double ratioLoseProfitArg){
    this.amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
    this.winningChance = winningChanceArg;
    this.ratioLoseProfit = ratioLoseProfitArg;
  }

  virtual void recalculateRiskAndStopLossIfNeeded(double stopLossInUnitsArg, double takeProfitInUnitsArg){
    this.stopLossInUnits = stopLossInUnitsArg;

    double calculatedStopLossInPips = 0;
    double calculatedTakeProfitInPips = 0;
    if(stopLossInUnitsArg < takeProfitInUnitsArg){
      //Buy Order
      calculatedStopLossInPips = priceUtils.getPipsFromPrice(Ask - stopLossInUnits);
      calculatedTakeProfitInPips = calculatedStopLossInPips / ratioLoseProfit;
      this.takeProfitInUnits = Ask + priceUtils.getPriceFromPips(calculatedTakeProfitInPips);
    } else {
      //Sell Order
      calculatedStopLossInPips = priceUtils.getPipsFromPrice(stopLossInUnits - Bid);
      calculatedTakeProfitInPips = calculatedStopLossInPips / ratioLoseProfit;
      this.takeProfitInUnits = Bid - priceUtils.getPriceFromPips(calculatedTakeProfitInPips);
    }

    this.riskInPourcent = KellyCalculator::getHalfKelly(calculatedTakeProfitInPips, calculatedStopLossInPips, winningChance) * 100;
  }
};

#include "MoneyManagementStrategy.mqh"

class ClassicMoneyManagementStrategy : public MoneyManagementStrategy {

  public :

     ClassicMoneyManagementStrategy(){
        amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
        riskInPourcent = 1;
     }

     ClassicMoneyManagementStrategy(double newRiskInPourcent){
       this.amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
       this.riskInPourcent = newRiskInPourcent;
     }

     virtual void calculateInformationsToTakePosition(double stopLossInUnitsArg, double takeProfitInUnitsArg){
       this.recalculateRiskAndStopLossIfNeeded(stopLossInUnitsArg, takeProfitInUnitsArg);
       this.distanceFromStop = getDistanceFromStop();
       //printf("this.distanceFromStop="+ string(this.distanceFromStop));
       this.pourcentDistanceFromStop = (distanceFromStop * 100) / getPrice();
       //printf("this.pourcentDistanceFromStop="+ string(this.pourcentDistanceFromStop));
       this.amountPositionInAccountCurrency = MathRound((riskInPourcent * AccountBalance()) / pourcentDistanceFromStop);
       //printf("this.amountPositionInAccountCurrency="+ string(this.amountPositionInAccountCurrency));
       this.amountInUnits = convertIntoUnitsUsingQuotedCurrency();
       //printf("this.amountInUnits="+ string(this.amountInUnits));
       this.nbrLotsToTake = convertIntoLots();
       //printf("this.nbrLotsToTake="+ string(this.nbrLotsToTake));
       this.pipValueInAccountCurrency = this.getPipValueInAccountCurrency();
       //printf("this.pipValueInAccountCurrency="+ string(this.pipValueInAccountCurrency));
       this.levier = this.getLevier();
     }

    virtual void recalculateRiskAndStopLossIfNeeded(double stopLossInUnitsArg, double takeProfitInUnitsArg){
      this.stopLossInUnits = stopLossInUnitsArg;
      this.takeProfitInUnits = takeProfitInUnitsArg;
    }

    void changeAmountUnitsInALot(double newAmountUnitsInALot){
      this.amountUnitsInALot = newAmountUnitsInALot;
    }

    void changeRiskInPourcent(double newRisk){
      this.riskInPourcent = newRisk;
    }

    virtual string getPositionInformations(){
      return "\tNombre de lots : "+string(nbrLotsToTake)+"\n"
      + "\tValeur en "+string(AccountCurrency()) +" : "+string(amountPositionInAccountCurrency)+"\n"
      + "\tLevier utilisé : x"+string(getLevier())+"\n"
      + "\tStop placé à : "+string(NormalizeDouble(stopLossInUnits,5))+" "+StringSubstr(Symbol(), 3)+" ("+string(priceUtils.getPipsFromPrice(MathAbs(getPriceForClosingPosition()-stopLossInUnits)))+"pips)\n"
      + getTakeProfitInformation()
      + "\tPrix au "+getPriceUsed()+" : "+string(NormalizeDouble(getPrice(),5))+" "+StringSubstr(Symbol(), 3)+"\n"
      + "\tPrix du pip : "+string(getPipValueInAccountCurrency())+" "+string(AccountCurrency())+"\n"
      + "\tRisque : "+string(NormalizeDouble(this.riskInPourcent,2))+"%\n"
      + "\tPerte maximale : "+string(getMaxloss())+" "+string(AccountCurrency())+"\n";
    }

    virtual double getMaxloss(){
      double maxLoss = 0;

      if(this.nbrLotsToTake > this.minimumInALot){
        maxLoss = this.riskInPourcent * AccountBalance() / 100;
      } else {
        maxLoss = priceUtils.getPipsFromPrice(MathAbs(getPriceForClosingPosition()-stopLossInUnits)) * pipValueInAccountCurrency;
      }

      return NormalizeDouble(maxLoss,5);
    }

};

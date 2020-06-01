#include "MoneyManagementStrategy.mqh"

class FixedAmountMoneyManagementStrategy : public MoneyManagementStrategy {

  public :

     FixedAmountMoneyManagementStrategy(){
        amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
        this.nbrLotsToTake = 0.1;
     }

     FixedAmountMoneyManagementStrategy(double nbrLotsToTakeArg){
       this.amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
       this.nbrLotsToTake = nbrLotsToTakeArg;
     }

     virtual void calculateInformationsToTakePosition(double stopLossInUnitsArg, double takeProfitInUnitsArg){
      //  this.riskInPourcent =  calculateRisk();
      //  this.distanceFromStop = getDistanceFromStop();
      //  this.pourcentDistanceFromStop = (distanceFromStop * 100) / getPrice();
      //  this.amountPositionInAccountCurrency = MathRound((riskInPourcent * AccountBalance()) / pourcentDistanceFromStop);
      //  this.amountInUnits = convertIntoUnitsUsingQuotedCurrency();
      //  this.pipValueInAccountCurrency = this.getPipValueInAccountCurrency();
      //  this.levier = this.getLevier();
     }

    virtual string getPositionInformations(){
      // return "\tNombre de lots : "+string(nbrLotsToTake)+"\n"
      // + "\tValeur en "+string(AccountCurrency()) +" : "+string(amountPositionInAccountCurrency)+"\n"
      // + "\tLevier utilisé : x"+string(getLevier())+"\n"
      // + "\tStop placé à : "+string(NormalizeDouble(stopLossInUnits,5))+" "+StringSubstr(Symbol(), 3)+" ("+string(priceUtils.getPipsFromPrice(MathAbs(getPriceForClosingPosition()-stopLossInUnits)))+"pips)\n"
      // + getTakeProfitInformation()
      // + "\tPrix au "+getPriceUsed()+" : "+string(NormalizeDouble(getPrice(),5))+" "+StringSubstr(Symbol(), 3)+"\n"
      // + "\tPrix du pip : "+string(getPipValueInAccountCurrency())+" "+string(AccountCurrency())+"\n"
      // + "\tRisque : "+string(NormalizeDouble(this.riskInPourcent,2))+"%\n"
      // + "\tPerte maximale : "+string(getMaxloss())+" "+string(AccountCurrency())+"\n";

      return "";
    }

    // double calculateRisk(){
    //   double risk = (actualFixedRatio.getMaxLoss() * 100) / AccountBalance();
    //   if(risk < 1){
    //     risk = 1;
    //   }
    //
    //   return risk;
    // }

    virtual double getMaxloss(){
      // double maxLoss = this.riskInPourcent * AccountBalance() / 100;
      //
      // return NormalizeDouble(maxLoss,5);

      return 0;
    }

};

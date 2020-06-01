#include "MoneyManagementStrategy.mqh"

class BackTestingManagementStrategy : public MoneyManagementStrategy {

  private :

    //A mettre a jour regulierement
    //Calcule sur capital de 800 CAD (630 USD) avec 20 pips et 5 %
    double getNbrLotForFivePourcent(){
      double nbrLotForFivePourcentAnd1point5PipsSL = 0;

      double calculatedStopLossInPips = 0;
      if(stopLossInUnits < Ask) {
        calculatedStopLossInPips = priceUtils.getPipsFromPrice(Ask - stopLossInUnits);
      } else {
        calculatedStopLossInPips = priceUtils.getPipsFromPrice(stopLossInUnits - Bid);
      }

      if(StringCompare(Symbol(), "EURUSD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "GBPUSD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "AUDUSD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "USDJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "USDCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "USDCAD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 2.09;
      } else if(StringCompare(Symbol(), "EURAUD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "EURCAD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.76;
      } else if(StringCompare(Symbol(), "EURCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "EURGBP") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "EURJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "GBPJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "GBPCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "NZDUSD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "AUDCAD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 2.69;
      } else if(StringCompare(Symbol(), "AUDJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "CHFJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "AUDNZD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "NZDJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      } else if(StringCompare(Symbol(), "NZDCAD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 2.96;
      } else if(StringCompare(Symbol(), "NZDCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "GBPNZD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "EURNZD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "GBPCAD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.56;
      } else if(StringCompare(Symbol(), "GBPAUD") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "AUDCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "CADCHF") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 1.97;
      } else if(StringCompare(Symbol(), "CADJPY") == 0){
        nbrLotForFivePourcentAnd1point5PipsSL = 0.02;
      }

      return (1.5 * nbrLotForFivePourcentAnd1point5PipsSL) / calculatedStopLossInPips;
    }

  public :

     BackTestingManagementStrategy(){
        riskInPourcent = 1;
     }

     BackTestingManagementStrategy(double newRiskInPourcent){
       this.riskInPourcent = newRiskInPourcent;
     }

     virtual void calculateInformationsToTakePosition(double stopLossInUnitsArg, double takeProfitInUnitsArg){
       this.stopLossInUnits = stopLossInUnitsArg;
       this.takeProfitInUnits = takeProfitInUnitsArg;

       this.pipValueInAccountCurrency = 0;

       double nbrLotForFivePourcent = getNbrLotForFivePourcent();

       this.nbrLotsToTake = ((nbrLotForFivePourcent * riskInPourcent) / 5 * AccountBalance()) / 630;
     }

    virtual string getPositionInformations(){
      return "\tNombre de lots : "+string(nbrLotsToTake)+"\n"
      + "\tRisque : "+string(NormalizeDouble(this.riskInPourcent,2))+"%\n"
      + "\tPerte maximale : "+string(getMaxloss())+" "+string(AccountCurrency())+"\n";
    }

    virtual double getMaxloss(){
      double maxLoss = this.riskInPourcent * AccountBalance() / 100;

      return NormalizeDouble(maxLoss,5);
    }

};

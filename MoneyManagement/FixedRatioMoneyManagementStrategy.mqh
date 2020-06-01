#include "MoneyManagementStrategy.mqh"
#include "FixedRatioElement.mqh"

#define MAX_CHART_SIZE 40

class FixedRatioManagementStrategy : public MoneyManagementStrategy {

  protected :

  double initialBalance;
  double initaldeltaInUnits;
  double initialLots;
  double initalMaxLoss;
  double initialRiskInPourcent;
  FixedRatioElement *fixedRatioTable[MAX_CHART_SIZE];
  FixedRatioElement *fixedRatioElementForUnderInitialBalance;
  FixedRatioElement *actualFixedRatio;

  public :

     FixedRatioManagementStrategy(){
        this.amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
        this.initialBalance = 1000;
        this.initialRiskInPourcent = 20;
        this.initialLots = 0.5;
        this.initaldeltaInUnits = 1000;
        this.initalMaxLoss = this.initialRiskInPourcent * this.initialBalance /  100;
        this.fillFixedRatioTable();
     }

     FixedRatioManagementStrategy(double initialRiskInPourcentArg, double deltaInUnitsArg, double initialBalanceArg){
       this.amountUnitsInALot = MarketInfo(Symbol(),MODE_LOTSIZE);
       this.initialBalance = initialBalanceArg;
       this.initialRiskInPourcent = initialRiskInPourcentArg;
       this.initialLots = 0.5;
       this.initaldeltaInUnits = deltaInUnitsArg;
       this.initalMaxLoss = this.initialRiskInPourcent * this.initialBalance /  100;
       this.fillFixedRatioTable();
     }

     FixedRatioManagementStrategy(double initialRiskInPourcentArg, double deltaInUnitsArg, double initialBalanceArg, string instrument){
       this.amountUnitsInALot = MarketInfo(instrument,MODE_LOTSIZE);
       this.initialBalance = initialBalanceArg;
       this.initialRiskInPourcent = initialRiskInPourcentArg;
       this.initialLots = 0.5;
       this.initaldeltaInUnits = deltaInUnitsArg;
       this.initalMaxLoss = this.initialRiskInPourcent * this.initialBalance /  100;
       this.fillFixedRatioTable();
     }

    virtual void calculateInformationsToTakePosition(double stopLossInUnitsArg, double takeProfitInUnitsArg){
       this.stopLossInUnits = stopLossInUnitsArg;
       this.takeProfitInUnits = takeProfitInUnitsArg;
       this.actualFixedRatio = getFixedRatioElement();
       this.distanceFromStop = getDistanceFromStop();
       this.pourcentDistanceFromStop = (distanceFromStop * 100) / getPrice();
       this.riskInPourcent =  calculateRisk();
       this.amountPositionInAccountCurrency = MathRound((riskInPourcent * AccountBalance()) / pourcentDistanceFromStop);
       this.amountInUnits = convertIntoUnitsUsingQuotedCurrency();
       this.nbrLotsToTake = convertIntoLots();
       this.pipValueInAccountCurrency = this.getPipValueInAccountCurrency();
       this.levier = this.getLevier();
    }

    void changeAmountUnitsInALot(double newAmountUnitsInALot){
      this.amountUnitsInALot = newAmountUnitsInALot;
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

      if(actualFixedRatio.getMaxLoss() != NULL){
        maxLoss = actualFixedRatio.getMaxLoss();
      }

      return NormalizeDouble(maxLoss,5);
    }

    void freeTable(){
      for(int i=0; i < MAX_CHART_SIZE -1; ++i){
        FixedRatioElement *actualFixedRatioElement =fixedRatioTable[i];
        delete actualFixedRatioElement;
      }
      ArrayFree(fixedRatioTable);
      delete fixedRatioElementForUnderInitialBalance;
      delete actualFixedRatio;
    }

    double getRiskFromCurrentRixedElement(){
      this.actualFixedRatio = getFixedRatioElement();
      return calculateRiskFromEquity();
    }

   protected :

   double calculateRisk(){
     double risk = (actualFixedRatio.getMaxLoss() * 100) / AccountBalance();
     if(risk < 1){
       risk = 1;
     }

     return risk;
   }

   double calculateRiskFromEquity(){
     double risk = (actualFixedRatio.getMaxLoss() * 100) / AccountEquity();
     if(risk < 1){
       risk = 1;
     }

     return risk;
   }

   FixedRatioElement *getFixedRatioElement(){
     FixedRatioElement *fixedRatioElementSearched = NULL;

     if(AccountBalance() < this.initialBalance) {
       fixedRatioElementSearched = fixedRatioElementForUnderInitialBalance;
     } else {
       for(int i=0; i < MAX_CHART_SIZE -1; ++i){
         FixedRatioElement *actualFixedRatioElement =fixedRatioTable[i];
         FixedRatioElement *nextFixedRatioElement =fixedRatioTable[i+1];

         if(AccountBalance() >= actualFixedRatioElement.getBalance() && AccountBalance() < nextFixedRatioElement.getBalance()){
           fixedRatioElementSearched = actualFixedRatioElement;
         }
       }

       if (fixedRatioElementSearched == NULL){
         FixedRatioElement *lastFixedRatioElement =fixedRatioTable[MAX_CHART_SIZE-1];
         if(lastFixedRatioElement.getBalance() <= AccountBalance()){
           fixedRatioElementSearched = lastFixedRatioElement;
         }
       }
     }

     return fixedRatioElementSearched;
   }


   void fillFixedRatioTable(){

     double lotTable = this.initialLots ;
     double balanceTable = this.initialBalance;
     double maxLossTable = this.initalMaxLoss;
     //printf("Init FixedRatioTable");
     //double pourc = (maxLossTable * 100) / AccountEquity();
     //printf("Ligne 0 : "+balanceTable+" - "+lotTable+" - "+maxLossTable+" - "+pourc);
     FixedRatioElement *firstFixedRatioElement = new FixedRatioElement(balanceTable, lotTable, maxLossTable);
     fixedRatioTable[0] = firstFixedRatioElement;

     for(int i=1; i < MAX_CHART_SIZE; ++i){
       balanceTable = balanceTable + ((this.initaldeltaInUnits * lotTable) / this.initialLots);
       lotTable = this.initialLots * (i + 1);
       maxLossTable = this.initalMaxLoss * lotTable / this.initialLots;

       //pourc = (maxLossTable * 100) / balanceTable;
       //printf("Ligne "+i+" : "+balanceTable+" - "+lotTable+" - "+maxLossTable+" - "+pourc);
       FixedRatioElement *fixedRatioElement = new FixedRatioElement(balanceTable, lotTable, maxLossTable);
       fixedRatioTable[i] = fixedRatioElement;
     }

     fixedRatioElementForUnderInitialBalance = new FixedRatioElement(AccountBalance(), 0.25, 100);
   }


};

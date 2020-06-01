#include "../Utils/PriceUtils.mqh"

class MoneyManagementStrategy {

  protected :

  double amountUnitsInALot;
  double riskInPourcent;
  double nbrLotsToTake;
  double distanceFromStop;
  double pourcentDistanceFromStop;
  double amountPositionInAccountCurrency;
  double amountInUnits;
  double stopLossInUnits;
  double takeProfitInUnits;
  double pipValueInAccountCurrency;
  double levier;
  double minimumInALot;
  double typeMarket;

  PriceUtils *priceUtils;

  public :

  MoneyManagementStrategy(){
    priceUtils = new PriceUtils();
    typeMarket = MarketInfo(Symbol(),MODE_PROFITCALCMODE);
    if(typeMarket == 0) { //FOREX
      minimumInALot = 0.01;
    } else {
      minimumInALot = 0.1;
    }
  }

  virtual void calculateInformationsToTakePosition(double stopLossInUnitsArg, double takeProfitInUnitsArg){return;};
  virtual string getPositionInformations(){return "";};
  virtual double getMaxloss(){return 0;};

  double getNbrLotsToTake(){
     return nbrLotsToTake;
  }

  double getPipValue(){
    return this.pipValueInAccountCurrency;
  }

  double getAmountInUnits(){
    return this.amountInUnits;
  }

  protected :

  string getTakeProfitInformation(){
    string takeProfitInformation = NULL;

    if(takeProfitInUnits != 0){
      takeProfitInformation = "\tTP placé à : "+string(takeProfitInUnits)+" "+StringSubstr(Symbol(), 3)+" ("+string(priceUtils.getPipsFromPrice(MathAbs(getPriceForClosingPosition()-takeProfitInUnits)))+"pips)\n";
    } else {
      takeProfitInformation = "";
    }

    return takeProfitInformation;
  }

  bool isForBuying(){
     bool isForBuying = true;

     if(stopLossInUnits < Bid){
        isForBuying = true;
     } else if (stopLossInUnits > Ask) {
        isForBuying = false;
     } else {
        printf("Error : Stop Loss Level is between Bid And Ask");
     }

     return isForBuying;
  }

  double getDistanceFromStop(){
     double distanceFromStopValue  = 0;
     if(isForBuying()){
        distanceFromStopValue = Ask - stopLossInUnits;
     } else {
        distanceFromStopValue = stopLossInUnits - Bid;
     }

     return distanceFromStopValue;
  }

  double getPrice(){
     double price = 0;

     if(isForBuying()){
        price = Ask;
     } else {
        price = Bid;
     }

     return price;
  }

  string getPriceUsed(){
     string price;

     if(isForBuying()){
        price = "Ask";
     } else {
        price = "Bid";
     }

     return price;

  }

  int getMode(){
    int mode;

    if(isForBuying()){
       mode = MODE_ASK;
    } else {
       mode = MODE_BID;
    }

    return mode;
  }

  double getPriceForClosingPosition(){
     double price = 0;

     if(isForBuying()){
        price = Bid;
     } else {
        price = Ask;
     }

     return price;
  }

  double convertIntoUnitsUsingBaseCurrency(){
     double amountInUnitsValue = 0;
     string currencyForConverting = StringSubstr(Symbol(), 0, 3)+AccountCurrency();
     double priceForConverting = MarketInfo(currencyForConverting,getMode());
     if(priceForConverting != 0){
        amountInUnitsValue = amountPositionInAccountCurrency / priceForConverting;
     } else {
        currencyForConverting = AccountCurrency()+StringSubstr(Symbol(), 0, 3);
        priceForConverting = MarketInfo(currencyForConverting,getMode());
        amountInUnitsValue =  amountPositionInAccountCurrency * priceForConverting;
     }

     return amountInUnitsValue;
  }

  double convertIntoUnitsUsingQuotedCurrency(){
     double amountInUnitsValue = 0;
     string quotedCurrency = StringSubstr(Symbol(),  StringLen(Symbol()) -3);

     if(StringCompare(quotedCurrency, AccountCurrency()) == 0){
       amountInUnitsValue = amountPositionInAccountCurrency / getPrice();
     } else{
       string currencyForConverting = quotedCurrency+AccountCurrency();
       double priceForConverting = MarketInfo(currencyForConverting,getMode());
       if(priceForConverting != 0){
         amountInUnitsValue = amountPositionInAccountCurrency / priceForConverting;
       } else {
         currencyForConverting = AccountCurrency()+quotedCurrency;
         priceForConverting = MarketInfo(currencyForConverting,getMode());
         amountInUnitsValue =  amountPositionInAccountCurrency * priceForConverting;
       }
     }
     return amountInUnitsValue;
  }

  double convertIntoLots(){
    double convertionInLots = NormalizeDouble(amountInUnits / amountUnitsInALot,2);
    if(convertionInLots < minimumInALot){
      convertionInLots = minimumInALot;
    }
    return convertionInLots;
  }

  double getPipValueInAccountCurrency(){
    double pipValue = 0;

    if(typeMarket == 0) { //FOREX
      double nbUnitsForAPip = ((1 / priceUtils.getPipsMultiplicator()) * amountInUnits) / getPriceForClosingPosition();
      string baseCurrency = StringSubstr(Symbol(), 0, 3);
      if(StringCompare(baseCurrency, AccountCurrency()) == 0){
        pipValue = nbUnitsForAPip;
      } else {
        string currencyForConverting = baseCurrency+AccountCurrency();
        double priceForConverting = MarketInfo(currencyForConverting,getMode());
        if(priceForConverting != 0){
          pipValue = priceForConverting * nbUnitsForAPip;
        } else {
          currencyForConverting = AccountCurrency()+baseCurrency;
          priceForConverting = MarketInfo(currencyForConverting,getMode());
          pipValue = priceForConverting / nbUnitsForAPip;
        }
      }
    } else if (typeMarket == 1){ //CFD
      //TODO
    }
    return  NormalizeDouble(pipValue,2);
  }

  double getLevier(){
     double levierValue;

     if(AccountBalance() >= amountPositionInAccountCurrency) {
        levierValue = 1;
     } else {
        levierValue = NormalizeDouble(amountPositionInAccountCurrency / AccountBalance(),1);
     }

     return levierValue;
  }

};

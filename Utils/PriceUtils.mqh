#define LOT_FEES_PRICE 3.5

class PriceUtils {

  public :

  double getPipsFromPrice(double price){
    return NormalizeDouble(price * getPipsMultiplicator(), 1);
  }

  double getPriceFromPips(double pips){
    return pips / getPipsMultiplicator();
  }

  double getPriceFromPips(double pips, string instrument){
    return pips / getPipsMultiplicator(instrument);
  }

  double getPipsMultiplicator(){
    return getPipsMultiplicator(Symbol());
  }

  double getPipsMultiplicator(string instrument){
    double multiplicator = 0;

    string firstCurrency = StringSubstr(instrument, 0, 3);
    string secondCurrency = StringSubstr(instrument, 3, 6);

    double typeMarket = MarketInfo(instrument,MODE_PROFITCALCMODE);
    if(typeMarket == 0) { //FOREX
      if(StringCompare(secondCurrency, "JPY", false) == 0){
        multiplicator = 100;
      } else {
        multiplicator = 10000;
      }
    } else if (typeMarket == 1){ //CFD
      multiplicator = 10;
    }

    return multiplicator;
  }

  int getsPointsFromPips(int pips) {
    int nbrPoint = 0;
    int digit = (int)MarketInfo(Symbol(), MODE_DIGITS);

    if (digit == 2 || digit == 4) {
      nbrPoint = pips;
    }
    else if (digit == 3 || digit == 5) {
      nbrPoint = pips * 10;
    } else {
      nbrPoint = pips;
    }

    return nbrPoint;
  }

  double calculatePipValue()
  {
    double pipValue = 0.1;

    int digit = Digits();
    if (digit == 2 || digit == 3){
      pipValue = 0.01;
    }
    else if (digit == 4 || digit == 5) {
      pipValue = 0.0001;
    }

    return pipValue;
  }

  double normalizePrice(double price)
  {
    // double tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
    // if(tickSize!=0) {
    //    return (NormalizeDouble(MathRound(price / tickSize) * tickSize, Digits()));
    // }

    return(NormalizeDouble(price, Digits()));
  }

  double normalizeEntrySize(double lots){
    double minlot  = MarketInfo(_Symbol, MODE_MINLOT);
    double maxlot  = MarketInfo(_Symbol, MODE_MAXLOT);
    double lotstep = MarketInfo(_Symbol, MODE_LOTSTEP);

    double normalizedLots = NormalizeDouble(lots,2);

    if(normalizedLots < minlot){
      normalizedLots = minlot;
    } else if (normalizedLots > maxlot){
      normalizedLots = maxlot;
    }

    return normalizedLots;
  }

  double getFeesInUSD(double quantity){
    return 2 * quantity * LOT_FEES_PRICE;
  }

  double getPipValueInSpecificCurrency(double quantityInLot, int typePosition, string currency){
    double pipValue = 0;

    double typeMarket = MarketInfo(Symbol(),MODE_PROFITCALCMODE);
    if(typeMarket == 0) { //FOREX
      int mode;
      double priceForClosinPosition = 0;
      if(typePosition == OP_BUY){
        priceForClosinPosition = Bid;
        mode = MODE_ASK;
      } else {
        priceForClosinPosition = Ask;
        mode = MODE_BID;
      }

      double nbUnitsForAPip = ((1 / getPipsMultiplicator()) * quantityInLot * 100000) / priceForClosinPosition;
      string baseCurrency = StringSubstr(Symbol(), 0, 3);
      if(StringCompare(baseCurrency, currency) == 0){
        pipValue = nbUnitsForAPip;
      } else {
        string currencyForConverting = baseCurrency+currency;
        double priceForConverting = MarketInfo(currencyForConverting,mode);
        if(priceForConverting != 0){
          pipValue = priceForConverting * nbUnitsForAPip;
        } else {
          currencyForConverting = currency+baseCurrency;
          priceForConverting = MarketInfo(currencyForConverting,mode);
          pipValue = priceForConverting / nbUnitsForAPip;
        }
      }
    } else if (typeMarket == 1){ //CFD
      //TODO
    }
    return  NormalizeDouble(pipValue,2);
  }

};

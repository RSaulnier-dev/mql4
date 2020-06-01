#include "./PriceUtils.mqh"

class EdgingCalculator {

private :

    PriceUtils *priceUtils;

public :

  double bidStartSens1;
  double askStartSens1;
  double bidStartSens2;
  double askStartSens2;
  double nbrPipTakeProfitSens1;
  double nbrPipTakeProfitSens2;
  double priceTakeProfitSens1;
  double priceTakeProfitSens2;
  double priceStopLossSens1;
  double priceStopLossSens2;
  double nbrPipGap;
  double quantityInitial;
  double quantityEdging;
  double quantityFive;
  double pipePriceInitialInUSD;
  double pipePriceEdgingInUSD;
  double pipePriceFiveInUSD;
  double edgingFactor;
  double initialFeesInUSD;
  double pourcentToAddTp;

  EdgingCalculator(){
    priceUtils = new PriceUtils();
  }

  void calculateInformations(double pourcentageGapArg, double quantityArg, double nbrPipsTpArg, double pourcentToAddTpArg, int typePosition){
    quantityInitial = quantityArg;
    nbrPipTakeProfitSens1 = nbrPipsTpArg;
    pourcentToAddTp = pourcentToAddTpArg;

    pipePriceInitialInUSD = priceUtils.getPipValueInSpecificCurrency(quantityInitial, typePosition, "USD");

    initialFeesInUSD = priceUtils.getFeesInUSD(quantityInitial);
    nbrPipGap = (pourcentageGapArg * nbrPipTakeProfitSens1) / 100;

    edgingFactor = (2 * (nbrPipTakeProfitSens1 - (initialFeesInUSD / pipePriceInitialInUSD))) / (nbrPipTakeProfitSens1 + nbrPipGap + (initialFeesInUSD / pipePriceInitialInUSD));
    nbrPipTakeProfitSens2 = (nbrPipGap + (initialFeesInUSD / pipePriceInitialInUSD) * (1 + edgingFactor)) / (edgingFactor - 1);
    pipePriceFiveInUSD = (2 * (pipePriceInitialInUSD * (edgingFactor * (nbrPipTakeProfitSens1 + nbrPipGap) - nbrPipTakeProfitSens1) + initialFeesInUSD * (edgingFactor + 1))) / (nbrPipTakeProfitSens1 - (initialFeesInUSD / pipePriceInitialInUSD));

    quantityEdging = edgingFactor * quantityInitial;
    quantityFive = (pipePriceFiveInUSD * quantityInitial) / pipePriceInitialInUSD;
    pipePriceEdgingInUSD = edgingFactor * pipePriceInitialInUSD;

    bidStartSens1 = Bid;
    askStartSens1 = Ask;

    double priceFromPipsZone1 = priceUtils.getPriceFromPips(nbrPipTakeProfitSens1 + (nbrPipTakeProfitSens1 * pourcentToAddTpArg ) / 100);
    double priceFromPipsZone2 = priceUtils.getPriceFromPips(nbrPipTakeProfitSens2 + (nbrPipTakeProfitSens2 * pourcentToAddTpArg ) / 100);
    double priceFromPipsGap = priceUtils.getPriceFromPips(nbrPipGap);

    if(typePosition == OP_BUY){
      bidStartSens2 = Bid - priceFromPipsGap;
      askStartSens2 = Ask - priceFromPipsGap;

      priceTakeProfitSens1 = Ask + priceFromPipsZone1;
      priceTakeProfitSens2 = bidStartSens2 - priceFromPipsZone2;

      priceStopLossSens1 = askStartSens2 - priceFromPipsZone2;
      priceStopLossSens2 = Bid + priceFromPipsZone1;

    } else if(typePosition == OP_SELL){
      bidStartSens2 = Bid + priceFromPipsGap;
      askStartSens2 = Ask + priceFromPipsGap;

      priceTakeProfitSens1 = Bid - priceFromPipsZone1;
      priceTakeProfitSens2 = askStartSens2 + priceFromPipsZone2;

      priceStopLossSens1 = bidStartSens2 + priceFromPipsZone2;
      priceStopLossSens2 = Ask - priceFromPipsZone1;
    }

    printDebug(typePosition);
  }

  void printDebug(int typePosition){
    printf("----");
    printf("typePosition == OP_SELL");
    printf("quantityFive : "+quantityFive);
    printf("edgingFactor : " + edgingFactor);
    printf("initialFeesInUSD: " + initialFeesInUSD);
    printf("pipePriceInitialInUSD: " + pipePriceInitialInUSD);
    printf("nbrPipGap : "+nbrPipGap);
    printf("bidStartSens2 : "+bidStartSens2);
    printf("askStartSens2 : "+askStartSens2);
    printf("priceTakeProfitSens1 : "+priceTakeProfitSens1);
    printf("nbrPipTakeProfitSens1 : "+nbrPipTakeProfitSens1);
    printf("priceTakeProfitSens2 : "+priceTakeProfitSens2);
    printf("nbrPipTakeProfitSens2 : "+nbrPipTakeProfitSens2);
    printf("----");
  }
};

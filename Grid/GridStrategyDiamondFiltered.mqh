#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Indicators/BandsIndicator.mqh>

class GridStrategyDiamondFiltered : public GridStrategy {

  private :

  double greenLineOut1;
  double greenLineOut2;

  double greenLineIn;
  double redLineIn;

  double redLineOut1;
  double redLineOut2;

  double greySupLine1;
  double greyInfLine1;
  double yellowLine1;

  bool isDiamondBuyingSignal;
  bool isDiamondSellingSignal;

  double ma50_1;
  double ma50_2;
  double ma200_1;
  double ma200_2;

  bool maHasjustChanged;
  int maTrendType;

  int nbrBuySignal;
  int nbrSellSignal;

  int nbrCandleSinceLastBuySignal;
  int nbrCandleSinceLastSellSignal;

  double lastBuyClose;
  double lastBuyOpen;
  double lastSellClose;
  double lastSellOpen;

  bool isBuySignal;
  bool isSellSignal;

  bool isCheckingBuySignal;
  bool isCheckingSellSignal;

  BandsIndicator *bandsIndicator;

  datetime lastInitIndicatorsTime;

  void initIndicators(){
    if(Time[0] != lastInitIndicatorsTime){

      isBuySignal = false;
      isSellSignal = false;

      ma50_1 = iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1);
      ma50_2 = iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2);
      ma200_1 = iMA(Symbol(),Period(),200,0,MODE_SMA,PRICE_CLOSE,1);
      ma200_2 = iMA(Symbol(),Period(),200,0,MODE_SMA,PRICE_CLOSE,2);

      maHasjustChanged = false;
      if(ma200_1 > ma50_1 && maTrendType == OP_BUY) {
        maTrendType = OP_SELL;
        maHasjustChanged = true;
      } else if(ma200_1 < ma50_1 && maTrendType == OP_SELL) {
        maTrendType = OP_BUY;
        maHasjustChanged = true;
      }

      if(maHasjustChanged){
        nbrBuySignal = 0;
        nbrSellSignal = 0;
        lastBuyClose = 0;
        lastBuyOpen = 0;
        lastSellClose = 0;
        lastSellOpen = 0;
        nbrCandleSinceLastBuySignal = 0;
        nbrCandleSinceLastSellSignal = 0;
        isCheckingBuySignal = false;
        isCheckingSellSignal = false;
      }

      bandsIndicator.recalculate();

      greenLineOut1 = bandsIndicator.getGreenOutLine(1);
      greenLineOut2 = bandsIndicator.getGreenOutLine(2);

      redLineOut1 = bandsIndicator.getRedOutLine(1);
      redLineOut2 = bandsIndicator.getRedOutLine(2);

      yellowLine1 = bandsIndicator.getYellowMiddleLine(1);
      greySupLine1 = bandsIndicator.getGraySupLine(1);
      greyInfLine1 = bandsIndicator.getGrayInfLine(1);

      isDiamondBuyingSignal = iCustom(Symbol(),Period(), "Reversal Diamond", 0, 1) != EMPTY_VALUE ? true : false;
      isDiamondSellingSignal = iCustom(Symbol(),Period(), "Reversal Diamond", 1, 1) != EMPTY_VALUE ? true : false;

      if(isDiamondBuyingSignal){
        lastBuyClose = Close[1];
        lastBuyOpen = Open[1];
        if(maTrendType == OP_BUY){
          //Trend
          if(lastBuyClose < Close[1] && lastBuyOpen < Open[1]){
            if(Close[1] > ma50_1){
              isBuySignal = true;
              nbrCandleSinceLastBuySignal = 0;
            } else {
              isCheckingBuySignal = true;
            }
          }
        } else {
          //Counter trend
          if(lastBuyClose > Close[1] && lastBuyOpen > Open[1]){
            isSellSignal = true;
            nbrCandleSinceLastSellSignal = 0;
          }
        }
      } else if(isDiamondSellingSignal){
        lastSellClose = Close[1];
        lastSellOpen = Open[1];
        if(maTrendType == OP_SELL){
          //Trend
          if(lastBuyClose > Close[1] && lastBuyOpen > Open[1]){
            if(Close[1] < ma50_1){
              isSellSignal = true;
              nbrCandleSinceLastSellSignal = 0;
            } else {
              isCheckingSellSignal = true;
            }
          }
        } else {
          //Counter trend
          if(lastBuyClose < Close[1] && lastBuyOpen < Open[1]){
            isBuySignal = true;
            nbrCandleSinceLastBuySignal = 0;
          }
        }
      }

      if(isCheckingBuySignal){
         if(nbrCandleSinceLastBuySignal < 15){
           if(Close[1] > ma50_1 && (lastBuyClose < Close[1] && lastBuyOpen < Open[1])){
             isBuySignal = true;
             nbrCandleSinceLastBuySignal = 0;
             isCheckingBuySignal = false;
           } else{
             nbrCandleSinceLastBuySignal++;
           }
         } else {
           isCheckingBuySignal = false;
           nbrCandleSinceLastBuySignal = 0;
         }
      } else if(isCheckingSellSignal){
        if(nbrCandleSinceLastSellSignal < 15){
          if(Close[1] < ma50_1 && (lastBuyClose > Close[1] && lastBuyOpen > Open[1])){
            isSellSignal = true;
            nbrCandleSinceLastSellSignal = 0;
            isCheckingSellSignal = false;
          } else {
            nbrCandleSinceLastSellSignal++;
          }
        } else {
          isCheckingSellSignal = false;
          nbrCandleSinceLastSellSignal = 0;
        }
      }

      lastInitIndicatorsTime = Time[0];
    }
  }

  public :

  GridStrategyDiamondFiltered(){
    bandsIndicator = new BandsIndicator(30,  25, 100);

    ma50_1 = iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1);
    ma50_2 = iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2);
    ma200_1 = iMA(Symbol(),Period(),200,0,MODE_SMA,PRICE_CLOSE,1);
    ma200_2 = iMA(Symbol(),Period(),200,0,MODE_SMA,PRICE_CLOSE,2);

    if(ma200_1 > ma50_1) {
      maTrendType = OP_SELL;
    } else {
      maTrendType = OP_BUY;
    }

    nbrBuySignal = 0;
    nbrSellSignal = 0;
    lastBuyClose = 0;
    lastBuyOpen = 0;
    lastSellClose = 0;
    lastSellOpen = 0;
    nbrCandleSinceLastBuySignal = 0;
    nbrCandleSinceLastSellSignal = 0;
    isCheckingBuySignal = false;
    isCheckingSellSignal = false;
  }

  void releaseStrategy(){

  }

  void setSpecificValues(){
    this.newOrderOpeningType =  OpenPositionIfNewSignal;
    this.updateAction = OnNewBar;

    lastInitIndicatorsTime = Time[1];
  }

  void onEachTick(){
  }

  void onNewBar(){
    initIndicators();
    double nbrPips = 0;

    if(isSellingSignal(OP_SELL, OP_SELL, 0) && this.gridBasketsManager.getNbrSellBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0);
      //nbrPips = MathAbs(orderUtils.convertQuotedPriceInNbrPip(MarketInfo(Symbol(),MODE_ASK) - yellowLine1));
      //this.gridBasketsManager.addNewBakset(OP_SELL, OP_SELL, 0, nbrPips);
    }
    if(isBuyingSignal(OP_BUY, OP_BUY, 0) && this.gridBasketsManager.getNbrBuyBaskets() == 0){
      this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0);
      //nbrPips =  MathAbs(orderUtils.convertQuotedPriceInNbrPip(yellowLine1 - MarketInfo(Symbol(),MODE_BID)));
      //this.gridBasketsManager.addNewBakset(OP_BUY, OP_BUY, 0,nbrPips);
    }
  }

  bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    initIndicators();

    return isBuySignal;
  }

  bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    initIndicators();

    return isSellSignal;
  }

  void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){
  }

  void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){
  }

  bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;


    return isClosing;
  }

  bool isClosingCoverOrderSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){
    bool isClosing = false;

    return isClosing;
  }
};

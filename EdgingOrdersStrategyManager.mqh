#include "StrategyManager.mqh"
#include "Utils/EdgingCalculator.mqh"

class EdgingOrdersStrategyManager : public StrategyManager {

  protected :

  virtual void onTick(){

    if(statusPosition != noPosition){
      int checkNbrOrdersOpened = orderUtils.numberTicketsOpenedByMagicTicket(magicNumber);
      if(checkNbrOrdersOpened < nbrOrdersOpened){
        //Verify if order has been automatically closed
        buySell.closeAllOpenOrdersForMagicNumber(magicNumber, true);
        nbrOrdersOpened = 0;
        nbrOrdersManaged = 0;
        statusPosition = noPosition;
        //nbrTotalOrder++;

        onCloseEvent();
      } else if(checkNbrOrdersOpened > nbrOrdersOpened) {
        //Verify if pending order has been activated
        nbrOrdersOpened = checkNbrOrdersOpened;
      }
    }

    onStartTickEvent();

    if(findPositionsOnTick()){
      generalProcessManagement();
    }

    onEndTickEvent();
  }

  virtual void onNewCandle(){

    onStartNewCandleEvent();

    if(!findPositionsOnTick()){
      generalProcessManagement();
    }

    onEndNewCandleEvent();
  }

  //Redefine all these functions
  virtual void initIndicators(){return;};
  virtual bool findPositionsOnTick(){return false;};
  virtual void onCloseEvent(){return;};
  virtual void onStartTickEvent(){return;};
  virtual void onEndTickEvent(){return;};
  virtual void onStartNewCandleEvent(){return;};
  virtual void onEndNewCandleEvent(){return;};
  virtual void onBuyEvent(){return;};
  virtual void onSellEvent(){return;};
  virtual bool checkIfOpenNewBuyPosition(){return false;};
  virtual bool checkIfOpenNewSellPosition(){return false;};
  virtual bool checkIfClosePositions(){return false;};

  double takeProfitInPips;
  double pourcentageGap;
  double pourcentageToAddToTp;

  int maxNbrOrders;
  int nbrOrdersOpened;
  int nbrOrdersManaged;

  //int nbrTotalOrder;

  EdgingCalculator *edgingCalculator;

  virtual void specificInitialization(){

  }

  enum statusPositionEnum {
    buyPosition = OP_BUY,
    sellPosition = OP_SELL,
    noPosition = 6,
  };

  statusPositionEnum statusPosition;

  bool checkIfMustRevertOrder(){
    bool checkIfMustRevertOrder = false;

    if((statusPosition == buyPosition && checkIfOpenNewSellPosition() == true)
        || (statusPosition == sellPosition && checkIfOpenNewBuyPosition() == true)){
        checkIfMustRevertOrder = true;
    }

    return checkIfMustRevertOrder;
  }

  void generalProcessManagement(){

    //Initialize indicators
    initIndicators();

    //Verify if must close all orders
    if(statusPosition != noPosition){
      if(checkIfClosePositions()){
        buySell.closeAllOpenOrdersForMagicNumber(magicNumber, true);
        nbrOrdersOpened = orderUtils.numberTicketsOpenedByMagicTicket(magicNumber);
        statusPosition = noPosition;
      }
    }

    //Verify if open new order
    // && nbrTotalOrder < 5
    if(isCurrenciesCanBeTrade()){
      if(statusPosition == noPosition){
        if(checkIfOpenNewBuyPosition()){
          sendInitialBuyOrder();
        } else if(checkIfOpenNewSellPosition()){
          sendInitialSellOrder();
        }
      } else {
        // printf("nbrOrdersOpened : "+nbrOrdersOpened);
        // printf("nbrOrdersManaged : "+nbrOrdersManaged);
        if(nbrOrdersOpened == 2 && nbrOrdersManaged == 2 && nbrOrdersManaged < maxNbrOrders){
          if(statusPosition == buyPosition) {
            buySell.buyStop(edgingCalculator.askStartSens1, edgingCalculator.quantityInitial,
              edgingCalculator.priceStopLossSens1, edgingCalculator.priceTakeProfitSens1, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          } else if(statusPosition == sellPosition){
            buySell.sellStop(edgingCalculator.bidStartSens1, edgingCalculator.quantityInitial,
              edgingCalculator.priceStopLossSens1, edgingCalculator.priceTakeProfitSens1, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          }
        } else if(nbrOrdersOpened == 3 && nbrOrdersManaged == 3 && nbrOrdersManaged < maxNbrOrders){
          if(statusPosition == buyPosition) {
            buySell.sellStop(edgingCalculator.bidStartSens2, edgingCalculator.quantityEdging,
              edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          } else if(statusPosition == sellPosition){
            buySell.buyStop(edgingCalculator.askStartSens2, edgingCalculator.quantityEdging,
              edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          }
        } else if (nbrOrdersOpened == 4 && nbrOrdersManaged == 4 && nbrOrdersManaged < maxNbrOrders){
          if(statusPosition == buyPosition) {
            buySell.buyStop(edgingCalculator.askStartSens1, edgingCalculator.quantityFive,
              edgingCalculator.priceStopLossSens1, edgingCalculator.priceTakeProfitSens1, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          } else if(statusPosition == sellPosition){
            buySell.sellStop(edgingCalculator.bidStartSens1, edgingCalculator.quantityFive,
              edgingCalculator.priceStopLossSens1, edgingCalculator.priceTakeProfitSens1, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          }
        } else if(nbrOrdersOpened == 5 && nbrOrdersManaged == 5 && nbrOrdersManaged < maxNbrOrders){
          if(statusPosition == buyPosition) {
            buySell.sellStop(edgingCalculator.bidStartSens2, edgingCalculator.quantityEdging,
              edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          } else if(statusPosition == sellPosition){
            buySell.buyStop(edgingCalculator.askStartSens2, edgingCalculator.quantityEdging,
              edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker);
            ++nbrOrdersManaged;
          }
        }
      }
    }
  }

  void sendInitialBuyOrder(){
    double tmpStopLossInUnits = Bid - priceUtils.getPriceFromPips(takeProfitInPips);
    double takeProfitInUnits = Ask + priceUtils.getPriceFromPips(takeProfitInPips);
    moneyManagementStrategy.calculateInformationsToTakePosition(tmpStopLossInUnits, takeProfitInUnits);
    edgingCalculator.calculateInformations(pourcentageGap, moneyManagementStrategy.getNbrLotsToTake(), takeProfitInPips, pourcentageToAddToTp, OP_BUY);

    // printf("Bid : "+Bid);
    // printf("Ask : "+Ask);
    // printf("Stop loss : "+edgingCalculator.priceTakeProfitSens2);
    // printf("Take Profit : "+edgingCalculator.priceTakeProfitSens1);
    // printf("BUY : "+moneyManagementStrategy.getPositionInformations());
    sendBuyOrder(edgingCalculator.quantityInitial);
  }

  void sendBuyOrder(double quantity){
    if(buySell.buyAtMarker(quantity,
      edgingCalculator.priceStopLossSens1,
      edgingCalculator.priceTakeProfitSens1,
      edgingCalculator.pipePriceInitialInUSD, NULL,
      magicNumber,
      isECNBroker)){
        statusPosition = buyPosition;
        ++nbrOrdersOpened;
        ++nbrOrdersManaged;
        onBuyEvent();

        if(buySell.sellStop(edgingCalculator.bidStartSens2, edgingCalculator.quantityEdging,
          edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker)){
            ++nbrOrdersManaged;
        }
    }
  }

  void sendInitialSellOrder(){
    double tmpStopLossInUnits = Ask + priceUtils.getPriceFromPips(takeProfitInPips);
    double takeProfitInUnits = Bid - priceUtils.getPriceFromPips(takeProfitInPips);
    moneyManagementStrategy.calculateInformationsToTakePosition(tmpStopLossInUnits, takeProfitInUnits);
    edgingCalculator.calculateInformations(pourcentageGap, moneyManagementStrategy.getNbrLotsToTake(), takeProfitInPips, pourcentageToAddToTp, OP_SELL);

    // printf("Bid : "+Bid);
    // printf("Ask : "+Ask);
    // printf("Stop loss : "+edgingCalculator.priceTakeProfitSens2);
    // printf("Take Profit : "+edgingCalculator.priceTakeProfitSens1);
    // printf("SELL : "+moneyManagementStrategy.getPositionInformations());
    sendSellOrder(edgingCalculator.quantityInitial);
  }

  void sendSellOrder(double quantity){
    if(buySell.sellAtMarker(quantity,
      edgingCalculator.priceStopLossSens1,
      edgingCalculator.priceTakeProfitSens1,
      edgingCalculator.pipePriceInitialInUSD, NULL,
      magicNumber,
      isECNBroker)){
        statusPosition = sellPosition;
        ++nbrOrdersOpened;
        ++nbrOrdersManaged;
        onSellEvent();

        if(buySell.buyStop(edgingCalculator.askStartSens2, edgingCalculator.quantityEdging,
          edgingCalculator.priceStopLossSens2, edgingCalculator.priceTakeProfitSens2, NULL, NULL, magicNumber, isECNBroker)){
            ++nbrOrdersManaged;
        }
    }
  }


};

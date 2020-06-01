#include "StrategyManager.mqh"

class MultiOrdersStrategyManager : public StrategyManager {

  protected :

  virtual void onTick(){
    //Verify if order has been automatically closed
    if(statusPosition != noPosition){
      int checkNbrOrdersOpened = orderUtils.numberTicketsOpenedByMagicTicket(magicNumber);
      if(checkNbrOrdersOpened < nbrOrdersOpened){
        nbrOrdersOpened = checkNbrOrdersOpened;
        if(nbrOrdersOpened == 0){
          statusPosition = noPosition;
        }
        onCloseEvent();
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
  virtual void setStopLossAndTakeProfitBuyPosition(){return;};
  virtual bool checkIfOpenNewSellPosition(){return false;};
  virtual void setStopLossAndTakeProfitSellPosition(){return;};
  virtual bool checkIfClosePositions(){return false;};

  virtual void updateStopLossAndTakeProfitBuyPosition(){return;};
  virtual void updateStopLossAndTakeProfitSellPosition(){return;};

  //Multi order redifinition functions
  virtual bool checkIfAddNewBuyPosition(){return false;};
  virtual bool checkIfAddNewSellPosition(){return false;};

  double stopLoss;
  double takeProfit;
  int lastTicket;
  int maxNbrOrders;
  int nbrOrdersOpened;

  virtual void specificInitialization(){
    loadPositionsIfAlreadyExist();
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

  void setStopLossAndTakeProfitOnNbrPips(double stopLossInPipsArg, double takeProfitInPipsArg, statusPositionEnum statusPositionArg){
    if(statusPositionArg == buyPosition){
      this.stopLoss = Ask - priceUtils.getPriceFromPips(stopLossInPipsArg);
      if(takeProfitInPipsArg != 0){
        this.takeProfit = Ask + priceUtils.getPriceFromPips(takeProfitInPipsArg);
      }
    }
    else if(statusPositionArg == sellPosition) {
      this.stopLoss = Bid + priceUtils.getPriceFromPips(stopLossInPipsArg);
      if(takeProfitInPipsArg != 0){
        this.takeProfit = Bid - priceUtils.getPriceFromPips(takeProfitInPipsArg);
      }
    }
  }

  void generalProcessManagement(){

    //Initialize indicators
    initIndicators();

    //Verify if must close all orders
    if(statusPosition != noPosition){
      if(checkIfClosePositions()){
        buySell.closeAllOpenOrdersForMagicNumber(magicNumber, false);
        nbrOrdersOpened = orderUtils.numberTicketsOpenedByMagicTicket(magicNumber);
        statusPosition = noPosition;
      }
    }

    //Verify if open new order
    if(isCurrenciesCanBeTrade()){
      if(statusPosition == noPosition){
        if(checkIfOpenNewBuyPosition()){
          sendBuyOrder();
        } else if(checkIfOpenNewSellPosition()){
          sendSellOrder();
        }
      } else if(statusPosition == buyPosition && nbrOrdersOpened < maxNbrOrders) {
        if(checkIfAddNewBuyPosition()){
          sendBuyOrder();
        }
      } else if(statusPosition == sellPosition && nbrOrdersOpened < maxNbrOrders) {
        if(checkIfAddNewSellPosition()){
          sendSellOrder();
        }
      }
    }

    //Trailing stop
    if(statusPosition != noPosition){
      updateAllTrailingStop();
    }
  }

  void sendBuyOrder(){
    setStopLossAndTakeProfitBuyPosition();
    if(stopLoss != 0){
      moneyManagementStrategy.calculateInformationsToTakePosition(stopLoss, takeProfit);
      if(buySell.buyAtMarker(moneyManagementStrategy.getNbrLotsToTake(),
        stopLoss,
        takeProfit,
        moneyManagementStrategy.getPipValue(), moneyManagementStrategy.getMaxloss(),
        magicNumber,
        isECNBroker)){
          statusPosition = buyPosition;
          increaseNumberOpenedOrders();
          onBuyEvent();
      }
    }
  }

  void sendSellOrder(){
    setStopLossAndTakeProfitSellPosition();
    if(stopLoss != 0){
      moneyManagementStrategy.calculateInformationsToTakePosition(stopLoss, takeProfit);
      if(buySell.sellAtMarker(moneyManagementStrategy.getNbrLotsToTake(),
        stopLoss,
        takeProfit,
        moneyManagementStrategy.getPipValue(), moneyManagementStrategy.getMaxloss(),
        magicNumber,
        isECNBroker)){
          statusPosition = sellPosition;
          increaseNumberOpenedOrders();
          onSellEvent();
      }
    }
  }

  void updateAllTrailingStop(){
    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if(OrderCloseTime() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
            trailingStopLossStrategy.update(OrderTicket());
          }
       }
    }
  }

  private :

  void loadPositionsIfAlreadyExist(){
    nbrOrdersOpened = orderUtils.numberTicketsOpenedByMagicTicket(magicNumber);

    if(nbrOrdersOpened != 0){
      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
         bool res = OrderSelect(i, SELECT_BY_POS);
         if(res == true) {
            if(OrderCloseTime() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
              if(OrderType() == OP_BUY){
                statusPosition = buyPosition;
                break;
              } else if(OrderType() == OP_SELL){
                statusPosition = sellPosition;
                break;
              }
            }
         }
      }
    } else {
      statusPosition = noPosition;
    }
  }

  void increaseNumberOpenedOrders(){
    if(nbrOrdersOpened <  maxNbrOrders){
      ++nbrOrdersOpened;
    }
  }

  void decreaseNumberOpenedOrders(){
    if(nbrOrdersOpened > 0){
      --nbrOrdersOpened;
      if(nbrOrdersOpened == 0){
        statusPosition = noPosition;
      }
    }
  }

};

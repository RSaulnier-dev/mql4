#include "StrategyManager.mqh"

class OneOrderAtATimeStrategyManager : public StrategyManager {

  protected :

  virtual void onTick(){
    //Verify if order has been automatically closed
    if(statusPosition != noPosition){
      if(orderUtils.checkIfOrderClosed(currentTicket)){
        onCloseEvent();
        initOrder();
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
  virtual bool checkIfClosePosition(){return false;};

  double stopLoss;
  double takeProfit;

  virtual void specificInitialization(){
    initOrder();
    loadPositionIfAlreadyExist();
  }

  enum statusPositionEnum {
    buyPosition = OP_BUY,
    sellPosition = OP_SELL,
    noPosition = 6,
  };

  statusPositionEnum statusPosition;
  int currentTicket;

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

    //Verify if close last order
    if(statusPosition != noPosition){
      if(checkIfClosePosition()){
        if(buySell.closeOrder(currentTicket)){
          initOrder();
        }
      }
    }

    //Verify if open new order
    if(isCurrenciesCanBeTrade()){
      if(statusPosition == noPosition){
        if(checkIfOpenNewBuyPosition()){
          buy();
        } else if(checkIfOpenNewSellPosition()){
          sell();
        }
      }
    }

    //Trailing stop
    if(statusPosition != noPosition){
        trailingStopLossStrategy.update(currentTicket);
    }
  }

  void buy(){
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
          currentTicket = orderUtils.findOpenTicketByMagicNumberAndCurrentCurrency(magicNumber);
          onBuyEvent();
      }
    }
  }

  void sell(){
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
          currentTicket = orderUtils.findOpenTicketByMagicNumberAndCurrentCurrency(magicNumber);
          onSellEvent();
      }
    }
  }

  private :

  void initOrder(){
    stopLoss = 0;
    takeProfit = 0;
    currentTicket = 0;
    statusPosition = noPosition;
  }

  void loadPositionIfAlreadyExist(){
    currentTicket = orderUtils.findOpenTicketByMagicNumberAndCurrentCurrency(magicNumber);
    if(currentTicket != 0){
      int type = orderUtils.typeOfPosition(currentTicket);

      if(type == OP_BUY){
        statusPosition = buyPosition;
      } else if(type == OP_SELL){
        statusPosition = sellPosition;
      }
    }
  }

};

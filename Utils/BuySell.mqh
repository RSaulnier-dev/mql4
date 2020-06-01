#include "./ErrorUtils.mqh"
#include "./PriceUtils.mqh"
#include "./NotificationUtils.mqh"
#include "../MoneyManagement/MoneyManagementStrategy.mqh"

#define TRADE_RETRY_COUNT 4
#define TRADE_RETRY_WAIT  1000
#define TRADE_CHANGE_SL_TP_RETRY_WAIT  2000

static int slippageInPips = 20;

static bool notifyInsteadOfSendingOrder = false;
static bool notifyWithAlert = true;
static bool notifyWithPush = false;
static bool notifyWithEmail = false;

//http://www.coensio.com/wp/spread-stop-loss-and-take-profit/
class BuySell {

  protected :

  ErrorUtils *errorUtils;
  PriceUtils *priceUtils;
  NotificationUtils *notificationUtils;
  bool isLastError130;
  int lastTicket;

  public :

  void release(){
    delete errorUtils;
    delete priceUtils;
    delete notificationUtils;
  }

  BuySell(){
    errorUtils = new ErrorUtils();
    priceUtils = new PriceUtils();
    notificationUtils = new NotificationUtils();
    isLastError130 = false;
    lastTicket = 0;
  }

  BuySell(bool displayAlertArg, bool displayPrinfArg){
    errorUtils = new ErrorUtils(displayAlertArg, displayPrinfArg);
    priceUtils = new PriceUtils();
    notificationUtils = new NotificationUtils();
    isLastError130 = false;
    lastTicket = 0;
  }

  BuySell(bool displayAlertArg, bool displayPrinfArg, bool displayNotificationArg){
    errorUtils = new ErrorUtils(displayAlertArg, displayPrinfArg, displayNotificationArg);
    priceUtils = new PriceUtils();
    notificationUtils = new NotificationUtils();
    isLastError130 = false;
    lastTicket = 0;
  }

  BuySell(ErrorUtils *errorUtilsArg, PriceUtils *priceUtilsArg){
    this.errorUtils = errorUtilsArg;
    this.priceUtils = priceUtilsArg;
    notificationUtils = new NotificationUtils();
    isLastError130 = false;
    lastTicket = 0;
  }

  bool isLastErrorNo130(){
    bool returnedValue = false;

    if(isLastError130 == true){
      returnedValue = true;
      isLastError130 = false;
    }

    return returnedValue;
  }

  int getLastTicket(){
    return lastTicket;
  }

  bool doubleStopOrder(double lotsArg, double distanceFromPriceInPipsArg, double stopLossInPipsArg, double takeProfitInPipsArg, int slippageArg, int magicArg, bool isECNBrokerArg){

    double calculatedSellStopTakeProfitInUnits;
    double calculatedSellStopStopLossInUnits;
    double calculatedBuyStopTakeProfitInUnits;
    double calculatedBuyStopStopLossInUnits;

    double buyPrice = Ask + priceUtils.getPriceFromPips(distanceFromPriceInPipsArg);
    double sellPrice = Bid - priceUtils.getPriceFromPips(distanceFromPriceInPipsArg);

    calculatedBuyStopStopLossInUnits = buyPrice - priceUtils.getPriceFromPips(stopLossInPipsArg);
    if(takeProfitInPipsArg != 0){
      calculatedBuyStopTakeProfitInUnits = buyPrice + priceUtils.getPriceFromPips(takeProfitInPipsArg);
    } else {
      calculatedBuyStopTakeProfitInUnits = 0;
    }

    calculatedSellStopStopLossInUnits = sellPrice + priceUtils.getPriceFromPips(stopLossInPipsArg);
    if(takeProfitInPipsArg != 0){
      calculatedSellStopTakeProfitInUnits = sellPrice - priceUtils.getPriceFromPips(takeProfitInPipsArg);
    } else {
      calculatedSellStopTakeProfitInUnits = 0;
    }

    int previousSlippageInPips = slippageInPips;
    slippageInPips = slippageArg;

    bool sellStopSuccessfull = sellStop(sellPrice, lotsArg, calculatedSellStopStopLossInUnits, calculatedSellStopTakeProfitInUnits, NULL, NULL, magicArg, isECNBrokerArg);
    bool buyStopSuccessfull = buyStop(buyPrice, lotsArg, calculatedBuyStopStopLossInUnits, calculatedBuyStopTakeProfitInUnits, NULL, NULL, magicArg, isECNBrokerArg);

    slippageInPips = previousSlippageInPips;

    return sellStopSuccessfull && buyStopSuccessfull;
  }


  //----------------------------------- With comment
  bool buyAtMarker(string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg, string commentArg){
    return buySellCommun(instrument, MarketInfo(instrument, MODE_ASK), nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_BUY, "Buy At Market Error", Lime, commentArg);
  }

  bool sellAtMarker(string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg, string commentArg){
    return buySellCommun(instrument, MarketInfo(instrument, MODE_BID), nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_SELL, "Sell At Market Error", Orange, commentArg);
  }

  //-----------------------------------
  bool buyAtMarker(string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, MarketInfo(instrument, MODE_ASK), nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_BUY, "Buy At Market Error", Lime, NULL);
  }

  bool sellAtMarker(string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, MarketInfo(instrument, MODE_BID), nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_SELL, "Sell At Market Error", Orange, NULL);
  }

  bool buyLimit(double priceArg, string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, priceArg, nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_BUYLIMIT, "Buy Limit Error", Lime, NULL);
  }

  bool sellLimit(double priceArg, string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, priceArg, nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_SELLLIMIT, "Sell Limit Error", Orange, NULL);
  }

  bool buyStop(double priceArg, string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, priceArg, nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_BUYSTOP, "Buy Stop Error", Lime, NULL);
  }

  bool sellStop(double priceArg, string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, int magicArg, bool isECNBrokerArg){
    return buySellCommun(instrument, priceArg, nbrLotsArg, stopLossArg, takeProfitArg, NULL, NULL, magicArg, isECNBrokerArg, OP_SELLSTOP, "Sell Stop Error", Orange, NULL);
  }

  //-----------------------------------

  bool buyAtMarker(double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, bool isECNBrokerArg){
    return buyAtMarker(nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, 0, isECNBrokerArg);
  }

  bool buyAtMarker(double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return buyGeneric(MarketInfo(Symbol(), MODE_ASK), nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_BUY);
  }

  bool buyStop(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return buyGeneric(priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_BUYSTOP);
  }

  bool buyLimit(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return buyGeneric(priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_BUYLIMIT);
  }

  bool sellAtMarker(double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, bool isECNBrokerArg){
    return sellAtMarker(nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, 0, isECNBrokerArg);
  }

  bool sellAtMarker(double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return sellGeneric(MarketInfo(Symbol(), MODE_BID), nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_SELL);
  }

  bool sellStop(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return sellGeneric(priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_SELLSTOP);
  }

  bool sellLimit(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg){
    return sellGeneric(priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, OP_SELLLIMIT);
  }

  bool buyGeneric(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg, int typeOrderArg){
    return buySellCommun(Symbol(), priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, typeOrderArg, "Buy At Market Error", Lime, NULL);
  }

  bool sellGeneric(double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg, int typeOrderArg){
    return buySellCommun(Symbol(), priceArg, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg, typeOrderArg, "Sell At Market Error", Orange, NULL);
  }

  bool buySellCommun(string instrument, double priceArg, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLossArg, int magicArg, bool isECNBrokerArg, int typeOrderArg, string errorDisplay, color colorOrder, string commentArg){
    lastTicket = 0;
    int ticket = 0;
    int lastError = 0;
    bool successfulOrder = false;
    bool modifyOrder = false;

    int StopLevel = (MarketInfo(instrument, MODE_STOPLEVEL) / (MathPow(10,MarketInfo(instrument, MODE_DIGITS)))) + (MarketInfo(instrument, MODE_SPREAD) / (MathPow(10,MarketInfo(instrument, MODE_DIGITS))));

    if(typeOrderArg == OP_BUYSTOP){
      //OpenPrice-Ask ≥ StopLevel 	OpenPrice-SL ≥ StopLevel 	TP-OpenPrice ≥ StopLevel
      if(priceArg > MarketInfo(instrument, MODE_ASK) && priceArg - MarketInfo(instrument, MODE_ASK) < StopLevel){
        priceArg = MarketInfo(instrument, MODE_ASK) + StopLevel;
      }
    } else if(typeOrderArg == OP_BUYLIMIT){
      //Ask-OpenPrice ≥ StopLevel 	OpenPrice-SL ≥ StopLevel 	TP-OpenPrice ≥ StopLevel
      if(priceArg < MarketInfo(instrument, MODE_ASK) &&  MarketInfo(instrument, MODE_ASK) - priceArg < StopLevel){
        priceArg = MarketInfo(instrument, MODE_ASK) - StopLevel;
      }
    } else if(typeOrderArg == OP_SELLSTOP) {
      //Bid-OpenPrice ≥ StopLevel 	SL-OpenPrice ≥ StopLevel 	OpenPrice-TP ≥ StopLevel
      if(priceArg < MarketInfo(instrument, MODE_BID) &&  MarketInfo(instrument, MODE_BID) - priceArg < StopLevel){
        priceArg = MarketInfo(instrument, MODE_BID) - StopLevel;
      }
    } else if(typeOrderArg == OP_SELLLIMIT){
      //OpenPrice-Bid ≥ StopLevel 	SL-OpenPrice ≥StopLevel 	OpenPrice-TP ≥ StopLevel
      if(priceArg > MarketInfo(instrument, MODE_BID) && priceArg - MarketInfo(instrument, MODE_BID) < StopLevel){
        priceArg = MarketInfo(instrument, MODE_BID) + StopLevel;
      }
    } else if(typeOrderArg == OP_BUY){
      //Bid-SL ≥ StopLevel 	TP-Bid ≥ StopLevel

    } else if(typeOrderArg == OP_SELL){
      //SL-Ask ≥ StopLevel 	Ask-TP ≥ StopLevel

    }

    if(!notifyInsteadOfSendingOrder){
      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {

        if(!isECNBrokerArg){
          //NONE ECN Broker
          ticket = OrderSend(instrument, typeOrderArg, priceUtils.normalizeEntrySize(nbrLotsArg), priceUtils.normalizePrice(priceArg), priceUtils.getsPointsFromPips(slippageInPips), priceUtils.normalizePrice(stopLossArg), priceUtils.normalizePrice(takeProfitArg), commentArg != NULL ? commentArg : getDescription(pipPriceArg, maxLossArg, magicArg), magicArg, 0, colorOrder);
          if(ticket < 0)
          {
            lastError = GetLastError();
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(lastError, errorDisplay);
            errorUtils.displayError(getBuySellArgs(priceArg, typeOrderArg, instrument, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg));
            errorUtils.displayError("---------------");
            if(lastError == 130){
              isLastError130 = true;
            }
            successfulOrder = false;
          } else {
            successfulOrder = true;
            modifyOrder = true;
            isLastError130 = false;
            break;
          }
        } else {
          //ECN Borker
          if(successfulOrder == false){
            ticket = OrderSend(instrument, typeOrderArg, priceUtils.normalizeEntrySize(nbrLotsArg), priceUtils.normalizePrice(priceArg), priceUtils.getsPointsFromPips(slippageInPips), 0, 0, commentArg != NULL ? commentArg : getDescription(pipPriceArg, maxLossArg, magicArg), magicArg);
          }
          if(ticket < 0)
          {
            lastError = GetLastError();
            errorUtils.displayError("--------------- ECN Detected");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(lastError, errorDisplay);
            errorUtils.displayError(getBuySellArgs(priceArg, typeOrderArg, instrument, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg));
            errorUtils.displayError("---------------");
            if(lastError == 130){
              isLastError130 = true;
            }
            successfulOrder = false;
          } else if(stopLossArg !=0 || takeProfitArg != 0)  {
            successfulOrder = true;
            isLastError130 = false;
            bool res = OrderModify(ticket, priceUtils.normalizePrice(priceArg), priceUtils.normalizePrice(stopLossArg), priceUtils.normalizePrice(takeProfitArg), 0);
            if(!res) {
              errorUtils.displayError("---------------  ECN Detected");
              errorUtils.displayError("Attempt #"+string(attempt+1));
              errorUtils.displayError(GetLastError(), "Modify Order Error");
              errorUtils.displayError("IMPORTANT: ORDER #"+ string(ticket)+ " HAS NO stopLossArg AND takeProfitArg");
              errorUtils.displayError(getBuySellArgs(priceArg, typeOrderArg, instrument, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg));
              errorUtils.displayError("---------------");
              modifyOrder = false;
            } else {
              modifyOrder = true;
              break;
            }
          } else {
            successfulOrder = true;
            isLastError130 = false;
            modifyOrder = true;
          }
        }
        if(successfulOrder == true && modifyOrder == false){
          Sleep(TRADE_CHANGE_SL_TP_RETRY_WAIT);
        } else {
          Sleep(TRADE_RETRY_WAIT);
        }
      }
    } else {
      string typeOrder;
      if(typeOrderArg == OP_BUY){
        typeOrder = "Buy order";
      } else if(typeOrderArg == OP_SELL){
        typeOrder = "Sell order";
      } else if(typeOrderArg == OP_BUYLIMIT){
        typeOrder = "Buy limit Order (" + string(priceUtils.normalizePrice(priceArg))+")";
      } else if(typeOrderArg == OP_SELLLIMIT){
        typeOrder = "Sell Limit Order (" + string(priceUtils.normalizePrice(priceArg))+")";
      } else if(typeOrderArg == OP_BUYSTOP){
        typeOrder = "Buy Stop Order (" + string(priceUtils.normalizePrice(priceArg))+")";
      } else if(typeOrderArg == OP_SELLSTOP){
        typeOrder = "Sell Stop Order (" + string(priceUtils.normalizePrice(priceArg))+")";
      }

      notificationUtils.sendNotification(
        instrument+" - "+typeOrder+
        " : "+getBuySellArgs(priceArg, typeOrderArg, instrument, nbrLotsArg, stopLossArg, takeProfitArg, pipPriceArg, maxLossArg, magicArg, isECNBrokerArg), notifyWithPush, notifyWithEmail, notifyWithAlert);
    }

    if(successfulOrder == true && modifyOrder == false){
      closeOrder(ticket, true);
    }

    if(ticket > 0){
      lastTicket = ticket;
    }

    return successfulOrder && modifyOrder;
  }

  bool closeOrder(int ticket){
    bool successfulOperation = false;
    bool selected = OrderSelect(ticket, SELECT_BY_TICKET);

    if(selected == true && OrderCloseTime() == 0){

      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
        bool res = OrderClose(ticket, OrderLots(), OrderClosePrice(), priceUtils.getsPointsFromPips(slippageInPips));

        if(res == false){
          errorUtils.displayError("---------------");
          errorUtils.displayError("Attempt #"+string(attempt+1));
          errorUtils.displayError(GetLastError(), "Close Order Error : ticket #"+string(ticket));
          errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
          errorUtils.displayError("---------------");
          successfulOperation = false;
        } else {
          successfulOperation = true;
          break;
        }

        Sleep(TRADE_RETRY_WAIT);
      }
    }

    return successfulOperation;
  }

  bool closeOrder(int ticket, bool alsoDeletePendingOrders){
    return closeOrder(ticket, alsoDeletePendingOrders, 1);
  }

  bool closeOrder(int ticket, bool alsoDeletePendingOrders, double quantityMultiplier){
    bool successfulOperation = true;

      bool selected = OrderSelect(ticket, SELECT_BY_TICKET);

      bool successfulClose = false;
      if(selected == true && (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0){
        for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
          bool res = OrderClose(OrderTicket(), OrderLots()*quantityMultiplier, OrderClosePrice(), priceUtils.getsPointsFromPips(slippageInPips));

          if(res == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(GetLastError(), "Close Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
        successfulOperation = successfulOperation && successfulClose;
      } else if(alsoDeletePendingOrders == true && selected == true && (OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderCloseTime() == 0) {
        for(int attempt2=0; attempt2<TRADE_RETRY_COUNT; attempt2++) {
          bool res2 = OrderDelete(OrderTicket());

          if(res2 == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt2+1));
            errorUtils.displayError(GetLastError(), "Delete Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
      }


    return successfulOperation;
  }

  bool closeAllOpenOrdersForCurrency(){
    return closeAllOpenOrdersForSpecificCurrency(-1, Symbol(), NULL, NULL, true, true);
  }

  bool closeAllOpenOrdersForSpecificCurrency(string currency){
    return closeAllOpenOrdersForSpecificCurrency(-1, currency, NULL, NULL, true, true);
  }

  bool closeAllOpenOrdersForAllCurrencies(){
    return closeAllOpenOrdersForSpecificCurrency(-1, NULL, NULL, NULL, true, true);
  }

  bool closeAllOpenOrdersForAllCurrencies(int magicNumberArg){
    return closeAllOpenOrdersForSpecificCurrency(-1, NULL, magicNumberArg, NULL, true, true);
  }

  bool closeAllOpenOrdersForSpecificCurrency(string instrumentArg, int magicNumberArg){
    return closeAllOpenOrdersForSpecificCurrency(-1, instrumentArg, magicNumberArg, NULL, true, true);
  }

  bool closeAllOpenOrdersForSpecificCurrency(string instrumentArg, int magicNumberArg, string commentArg){
    return closeAllOpenOrdersForSpecificCurrency(-1, instrumentArg, magicNumberArg, commentArg, true, true);
  }

  bool closeAllOpenOrdersForSpecificCurrency(int typeOrderArg, string instrumentArg, int magicNumberArg, string commentArg){
    return closeAllOpenOrdersForSpecificCurrency(typeOrderArg, instrumentArg, magicNumberArg, commentArg, true, true);
  }

  bool closeAllOpenOrdersForSpecificCurrency(int typeOrderArg, string instrumentArg, int magicNumberArg, string commentArg, bool loosingOrders, bool winningOrders){
    bool successfulOperation = true;

    int total = OrdersTotal();
    for(int i=total-1;i>=0;i--)
    {
    //for (int i = 0; i < OrdersTotal(); i++){
      bool selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      bool instrumentChecked = false;
      if(instrumentArg == NULL || StringCompare(OrderSymbol(), instrumentArg) == 0){
        instrumentChecked = true;
      }

      bool magicChecked = false;
      if(magicNumberArg == NULL || magicNumberArg == 0 || OrderMagicNumber() == magicNumberArg){
        magicChecked = true;
      }

      bool commentCheck = false;
      if(commentArg == NULL || StringCompare(OrderComment(), commentArg) == 0){
        commentCheck = true;
      }

      bool orderTypeCheck = false;
      if((typeOrderArg == -1 && (OrderType() == OP_BUY || OrderType() == OP_SELL)) || typeOrderArg == OrderType()){
        orderTypeCheck = true;
      }

      bool successfulClose = false;
      if(selected == true  && orderTypeCheck == true && OrderCloseTime() == 0 && instrumentChecked == true && magicChecked == true && commentCheck == true){
        for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
          bool res = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), priceUtils.getsPointsFromPips(slippageInPips));

          if(res == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(GetLastError(), "Close Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
        successfulOperation = successfulOperation && successfulClose;
      }
    }

    return successfulOperation;
  }

  bool deleteAllPendingOrdersForMagicNumber(int magicNumberArg){
    bool successfulOperation = true;

    int total = OrdersTotal();
    for(int i=total-1;i>=0;i--) {
      bool selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      bool successfulClose = false;
      if(selected == true && (OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberArg && OrderSymbol() == Symbol()) {
        for(int attempt2=0; attempt2<TRADE_RETRY_COUNT; attempt2++) {
          bool res2 = OrderDelete(OrderTicket());

          if(res2 == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt2+1));
            errorUtils.displayError(GetLastError(), "Delete Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
      }
    }

    return successfulOperation;
  }

  bool closeAllOpenOrdersForMagicNumber(int magicNumberArg, bool alsoDeletePendingOrders){
    return closeAllOpenOrdersForMagicNumberDependingInstrument(magicNumberArg, alsoDeletePendingOrders, Symbol());
  }

  bool closeAllOpenOrdersForMagicNumberDependingInstrument(int magicNumberArg, bool alsoDeletePendingOrders, string instrumentArg){
    return closeAllOpenOrdersForMagicNumberDependingInstrument(magicNumberArg, alsoDeletePendingOrders, instrumentArg, 1);
  }

  bool closeAllOpenOrdersForMagicNumberDependingInstrument(int magicNumberArg, bool alsoDeletePendingOrders, string instrumentArg, double quantityMultiplier){
    bool successfulOperation = true;

    int total = OrdersTotal();
    for(int i=total-1;i>=0;i--) {
      bool selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      bool instrumentChecked = false;
      if(instrumentArg == NULL){
        instrumentChecked = true;
      } else if(StringCompare(OrderSymbol(), instrumentArg) == 0){
        instrumentChecked = true;
      }

      bool successfulClose = false;
      if(selected == true && (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberArg && instrumentChecked == true){
        for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
          bool res = OrderClose(OrderTicket(), OrderLots()*quantityMultiplier, OrderClosePrice(), priceUtils.getsPointsFromPips(slippageInPips));

          if(res == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(GetLastError(), "Close Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
        successfulOperation = successfulOperation && successfulClose;
      } else if(alsoDeletePendingOrders == true && selected == true && (OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberArg && instrumentChecked == true) {
        for(int attempt2=0; attempt2<TRADE_RETRY_COUNT; attempt2++) {
          bool res2 = OrderDelete(OrderTicket());

          if(res2 == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt2+1));
            errorUtils.displayError(GetLastError(), "Delete Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulClose = false;
          } else {
            successfulClose = true;
            break;
          }

          Sleep(TRADE_RETRY_WAIT);
        }
      }
    }

    return successfulOperation;
  }

  bool checkIfOrderExistAndNotClosed(int ticket){
    bool orderExistAndNotCLosed = false;
    bool selected = OrderSelect(ticket, SELECT_BY_TICKET);

    if(selected == true && OrderCloseTime() == 0){
      orderExistAndNotCLosed = true;
    }

    return orderExistAndNotCLosed;
  }

  bool checkIfOrderIsOnMarket(int ticket){
    bool orderOnMarket = false;
    bool selected = OrderSelect(ticket, SELECT_BY_TICKET);

    if(selected == true && OrderCloseTime() == 0 && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
      orderOnMarket = true;
    }

    return orderOnMarket;
  }

  bool closeAllPendingOrdersContraryToOpenOrder(int magicNumberArg){
    bool successfulOperation = true;
    string arrayInstruments[20];
    int arrayType[20];
    int pos = 0;
    bool selected = false;

    for(int l=0; l < 20; l++){
      arrayInstruments[l] = EMPTY_VALUE;
      arrayType[l] = EMPTY_VALUE;
    }

    for (int i = 0; i < OrdersTotal(); i++){
      selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if(selected == true && (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberArg){
        arrayInstruments[pos] = OrderSymbol();
        arrayType[pos] = OrderType();
        pos++;
      }
    }

    for (int j = 0; j < OrdersTotal(); j++){
      selected = OrderSelect(j, SELECT_BY_POS, MODE_TRADES);

      if(selected == true && (OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberArg){
        bool successfulClose = false;
        for(int k=0; k < 20; k++){
          if(arrayInstruments[k] != EMPTY_VALUE && StringCompare(OrderSymbol(), arrayInstruments[k]) == 0
            && ((arrayType[k] == OP_BUY && (OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)) || (arrayType[k] == OP_SELL && (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)))){
            for(int attempt2=0; attempt2<TRADE_RETRY_COUNT; attempt2++) {
              bool res2 = OrderDelete(OrderTicket());

              if(res2 == false){
                errorUtils.displayError("---------------");
                errorUtils.displayError("Attempt #"+string(attempt2+1));
                errorUtils.displayError(GetLastError(), "Delete Order Error : ticket #"+string(OrderTicket()));
                errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderClosePrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
                errorUtils.displayError("---------------");
                successfulClose = false;
              } else {
                successfulClose = true;
                break;
              }

              Sleep(TRADE_RETRY_WAIT);
            }
            successfulOperation = successfulOperation && successfulClose;
          }
        }
      }
    }

    ArrayFree(arrayInstruments);
    ArrayFree(arrayType);

    return successfulOperation;
  }

  bool changeSLForSpecificTicketOrder(int ticketOrderArg, double newPriceArg){
    bool successfulOperation = true;

    bool selected = OrderSelect(ticketOrderArg, SELECT_BY_TICKET);

    bool successfulModified = false;
    if(selected == true && OrderCloseTime() == 0 && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
        bool res = OrderModify(OrderTicket(), OrderOpenPrice(), priceUtils.normalizePrice(newPriceArg), OrderTakeProfit(), 0);

        if(res == false){
          errorUtils.displayError("---------------");
          errorUtils.displayError("Attempt #"+string(attempt+1));
          errorUtils.displayError(GetLastError(), "Modify Order Error : ticket #"+string(OrderTicket()));
          errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderOpenPrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
          errorUtils.displayError("---------------");
          successfulModified = false;
        } else {
          successfulModified = true;
          break;
        }

        Sleep(TRADE_CHANGE_SL_TP_RETRY_WAIT);
      }
      successfulOperation = successfulOperation && successfulModified;
    }

    return successfulOperation;
  }

  bool changeTPForSpecificTicketOrder(int ticketOrderArg, double newPriceArg){
    bool successfulOperation = true;

    bool selected = OrderSelect(ticketOrderArg, SELECT_BY_TICKET);

    bool successfulModified = false;
    if(selected == true && OrderCloseTime() == 0 && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
      for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
        bool res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), priceUtils.normalizePrice(newPriceArg), 0);

        if(res == false){
          errorUtils.displayError("---------------");
          errorUtils.displayError("Attempt #"+string(attempt+1));
          errorUtils.displayError(GetLastError(), "Modify Order Error : ticket #"+string(OrderTicket()));
          errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderOpenPrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
          errorUtils.displayError("---------------");
          successfulModified = false;
        } else {
          successfulModified = true;
          break;
        }

        Sleep(TRADE_CHANGE_SL_TP_RETRY_WAIT);
      }
      successfulOperation = successfulOperation && successfulModified;
    }

    return successfulOperation;
  }

  bool changeSLForSpecificCurrency(string instrumentArg, int magicNumberArg, double newPriceArg){
    bool successfulOperation = true;

    for (int i = 0; i < OrdersTotal(); i++){
      bool selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      bool instrumentChecked = false;
      if(instrumentArg == NULL){
        instrumentChecked = true;
      } else if(StringCompare(OrderSymbol(), instrumentArg) == 0){
        instrumentChecked = true;
      }

      bool magicChecked = false;
      if(magicNumberArg == NULL || magicNumberArg == 0){
        magicChecked = true;
      } else if(OrderMagicNumber() == magicNumberArg){
        magicChecked = true;
      }

      bool successfulModified = false;
      if(selected == true && OrderCloseTime() == 0 && instrumentChecked == true && magicChecked == true){
        for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
          bool res = OrderModify(OrderTicket(), OrderOpenPrice(), priceUtils.normalizePrice(newPriceArg), OrderTakeProfit(), 0);

          if(res == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(GetLastError(), "Modify Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderOpenPrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulModified = false;
          } else {
            successfulModified = true;
            break;
          }

          Sleep(TRADE_CHANGE_SL_TP_RETRY_WAIT);
        }
        successfulOperation = successfulOperation && successfulModified;
      }
    }

    return successfulOperation;
  }

  bool changeTPForSpecificCurrency(string instrumentArg, int magicNumberArg, double newPriceArg){
    bool successfulOperation = true;

    for (int i = 0; i < OrdersTotal(); i++){
      bool selected = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      bool instrumentChecked = false;
      if(instrumentArg == NULL){
        instrumentChecked = true;
      } else if(StringCompare(OrderSymbol(), instrumentArg) == 0){
        instrumentChecked = true;
      }

      bool magicChecked = false;
      if(magicNumberArg == NULL || magicNumberArg == 0){
        magicChecked = true;
      } else if(OrderMagicNumber() == magicNumberArg){
        magicChecked = true;
      }

      bool successfulModified = false;
      if(selected == true && OrderCloseTime() == 0 && instrumentChecked == true && magicChecked == true){
        for(int attempt=0; attempt<TRADE_RETRY_COUNT; attempt++) {
          bool res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), priceUtils.normalizePrice(newPriceArg), 0);

          if(res == false){
            errorUtils.displayError("---------------");
            errorUtils.displayError("Attempt #"+string(attempt+1));
            errorUtils.displayError(GetLastError(), "Modify Order Error : ticket #"+string(OrderTicket()));
            errorUtils.displayError("Lots : "+string(OrderLots())+" - "+"Order Close Price : "+string(OrderOpenPrice())+" - "+"Slippage : "+string(priceUtils.getsPointsFromPips(slippageInPips)));
            errorUtils.displayError("---------------");
            successfulModified = false;
          } else {
            successfulModified = true;
            break;
          }

          Sleep(TRADE_CHANGE_SL_TP_RETRY_WAIT);
        }
        successfulOperation = successfulOperation && successfulModified;
      }
    }

    return successfulOperation;
  }

  private :

  string getDescription(double pipPriceArg, double maxLoss, int magicArg){

    string description = "";

    if(magicArg == 0){
      if(pipPriceArg != NULL){
        description = description + "Pip:"+string(pipPriceArg)+string(AccountCurrency());

        if(maxLoss != NULL){
          description = description + "/";
        }
      }

      if(maxLoss != NULL){
        description = description + "Loss:"+string(maxLoss)+string(AccountCurrency());
      }
    } else {
      description = "#Magic : "+string(magicArg);
    }

    return description;
  }

  string getBuySellArgs(double priceArg, int typeOrder, string instrument, double nbrLotsArg, double stopLossArg, double takeProfitArg, double pipPriceArg, double maxLoss, int magicArg, bool isECNBrokerArg){

    string buySellArgs = "Symbol : "  + string(instrument) + " - "+
    "PriceOrder : " + string(priceUtils.normalizeEntrySize(priceArg)) + " - "+
    "Lots : " + string(priceUtils.normalizeEntrySize(nbrLotsArg)) + " - "+
    "Slippage  : "  + string(priceUtils.getsPointsFromPips(slippageInPips)) + " - "+
    "Stop Loss : " + string(priceUtils.normalizePrice(stopLossArg)) + " - "+
    "Take Profit  : "  + string(priceUtils.normalizePrice(takeProfitArg)) + " - "+
    "Description  : "  + string(getDescription(pipPriceArg, maxLoss, magicArg)) + " - "+
    "Magic  : "  + string(magicArg) + " - "+
    "Type Order : "+ string(typeOrder) + " - "+
    "Bid : " + string(priceUtils.normalizeEntrySize(MarketInfo(Symbol(), MODE_BID))) + " - "+
    "Ask : " + string(priceUtils.normalizeEntrySize(MarketInfo(Symbol(), MODE_ASK)));

    return buySellArgs;
  }

};

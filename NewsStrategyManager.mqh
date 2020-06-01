#include "StrategyManager.mqh"
#include "./Utils/NewsElement.mqh"

#define MAX_NEWS_CHART_SIZE 100

class NewsStrategyManager : public StrategyManager {

public :

  void initNews(){
    addNews("USD", D'2017.12.08 08:30:00' , -5, "Non-Farm Employment Change and Unemployment Rate");
    addNews("USD", D'2017.11.28 09:45:00' , -5, "Fed Chair Designate Powell Speaks");
    addNews("USD", D'2017.11.28 15:45:00' , -5, "Treasury Sec Mnuchin Speaks");
    addNews("USD", D'2017.11.29 10:00:00' , -5, "Fed Chair Yellen Testifies");
    addNews("USD", D'2017.11.29 10:30:00' , -5, "Crude Oil Inventories");
    addNews("EUR", D'2017.11.30 05:00:00' , -5, "CPI Flash Estimate y/y");
    addNews("USD", D'2017.11.30 08:30:00' , -5, "Unemployment Claims");
  }

  NewsStrategyManager(double nbrPipsStopLossArg, double nbrPipsTakeProfitArg,
    TrailingStopLossStrategy *trailingStopLossStrategyArg,
    MoneyManagementStrategy *moneyManagementStrategyArg,
    TimeManager *timeManagerArg,
    int magicNumberArg,
    bool isECNBrokerArg,
    bool closeAllTradesWhenForexMarketCloseArg,
    bool tradeOnlyWhenAtLeastOneCurrencyOpenedArg,
    bool tradeOnlyDuringWhenBothCurrencesOpenedArg,
    double protectionMinAccountArg, int maxNbrOrdersArg,
    int slippageArg, int nbrMinutesBeforeNewsArg, double distanceForPendingOrderArg){
    initialize(trailingStopLossStrategyArg, moneyManagementStrategyArg, timeManagerArg, magicNumberArg, isECNBrokerArg,
        closeAllTradesWhenForexMarketCloseArg, tradeOnlyWhenAtLeastOneCurrencyOpenedArg, tradeOnlyDuringWhenBothCurrencesOpenedArg, protectionMinAccountArg);

    maxNbrOrders = maxNbrOrdersArg;
    nbrOrdersOpened = 0;

    //Init strategy arguments
    nbrPipsStopLoss = nbrPipsStopLossArg;
    nbrPipsTakeProfit = nbrPipsTakeProfitArg;
    slippage = slippageArg;
    distanceForPendingOrder = distanceForPendingOrderArg;
    nbrMinutesBeforeNews = nbrMinutesBeforeNewsArg;
    noLastNews = 0;

    initNews();
  }

  virtual void onTick(){
    if(nbrOrdersOpened == 2){
      //Check if a stopOrder has been started - In that case, close the other one
      int nbrCalculateNbrPendingOrders = calculateNbrPendingOrders();
      if(nbrCalculateNbrPendingOrders != 2){
        deleteAllNoneOpenedOrder();
        nbrOrdersOpened = calculateNbrOpenedOrders();
      }
    } else if(nbrOrdersOpened == 0){
      //Check news and open double order if one is arriving soon
      if(checkIfNewsComingSoon()){
        sendOrder();
      }
    } else if(nbrOrdersOpened == 1){
      //Trailing stop
      updateAllTrailingStop();
      nbrOrdersOpened = calculateNbrOpenedOrders();
    }
  }

  virtual void onNewCandle(){

  }

private :

  NewsElement *newsElementTable[MAX_NEWS_CHART_SIZE];
  double nbrPipsStopLoss;
  double nbrPipsTakeProfit;
  double distanceForPendingOrder;
  int slippage;
  int nbrMinutesBeforeNews;

  int maxNbrOrders;
  int nbrOrdersOpened;
  int noLastNews;

  bool checkIfNewsComingSoon(){
    bool newsComingSoon = false;

    string quotedCurrency = StringSubstr(Symbol(),  StringLen(Symbol()) -3);
    string baseCurrency = StringSubstr(Symbol(), 0, 3);

    for(int i=0; i < noLastNews; ++i){
      NewsElement *newsElement = newsElementTable[i];
      if(StringCompare(newsElement.getCurrency(), baseCurrency) || StringCompare(newsElement.getCurrency(), quotedCurrency)){
          datetime currentTimeForCurrency = TimeGMT() + newsElement.getOffSetGMTInHour() * 3600;
          int diffWithNewsInMinutes = (currentTimeForCurrency - newsElement.getTimeEvent()) / 60;

          if((nbrMinutesBeforeNews >= 0 && diffWithNewsInMinutes > 0 && diffWithNewsInMinutes <= nbrMinutesBeforeNews)
            || (nbrMinutesBeforeNews < 0 && diffWithNewsInMinutes < 0 && diffWithNewsInMinutes >= nbrMinutesBeforeNews)){
            newsComingSoon = true;
            break;
          }
      }
    }
    return newsComingSoon;
  }

  void addNews(string currencyArg, datetime timeEventArg, int offSetGMTInHourArg, string typeAndCommentArg){
    NewsElement *newsElement = new NewsElement(currencyArg, timeEventArg, offSetGMTInHourArg, typeAndCommentArg);
    newsElementTable[noLastNews] = newsElement;
    ++noLastNews;
  }

  virtual void specificInitialization(){
    initNews();
  }

  void sendOrder(){
    if(nbrPipsStopLoss != 0){
      if(buySell.doubleStopOrder(0.01, distanceForPendingOrder,
        nbrPipsStopLoss,
        nbrPipsTakeProfit,
        slippage,
        magicNumber,
        isECNBroker)){
          nbrOrdersOpened = 2;
      }
    }
  }

  bool deleteAllNoneOpenedOrder(){
    bool taskAccomplished = true;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
       if(res == true) {
          if((OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
            taskAccomplished = OrderDelete(OrderTicket());
          }
       }
    }

    return taskAccomplished;
  }

  int calculateNbrOpenedOrders(){
    int nbrOpenedOrders = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
            ++nbrOpenedOrders;
          }
       }
    }

    return nbrOpenedOrders;
  }

  int calculateNbrPendingOrders(){
    int nbrPendingOrders = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
            ++nbrPendingOrders;
          }
       }
    }

    return nbrPendingOrders;
  }

  void updateAllTrailingStop(){
    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber) {
            trailingStopLossStrategy.update(OrderTicket());
          }
       }
    }
  }

};

#include "./ErrorUtils.mqh"
#include "./PriceUtils.mqh"

class OrderUtils {

  protected :

  ErrorUtils *errorUtils;
  PriceUtils *priceUtils;

  private :

  string allCurrencies[];

  public :

  void release(){
    delete errorUtils;
    delete priceUtils;
  }

  OrderUtils(){
    errorUtils = new ErrorUtils();
    priceUtils = new PriceUtils();
    initAllCurrencies();
  }

  OrderUtils(ErrorUtils *errorUtilsArg, PriceUtils *priceUtilsArg){
    this.errorUtils = errorUtilsArg;
    this.priceUtils = priceUtilsArg;
    initAllCurrencies();
  }

  double getPipValueInPoint(){
    double pipValueInPoint;

    if(Digits==3 || Digits==5) {
      pipValueInPoint = 10 * Point;
    }
    else {
      pipValueInPoint = Point;
    }

    return pipValueInPoint;
  }

  double convertNbrPipInQuotedPrice(double nbrPipsArg){
    return getPipValueInPoint() * nbrPipsArg;
  }

  double convertQuotedPriceInNbrPip(double quotedPriceArg){
    return NormalizeDouble(quotedPriceArg / getPipValueInPoint(),2);
  }

  double getPriceForClosingOrder(string symbolToTradeArg, int typeOrderArg){
    return typeOrderArg == OP_BUY ? MarketInfo(symbolToTradeArg,MODE_BID) : MarketInfo(symbolToTradeArg,MODE_ASK);
  }

  double getPriceForOpeningOrder(string symbolToTradeArg, int typeOrderArg){
    return typeOrderArg == OP_BUY ? MarketInfo(symbolToTradeArg,MODE_ASK) : MarketInfo(symbolToTradeArg,MODE_BID);
  }


  double getAndAdjustStopLossOrTakeProfitLevel(string symbolToTradeArg,double levelArg){
    double correctLevel = 0;

    double levelMin = (MarketInfo(symbolToTradeArg, MODE_STOPLEVEL) / (MathPow(10,MarketInfo(symbolToTradeArg, MODE_DIGITS)))) + (MarketInfo(symbolToTradeArg, MODE_SPREAD) / (MathPow(10,MarketInfo(symbolToTradeArg, MODE_DIGITS))));
    if(levelArg < 0){
      if (levelArg > -levelMin){
        correctLevel = -levelMin;
      } else {
        correctLevel  = levelArg;
      }
    } else {
      if (levelArg < levelMin){
        correctLevel = levelMin;
      } else {
        correctLevel  = levelArg;
      }
    }

    return correctLevel;
  }

  bool changeTakeProfitInUnits(int ticketArg, double newTakeProfitInUnits){
    bool successfulOrder = true;
    bool selected = OrderSelect(ticketArg, SELECT_BY_TICKET);

    if(selected == true && OrderCloseTime() == 0){
      bool res = OrderModify(ticketArg, OrderOpenPrice(), OrderStopLoss(), priceUtils.normalizePrice(newTakeProfitInUnits), 0);

      if(res == false){
        errorUtils.displayError(GetLastError(), "OrderModify Error : Une erreur est survenue lors du changement du take profit de l'ordre #"+string(ticketArg));
        successfulOrder = false;
      }
    }

    return successfulOrder;
  }

  bool changeStopLossInUnits(int ticketArg, double newStopLossInUnits){
    bool successfulOrder = true;
    bool selected = OrderSelect(ticketArg, SELECT_BY_TICKET);

    if(selected == true && OrderCloseTime() == 0){
      bool res = OrderModify(ticketArg, OrderOpenPrice(), priceUtils.normalizePrice(newStopLossInUnits), OrderTakeProfit(), 0);

      if(res == false){
        errorUtils.displayError(GetLastError(), "OrderModify Error : Une erreur est survenue lors du changement du take profit de l'ordre #"+string(ticketArg));
        successfulOrder = false;
      }
    }

    return successfulOrder;
  }

  int typeOfPosition(int ticketArg){
    int typeOfPosition = -1;
    bool selected = OrderSelect(ticketArg, SELECT_BY_TICKET);
    if(selected == true){
      typeOfPosition = OrderType();
    }

    return typeOfPosition;
  }

  bool checkIfOrderClosed(int ticketArg){
    bool orderAlreadyClosed = false;
    bool selected = OrderSelect(ticketArg, SELECT_BY_TICKET);
    if(selected == true && OrderCloseTime() != 0){
      orderAlreadyClosed = true;
    }

    return orderAlreadyClosed;
  }

  int getOrderOpenPrice(int ticketArg){
    double openPrice = 0;
    if(OrderSelect(ticketArg, SELECT_BY_TICKET)){
      openPrice = OrderOpenPrice();
    }

    return NormalizeDouble(openPrice, Digits);
  }

  double getRealLeverage(int ticketArg)
  {
    double leverage = 0;
    double accountEquity = AccountEquity();

    if(OrderSelect(ticketArg, SELECT_BY_TICKET)) {
        leverage = NormalizeDouble(((OrderLots() * 100000) / (convertFromAccountCurrenyToGivenBaseCurrency(accountEquity, OrderSymbol()))), 2);
    }

    return leverage;
  }

  int findOpenTicketByMagicNumberAndCurrentCurrency(int magicNumberArg)
  {
     int ticket = 0;

     for(int i = OrdersTotal()-1; i >= 0; i--) {
        bool res = OrderSelect(i, SELECT_BY_POS);
        if(res == true) {
           if(OrderMagicNumber() == magicNumberArg && OrderSymbol() == Symbol() && OrderCloseTime() == 0) {
              ticket = OrderTicket();
              break;
           }
        }
     }

     return ticket;
  }

  int numberTicketsOpenedForCurrentCurrency(){
    int nbrTickets = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol() == Symbol() && OrderCloseTime() == 0) {
            ++nbrTickets;
          }
       }
    }

    return nbrTickets;
  }

  int numberTicketsOpenedByMagicTicket(int magicNumberArg){
    int nbrTickets = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumberArg) {
            ++nbrTickets;
          }
       }
    }

    return nbrTickets;
  }

  double getPotentialLostForMagicNumberAndCommentGivenStopLoss(string instrumentArg, int orderTypeArg,  int magicNumberArg, string commentArg, double stopLossArg)
  {
    double loss = 0;

    double TickSize = MarketInfo(instrumentArg, MODE_TICKSIZE);
    double TickCostInAccountCurrencyWithNoLeverage = MarketInfo(instrumentArg, MODE_TICKVALUE);

    for(int i = 0; i<OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {

          if(OrderType() == orderTypeArg && OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberArg && StringCompare(OrderComment(),commentArg) == 0){
            if(OrderType() == OP_BUY){
              loss += OrderLots() * (((OrderOpenPrice() - stopLossArg) * TickCostInAccountCurrencyWithNoLeverage) / TickSize) + MathAbs(OrderCommission());
            } else if(OrderType() == OP_SELL) {
              loss += OrderLots() * (((stopLossArg - OrderOpenPrice()) * TickCostInAccountCurrencyWithNoLeverage) / TickSize) + MathAbs(OrderCommission());
            }
          }
      }
    }
    return loss;
  }

  int numberTicketsOpenedByMagicTicketAndComment(int orderTypeArg, int magicNumberArg, string commentArg){
    int nbrTickets = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if(OrderType() == orderTypeArg && OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberArg && StringCompare(OrderComment(),commentArg) == 0) {
            ++nbrTickets;
          }
       }
    }

    return nbrTickets;
  }

  double numberOfLotsOpenedByMagicNumberAndComment(int orderTypeArg, int magicNumberArg, string commentArg){
    double nbrLots = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if(OrderType() == orderTypeArg && OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberArg && StringCompare(OrderComment(),commentArg) == 0) {
            nbrLots += OrderLots();
          }
       }
    }

    return nbrLots;
  }

  void updateTPForTicketsOpenWithMagicNumberAndComment(int orderTypeArg, double takeProfitArg, int magicNumberArg, string commentArg){
    if(takeProfitArg != 0){
      for(int i=0; i<OrdersTotal(); i++)
      {
         if(OrderSelect(i, SELECT_BY_POS)) {
            if(OrderType() == orderTypeArg && OrderCloseTime() == 0
            && OrderMagicNumber() == magicNumberArg && StringCompare(OrderComment(),commentArg) == 0) {
              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),takeProfitArg ,0);
              if(!res)
                 Print("Error in OrderModify. Error code=",GetLastError());
              }
            }
         }
     }
  }

  void updateSLForTicketsOpenWithMagicNumberAndComment(int orderTypeArg, double stopLossArg, int magicNumberArg, string commentArg){
    if(stopLossArg != 0){
    for(int i=0; i<OrdersTotal(); i++)
    {
       if(OrderSelect(i, SELECT_BY_POS)) {
         if(OrderType() == orderTypeArg && OrderCloseTime() == 0
         && OrderMagicNumber() == magicNumberArg && StringCompare(OrderComment(),commentArg) == 0) {
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArg,OrderTakeProfit() ,0);
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            }
          }
       }
     }
  }

  void updateSLForBuyingTicketsOpenWithMagicNumber(double stopLossArg, int magicNumberArg){
    if(stopLossArg != 0){
    for(int i=0; i<OrdersTotal(); i++)
    {
       if(OrderSelect(i, SELECT_BY_POS)) {
          if((OrderType() == OP_BUY) && OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberArg) {
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArg,OrderTakeProfit() ,0);
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            }
          }
       }
     }
  }

  void updateSLForSellingTicketsOpenWithMagicNumber(double stopLossArg, int magicNumberArg){
    for(int i=0; i<OrdersTotal(); i++)
    {
       if(OrderSelect(i, SELECT_BY_POS)) {
          if((OrderType() == OP_SELL) && OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberArg) {
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArg,OrderTakeProfit() ,0);
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            }
          }
       }
  }

  int numberPendingOrdersByMagicTicket(int magicNumberArg){
    int nbrPendingOrders = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if((OrderType() != OP_BUY && OrderType() != OP_SELL) && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumberArg) {
            ++nbrPendingOrders;
          }
       }
    }

    return nbrPendingOrders;
  }

  int getLastTicketOpenedForCurrentCurrency(){
    int ticket = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res;
       res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if(OrderSymbol() == Symbol() && OrderCloseTime() == 0) {
             ticket = OrderTicket();
             break;
          }
       }
    }

    return ticket;
  }

  int getLastTicketOpenedByMagicNumber(int magicNumberArg){
    int ticket = 0;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       bool res;
       res = OrderSelect(i, SELECT_BY_POS);
       if(res == true) {
          if(OrderMagicNumber() == magicNumberArg && OrderSymbol() == Symbol() && OrderCloseTime() == 0) {
             ticket = OrderTicket();
             break;
          }
       }
    }

    return ticket;
  }

  double getCorrectLotSize(double nbrLotsSizeArg){
    double correctLotSize = 0;

    double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
    double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);

    if (nbrLotsSizeArg < MinLot) {
      correctLotSize = MinLot;
    }
    else if (nbrLotsSizeArg > MaxLot) {
      correctLotSize = MaxLot;
    } else {
      correctLotSize = nbrLotsSizeArg;
    }

    return correctLotSize;
  }

  //+------------------------------------------------------------------+
  double getPositionSizeOnPourcentageRisk(double currentPriceAtMArketValue, double stopLossLevelValue, double riskInPourcentValue, double commissionPerLotValue){
    double OutputPositionSize = 0;

    //OrderCommission()
    //double currentPriceAtMArketValue = isBuyAction ? MarketInfo(Symbol(), MODE_ASK) : MarketInfo(Symbol(), MODE_BID);
    double StopLossValue = MathAbs(currentPriceAtMArketValue - stopLossLevelValue);
    double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double TickCostInAccountCurrencyWithNoLeverage = MarketInfo(Symbol(), MODE_TICKVALUE);
    double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
    double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double RiskMoney = roundDown(AccountEquity() * riskInPourcentValue / 100, 2);

    if ((StopLossValue != 0) && (TickCostInAccountCurrencyWithNoLeverage != 0) && (TickSize != 0)) {
      OutputPositionSize = roundDown(RiskMoney / (StopLossValue * TickCostInAccountCurrencyWithNoLeverage / TickSize + 2 * commissionPerLotValue), 2);

      if (OutputPositionSize < MinLot) {
        OutputPositionSize = MinLot;
      }
      else if (OutputPositionSize > MaxLot) {
        OutputPositionSize = MaxLot;
      }

      double steps = 0;
      if (LotStep != 0) {
        steps = OutputPositionSize / LotStep;
      }
      if (MathFloor(steps) < steps){
        OutputPositionSize = MathFloor(steps) * LotStep;
      }
    }

    return OutputPositionSize;
  }

  //+------------------------------------------------------------------+
  double roundDown(const double value, const double digits)
  {
    int norm = (int) MathPow(10, digits);
    return(MathFloor(value * norm) / norm);
  }

  //+------------------------------------------------------------------+

  /**
   * This method calculates the profit or loss of a position in the home currency of the account
   * @param  string  sym
   * @param  int     type    0 = buy, 1 = sell
   * @param  double  entry
   * @param  double  exit
   * @param  double  lots
   * @result double          profit/loss in home currency
   */
   // double calcPL(string sym, int type, double entry, double exit, double lots) {
   //   var result;
   //   if ( type == 0 ) {
   //     result = (exit - entry) * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   //   } else if ( type == 1 ) {
   //     result = (entry - exit) * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   //   }
   //   return ( result );
   //
   // }




  double getCurrentProfitOnOpenedPosisions(string instrumentArg, int eaMagicNumberArg){
    double profit = 0;

    for(int i=0; i<OrdersTotal(); i++)
    {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){

         bool instrumentChecked = false;
         if(instrumentArg == NULL || StringCompare(OrderSymbol(), instrumentArg) == 0){
           instrumentChecked = true;
         }

         bool magicNumberArgChecked = false;
         if(eaMagicNumberArg == NULL || eaMagicNumberArg == OrderMagicNumber()){
           magicNumberArgChecked = true;
         }

         if(instrumentChecked && magicNumberArgChecked && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
           profit += OrderProfit() + OrderCommission() + OrderSwap();
         }
       }
     }

     return profit;
  }

  double getProfitOnClosedPosisions(string instrumentArg, int eaMagicNumberArg){
    double profit = 0;

    for(int i=0; i<OrdersHistoryTotal(); i++)
    {
       if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){

         bool instrumentChecked = false;
         if(instrumentArg == NULL || StringCompare(OrderSymbol(), instrumentArg) == 0){
           instrumentChecked = true;
         }

         bool magicNumberArgChecked = false;
         if(eaMagicNumberArg == NULL || eaMagicNumberArg == OrderMagicNumber()){
           magicNumberArgChecked = true;
         }

         if(instrumentChecked && magicNumberArgChecked && (OrderType() <= 5)) {
           profit += OrderProfit() + OrderCommission() + OrderSwap();
         }
       }
     }

     return profit;
  }

  //+------------------------------------------------------------------+
  double dailyprofitForCurrencyAndMagicNumber(string instrumentArg, int eaMagicNumberArg)
  {
    int day = Day();
    double dailyProfit = 0;

    for(int i=0; i<OrdersHistoryTotal(); i++)
    {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){

        bool instrumentChecked = false;
        if(instrumentArg == NULL){
          instrumentChecked = true;
        } else if(StringCompare(OrderSymbol(), instrumentArg) == 0){
          instrumentChecked = true;
        }

        bool magicNumberArgChecked = false;
        if(eaMagicNumberArg == NULL){
          magicNumberArgChecked = true;
        } else if(eaMagicNumberArg == OrderMagicNumber()){
          magicNumberArgChecked = true;
        }

        if(instrumentChecked && magicNumberArgChecked && TimeDay(OrderOpenTime())==day) {
          dailyProfit += OrderProfit();
        }
      }
    }
    return(dailyProfit);
  }

  //+------------------------------------------------------------------+
  int totalOpenOrdersForCurrencyAndMagicNumber(string instrumentArg, int eaMagicNumberArg)
  {
    int totalOrders = 0;

    for(int i = 0; i<OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {

          bool instrumentChecked = false;
          if(instrumentArg == NULL || StringCompare(OrderSymbol(), instrumentArg) == 0){
            instrumentChecked = true;
          }

          bool magicNumberArgChecked = false;
          if(eaMagicNumberArg == NULL || eaMagicNumberArg == OrderMagicNumber()){
            magicNumberArgChecked = true;
          }

          if(instrumentChecked && magicNumberArgChecked) {
            totalOrders++;
          }
      }
    }
    return(totalOrders);
  }

  //+------------------------------------------------------------------+
  double getDepositsOnAccount()
  {
     double total=0;
     for (int i=0; i<OrdersHistoryTotal(); i++)
        {
           if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
              {
                 if(OrderType()>5)
                    {
                       total+=OrderProfit();

                    }
              }
        }
     return(total);
  }

  //+------------------------------------------------------------------+
  double getRealLeverage()
  {
    double leverage = 0;
    double accountEquity = AccountEquity();

    for(int i = 0; i<OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
          leverage += NormalizeDouble(((OrderLots() * 100000) / (convertFromAccountCurrenyToGivenBaseCurrency(accountEquity, OrderSymbol()))), 2);
      }
    }

    return leverage;
  }

  //+------------------------------------------------------------------+
  double convertFromAccountCurrenyToGivenBaseCurrency(double amountToConvertArg, string currencyArg){
    double convertResult = 0;
    string prefix = this.getPrefix(currencyArg);
    string suffix = this.getSuffix(currencyArg);


    string baseCurrency = this.getBaseCurrency(currencyArg);
    if(StringCompare(baseCurrency, AccountCurrency()) == 0){
      convertResult = amountToConvertArg;
    } else {
      string currencyForConverting = prefix+baseCurrency+AccountCurrency()+suffix;
      double priceForConverting = MarketInfo(currencyForConverting,MODE_BID);

      if(priceForConverting != 0){
        convertResult = amountToConvertArg / priceForConverting;
      } else {
        currencyForConverting = prefix+AccountCurrency()+baseCurrency+suffix;
        priceForConverting = MarketInfo(currencyForConverting,MODE_ASK);
        convertResult =  amountToConvertArg * priceForConverting;
      }
    }

    return convertResult;
  }

  double convertFromGivenCurrencyToAccountCurreny(double amountToConvertArg, string currencyArg){
    return convertFromOneCurrencyToAnother(amountToConvertArg, currencyArg, AccountCurrency());
  }

  double convertFromOneCurrencyToAnother(double amountToConvertArg, string currencyToConvertArg, string currencyToGet){
    double convertResult = 0;
    string prefix = this.getPrefix(Symbol());
    string suffix = this.getSuffix(Symbol());

    if(StringCompare(currencyToConvertArg, currencyToGet) == 0){
      convertResult = amountToConvertArg;
    } else {
      string currencyForConverting = prefix+currencyToGet+currencyToConvertArg+suffix;
      double priceForConverting = MarketInfo(currencyForConverting,MODE_ASK);

      if(priceForConverting != 0){
        convertResult = amountToConvertArg / priceForConverting;
      } else {
        currencyForConverting = prefix+currencyToConvertArg+currencyToGet+suffix;
        priceForConverting = MarketInfo(currencyForConverting,MODE_BID);
        convertResult =  amountToConvertArg * priceForConverting;
      }
    }

    return NormalizeDouble(convertResult,2);
  }

  void initAllCurrencies(){
      if(ArraySize(allCurrencies) == 0){

        ArrayResize(allCurrencies,8);
        allCurrencies[0] = "USD";
        allCurrencies[1] = "EUR";
        allCurrencies[2] = "GBP";
        allCurrencies[3] = "CHF";
        allCurrencies[4] = "JPY";
        allCurrencies[5] = "CAD";
        allCurrencies[6] = "AUD";
        allCurrencies[7] = "NZD";
      }
  }

  string getPrefix(string currencyArg){
    int indexToCheck = 0;

    if(currencyArg != NULL){
      int lenght = StringLen(currencyArg);
      int nbrCurrencies = ArraySize(allCurrencies);

      while(indexToCheck+3 <= lenght) {
        string substring = StringSubstr(currencyArg, indexToCheck, 3);
        for(int j = 0; j < nbrCurrencies; j++){
          if(StringCompare(substring, allCurrencies[j]) == 0){
            if(indexToCheck == 0){
              return "";
            } else {
              return StringSubstr(currencyArg, 0, indexToCheck);
            }
          }
        }
        ++indexToCheck;
      }
    }
    return "";
  }

  string getSuffix(string currencyArg){
      int indexToCheck = 0;

      if(currencyArg != NULL){
        int lenght = StringLen(currencyArg);
        int nbrCurrencies = ArraySize(allCurrencies);

        while(indexToCheck+3 <= lenght) {
          string baseCurrency = StringSubstr(currencyArg, indexToCheck, 3);
          for(int j = 0; j < nbrCurrencies; j++){
            if(StringCompare(baseCurrency, allCurrencies[j]) == 0){
              if(indexToCheck+6  <= lenght){
                string quotedCurrency = StringSubstr(currencyArg, indexToCheck+3, 3);
                for(int k = 0; k < nbrCurrencies; k++){
                  if(StringCompare(quotedCurrency, allCurrencies[k]) == 0){
                    if(indexToCheck+6 == lenght){
                      return "";
                    } else {
                      return StringSubstr(currencyArg, indexToCheck+6);
                    }
                  }
                }
                return "";
              } else {
                return "";
              }
            }
          }
          ++indexToCheck;
        }
      }
      return "";
  }

  string getBaseCurrency(string currencyArg){
    int indexToCheck = 0;

    if(currencyArg != NULL){
      int lenght = StringLen(currencyArg);
      int nbrCurrencies = ArraySize(allCurrencies);

      while(indexToCheck+3 <= lenght) {
        string substring = StringSubstr(currencyArg, indexToCheck, 3);
        for(int j = 0; j < nbrCurrencies; j++){
          if(StringCompare(substring, allCurrencies[j]) == 0){
            return substring;
          }
        }
        ++indexToCheck;
      }
    }
    return "";
  }

  string getQuoteCurrency(string currencyArg){
    int indexToCheck = 0;

    if(currencyArg != NULL){
      int lenght = StringLen(currencyArg);
      int nbrCurrencies = ArraySize(allCurrencies);

      while(indexToCheck+3 <= lenght) {
        string baseCurrency = StringSubstr(currencyArg, indexToCheck, 3);
        for(int j = 0; j < nbrCurrencies; j++){
          if(StringCompare(baseCurrency, allCurrencies[j]) == 0){
            if(indexToCheck+6  <= lenght){
              string quotedCurrency = StringSubstr(currencyArg, indexToCheck+3, 3);
              for(int k = 0; k < nbrCurrencies; k++){
                if(StringCompare(quotedCurrency, allCurrencies[k]) == 0){
                  return quotedCurrency;
                }
              }
              return "";
            } else {
              return "";
            }
          }
        }
        ++indexToCheck;
      }
    }
    return "";
  }

  double getPotentialGainForCurrencyAndMagicNumber(string instrumentArg, int eaMagicNumberArg)
  {
    double gain = 0;

    double TickSize = MarketInfo(instrumentArg, MODE_TICKSIZE);
    double TickCostInAccountCurrencyWithNoLeverage = MarketInfo(instrumentArg, MODE_TICKVALUE);

    for(int i = 0; i<OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {

          bool instrumentChecked = false;
          if(instrumentArg == NULL || StringCompare(OrderSymbol(), instrumentArg) == 0){
            instrumentChecked = true;
          }

          bool magicNumberArgChecked = false;
          if(eaMagicNumberArg == NULL || eaMagicNumberArg == OrderMagicNumber()){
            magicNumberArgChecked = true;
          }

          if(instrumentChecked && magicNumberArgChecked && (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0 && OrderTakeProfit() != 0) {

            if(OrderType() == OP_BUY){
              gain += OrderLots() * (((OrderTakeProfit() - OrderOpenPrice()) * TickCostInAccountCurrencyWithNoLeverage) / TickSize) + MathAbs(OrderCommission());
            } else if(OrderType() == OP_SELL) {
              gain += OrderLots() * (((OrderOpenPrice() - OrderTakeProfit()) * TickCostInAccountCurrencyWithNoLeverage) / TickSize) + MathAbs(OrderCommission());
            }
          }
      }
    }
    return(gain);
  }


};

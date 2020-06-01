#include "TimeManager.mqh"

#define NBR_CURRENCIES_SIZE 8
#define NBR_SECONDS_IN_HOUR 3600
#define OPENING_MARKETS_HOUR 8
#define CLOSING_MARKETS_HOUR 17
#define OPENING_FOREX_EST_SUNDAY_HOUR 17
#define CLOSING_FOREX_EST_FRIDAY_HOUR 17

// The Forex market is the only 24-hour market, opening Sunday 5 PM EST, and running continuously until Friday 5 PM EST. The Forex day starts with the opening of Sydney's (Australia) Forex market at 5:00 PM EST (10:00 PM GMT / 22:00), and ends with the closing of New York's market, a day after, at 5:00 PM EST (10:00 PM GMT / 22:00), immediately reopening in Sydney restart trading.
// Note: EST is an abbreviation for Eastern Standard Time (e.g. New York), while GMT is an abbreviation for Greenwich Mean Time (e.g. London).
//https://forums.babypips.com/t/when-does-the-market-open-on-sunday/39758/12

//Informations on a specific time :
//https://time.is/fr/London
//https://www.timeanddate.com/worldclock/uk/london

class ForexTimeManager : public TimeManager {

private :

  string listCurrencies[NBR_CURRENCIES_SIZE];


public :

  ForexTimeManager(int nbrMinutesToStartTradingAfterForexOpenArg, int nbrMinutesToStopTradingBeforeForexEndArg, int nbrMinutesToStopOpeningOrderBeforeForexEndArg){
    this.nbrMinutesToStartTradingAfterForexOpen = nbrMinutesToStartTradingAfterForexOpenArg;
    this.nbrMinutesToStopTradingBeforeForexEnd = nbrMinutesToStopTradingBeforeForexEndArg;
    this.nbrMinutesToStopOpeningOrderBeforeForexEnd = nbrMinutesToStopOpeningOrderBeforeForexEndArg;
    init();
  }

  virtual void calculateTimesForCurrentSymbol(){
    calculateTimes(Symbol());
  }

  virtual void calculateTimes(string symbol){

    string quotedCurrency = StringSubstr(symbol,  StringLen(symbol) -3);
    string baseCurrency = StringSubstr(symbol, 0, 3);

    quotedCurrencyTime = getCurrentTimeForCurrency(quotedCurrency);
    baseCurrencyTime = getCurrentTimeForCurrency(baseCurrency);

    hourBaseCurrencyTime = TimeHour(baseCurrencyTime);
    hourQuotedCurrencyTime = TimeHour(quotedCurrencyTime);

    bool previousMarketOpened = marketOpened;
    marketOpened = isForexOpenedForTrading();
    allowNewOrders = isForexNewOrdersAllowed();

    if(previousMarketOpened == false && marketOpened == true){
      hasMarketJustOpened = true;
    }

    if(marketOpened && hourBaseCurrencyTime >= OPENING_MARKETS_HOUR && hourBaseCurrencyTime < CLOSING_MARKETS_HOUR){
      baseCurrencyOpened = true;
    } else {
      baseCurrencyOpened = false;
    }

    if(marketOpened && hourQuotedCurrencyTime >= OPENING_MARKETS_HOUR && hourQuotedCurrencyTime < CLOSING_MARKETS_HOUR){
      quotedCurrencyOpened = true;
    } else {
      quotedCurrencyOpened = false;
    }

  }

private :

  void init(){
    listCurrencies[0] = "USD";
    listCurrencies[1] = "EUR";
    listCurrencies[2] = "GBP";
    listCurrencies[3] = "CHF";
    listCurrencies[4] = "JPY";
    listCurrencies[5] = "CAD";
    listCurrencies[6] = "AUD";
    listCurrencies[7] = "NZD";
  }

  bool isForexOpenedForTrading(){
    bool forexOpened = true;
    datetime ESTTime = getCurrentTimeForCurrency("USD");
    datetime checkOpenTime = ESTTime - this.nbrMinutesToStartTradingAfterForexOpen * 60;
    datetime checkCloseTime = ESTTime + this.nbrMinutesToStopTradingBeforeForexEnd * 60;

    if((TimeDayOfWeek(ESTTime) == 0 && TimeHour(ESTTime) <= OPENING_FOREX_EST_SUNDAY_HOUR)
        || (TimeDayOfWeek(ESTTime) == 5 && TimeHour(checkCloseTime) >= CLOSING_FOREX_EST_FRIDAY_HOUR)
        ||  (TimeDayOfWeek(ESTTime) == 6)){
          forexOpened = false;
    }

    if( forexOpened && (
        (TimeDayOfWeek(checkOpenTime) == 6 ||  (TimeDayOfWeek(checkOpenTime) == 0 && TimeHour(checkOpenTime) <= OPENING_FOREX_EST_SUNDAY_HOUR))
        || (TimeDayOfWeek(checkCloseTime) == 6 || (TimeDayOfWeek(checkCloseTime) == 5 && TimeHour(checkCloseTime) >= CLOSING_FOREX_EST_FRIDAY_HOUR)))){
          forexOpened = false;
    }

    return forexOpened;
  }

  bool isForexNewOrdersAllowed(){
    bool newOrderAllowed = true;
    datetime ESTTime = getCurrentTimeForCurrency("USD");
    datetime checkStopOpeningTime = ESTTime + this.nbrMinutesToStopOpeningOrderBeforeForexEnd * 60;

    if(this.nbrMinutesToStopTradingBeforeForexEnd < this.nbrMinutesToStopOpeningOrderBeforeForexEnd){
      if(TimeDayOfWeek(checkStopOpeningTime) == 6 || (TimeDayOfWeek(checkStopOpeningTime) == 5 && TimeHour(checkStopOpeningTime) >= CLOSING_FOREX_EST_FRIDAY_HOUR)){
        newOrderAllowed = false;
      }
    }

    return newOrderAllowed;
  }

  datetime getCurrentTimeForCurrency(string currency){
    datetime currentTimeForCurrency = TimeGMT();
    int noMonth = TimeMonth(currentTimeForCurrency);
    int noDay = TimeDay(currentTimeForCurrency);

    int offSetGMTInHour = 0;
    if(StringCompare(currency, "USD") == 0){
      //Hivers -5, Ete -4
      //begins at 2:00 a.m. on the second Sunday of March and
      //ends at 2:00 a.m. on the first Sunday of November
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 3, 11, 2, 1, -5, -4);
    }
    else if(StringCompare(currency, "EUR") == 0){
      //In continental France, which includes the capital Paris,
      //the Daylight Saving Time (DST) period starts on the last Sunday of March and ends on the last Sunday of October,
      //together with most other European countries.
      //Hivers +1, Ete +2
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 3, 10, 5, 5, 1, 2);
    }
    else if(StringCompare(currency, "GBP") == 0){
      //the Daylight Saving Time (DST) period starts on the last Sunday of March and ends on the last Sunday of October,
      //Hivers +0, Ete +1
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 3, 10, 5, 5, 0, 1);
    }
    else if(StringCompare(currency, "CHF") == 0){
      //In continental France, which includes the capital Paris,
      //the Daylight Saving Time (DST) period starts on the last Sunday of March and ends on the last Sunday of October,
      //together with most other European countries.
      //Hivers +1, Ete +2
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 3, 10, 5, 5, 1, 2);
    }
    else if(StringCompare(currency, "JPY") == 0){
      //No changing time
      //+9
      offSetGMTInHour = 9;
    }
    else if(StringCompare(currency, "CAD") == 0){
      //Hivers -5, Ete -4
      //begins at 2:00 a.m. on the second Sunday of March and
      //ends at 2:00 a.m. on the first Sunday of November
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 3, 11, 2, 1, -5, -4);
    }
    else if(StringCompare(currency, "AUD") == 0){
      //Sydney
      //Daylight Saving Time begins at 2am on the first Sunday in October,
      //when clocks are put forward one hour.
      //It ends at 2am (which is 3am Daylight Saving Time) on the first Sunday in April, when clocks are put back one hour.
      //Hivers +11, Ete +10
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 4, 10, 1, 1, 11, 10);
    }

    else if(StringCompare(currency, "NZD") == 0){
      //Daylight saving time (DST) now runs from the last Sunday in September until the first Sunday in April.
      //Hivers +13, Ete +12
      offSetGMTInHour = getOffSetGMTInHour(noMonth, noDay, 4, 9, 1, 5, 13, 12);
    }

    return currentTimeForCurrency + offSetGMTInHour * NBR_SECONDS_IN_HOUR;
  }

  int getOffSetGMTInHour(int noMonth, int noDay,
                          int noMonthStartingSummerPeriod, int noMonthEndingSummerPeriod,
                          int noSundaySartingSummerPeriod, int noSundayEndingSummerPeriod,
                          int gmtWinterOffset, int gmtSummerOffset){
    int offSetGMTInHour = gmtSummerOffset;

    if(noMonth > noMonthStartingSummerPeriod && noMonth < noMonthEndingSummerPeriod){
      offSetGMTInHour = gmtSummerOffset;
    } else if((noMonth >= 1 && noMonth < noMonthStartingSummerPeriod) || (noMonth > noMonthEndingSummerPeriod && noMonth <= 12)) {
      offSetGMTInHour = gmtWinterOffset;
    } else if(noMonth == noMonthStartingSummerPeriod){
      int sundayDayOfMonthBeginningSummerPeriode = findSpecificDayInGivenPositionOfCurrentMonth(0, noSundaySartingSummerPeriod, getNbrDaysInMonth(noMonth));
      if(noDay >= sundayDayOfMonthBeginningSummerPeriode){
        offSetGMTInHour = gmtSummerOffset;
      } else {
        offSetGMTInHour = gmtWinterOffset;
      }
    } else if(noMonth == noMonthEndingSummerPeriod){
      int sundayDayOfMonthBeginningWinterPeriode = findSpecificDayInGivenPositionOfCurrentMonth(0, noSundayEndingSummerPeriod, getNbrDaysInMonth(noMonth));
      if(noDay >= sundayDayOfMonthBeginningWinterPeriode){
        offSetGMTInHour = gmtWinterOffset;
      } else {
        offSetGMTInHour = gmtSummerOffset;
      }
    }

    return offSetGMTInHour;
  }

};

//https://docs.mql4.com/dateandtime
//https://docs.mql4.com/constants/structures/mqldatetime
class TimeManager {

protected :

  datetime baseCurrencyTime;
  datetime quotedCurrencyTime;

  int hourBaseCurrencyTime;
  int hourQuotedCurrencyTime;

  bool baseCurrencyOpened;
  bool quotedCurrencyOpened;
  bool marketOpened;
  bool allowNewOrders;
  bool hasMarketJustOpened;

  int nbrMinutesToStartTradingAfterForexOpen;
  int nbrMinutesToStopTradingBeforeForexEnd;
  int nbrMinutesToStopOpeningOrderBeforeForexEnd;

public :

  TimeManager(){
    baseCurrencyTime = NULL;
    quotedCurrencyTime = NULL;
    baseCurrencyOpened = false;
    quotedCurrencyOpened = false;
    marketOpened = false;
    allowNewOrders = false;
    hasMarketJustOpened = true;
  }

  static bool isFirstFridayOfMonth(){
    bool isTheDay = false;

    if(Day() <= 7 && DayOfWeek() == 5){
      isTheDay = true;
    }

    return isTheDay;
  }

  bool isNewWeek(){
    bool valueToReturn = false;

    if(hasMarketJustOpened) {
      valueToReturn = true;
      hasMarketJustOpened = false;
    }

    return valueToReturn;
  }

  datetime getBaseCurrencyTime(){
    return baseCurrencyTime;
  }

  datetime getQuotedCurrencyTime(){
    return quotedCurrencyTime;
  }

  int getBaseCurrencyHourTime(){
    return hourBaseCurrencyTime;
  }

  int getQuotedCurrencyHourTime(){
    return hourQuotedCurrencyTime;
  }

  bool isBaseAndQuotedCurrenciesOpened(){
    return this.baseCurrencyOpened && this.quotedCurrencyOpened;
  }

  bool isBaseOrQuotedCurrenciesOpened(){
    return this.baseCurrencyOpened || this.quotedCurrencyOpened;
  }

  bool isBaseCurrencyOpened(){
    return this.baseCurrencyOpened;
  }

  bool isQuotedCurrencyOpened(){
    return this.quotedCurrencyOpened;
  }

  bool isMarketOpenedForTrading(){
    return this.marketOpened;
  }

  bool isNewOrdersAllowed(){
    return this.allowNewOrders;
  }

  virtual void calculateTimesForCurrentSymbol(){return;};
  virtual void calculateTimes(string symbol){return;};

protected :

  //noOfDay : 0 = Sunday, 1 = Monday, 2 = Tuesday, ...
  int findSpecificDayInGivenPositionOfCurrentMonth(int noOfDay, int position, int nbDaysInTheMonth){
    int noDayOfMonthOfLastSunday = 0;
    int noSundayFound = 0;

    datetime currentTimeForCurrency = TimeGMT();
    MqlDateTime mqlDateTime;
    TimeToStruct(currentTimeForCurrency,mqlDateTime);

    for(int day = 1; day <= nbDaysInTheMonth; day++){
      mqlDateTime.day = day;
      if(TimeDayOfWeek(StructToTime(mqlDateTime)) == 0){
        ++noSundayFound;
        noDayOfMonthOfLastSunday = day;
        if(noSundayFound == position){
          break;
        }
      }
    }

    return noDayOfMonthOfLastSunday;
  }

  int getNbrDaysInMonth(int noMonth){
    int nbrDays = 0;

    switch(noMonth){
      case 1:
            nbrDays = 31;
            break;
      case 2:
      //TODO ajouter annees bisextiles
      nbrDays = 28;
      break;
      case 3:
      nbrDays = 31;
      break;
      case 4:
      nbrDays = 30;
      break;
      case 5:
      nbrDays = 31;
      break;
      case 6:
      nbrDays = 30;
      break;
      case 7:
      nbrDays = 31;
      break;
      case 8:
      nbrDays = 31;
      break;
      case 9:
      nbrDays = 30;
      break;
      case 10:
      nbrDays = 31;
      break;
      case 11:
      nbrDays = 30;
      break;
      case 12:
      nbrDays = 31;
      break;
    }

    return nbrDays;
  }

};

#include "StopLoss/TrailingStopLossStrategy.mqh"
#include "MoneyManagement/MoneyManagementStrategy.mqh"
#include "Indicators/CustomIndicatorsAcces.mqh"
#include "TimeManager/TimeManager.mqh"
#include "Utils/OrderUtils.mqh"
#include "Utils/BuySell.mqh"
#include "Utils/ErrorUtils.mqh"
#include "Utils/PriceUtils.mqh"

class StrategyManager {

public :

  StrategyManager(){
    errorUtils = new ErrorUtils();
    priceUtils = new PriceUtils();
    buySell = new BuySell(errorUtils, priceUtils);
    orderUtils = new OrderUtils(errorUtils, priceUtils);
  }

  void execute(){

    if(protectionMinAccount>0 && AccountEquity()<protectionMinAccount){
      this.activateProtectionMinAccount();
    } else {
      timeManager.calculateTimesForCurrentSymbol();
      this.manageWeeklyProtection();

      if((closeAllTradesWhenForexMarketClose == false || timeManager.isMarketOpenedForTrading()) && (this.checkIfEquityReachedLimit() == false)) {
        this.onTick();
        if(isNewBar()) {
          this.onNewCandle();
        }
        allOrdersHaveBeenClosed = false;
      } else {
        if(allOrdersHaveBeenClosed == false){
          allOrdersHaveBeenClosed = buySell.closeAllOpenOrdersForMagicNumber(magicNumber, true);
        }
      }
    }
  }

  void onDeinit()
  {
    delete(errorUtils);
    delete(priceUtils);
    delete(buySell);
    delete(orderUtils);
    delete(trailingStopLossStrategy);
    delete(moneyManagementStrategy);
    delete(timeManager);
  }

  virtual void initialize(TrailingStopLossStrategy *trailingStopLossStrategyArg,
                          MoneyManagementStrategy *moneyManagementStrategyArg,
                          TimeManager *timeManagerArg,
                          int magicNumberArg,
                          bool isECNBrokerArg,
                          bool closeAllTradesWhenForexMarketCloseArg,
                          bool tradeOnlyWhenAtLeastOneCurrencyOpenedArg,
                          bool tradeOnlyDuringWhenBothCurrencesOpenedArg,
                          double protectionMinAccountArg,
                          bool isAccountProtectedByWeeklyLossArg,
                          double pourcentLossAllowedInAWeekArg,
                          double pourcentFollowingStopLossInAWeekArg
                        ){
    if(magicNumberArg == 0){
      Alert("No magic Number. Closing EA ...");
      closeExpert();
    }
    trailingStopLossStrategy = trailingStopLossStrategyArg;
    moneyManagementStrategy = moneyManagementStrategyArg;
    timeManager = timeManagerArg;
    magicNumber = magicNumberArg;
    isECNBroker = isECNBrokerArg;
    protectionMinAccount = protectionMinAccountArg;
    closeAllTradesWhenForexMarketClose = closeAllTradesWhenForexMarketCloseArg;
    tradeOnlyWhenAtLeastOneCurrencyOpened = tradeOnlyWhenAtLeastOneCurrencyOpenedArg;
    tradeOnlyDuringWhenBothCurrencesOpened = tradeOnlyDuringWhenBothCurrencesOpenedArg;
    allOrdersHaveBeenClosed = false;
    isAccountProtectedByWeeklyLoss = isAccountProtectedByWeeklyLossArg;
    pourcentLossAllowedInAWeek = pourcentLossAllowedInAWeekArg;
    pourcentFollowingStopLossInAWeek = pourcentFollowingStopLossInAWeekArg;
    equityAtBeginingOfWeek = 0;
    specificInitialization();
  }

protected :

  ErrorUtils *errorUtils;
  PriceUtils *priceUtils;
  BuySell *buySell;
  OrderUtils *orderUtils;
  bool allOrdersHaveBeenClosed;

  TrailingStopLossStrategy *trailingStopLossStrategy;
  MoneyManagementStrategy *moneyManagementStrategy;
  TimeManager *timeManager;
  int magicNumber;
  bool isECNBroker;
  double protectionMinAccount;

  //Time Management
  bool closeAllTradesWhenForexMarketClose;
  bool tradeOnlyWhenAtLeastOneCurrencyOpened;
  bool tradeOnlyDuringWhenBothCurrencesOpened;
  //Weekly Protection
  double equityAtBeginingOfWeek;
  double equityLossLimit;
  double equityTakeProfitLimit;
  double equityFollowingTakeProfit;
  double pourcentLossAllowedInAWeek;
  double pourcentFollowingStopLossInAWeek;
  bool isAccountProtectedByWeeklyLoss;
  bool isTradingFinishedForTheWeek;

  virtual void onTick(){return;};
  virtual void onNewCandle(){return;};
  virtual void specificInitialization(){return;};

  bool isCurrenciesCanBeTrade(){
    bool currenciesCanBeTrade = false;

    if(timeManager.isNewOrdersAllowed()){
      if(tradeOnlyDuringWhenBothCurrencesOpened == false && tradeOnlyWhenAtLeastOneCurrencyOpened == false){
        currenciesCanBeTrade = true;
      }
      else if((tradeOnlyDuringWhenBothCurrencesOpened == true && timeManager.isBaseAndQuotedCurrenciesOpened())
            || (tradeOnlyWhenAtLeastOneCurrencyOpened == true && timeManager.isBaseOrQuotedCurrenciesOpened())){
        currenciesCanBeTrade = true;
      }
    }

    return currenciesCanBeTrade;
  }


  void setTrailingStopLossStrategy(TrailingStopLossStrategy *trailingStopLossStrategyArg){
    trailingStopLossStrategy = trailingStopLossStrategyArg;
  }

  void setMoneyManagementStrategy(MoneyManagementStrategy *moneyManagementStrategyArg){
    moneyManagementStrategy = moneyManagementStrategyArg;
  }

  void setTimeManager(TimeManager *timeManagerArg){
    timeManager = timeManagerArg;
  }

  void setMagicNumber(int magicNumberArg){
    magicNumber = magicNumberArg;
  }

  private :

  datetime lastBarOpenTime;

  bool isNewBar() {
    datetime thisBarOpenTime = Time[0];
    if(thisBarOpenTime != lastBarOpenTime) {
      lastBarOpenTime = thisBarOpenTime;
      return (true);
    } else {
      return (false);
    }
  }

  void manageWeeklyProtection(){
    if(isAccountProtectedByWeeklyLoss){
      if(timeManager.isNewWeek() || equityAtBeginingOfWeek == 0){
        isTradingFinishedForTheWeek = false;
        equityAtBeginingOfWeek = AccountEquity();
        equityLossLimit = equityAtBeginingOfWeek - ((pourcentLossAllowedInAWeek * equityAtBeginingOfWeek) / 100);
        equityTakeProfitLimit = equityAtBeginingOfWeek + ((pourcentLossAllowedInAWeek * equityAtBeginingOfWeek) / 100);
        equityFollowingTakeProfit = 0;
      }
    }
  }

  bool checkIfEquityReachedLimit(){
    bool equityReachedLimit = false;

    if(isAccountProtectedByWeeklyLoss){
      if(isTradingFinishedForTheWeek) {
        equityReachedLimit = true;
      } else {
        if(AccountEquity() < equityLossLimit) {
          equityReachedLimit = true;
          isTradingFinishedForTheWeek = true;
        } else if(equityFollowingTakeProfit == 0){
          //Not reached tp yet
          if(AccountEquity() >= equityTakeProfitLimit){
            equityFollowingTakeProfit = equityTakeProfitLimit - ((pourcentFollowingStopLossInAWeek * equityTakeProfitLimit) / 100);
          }
        } else if(equityFollowingTakeProfit != 0) {
          if(AccountEquity() < equityFollowingTakeProfit) {
            equityReachedLimit = true;
            isTradingFinishedForTheWeek = true;
          } else {
            //Update following tp
            double newDistanceForFollowing = AccountEquity() - ((pourcentFollowingStopLossInAWeek * AccountEquity()) / 100);
            if(equityFollowingTakeProfit < newDistanceForFollowing) {
              equityFollowingTakeProfit = newDistanceForFollowing;
            }
          }
        }
      }
    }

    return equityReachedLimit;
  }

  void activateProtectionMinAccount()
  {
    buySell.closeAllOpenOrdersForMagicNumber(magicNumber, true);

    string account = DoubleToString(AccountEquity(), 2);
    string message = "The account equity (" + account + ") dropped below the minimum allowed (" + string(protectionMinAccount)+").";
    errorUtils.displayError(message);

    Sleep(20*1000);
    closeExpert();
  }

  void closeExpert(void)
  {
    ExpertRemove();
  }

};

#include "StopLoss/TrailingStopLossStrategy.mqh"
#include "StopLoss/FollowDistanceBreakHeavenStopLossStrategy.mqh"
#include "StopLoss/FollowDistanceInPipsStopLossStrategy.mqh"
#include "StopLoss/SimulateTakeProfitStopLossStrategy.mqh"
#include "StopLoss/NoStopLossStrategy.mqh"
#include "MoneyManagement/MoneyManagementStrategy.mqh"
#include "MoneyManagement/ClassicMoneyManagementStrategy.mqh"
#include "MoneyManagement/FixedRatioMoneyManagementStrategy.mqh"
#include "MoneyManagement/KellyMoneyManagementStrategy.mqh"
#include "MoneyManagement/BackTestingManagementStrategy.mqh"
#include "MoneyManagement/FixedAmountMoneyManagementStrategy.mqh"
#include "TimeManager/TimeManager.mqh"
#include "TimeManager/ForexTimeManager.mqh"

class StrategyFactory {

  public :

  enum MoneyManagementEnum {
    Pourcent_Risk_Money_Management = 0,
    Fixed_Ratio_Money_Management = 1,
    Kelly_Money_Management = 2,
    Fixed_Amount_Money_Management = 3,
    BackTesting_Money_Management = 4,
  };

  enum TrailingStopLossEnum {
    Follow_distance_in_pips = 0,
    Follow_distance_with_breakheaven_levels = 1,
    Simulate_take_profit_and_then_follow = 2,
    No_trailing_stop = 3,
  };

  static MoneyManagementStrategy *createMoneyManagement(MoneyManagementEnum moneyManagementEnumArg,
                                                        double riskInPourcentArg,
                                                        double initialRiskInPourcentArg,
                                                        double deltaInUnitsArg,
                                                        double initialBalanceArg,
                                                        double winningChanceArg,
                                                        double ratioLoseProfitArg,
                                                        double nbrLotsArg){
    if(moneyManagementEnumArg == Pourcent_Risk_Money_Management){
      return new ClassicMoneyManagementStrategy(riskInPourcentArg);
    } else if(moneyManagementEnumArg == Fixed_Ratio_Money_Management){
      return new FixedRatioManagementStrategy(initialRiskInPourcentArg, deltaInUnitsArg, initialBalanceArg);
    } else if(moneyManagementEnumArg == Kelly_Money_Management){
      return new KellyMoneyManagementStrategy(winningChanceArg, ratioLoseProfitArg);
    } else if(moneyManagementEnumArg == Fixed_Amount_Money_Management){
      return new FixedAmountMoneyManagementStrategy(nbrLotsArg);
    } else if(moneyManagementEnumArg == BackTesting_Money_Management){
      return new BackTestingManagementStrategy(riskInPourcentArg);
    }

    return NULL;
  }

  static TrailingStopLossStrategy *createTrailingStopStrategy(TrailingStopLossEnum trailingStopLossEnumArg,
                                                        double stopLossDistanceInPipsArg, double simulatedTakeProfitArg){
    if(trailingStopLossEnumArg == Follow_distance_in_pips){
      return new FollowDistanceInPipsStopLossStrategy(stopLossDistanceInPipsArg);
    } else if(trailingStopLossEnumArg == Follow_distance_with_breakheaven_levels){
      return new FollowDistanceBreakHeavenStopLossStrategy(stopLossDistanceInPipsArg);
    } else if(trailingStopLossEnumArg == No_trailing_stop){
      return new NoStopLossStrategy();
    }  else if(trailingStopLossEnumArg == Simulate_take_profit_and_then_follow){
      return new SimulateTakeProfitStopLossStrategy(simulatedTakeProfitArg, stopLossDistanceInPipsArg);
    }

    return NULL;
  }

  static TimeManager *createTimeManager(int nbrHoursAfterForexMarketOpenForStartingTradingArg, int nbrHoursBeforeForexMarketCloseForClosingAllTradeArg, int nbrMinutesBeforeForexMarketCloseForStopingOpeningNewTradesArg){
    return new ForexTimeManager(nbrHoursAfterForexMarketOpenForStartingTradingArg, nbrHoursBeforeForexMarketCloseForClosingAllTradeArg, nbrMinutesBeforeForexMarketCloseForStopingOpeningNewTradesArg);
  }

};

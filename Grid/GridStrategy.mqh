#include <Strategy/Grid/GridBasketSignalStrategy.mqh>
#include <Strategy/Grid/GridBasketsManager.mqh>
#include <Strategy/Utils/OrderUtils.mqh>

#define GRID_VERSION 2.16
//2.16  Correction save basket

class GridStrategy : public GridBasketSignalStrategy {

  protected :

  enum UpdateActionType {
    OnNewBar = 0,
    OnNewTick = 1,
  };

  //From exterm parameters
  //For Strategy
  double gridInPips;
  double gridMultiplier;
  double gridAddition;
  int numberOfOrdersForRaisingGrid;
  int basketNumber;
  int strategyNumber;
  string symbolToTrade;
  GridNewOrderOpeningType newOrderOpeningType;
  double nbrLotsToTake;
  double initialBalanceForAutomaticCalculation;
  bool autoMoneyManagement;
  int nbrOrdersMax;
  bool dontTakeAnyLeverage;
  double slInNbrPipsForCalculatingNbrLots;
  GridMoneyManagementStrategyType moneyManagementStrategyType;

  //Out of strategy
  GridTakeProfitCalcultationType takeProfitCalcultationType;
  GridNewOrderLotCalculationType newOrderLotCalculationType;
  GridTrailingSLType trailingSLType;

  double TPAccountBalancePourcentage;
  double TPNbrPips;
  double TPAmountInAccountCurrency;
  double TrailingSLNumberOfPips;
  double lotMultiplierForNextPosition;
  double lotAdditionForNextPosition;

  int nbrOrdersMaxBeforeSecurity;
  double TPSecurityAmountInAccountCurrency;
  int magicNumberValue;
  bool isBroketECN;

  bool protectAccount;
  double lossAllowedInAccountPourcentage;

  GridBasketsManager *gridBasketsManager;

  bool addTrailingOnCoverOrders;
  bool closeCoverOrderOnSignal;
  bool trailCoverOrdersFromStart;
  double TrailingCoverOrdersSLNumberOfPips;
  double coverOrdersSLSecurityRatio;
  double coverOrdersQuantityRatio;
  GridCoverType coverType;

  bool saveAndLoadData;
  double gridCoverInPips;
  double coverOrdersTPRatio;
  CoverLotCalulationType coverLotCalulation;

  int numberOfOrdersForDecreasingTPNbrPips;
  double TPNbrPipsDecreasingValue;
  int numberOfOrdersForIncreasingLotMultiplier;
  double LotMultiplierIncresing;

  bool closeAfterReachMaxNbrOrder;

  double doubleValue1;
  double doubleValue2;
  double doubleValue3;
  double doubleValue4;
  int intValue1;
  int intValue2;
  int intValue3;
  int intValue4;
  bool boolValue1;
  bool boolValue2;
  bool boolValue3;
  bool boolValue4;

  UpdateActionType updateAction;

  int timeFrame;
  double maxLot;

  int todayValue;

  OrderUtils *orderUtils;

  public :

  string getVersion(){
    return string(GRID_VERSION);
  }

  void setValues(double gridInPipsArg, double gridMultiplierArg, double gridAdditionArg, int numberOfOrdersForRaisingGridArg,
    int basketNumberArg, int strategyNumberArg, string symbolToTradeArg,
    GridTakeProfitCalcultationType takeProfitCalcultationTypeArg, GridNewOrderLotCalculationType newOrderLotCalculationTypeArg, GridTrailingSLType trailingSLTypeArg, GridNewOrderOpeningType newOrderOpeningTypeArg,
    double TPAccountBalancePourcentageArg, double TPNbrPipsArg, double TPAmountInAccountCurrencyArg,
    double TrailingSLNumberOfPipsArg, double lotMultiplierForNextPositionArg, double lotAdditionForNextPositionArg,
    int nbrOrdersMaxBeforeSecurityArg, double TPSecurityAmountInAccountCurrencyArg,
    int magicNumberValueArg, bool isBroketECNArg, bool protectAccountArg, double lossAllowedInAccountPourcentageArg,
    double nbrLotsToTakeArg,  double initialBalanceForAutomaticCalculationArg, int nbrOrdersMaxArg, bool dontTakeAnyLeverageArg, double slInNbrPipsForCalculatingNbrLotsArg, GridMoneyManagementStrategyType moneyManagementStrategyTypeArg,
    bool addTrailingOnCoverOrdersArg, bool closeCoverOrderOnSignalArg, bool trailCoverOrdersFromStartArg, double TrailingCoverOrdersSLNumberOfPipsArg, double coverOrdersSLSecurityRatioArg, double coverOrdersQuantityRatioArg, GridCoverType coverTypeArg,
    bool saveAndLoadDataArg, double gridCoverInPipsArg, double coverOrdersTPRatioArg, CoverLotCalulationType coverLotCalulationArg,
    int numberOfOrdersForDecreasingTPNbrPipsArg, double TPNbrPipsDecreasingValueArg, int numberOfOrdersForIncreasingLotMultiplierArg, double LotMultiplierIncresingArg, bool closeAfterReachMaxNbrOrderArg,
    double doubleValue1Arg,
    double doubleValue2Arg,
    double doubleValue3Arg,
    double doubleValue4Arg,
    int intValue1Arg,
    int intValue2Arg,
    int intValue3Arg,
    int intValue4Arg,
    bool boolValue1Arg,
    bool boolValue2Arg,
    bool boolValue3Arg,
    bool boolValue4Arg){
      this.gridInPips = gridInPipsArg;
      this.gridMultiplier = gridMultiplierArg;
      this.gridAddition = gridAdditionArg;
      this.numberOfOrdersForRaisingGrid = numberOfOrdersForRaisingGridArg;
      this.basketNumber = basketNumberArg;
      this.strategyNumber = strategyNumberArg;
      this.symbolToTrade = symbolToTradeArg;
      this.takeProfitCalcultationType = takeProfitCalcultationTypeArg;
      this.newOrderLotCalculationType = newOrderLotCalculationTypeArg;
      this.trailingSLType = trailingSLTypeArg;
      this.newOrderOpeningType = newOrderOpeningTypeArg;
      this.TPAccountBalancePourcentage = TPAccountBalancePourcentageArg;
      this.TPNbrPips = TPNbrPipsArg;
      this.TPAmountInAccountCurrency= TPAmountInAccountCurrencyArg;
      this.TrailingSLNumberOfPips = TrailingSLNumberOfPipsArg;
      this.lotMultiplierForNextPosition = lotMultiplierForNextPositionArg;
      this.lotAdditionForNextPosition = lotAdditionForNextPositionArg;
      this.nbrOrdersMaxBeforeSecurity = nbrOrdersMaxBeforeSecurityArg;
      this.TPSecurityAmountInAccountCurrency = TPSecurityAmountInAccountCurrencyArg;
      this.magicNumberValue = magicNumberValueArg;
      this.isBroketECN = isBroketECNArg;
      this.protectAccount = protectAccountArg;
      this.lossAllowedInAccountPourcentage = lossAllowedInAccountPourcentageArg;
      this.nbrLotsToTake = nbrLotsToTakeArg;
      this.initialBalanceForAutomaticCalculation = initialBalanceForAutomaticCalculationArg;
      this.nbrOrdersMax = nbrOrdersMaxArg;
      this.dontTakeAnyLeverage = dontTakeAnyLeverageArg;
      this.slInNbrPipsForCalculatingNbrLots = slInNbrPipsForCalculatingNbrLotsArg;
      this.moneyManagementStrategyType = moneyManagementStrategyTypeArg;

      this.addTrailingOnCoverOrders = addTrailingOnCoverOrdersArg;
      this.closeCoverOrderOnSignal = closeCoverOrderOnSignalArg;
      this.trailCoverOrdersFromStart = trailCoverOrdersFromStartArg;
      this.TrailingCoverOrdersSLNumberOfPips = TrailingCoverOrdersSLNumberOfPipsArg;
      this.coverOrdersSLSecurityRatio = coverOrdersSLSecurityRatioArg;
      this.coverOrdersQuantityRatio = coverOrdersQuantityRatioArg;
      this.coverType = coverTypeArg;

      this.saveAndLoadData = saveAndLoadDataArg;
      this.gridCoverInPips = gridCoverInPipsArg;
      this.coverOrdersTPRatio = coverOrdersTPRatioArg;
      this.coverLotCalulation = coverLotCalulationArg;

      this.numberOfOrdersForDecreasingTPNbrPips = numberOfOrdersForDecreasingTPNbrPipsArg;
      this.TPNbrPipsDecreasingValue = TPNbrPipsDecreasingValueArg;
      this.numberOfOrdersForIncreasingLotMultiplier = numberOfOrdersForIncreasingLotMultiplierArg;
      this.LotMultiplierIncresing = LotMultiplierIncresingArg;

      this.closeAfterReachMaxNbrOrder = closeAfterReachMaxNbrOrderArg;

      this.doubleValue1 = doubleValue1Arg;
      this.doubleValue2 = doubleValue2Arg;
      this.doubleValue3 = doubleValue3Arg;
      this.doubleValue4 = doubleValue4Arg;
      this.intValue1 = intValue1Arg;
      this.intValue2 = intValue2Arg;
      this.intValue3 = intValue3Arg;
      this.intValue4 = intValue4Arg;
      this.boolValue1 = boolValue1Arg;
      this.boolValue2 = boolValue2Arg;
      this.boolValue3 = boolValue3Arg;
      this.boolValue4 = boolValue4Arg;

      this.updateAction = OnNewTick;
      this.timeFrame = Period();

      this.orderUtils = new OrderUtils();

      this.setSpecificValues();

      this.gridBasketsManager = new GridBasketsManager(
        gridInPips,
        gridMultiplier,
        gridAddition,
        numberOfOrdersForRaisingGrid,
        basketNumber,
        strategyNumber,
        symbolToTrade,
        takeProfitCalcultationType,
        newOrderLotCalculationType,
        trailingSLType,
        newOrderOpeningType,
        TPAccountBalancePourcentage,
        TPNbrPips,
        TPAmountInAccountCurrency,
        TrailingSLNumberOfPips,
        lotMultiplierForNextPosition,
        lotAdditionForNextPosition,
        nbrOrdersMaxBeforeSecurity,
        TPSecurityAmountInAccountCurrency,
        magicNumberValue,
        isBroketECN,
        protectAccount,
        lossAllowedInAccountPourcentage,
        GetPointer(this),
        nbrLotsToTake,
        initialBalanceForAutomaticCalculation,
        nbrOrdersMax,
        dontTakeAnyLeverage,
        slInNbrPipsForCalculatingNbrLots,
        moneyManagementStrategyType,
        addTrailingOnCoverOrders,
        closeCoverOrderOnSignal,
        trailCoverOrdersFromStart,
        TrailingCoverOrdersSLNumberOfPips,
        coverOrdersSLSecurityRatio,
        coverOrdersQuantityRatio,
        coverType,
        saveAndLoadData,
        gridCoverInPips,
        coverOrdersTPRatio,
        coverLotCalulation,
        numberOfOrdersForDecreasingTPNbrPips,
        TPNbrPipsDecreasingValue,
        numberOfOrdersForIncreasingLotMultiplier,
        LotMultiplierIncresing,
        closeAfterReachMaxNbrOrder
      );
  }

  void setDefaultValues(){
    this.gridInPips = 100;
    this.gridMultiplier = 1;
    this.gridAddition = 0;
    this.basketNumber = 0;
    this.strategyNumber = 0;
    this.symbolToTrade = Symbol();
    this.takeProfitCalcultationType = OnNbrPips;
    this.newOrderLotCalculationType = MultiplyPreviousLotQuantity;
    this.trailingSLType = noTrailingSL;
    this.newOrderOpeningType = ClassicGridSytem;
    this.TPAccountBalancePourcentage = 1;
    this.TPNbrPips = 30;
    this.TPAmountInAccountCurrency= 0;
    this.TrailingSLNumberOfPips = 0;
    this.lotMultiplierForNextPosition = 1.7;
    this.lotAdditionForNextPosition = 0.1;
    this.nbrOrdersMaxBeforeSecurity = 6;
    this.TPSecurityAmountInAccountCurrency = 40;
    this.magicNumberValue = 46785;
    this.isBroketECN = true;
    this.protectAccount = false;
    this.lossAllowedInAccountPourcentage = 20;
    this.nbrLotsToTake = 0.1;
    this.initialBalanceForAutomaticCalculation = 1000;
    this.nbrOrdersMax = 15;
    this.dontTakeAnyLeverage = false;
    this.slInNbrPipsForCalculatingNbrLots = 15;
    this.moneyManagementStrategyType = FixedAmountLots;

    this.addTrailingOnCoverOrders = true;
    this.closeCoverOrderOnSignal = false;
    this.trailCoverOrdersFromStart = false;
    this.TrailingCoverOrdersSLNumberOfPips = 1;
    this.coverOrdersSLSecurityRatio = 2;

    this.updateAction = OnNewTick;
    this.timeFrame = Period();

    this.orderUtils = new OrderUtils();

    this.setSpecificValues();

    this.gridBasketsManager = new GridBasketsManager(
      gridInPips,
      gridMultiplier,
      gridAddition,
      numberOfOrdersForRaisingGrid,
      basketNumber,
      strategyNumber,
      symbolToTrade,
      takeProfitCalcultationType,
      newOrderLotCalculationType,
      trailingSLType,
      newOrderOpeningType,
      TPAccountBalancePourcentage,
      TPNbrPips,
      TPAmountInAccountCurrency,
      TrailingSLNumberOfPips,
      lotMultiplierForNextPosition,
      lotAdditionForNextPosition,
      nbrOrdersMaxBeforeSecurity,
      TPSecurityAmountInAccountCurrency,
      magicNumberValue,
      isBroketECN,
      protectAccount,
      lossAllowedInAccountPourcentage,
      GetPointer(this),
      nbrLotsToTake,
      initialBalanceForAutomaticCalculation,
      nbrOrdersMax,
      dontTakeAnyLeverage,
      slInNbrPipsForCalculatingNbrLots,
      moneyManagementStrategyType,
      addTrailingOnCoverOrders,
      closeCoverOrderOnSignal,
      trailCoverOrdersFromStart,
      TrailingCoverOrdersSLNumberOfPips,
      coverOrdersSLSecurityRatio,
      coverOrdersQuantityRatio,
      coverType,
      saveAndLoadData,
      gridCoverInPips,
      coverOrdersTPRatio,
      coverLotCalulation,
      numberOfOrdersForDecreasingTPNbrPips,
      TPNbrPipsDecreasingValue,
      numberOfOrdersForIncreasingLotMultiplier,
      LotMultiplierIncresing,
      closeAfterReachMaxNbrOrder
    );
  }

  GridStrategy(){
    maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    todayValue = DayOfWeek();
  }

  virtual void setSpecificValues(){return;};

  void onTick(){

    if(isNewDay()){
      onNewDay();
    }

    bool newBar = isNewBar();

    if(newBar){
      onNewBar();
    }
    onEachTick();

    if((updateAction == OnNewBar && newBar) || (updateAction == OnNewTick)){
      this.gridBasketsManager.updateAllBaskets();
    }

    if(trailingSLType == WhenTPReachedFollowContinuouslyByNumberOfPips){
      this.gridBasketsManager.updateAllTrailingStop();
    }

    this.gridBasketsManager.updateAllCoverOrders();
  };

  void release(){
    releaseStrategy();

    if(CheckPointer(gridBasketsManager) != POINTER_INVALID && gridBasketsManager != NULL) {
      gridBasketsManager.release();
      delete gridBasketsManager;
    }

    delete this.orderUtils;
  }

  virtual void releaseStrategy(){return;};

  virtual void onEachTick(){return;};
  virtual void onNewBar(){return;};
  virtual void onNewDay(){return;};

  virtual void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){return;};
  virtual void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){return;};

  virtual bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return true;};
  virtual bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return true;};
  virtual bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return false;};
  virtual bool isClosingCoverOrderSignal(int orderCoverTypeArg, int basketNumberArg, int strategyNumberArg){return false;};

  protected :

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



  bool isNewDay(){
    bool newDay = false;

    if(DayOfWeek() != todayValue){
        todayValue = DayOfWeek();
        newDay = true;
    }

    return newDay;
  }

};

#include <Strategy/Utils/OrderUtils.mqh>
#include <Strategy/Utils/NotificationUtils.mqh>
#include <Strategy/List/ArrayList.mqh>
#include <Strategy/List/ElementList.mqh>
#include <Strategy/List/Iterator.mqh>
#include <Strategy/Grid/GridBasket.mqh>
#include <Strategy/Grid/GridBasketSignalStrategy.mqh>

class GridBasketsManager {

  private :

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
  GridBasketSignalStrategy *basketSignalStrategy;
  double nbrLotsToTake;
  double initialBalanceForAutomaticCalculation;
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

  //Intern parameters
  ArrayList *basketList;
  OrderUtils *orderUtils;

  string inpDirectoryName;

  public :

  GridBasketsManager(double gridInPipsArg, double gridMultiplierArg, double gridAdditionArg, int numberOfOrdersForRaisingGridArg,
    int basketNumberArg, int strategyNumberArg, string symbolToTradeArg,
    GridTakeProfitCalcultationType takeProfitCalcultationTypeArg, GridNewOrderLotCalculationType newOrderLotCalculationTypeArg, GridTrailingSLType trailingSLTypeArg, GridNewOrderOpeningType newOrderOpeningTypeArg,
    double TPAccountBalancePourcentageArg, double TPNbrPipsArg, double TPAmountInAccountCurrencyArg,
    double TrailingSLNumberOfPipsArg, double lotMultiplierForNextPositionArg, double lotAdditionForNextPositionArg,
    int nbrOrdersMaxBeforeSecurityArg, double TPSecurityAmountInAccountCurrencyArg,
    int magicNumberValueArg, bool isBroketECNArg, bool protectAccountArg, double lossAllowedInAccountPourcentageArg,
    GridBasketSignalStrategy *basketSignalStrategyArg, double nbrLotsToTakeArg, double initialBalanceForAutomaticCalculationArg, int nbrOrdersMaxArg, bool dontTakeAnyLeverageArg,
    double slInNbrPipsForCalculatingNbrLotsArg, GridMoneyManagementStrategyType moneyManagementStrategyTypeArg,
    bool addTrailingOnCoverOrdersArg, bool closeCoverOrderOnSignalArg, bool trailCoverOrdersFromStartArg, double TrailingCoverOrdersSLNumberOfPipsArg, double coverOrdersSLSecurityRatioArg, double coverOrdersQuantityRatioArg, GridCoverType coverTypeArg,
    bool saveAndLoadDataArg, double gridCoverInPipsArg, double coverOrdersTPRatioArg, CoverLotCalulationType coverLotCalulationArg,
    int numberOfOrdersForDecreasingTPNbrPipsArg, double TPNbrPipsDecreasingValueArg, int numberOfOrdersForIncreasingLotMultiplierArg, double LotMultiplierIncresingArg, bool closeAfterReachMaxNbrOrderArg){
      gridInPips = gridInPipsArg;
      gridMultiplier = gridMultiplierArg;
      gridAddition = gridAdditionArg;
      numberOfOrdersForRaisingGrid = numberOfOrdersForRaisingGridArg;
      basketNumber = basketNumberArg;
      strategyNumber = strategyNumberArg;
      symbolToTrade = symbolToTradeArg;
      this.nbrLotsToTake = nbrLotsToTakeArg;
      this.initialBalanceForAutomaticCalculation = initialBalanceForAutomaticCalculationArg;
      takeProfitCalcultationType = takeProfitCalcultationTypeArg;
      newOrderLotCalculationType = newOrderLotCalculationTypeArg;
      trailingSLType = trailingSLTypeArg;
      this.newOrderOpeningType = newOrderOpeningTypeArg;
      TPAccountBalancePourcentage = TPAccountBalancePourcentageArg;
      TPNbrPips = TPNbrPipsArg;
      TPAmountInAccountCurrency = TPAmountInAccountCurrencyArg;
      TrailingSLNumberOfPips = TrailingSLNumberOfPipsArg;
      lotMultiplierForNextPosition = lotMultiplierForNextPositionArg;
      lotAdditionForNextPosition = lotAdditionForNextPositionArg;
      nbrOrdersMaxBeforeSecurity = nbrOrdersMaxBeforeSecurityArg;
      TPSecurityAmountInAccountCurrency = TPSecurityAmountInAccountCurrencyArg;
      magicNumberValue = magicNumberValueArg;
      isBroketECN = isBroketECNArg;
      protectAccount = protectAccountArg;
      lossAllowedInAccountPourcentage = lossAllowedInAccountPourcentageArg;

      this.basketSignalStrategy = basketSignalStrategyArg;

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

      this.basketList = new ArrayList();
      this.orderUtils = new OrderUtils();

      inpDirectoryName="Data";

      this.loadBaskets();
  }

  void loadBaskets(){
    if(!IsTesting() && saveAndLoadData){
      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
        if(OrderSelect(i, SELECT_BY_POS)) {
          if(OrderCloseTime() == 0 && OrderMagicNumber() == magicNumberValue) {
            Print("*** LoadBaskets - found 1 position with comment : "+OrderComment());
            if(FileIsExist(inpDirectoryName + "//" + OrderComment())) {
              if(!basketList.isElementWithIdExist(OrderComment())){
                GridBasket *newBasketElt = new GridBasket(
                  symbolToTrade,
                  magicNumberValue,
                  basketNumber,
                  strategyNumber,
                  nbrLotsToTake,
                  initialBalanceForAutomaticCalculation,
                  isBroketECN,
                  takeProfitCalcultationType,
                  newOrderLotCalculationType,
                  trailingSLType,
                  newOrderOpeningType,
                  gridInPips,
                  gridMultiplier,
                  gridAddition,
                  numberOfOrdersForRaisingGrid,
                  nbrOrdersMaxBeforeSecurity,
                  TPSecurityAmountInAccountCurrency,
                  TPAccountBalancePourcentage,
                  TPNbrPips,
                  TPAmountInAccountCurrency,
                  TrailingSLNumberOfPips,
                  lotMultiplierForNextPosition,
                  lotAdditionForNextPosition,
                  basketSignalStrategy,
                  nbrOrdersMax,
                  dontTakeAnyLeverage,
                  slInNbrPipsForCalculatingNbrLots,
                  lossAllowedInAccountPourcentage,
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
                Print("** BEGIN LOAD BASKET : "+OrderComment());
                newBasketElt.loadBasket(OrderComment());
                Print("** END LOAD BASKET : "+OrderComment());
                basketList.add(newBasketElt);
              }
            } else {
              Print("*** NO DATA FILE FOUND - IMPOSSIBLE TO MANAGE THIS ORDER ");
            }
          }
        }
      }
    }
  }

  void release(){

    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      basketElt.release();
    }

    delete iterator;

    basketList.release();
    orderUtils.release();
    delete basketList;
    delete orderUtils;
  }

  int removeUnusedBasket(){
    int nbBasketsRemoved = 0;

    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(!basketElt.isInUsed()){
        iterator.removeCurrentElement();
        ++nbBasketsRemoved;
      }
    }
    delete iterator;

    return nbBasketsRemoved;
  }

  int getNbrSellBaskets(){
    int nbrOrders = 0;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == OP_SELL && basketElt.isInUsed()){
        ++nbrOrders;
      }
    }

    delete iterator;

    return nbrOrders;
  }

  int getNbrBuyBaskets(){
    int nbrOrders = 0;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == OP_BUY && basketElt.isInUsed()){
        ++nbrOrders;
      }
    }

    delete iterator;

    return nbrOrders;
  }

  int getNbrOrdersInABasket(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg){
    int nbrOrders = 0;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
      && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
        nbrOrders += basketElt.getNbrPositionsOpenForThisBasket();
      }
    }

    delete iterator;

    return nbrOrders;
  }

  double getLastNbrLotsForABasket(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg){
    double lastNbrLots = 0;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
      && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
        lastNbrLots = basketElt.getLastOrderNbrLots();
      }
    }

    delete iterator;

    return lastNbrLots;
  }


    double getNbrLotsForABasket(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg){
      double lastNbrLots = 0;
      Iterator *iterator = basketList.iterator();
      while(iterator.hasNext()){
        GridBasket *basketElt = (GridBasket*)iterator.next();
        if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
        && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
          lastNbrLots = basketElt.getNbrLotsInThisBasket();
        }
      }

      delete iterator;

      return lastNbrLots;
    }

  bool isSpecificBasketWinning(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg){
    double profit = 0;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
      && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
        profit = basketElt.getCurrentProfitOnOpenedPositions();
      }
    }

    delete iterator;

    return profit > 0;
  }

  void  reajustTPSpecificBasket(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg, double tpArg){
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
      && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
        basketElt.reajustTP(tpArg);
      }
    }

    delete iterator;
  }

  void closeSpecificBasket(int basketOrderTypeArg, int basketNumberArg, int strategyNumberArg){

    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getBasketOrderType() == basketOrderTypeArg && basketElt.isInUsed()
      && basketElt.getBasketNumber() == basketNumberArg && basketElt.getStrategyNumber() == strategyNumberArg){
        basketElt.closeBasket();
      }
    }

    delete iterator;
  }

  ///No Grid - Just one order
  void addNewOrder(int typeBuyOrSellOrderArg, double slInNbrPipsForCalculatingNbrLotsArg){
      addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumber, strategyNumber, symbolToTrade,
        newOrderOpeningType, basketSignalStrategy, 1, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLotsArg, CalculateAmountLotsOnPourcentReadyToLose, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
        addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewOrder(int typeBuyOrSellOrderArg, double slInNbrPipsForCalculatingNbrLotsArg, int basketNumberArg){
      addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumber, symbolToTrade,
        newOrderOpeningType, basketSignalStrategy, 1, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLotsArg, CalculateAmountLotsOnPourcentReadyToLose, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
        addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewOrder(int typeBuyOrSellOrderArg, double slInNbrPipsForCalculatingNbrLotsArg, int basketNumberArg, int strategyNumberArg){
      addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
        newOrderOpeningType, basketSignalStrategy, 1, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLotsArg, CalculateAmountLotsOnPourcentReadyToLose, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
        addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  ///Grid - Multi order by basket
  void addNewBakset(int typeBuyOrSellOrderArg){
      addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumber, strategyNumber, symbolToTrade,
        newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
        addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewBakset(int typeBuyOrSellOrderArg, int basketNumberArg){
      addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumber, symbolToTrade,
        newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
        addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewBakset(int typeBuyOrSellOrderArg, int basketNumberArg, int strategyNumberArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPips,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewBakset(int typeBuyOrSellOrderArg, int basketNumberArg, int strategyNumberArg, double TPNbrPipsArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculation, TPNbrPipsArg,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewBaksetWithNbrLotsToTake(int typeBuyOrSellOrderArg, int basketNumberArg, int strategyNumberArg, double nbrLotsToTakeArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTakeArg, initialBalanceForAutomaticCalculation, TPNbrPips,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewBaksetWithNbrLotsMultiplier(int typeBuyOrSellOrderArg, int basketNumberArg, int strategyNumberArg, int multiplierArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake * multiplierArg, initialBalanceForAutomaticCalculation, TPNbrPips,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }

  void addNewSecurityBakset(int typeBuyOrSellOrderArg, double nbrLotsToTakeArg, int nbrOrdersMaxArg, int basketNumberArg, int strategyNumberArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPips, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMaxArg, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, FixedAmountLots, closeAfterReachMaxNbrOrder, nbrLotsToTakeArg, initialBalanceForAutomaticCalculation, TPNbrPips,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPips, coverOrdersSLSecurityRatio, coverOrdersQuantityRatio, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPosition, gridCoverInPips, trailingSLType);
  }


  void addNewBaksetSpecific01(int typeBuyOrSellOrderArg, int basketNumberArg, int strategyNumberArg, double initialBalanceForAutomaticCalculationArg, double lotMultiplierForNextPositionArg, double gridInPipsArg, double TPNbrPipsArg, double TrailingCoverOrdersSLNumberOfPipsArg, double coverOrdersQuantityRatioArg, double gridCoverInPipsArg, GridTrailingSLType trailingSLTypeArg){
    addNewBakset(typeBuyOrSellOrderArg, gridInPipsArg, gridMultiplier, gridAddition, numberOfOrdersForRaisingGrid, basketNumberArg, strategyNumberArg, symbolToTrade,
      newOrderOpeningType, basketSignalStrategy, nbrOrdersMax, dontTakeAnyLeverage, slInNbrPipsForCalculatingNbrLots, moneyManagementStrategyType, closeAfterReachMaxNbrOrder, nbrLotsToTake, initialBalanceForAutomaticCalculationArg, TPNbrPipsArg,
      addTrailingOnCoverOrders, closeCoverOrderOnSignal, trailCoverOrdersFromStart, TrailingCoverOrdersSLNumberOfPipsArg, coverOrdersSLSecurityRatio, coverOrdersQuantityRatioArg, coverType, nbrOrdersMaxBeforeSecurity, lotMultiplierForNextPositionArg, gridCoverInPipsArg, trailingSLTypeArg);
  }


  bool addNewBakset(int typeBuyOrSellOrderArg, double gridInPipsArg, double gridMultiplierArg, double gridAdditionArg, int numberOfOrdersForRaisingGridArg, int basketNumberArg, int strategyNumberArg, string symbolToTradeArg,
    GridNewOrderOpeningType newOrderOpeningTypeArg, GridBasketSignalStrategy *basketSignalStrategyArg, int nbrOrdersMaxArg, bool dontTakeAnyLeverageArg,
    double slInNbrPipsForCalculatingNbrLotsArg, GridMoneyManagementStrategyType moneyManagementStrategyTypeArg, bool closeAfterReachMaxNbrOrderArg, double nbrLotsToTakeArg, double initialBalanceForAutomaticCalculationArg, double TPNbrPipsArg,
    bool addTrailingOnCoverOrdersArg, bool closeCoverOrderOnSignalArg, bool trailCoverOrdersFromStartArg, double TrailingCoverOrdersSLNumberOfPipsArg, double coverOrdersSLSecurityRatioArg, double coverOrdersQuantityRatioArg, GridCoverType coverTypeArg, int nbrOrdersMaxBeforeSecurityArg,
    double lotMultiplierForNextPositionArg, double gridCoverInPipsArg, GridTrailingSLType trailingSLTypeArg){

      bool alreadyExist = false;
      bool hasBeenStarted = false;

      Iterator *iterator = basketList.iterator();
      while(iterator.hasNext()){
        GridBasket *basketElt = (GridBasket*)iterator.next();
        if(basketElt.checkBasket(basketNumberArg, strategyNumberArg)){
          if(!basketElt.isInUsed()){
            basketElt.reinitBasketForANewUse(TPNbrPipsArg);
            if(closeAfterReachMaxNbrOrderArg){
              basketElt.activateSpecialSecurity();
            }
            basketElt.setNbrLotsToTake(nbrLotsToTakeArg);
            basketElt.launchBasket(typeBuyOrSellOrderArg);
            hasBeenStarted = true;
          }
          alreadyExist = true;
          break;
        }
      }

      delete iterator;

      if(alreadyExist == false) {
          GridBasket *newBasketElt = new GridBasket(
            symbolToTradeArg,
            magicNumberValue,
            basketNumberArg,
            strategyNumberArg,
            nbrLotsToTakeArg,
            initialBalanceForAutomaticCalculationArg,
            isBroketECN,
            takeProfitCalcultationType,
            newOrderLotCalculationType,
            trailingSLTypeArg,
            newOrderOpeningTypeArg,
            gridInPipsArg,
            gridMultiplierArg,
            gridAdditionArg,
            numberOfOrdersForRaisingGridArg,
            nbrOrdersMaxBeforeSecurityArg,
            TPSecurityAmountInAccountCurrency,
            TPAccountBalancePourcentage,
            TPNbrPipsArg,
            TPAmountInAccountCurrency,
            TrailingSLNumberOfPips,
            lotMultiplierForNextPositionArg,
            lotAdditionForNextPosition,
            basketSignalStrategyArg,
            nbrOrdersMaxArg,
            dontTakeAnyLeverageArg,
            slInNbrPipsForCalculatingNbrLotsArg,
            lossAllowedInAccountPourcentage,
            moneyManagementStrategyTypeArg,
            addTrailingOnCoverOrdersArg,
            closeCoverOrderOnSignalArg,
            trailCoverOrdersFromStartArg,
            TrailingCoverOrdersSLNumberOfPipsArg,
            coverOrdersSLSecurityRatioArg,
            coverOrdersQuantityRatioArg,
            coverTypeArg,
            saveAndLoadData,
            gridCoverInPipsArg,
            coverOrdersTPRatio,
            coverLotCalulation,
            numberOfOrdersForDecreasingTPNbrPips,
            TPNbrPipsDecreasingValue,
            numberOfOrdersForIncreasingLotMultiplier,
            LotMultiplierIncresing,
            closeAfterReachMaxNbrOrderArg
          );

          newBasketElt.launchBasket(typeBuyOrSellOrderArg);
          basketList.add(newBasketElt);

          hasBeenStarted = true;
      }

      if(protectAccount && hasBeenStarted){
        this.updateAllStopLoss();
      }

      return hasBeenStarted;
  }

  void updateAllBaskets(){

    int nbBasketsRemoved = this.removeUnusedBasket();

    bool newOrdersAdded = false;
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      newOrdersAdded = basketElt.onUpdateBasket() || newOrdersAdded;
    }

    delete iterator;

    if(protectAccount && (newOrdersAdded || nbBasketsRemoved > 0)){
      this.updateAllStopLoss();
    }
  }

  void updateAllTrailingStop(){
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.isTrailingMustBeManaged()){
        basketElt.manageTrailingStop();
      }
    }

    delete iterator;
  }

  void updateAllCoverOrders(){
    Iterator *iterator = basketList.iterator();
    while(iterator.hasNext()){
      GridBasket *basketElt = (GridBasket*)iterator.next();
      if(basketElt.getNbrPositionsOpenForThisBasket() > nbrOrdersMaxBeforeSecurity || basketElt.getGridCoverStrategy().isNonStopEdging()) {
        basketElt.manageCoverOrders();
      }
    }

    delete iterator;
  }

  private :

  void updateAllStopLoss(){
    bool hasBuyingOrders = false;
    bool hasSellingOrders = false;
    double calculatedStopLoss;

    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
       if(OrderSelect(i, SELECT_BY_POS)) {
          if(OrderCloseTime() == 0
          && OrderMagicNumber() == magicNumberValue) {
            if(OrderType() == OP_BUY){
              hasBuyingOrders = true;
            } else if(OrderType() == OP_SELL){
              hasSellingOrders = true;
            }
          }
       }
    }

    if(hasBuyingOrders) {
      calculatedStopLoss = getStopLossOnUptrendSimulation();
      //orderUtils.updateSLForBuyingTicketsOpenWithMagicNumber(calculatedStopLoss, magicNumberValue);
      Iterator *iterator1 = basketList.iterator();
      while(iterator1.hasNext()){
        GridBasket *basketElt1 = (GridBasket*)iterator1.next();
        if(basketElt1.getBasketOrderType() == OP_BUY && !basketElt1.isTrailingActivated()){
          basketElt1.updateSecurityStopLoss(calculatedStopLoss);
        }
      }

      delete iterator1;
    }

    if(hasSellingOrders) {
      calculatedStopLoss = getStopLossOnDowntrendSimulation();
      //orderUtils.updateSLForSellingTicketsOpenWithMagicNumber(calculatedStopLoss, magicNumberValue);
      Iterator *iterator2 = basketList.iterator();
      while(iterator2.hasNext()){
        GridBasket *basketElt2 = (GridBasket*)iterator2.next();
        if(basketElt2.getBasketOrderType() == OP_SELL && !basketElt2.isTrailingActivated()){
          basketElt2.updateSecurityStopLoss(calculatedStopLoss);
        }
      }

      delete iterator2;
    }
  }

  double getStopLossOnUptrendSimulation(){
    return getStopLossSimulation(OP_BUY);
  }

  double getStopLossOnDowntrendSimulation(){
    return getStopLossSimulation(OP_SELL);
  }

  double getStopLossSimulation(int trendType) {
    double stopLossLevel = 0;
    //double leverage = 0;

    double TickSize = MarketInfo(symbolToTrade, MODE_TICKSIZE);
    double TickCostInAccountCurrencyForOneLot = MarketInfo(symbolToTrade, MODE_TICKVALUE);
    double amountToMaxToLoose = lossAllowedInAccountPourcentage * AccountBalance() / 100;

    double amountCalculated = 0;
    double priceToTest = trendType == OP_BUY ? MarketInfo(symbolToTrade,MODE_BID) : MarketInfo(symbolToTrade,MODE_ASK);

    double previousAmountCalculated = -1;
    while(amountCalculated < amountToMaxToLoose && amountCalculated > previousAmountCalculated) {
      previousAmountCalculated = amountCalculated;
      amountCalculated = 0;

      //We add one pip
      if(trendType == OP_BUY){
        priceToTest -= orderUtils.convertNbrPipInQuotedPrice(1);
      } else {
        priceToTest += orderUtils.convertNbrPipInQuotedPrice(1);
      }

      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)) {
            if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0
            && OrderMagicNumber() == magicNumberValue) {

              if(trendType == OP_BUY && OrderType() == OP_BUY){
                amountCalculated += OrderLots() * (((OrderOpenPrice() - priceToTest) * TickCostInAccountCurrencyForOneLot) / TickSize + MathAbs(OrderCommission()));
              } else if(OrderType() == OP_SELL && trendType == OP_SELL) {
                amountCalculated += OrderLots() * (((priceToTest - OrderOpenPrice()) * TickCostInAccountCurrencyForOneLot) / TickSize + MathAbs(OrderCommission()));
              }
            }
         }
      }

    }

    stopLossLevel = amountCalculated > 0 && amountCalculated > previousAmountCalculated && priceToTest > 0 ? priceToTest : 0;

    return stopLossLevel;
  }

};

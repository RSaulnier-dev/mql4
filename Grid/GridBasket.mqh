#include <Strategy/Utils/BuySell.mqh>
#include <Strategy/Utils/OrderUtils.mqh>
#include <Strategy/Orders/OrderElt.mqh>
#include <Strategy/List/ElementList.mqh>
#include <Strategy/Grid/GridBasketSignalStrategy.mqh>
#include <Strategy/Utils/DisplayUtils.mqh>
#include <Strategy/Grid/GridCoverStrategyFactory.mqh>
#include <Strategy/Grid/GridCoverTypeDefinition.mqh>

class GridBasket : public ElementList {

  enum GridMoneyManagementStrategyType {
    CalculateAmountLotsOnPourcentReadyToLose = 0,
    FixedAmountLots = 1,
    AutomaticAmountLotsDefinedForInitialBalanceInAccountCurrency = 2,
    AutomaticAmountLotsDefinedForInitialBalance_riskDecreasing = 3,
  };

  enum GridTakeProfitCalcultationType {
    OnAccountBalancePourcentage = 0,
    OnNbrPips = 1,
    OnAccountCurrencyAmount = 2,
    OnStrategySignal = 3,
    OnNbrPipsFromFirstOrder = 4,
  };

  enum GridNewOrderLotCalculationType {
    MultiplyPreviousLotQuantity = 0,
    AddAmountToPreviousLot = 1,
    MultiplyPreviousLotQuantityANDAddAmountToPreviousLot = 2,
  };

  enum GridTrailingSLType {
    noTrailingSL = 0,
    WhenTPReachedFollowContinuouslyByNumberOfPips = 1,
    //WhenTPReachedFollowAtEachNewLevel = 2,
    //WhenTPReachedFollowWithEdgeOfEachCandle = 3,
  };

  enum GridNewOrderOpeningType {
    ClassicGridSytem = 0,
    OpenPositionIfNewSignal = 1,
  };

  private :

  //From exterm parameters
  double gridInPips;
  double gridMultiplier;
  double gridAddition;
  int numberOfOrdersForRaisingGrid;
  int basketNumber;
  int strategyNumber;
  int magicNumberValue;
  string symbolToTrade;
  double nbrLotsToTake;
  double initialBalanceForAutomaticCalculation;
  double slInNbrPipsForCalculatingNbrLots;
  double lossAllowedInAccountPourcentage;
  bool isBroketECN;

  GridTakeProfitCalcultationType takeProfitCalcultationType;
  GridNewOrderLotCalculationType newOrderLotCalculationType;
  GridTrailingSLType trailingSLType;
  GridNewOrderOpeningType newOrderOpeningType;
  GridMoneyManagementStrategyType moneyManagementStrategyType;

  int nbrOrdersMaxBeforeSecurity;
  double TPSecurityAmountInAccountCurrency;
  double TPAccountBalancePourcentage;
  double TPNbrPips;
  double TPAmountInAccountCurrency;
  double TrailingSLNumberOfPips;
  double lotMultiplierForNextPosition;
  double lotAdditionForNextPosition;

  GridBasketSignalStrategy *basketSignalStrategy;

  int nbrOrdersMax;
  bool dontTakeAnyLeverage;

  bool closeAfterReachMaxNbrOrder;

  bool addTrailingOnCoverOrders;
  bool closeCoverOrderOnSignal;
  bool trailCoverOrdersFromStart;
  double TrailingCoverOrdersSLNumberOfPips;
  double coverOrdersSLSecurityRatio;
  double coverOrdersQuantityRatio;

  bool saveAndLoadData;
  double gridCoverInPips;
  double coverOrdersTPRatio;

  int numberOfOrdersForDecreasingTPNbrPips;
  double TPNbrPipsDecreasingValue;
  int numberOfOrdersForIncreasingLotMultiplier;
  double LotMultiplierIncresing;

  //Intern parameters
  BuySell *buySell;
  OrderUtils *orderUtils;
  DisplayUtils *displayUtils;
  GridCoverStrategy *gridCoverStrategy;

  double initialNbrLotsToTake;
  double initialPrice;
  double takeProfitLevel;
  double takeProfitRecoverLevel;
  double nextOrderLevel;
  double nextInversedOrderLevel;
  double previousOrderLevel;
  double firstCoverLevelForClosingAllPositions;
  int typeBuyOrSellOrder;
  string orderCommentForBasket;
  bool isInitialised;
  int lastTicketNumber;
  double pipValueInPoint;
  int nbrPositionsOpen;
  double nbrPips;

  bool trailingActivated;
  double virtualTrailingSLLevel;

  bool trailingCoverActivated;
  double virtualTrailingSLLevelForCoverOrders;
  double takeProfitLevelForCover;

  bool coverIsActivated;
  double lastCoverOrderNbrLots;
  double lastOrderNbrLots;
  double coverOpenLevel;

  int file_handle;
  string inpFileName;
  string inpDirectoryName;

  double tickSize;
  double tickCostInAccountCurrencyForOneLot;

  double nextCoverOrderLevel;
  double currentCoverOrderLevel;
  bool hasGridCoverStarted;
  CoverLotCalulationType coverLotCalulation;

  double TPNbrPipsInitialValue;
  double lotMultiplierForNextPositionInitialValue;
  double lotAdditionForNextPositionInitialValue;

  bool closeAfterReachMaxNbrOrderInitial;
  bool closedWhenReachMaxNbrOrder;

  public :

  GridBasket(string symbolToTradeArg, int magicNumberValueArg, int basketNumberArg, int strategyNumberArg, double nbrLotsToTakeArg, double initialBalanceForAutomaticCalculationArg, bool isBroketECNArg,
    GridTakeProfitCalcultationType takeProfitCalcultationTypeArg, GridNewOrderLotCalculationType newOrderLotCalculationTypeArg, GridTrailingSLType trailingSLTypeArg, GridNewOrderOpeningType newOrderOpeningTypeArg,
    double gridInPipsArg, double gridMultiplierArg, double gridAdditionArg, int numberOfOrdersForRaisingGridArg, int nbrOrdersMaxBeforeSecurityArg, double TPSecurityAmountInAccountCurrencyArg, double TPAccountBalancePourcentageArg,
    double TPNbrPipsArg, double TPAmountInAccountCurrencyArg, double TrailingSLNumberOfPipsArg,  double lotMultiplierForNextPositionArg, double lotAdditionForNextPositionArg,
    GridBasketSignalStrategy *basketSignalStrategyArg, int nbrOrdersMaxArg, bool dontTakeAnyLeverageArg,
    double slInNbrPipsForCalculatingNbrLotsArg, double lossAllowedInAccountPourcentageArg, GridMoneyManagementStrategyType moneyManagementStrategyTypeArg,
    bool addTrailingOnCoverOrdersArg, bool closeCoverOrderOnSignalArg, bool trailCoverOrdersFromStartArg, double TrailingCoverOrdersSLNumberOfPipsArg, double coverOrdersSLSecurityRatioArg, double coverOrdersQuantityRatioArg, GridCoverType coverTypeArg,
    bool saveAndLoadDataArg, double gridCoverInPipsArg, double coverOrdersTPRatioArg, CoverLotCalulationType coverLotCalulationArg,
    int numberOfOrdersForDecreasingTPNbrPipsArg, double TPNbrPipsDecreasingValueArg, int numberOfOrdersForIncreasingLotMultiplierArg, double LotMultiplierIncresingArg, bool closeAfterReachMaxNbrOrderArg){
    this.buySell = new BuySell(false, true, true);
    this.orderUtils = new OrderUtils();
    this.displayUtils = new DisplayUtils();
    this.nbrPips = 0;

    this.symbolToTrade = symbolToTradeArg;
    this.magicNumberValue = magicNumberValueArg;
    this.basketNumber = basketNumberArg;
    this.strategyNumber = strategyNumberArg;
    this.takeProfitCalcultationType = takeProfitCalcultationTypeArg;
    this.newOrderLotCalculationType = newOrderLotCalculationTypeArg;
    this.trailingSLType = trailingSLTypeArg;
    this.newOrderOpeningType = newOrderOpeningTypeArg;
    this.gridInPips = gridInPipsArg;
    this.gridMultiplier = gridMultiplierArg;
    this.gridAddition = gridAdditionArg;
    this.numberOfOrdersForRaisingGrid = numberOfOrdersForRaisingGridArg;
    this.nbrLotsToTake = orderUtils.getCorrectLotSize(nbrLotsToTakeArg);
    this.initialNbrLotsToTake = this.nbrLotsToTake;
    this.initialBalanceForAutomaticCalculation = initialBalanceForAutomaticCalculationArg;
    this.isBroketECN = isBroketECNArg;

    this.nbrOrdersMaxBeforeSecurity = nbrOrdersMaxBeforeSecurityArg;
    this.TPSecurityAmountInAccountCurrency = TPSecurityAmountInAccountCurrencyArg;
    this.TPAccountBalancePourcentage = TPAccountBalancePourcentageArg;
    this.TPNbrPips = TPNbrPipsArg;
    this.TPAmountInAccountCurrency = TPAmountInAccountCurrencyArg;
    this.TrailingSLNumberOfPips = TrailingSLNumberOfPipsArg;
    this.lotMultiplierForNextPosition = lotMultiplierForNextPositionArg;
    this.lotAdditionForNextPosition = lotAdditionForNextPositionArg;

    this.basketSignalStrategy = basketSignalStrategyArg;

    this.isInitialised = false;
    if(Digits==3 || Digits==5) {
      pipValueInPoint = 10 * Point;
    }
    else {
      pipValueInPoint = Point;
    }

    this.nbrOrdersMax = nbrOrdersMaxArg;
    this.dontTakeAnyLeverage = dontTakeAnyLeverageArg;
    this.slInNbrPipsForCalculatingNbrLots = slInNbrPipsForCalculatingNbrLotsArg;
    this.lossAllowedInAccountPourcentage = lossAllowedInAccountPourcentageArg;
    this.moneyManagementStrategyType = moneyManagementStrategyTypeArg;

    this.addTrailingOnCoverOrders = addTrailingOnCoverOrdersArg;
    this.closeCoverOrderOnSignal = closeCoverOrderOnSignalArg;
    this.trailCoverOrdersFromStart = trailCoverOrdersFromStartArg;
    this.TrailingCoverOrdersSLNumberOfPips = TrailingCoverOrdersSLNumberOfPipsArg;
    this.coverOrdersSLSecurityRatio = coverOrdersSLSecurityRatioArg;
    this.coverOrdersQuantityRatio = coverOrdersQuantityRatioArg;
    this.trailingActivated = false;
    this.trailingCoverActivated = false;
    this.virtualTrailingSLLevel = 0;
    this.virtualTrailingSLLevelForCoverOrders = 0;
    this.takeProfitLevelForCover = 0;
    this.coverIsActivated = false;
    this.firstCoverLevelForClosingAllPositions = 0;
    this.lastCoverOrderNbrLots = 0;
    this.lastOrderNbrLots = 0;

    this.nextInversedOrderLevel = 0;
    this.coverOpenLevel = 0;
    this.initialPrice = 0;
    this.lastTicketNumber = 0;
    this.nextCoverOrderLevel = 0;
    this.currentCoverOrderLevel = 0;
    this.hasGridCoverStarted = false;

    inpDirectoryName="Data";

    tickSize = MarketInfo(symbolToTrade, MODE_TICKSIZE);
    tickCostInAccountCurrencyForOneLot = MarketInfo(symbolToTrade, MODE_TICKVALUE);

    this.gridCoverStrategy = GridCoverStrategyFactory::getCoverStrategy(coverTypeArg, GetPointer(this));

    this.saveAndLoadData = saveAndLoadDataArg;
    this.gridCoverInPips = gridCoverInPipsArg;
    this.coverOrdersTPRatio = coverOrdersTPRatioArg;
    this.coverLotCalulation = coverLotCalulationArg;

    this.TPNbrPipsInitialValue = this.TPNbrPips;
    this.lotMultiplierForNextPositionInitialValue = this.lotMultiplierForNextPosition;
    this.lotAdditionForNextPositionInitialValue = this.lotAdditionForNextPosition;

    this.numberOfOrdersForDecreasingTPNbrPips = numberOfOrdersForDecreasingTPNbrPipsArg;
    this.TPNbrPipsDecreasingValue = TPNbrPipsDecreasingValueArg;
    this.numberOfOrdersForIncreasingLotMultiplier = numberOfOrdersForIncreasingLotMultiplierArg;
    this.LotMultiplierIncresing = LotMultiplierIncresingArg;

    this.closeAfterReachMaxNbrOrderInitial = closeAfterReachMaxNbrOrderArg;
    this.closeAfterReachMaxNbrOrder = this.closeAfterReachMaxNbrOrderInitial;
    this.closedWhenReachMaxNbrOrder = false;

    if(this.gridCoverStrategy.getCoverType() == Type6){
      this.TPNbrPips = this.gridInPips;
      this.TPNbrPipsInitialValue = this.gridInPips;
      this.gridCoverInPips = this.gridInPips;
    }
  }

  string getId(){
    return (typeBuyOrSellOrder == OP_BUY ? "BUY" : "SELL") + " Basket "+string(basketNumber)+" - "+string(strategyNumber);
  }

  bool checkBasket(int basketNumberArg, int strategyNumberArg){
    bool checkNumbers = false;

    if(basketNumber == basketNumberArg && strategyNumber == strategyNumberArg){
      checkNumbers = true;
    }

    return checkNumbers;
  }

  void release(){
    orderUtils.release();
    buySell.release();
    gridCoverStrategy.release();
    delete orderUtils;
    delete buySell;
    delete displayUtils;
    delete gridCoverStrategy;
    FileClose(file_handle);
    ObjectDelete("TakeProfitLine");
  }

  int getBasketNumber(){
    return basketNumber;
  }

  int getStrategyNumber(){
    return strategyNumber;
  }

  int getNbrPositionsOpenForThisBasket(){
    int nbrPositions = 0;

    if(this.orderCommentForBasket != NULL && StringCompare(this.orderCommentForBasket, "") != 0) {
      nbrPositions = orderUtils.numberTicketsOpenedByMagicTicketAndComment(this.typeBuyOrSellOrder, this.magicNumberValue, this.orderCommentForBasket);
    }

    nbrPositionsOpen  = nbrPositions;

    return nbrPositions;
  }

  int getNbrPositionsOpenForCoveringThisBasket(){
    int nbrPositions = 0;

    if(this.orderCommentForBasket != NULL && StringCompare(this.orderCommentForBasket, "") != 0) {
      nbrPositions = orderUtils.numberTicketsOpenedByMagicTicketAndComment(this.getBasketCoverOrderType(), this.magicNumberValue, this.orderCommentForBasket);
    }

    return nbrPositions;
  }

  double getNbrLotsInThisBasket(){
    double nbrLots = 0;

    if(this.orderCommentForBasket != NULL && StringCompare(this.orderCommentForBasket, "") != 0) {
      nbrLots = orderUtils.numberOfLotsOpenedByMagicNumberAndComment(this.typeBuyOrSellOrder, this.magicNumberValue, this.orderCommentForBasket);
    }

    return nbrLots;
  }

  double getQuantityFromTakeProfitLevel(double takeProfitLevelArg){
    double amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(TPNbrPips) * tickCostInAccountCurrencyForOneLot) / tickSize;
    double quantity = 0;
    double priceToClose = orderUtils.getPriceForClosingOrder(this.symbolToTrade, this.typeBuyOrSellOrder);
    double distance = typeBuyOrSellOrder == OP_BUY ? takeProfitLevelArg - priceToClose : priceToClose - takeProfitLevelArg;

    quantity = orderUtils.roundDown(amountToReach / (distance * tickCostInAccountCurrencyForOneLot / tickSize), 2);

    return orderUtils.getCorrectLotSize(quantity);
  }

  double getCurrentProfitOnOpenedPositions(){
    double profit = 0;

    for(int i=0; i<OrdersTotal(); i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
        if(OrderType() == this.typeBuyOrSellOrder && OrderCloseTime() == 0
        && OrderMagicNumber() == magicNumberValue && StringCompare(OrderComment(),orderCommentForBasket) == 0
        && OrderTicket() != lastTicketNumber) {
          profit += OrderProfit() + OrderCommission() + OrderSwap();
        }
      }
    }

     return profit;
  }

  int getBasketOrderType(){
    return this.typeBuyOrSellOrder;
  }

  int getBasketCoverOrderType(){
    return this.typeBuyOrSellOrder == OP_BUY ? OP_SELL : OP_BUY;
  }

  double getLastOrderNbrLots(){
    return lastOrderNbrLots;
  }

  double getGridCoverInPips(){
    return gridCoverInPips;
  }

  double getTakeProfitLevel(){
    return this.takeProfitLevel;
  }

  double getCoverOrdersSLSecurityRatio(){
    return this.coverOrdersSLSecurityRatio;
  }

  double getCoverOrdersTPRatio(){
    return this.coverOrdersTPRatio;
  }

  double getCoverLotCalulation(){
    return coverLotCalulation;
  }

  double getCoverOrdersQuantityRatio(){
    return this.coverOrdersQuantityRatio;
  }

  string getSymbolToTrade(){
    return this.symbolToTrade;
  }

  double getTPNbrPips(){
    return this.TPNbrPips;
  }

  bool isTrailingActivated(){
    return this.trailingActivated;
  }

  bool isTrailingCoverActivated(){
    return this.trailingCoverActivated;
  }

  bool isCoverActivated(){
    return this.coverIsActivated;
  }

  bool hasCoverOrdersOpen(){
    return this.getNbrPositionsOpenForCoveringThisBasket() != 0;
  }

  void closeBasket(){
    if(buySell.closeAllOpenOrdersForSpecificCurrency(this.symbolToTrade, this.magicNumberValue, this.orderCommentForBasket)){
      this.reinitBasketForANewUse();
    }
  }

  void activateSpecialSecurity(){
    this.closeAfterReachMaxNbrOrder = true;
  }

  void reajustTP(double TPNbrPipsArg){
    TPNbrPips = TPNbrPipsArg;
    updateAllTakeProfit();
  }

  void setNbrLotsToTake(double nbrLotsToTakeArg){
    this.nbrLotsToTake = orderUtils.getCorrectLotSize(nbrLotsToTakeArg);
    this.initialNbrLotsToTake = this.nbrLotsToTake;
  }

  void launchBasket(int typeBuyOrSellOrderArg){
    if(getNbrPositionsOpenForThisBasket() == 0 && (typeBuyOrSellOrderArg == OP_BUY || typeBuyOrSellOrderArg == OP_SELL)){
      isInitialised = false;

      if(this.gridCoverStrategy.calculateTrendAfterFirstOrder()){
        this.typeBuyOrSellOrder = OP_BUY;
      } else {
        this.typeBuyOrSellOrder = typeBuyOrSellOrderArg;
      }

      this.orderCommentForBasket = getId();

      this.initialPrice = orderUtils.getPriceForClosingOrder(symbolToTrade, typeBuyOrSellOrder);

      openSavingFile();

      if(typeBuyOrSellOrder == OP_BUY){
        addBuyOrder();
      } else {
        addSellOrder();
      }
      isInitialised = true;
    }
  }

  bool onUpdateBasket(){

    bool newOrdersAdded = false;

    if(isInitialised && getNbrPositionsOpenForThisBasket() != 0){
      if(this.gridCoverStrategy.calculateTrendAfterFirstOrder() && nbrPositionsOpen == 1){
        //Trend not identified yet
        if(MarketInfo(symbolToTrade,MODE_ASK) < this.nextOrderLevel){
          this.typeBuyOrSellOrder = OP_BUY;
          newOrdersAdded = addBuyOrder() || newOrdersAdded;
        }else if(MarketInfo(symbolToTrade,MODE_BID) > this.nextInversedOrderLevel){
          this.typeBuyOrSellOrder = OP_SELL;
          newOrdersAdded = addSellOrder() || newOrdersAdded;
        }
      } else if(typeBuyOrSellOrder == OP_BUY && MarketInfo(symbolToTrade,MODE_ASK) < this.nextOrderLevel
        && !trailingActivated && ((this.newOrderOpeningType == ClassicGridSytem) || (this.newOrderOpeningType == OpenPositionIfNewSignal && this.basketSignalStrategy.isBuyingSignal(typeBuyOrSellOrder, basketNumber, strategyNumber)))){
          if(nbrOrdersMax == 0 || nbrPositionsOpen < nbrOrdersMax){
            newOrdersAdded = addBuyOrder() || newOrdersAdded;
          } else if(this.closeAfterReachMaxNbrOrder){
            this.closedWhenReachMaxNbrOrder = true;
            this.displayUtils.drawOrMoveVerticalLine("buyCloseAfterReachMaxNbrOrder", Green, false);
            closeBasket();
          }
      } else if(typeBuyOrSellOrder == OP_SELL && MarketInfo(symbolToTrade,MODE_BID) > this.nextOrderLevel
        && !trailingActivated && ((this.newOrderOpeningType == ClassicGridSytem) || (this.newOrderOpeningType == OpenPositionIfNewSignal && this.basketSignalStrategy.isSellingSignal(typeBuyOrSellOrder, basketNumber, strategyNumber)))){
          if(nbrOrdersMax == 0 || nbrPositionsOpen < nbrOrdersMax){
            newOrdersAdded = addSellOrder() || newOrdersAdded;
          } else if(this.closeAfterReachMaxNbrOrder){
            this.closedWhenReachMaxNbrOrder = true;
            this.displayUtils.drawOrMoveVerticalLine("sellCloseAfterReachMaxNbrOrder", Red, false);
            closeBasket();
          }
      }

      //if(takeProfitCalcultationType == OnStrategySignal){
        if(this.basketSignalStrategy.isClosingSignal(typeBuyOrSellOrder, basketNumber, strategyNumber)){
          closeBasket();
        }
      //}
    }

    return newOrdersAdded;
  }

  bool isTrailingMustBeManaged(){
    return trailingSLType == WhenTPReachedFollowContinuouslyByNumberOfPips;
  }

  void manageTrailingStop(){
    if(trailingSLType == WhenTPReachedFollowContinuouslyByNumberOfPips){

      double trailingNbrPips = orderUtils.convertNbrPipInQuotedPrice(getTrailingSLNumberOfPips());

      //Start trailing
      if(!trailingActivated){
        if(typeBuyOrSellOrder == OP_BUY && MarketInfo(symbolToTrade,MODE_BID) >= takeProfitLevel){
          trailingActivated = true;
          virtualTrailingSLLevel = MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips;
          updateTrailingStopLoss(virtualTrailingSLLevel);
          saveBasket();
        } else if(typeBuyOrSellOrder == OP_SELL && MarketInfo(symbolToTrade,MODE_ASK) <= takeProfitLevel){
          trailingActivated = true;
          virtualTrailingSLLevel = MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips;
          updateTrailingStopLoss(virtualTrailingSLLevel);
          saveBasket();
        }

      } else{
        if(getNbrPositionsOpenForThisBasket() == 0){
            //If no order anymore
            this.reinitBasketForANewUse();
        } else {
          //Update trailing
          if(typeBuyOrSellOrder == OP_BUY && (MarketInfo(symbolToTrade,MODE_BID) - virtualTrailingSLLevel) > trailingNbrPips
          && virtualTrailingSLLevel < MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips){
            virtualTrailingSLLevel  = MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips;
            updateTrailingStopLoss(virtualTrailingSLLevel);
          } else if(typeBuyOrSellOrder == OP_SELL && (virtualTrailingSLLevel - MarketInfo(symbolToTrade,MODE_ASK)) > trailingNbrPips
          && virtualTrailingSLLevel > MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips){
            virtualTrailingSLLevel  = MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips;
            updateTrailingStopLoss(virtualTrailingSLLevel);
          }
        }
      }
    }
  }

  GridCoverStrategy* getGridCoverStrategy(){
    return this.gridCoverStrategy;
  }

  void manageCoverOrders(){
    //Trailing Cover orders
    if(!this.gridCoverStrategy.calculateTrendAfterFirstOrder()){
      if(this.closeCoverOrderOnSignal == true && hasCoverOrdersOpen()){
        if(this.basketSignalStrategy.isClosingCoverOrderSignal(this.getBasketCoverOrderType(), basketNumber, strategyNumber)){
          buySell.closeAllOpenOrdersForSpecificCurrency(this.getBasketCoverOrderType(), this.symbolToTrade, this.magicNumberValue, this.orderCommentForBasket);
        }
      } else if(this.gridCoverStrategy.isNonStopEdging()){
        this.manageNonStopCoverEdging();
      } else if(this.gridCoverStrategy.isClassicTrailingCoverStop() && (this.gridCoverStrategy.isTrailingAction() || this.gridCoverStrategy.isBreakHeavenAction()) && addTrailingOnCoverOrders && hasCoverOrdersOpen()){
        this.manageTrailingStopForCoverOrders();
      } else if(this.gridCoverStrategy.isGridSystemTrailingCoverStop() && hasGridCoverStarted){
        this.manageCoverGridSystem();
      } else if(this.gridCoverStrategy.isClassicTrailingCoverStop()) {
        trailingCoverActivated = false;
        ObjectDelete("TakeProfitCoverLine");
      }
    }

    if(getNbrPositionsOpenForThisBasket() == 0 && hasCoverOrdersOpen()){
      buySell.closeAllOpenOrdersForSpecificCurrency(this.getBasketCoverOrderType(), this.symbolToTrade, this.magicNumberValue, this.orderCommentForBasket);
    }
  }

  void manageNonStopCoverEdging(){
    double firstOrderLimitPrice =  this.initialPrice + (this.getBasketCoverOrderType() == OP_BUY ? orderUtils.convertNbrPipInQuotedPrice(TPInNbrPips) : -orderUtils.convertNbrPipInQuotedPrice(TPInNbrPips));
    double openingPrice = this.orderUtils.getPriceForOpeningOrder(this.getSymbolToTrade(), this.getBasketCoverOrderType());
    bool hasReachOpeningLimit = this.getBasketCoverOrderType() == OP_BUY ? openingPrice >= firstOrderLimitPrice : openingPrice <= firstOrderLimitPrice;

    // Print("firstOrderLimitPrice : "+this.initialPrice+ " / "+orderUtils.convertNbrPipInQuotedPrice(TPInNbrPips)+" / "+firstOrderLimitPrice);
    // Print("openingPrice : "+openingPrice);
    // Print("hasReachOpeningLimit : "+hasReachOpeningLimit);

    if(!hasCoverOrdersOpen() && hasReachOpeningLimit){
      //this.startCoverOrderProcess(true);
      this.addNewCoverOrder(this.gridCoverStrategy.getNbrLots(), this.gridCoverStrategy.getStopLoss(), this.gridCoverStrategy.getTakeProfit());
    }
  }

  void manageCoverGridSystem(){
    double currentPrice = orderUtils.getPriceForOpeningOrder(this.getSymbolToTrade(), this.getBasketCoverOrderType());

    if((this.getBasketCoverOrderType() == OP_BUY && currentPrice >= nextCoverOrderLevel)
      || (this.getBasketCoverOrderType() == OP_SELL && currentPrice <= nextCoverOrderLevel)) {
      double stopLossForCover = this.gridCoverStrategy.getStopLoss();
      double takeProfitForCover = this.gridCoverStrategy.getTakeProfit();
      double nbrLots = this.gridCoverStrategy.getNbrLots();

      this.updateTrailingStopLossForCoverOrders(stopLossForCover);

      if(this.addNewCoverOrder(nbrLots, stopLossForCover, takeProfitForCover)){
        currentCoverOrderLevel = this.gridCoverStrategy.getCurrentCoverOrderLevel();
        nextCoverOrderLevel = this.gridCoverStrategy.getNextCoverOrderLevel();
      }
    }
  }

  void manageTrailingStopForCoverOrders(){

    double trailingNbrPips = orderUtils.convertNbrPipInQuotedPrice(getTrailingCoverOrdersSLNumberOfPips());

    if(!trailingCoverActivated){
      if(this.getBasketCoverOrderType() == OP_BUY && ((this.trailCoverOrdersFromStart == false && MarketInfo(symbolToTrade,MODE_BID) >= takeProfitLevelForCover) || this.trailCoverOrdersFromStart == true)){
        trailingCoverActivated = true;
        if(this.gridCoverStrategy.isTrailingAction()){
          virtualTrailingSLLevelForCoverOrders = MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips;
        } else if(this.gridCoverStrategy.isBreakHeavenAction()){
          virtualTrailingSLLevelForCoverOrders = coverOpenLevel + orderUtils.convertNbrPipInQuotedPrice(1);
        }
        updateTrailingStopLossForCoverOrders(virtualTrailingSLLevelForCoverOrders);
        saveBasket();
      } else if(this.getBasketCoverOrderType() == OP_SELL && ((this.trailCoverOrdersFromStart == false && MarketInfo(symbolToTrade,MODE_ASK) <= takeProfitLevelForCover) || this.trailCoverOrdersFromStart == true)){
        trailingCoverActivated = true;
        if(this.gridCoverStrategy.isTrailingAction()){
          virtualTrailingSLLevelForCoverOrders = MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips;
        } else if(this.gridCoverStrategy.isBreakHeavenAction()){
          virtualTrailingSLLevelForCoverOrders = coverOpenLevel - orderUtils.convertNbrPipInQuotedPrice(1);
        }

        updateTrailingStopLossForCoverOrders(virtualTrailingSLLevelForCoverOrders);
        saveBasket();
      }
    } else {
      //Update trailing
      if(this.gridCoverStrategy.isTrailingAction()){
        if(this.getBasketCoverOrderType() == OP_BUY && (MarketInfo(symbolToTrade,MODE_BID) - virtualTrailingSLLevelForCoverOrders) > trailingNbrPips
        && virtualTrailingSLLevelForCoverOrders < MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips){
          virtualTrailingSLLevelForCoverOrders  = MarketInfo(symbolToTrade,MODE_BID) - trailingNbrPips;
          updateTrailingStopLossForCoverOrders(virtualTrailingSLLevelForCoverOrders);
          this.displayUtils.drawOrMoveHorizontalLine("TakeProfitCoverLine", virtualTrailingSLLevelForCoverOrders, Orange);
        } else if(this.getBasketCoverOrderType() == OP_SELL && (virtualTrailingSLLevelForCoverOrders - MarketInfo(symbolToTrade,MODE_ASK)) > trailingNbrPips
        && virtualTrailingSLLevelForCoverOrders > MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips){
          virtualTrailingSLLevelForCoverOrders  = MarketInfo(symbolToTrade,MODE_ASK) + trailingNbrPips;
          updateTrailingStopLossForCoverOrders(virtualTrailingSLLevelForCoverOrders);
          this.displayUtils.drawOrMoveHorizontalLine("TakeProfitCoverLine", virtualTrailingSLLevelForCoverOrders, Orange);
        }
      }
    }
  }

  double getTrailingSLNumberOfPips(){
    double numberOfPipsForTrailing = 0;
    double stopLevel = orderUtils.convertQuotedPriceInNbrPip((MarketInfo(symbolToTrade, MODE_STOPLEVEL) + MarketInfo(symbolToTrade, MODE_SPREAD))*Point);

    if (TrailingSLNumberOfPips < stopLevel){
      numberOfPipsForTrailing = stopLevel;
    } else {
      numberOfPipsForTrailing  = TrailingSLNumberOfPips;
    }

    return numberOfPipsForTrailing;
  }

  double getTrailingCoverOrdersSLNumberOfPips(){
    double numberOfPipsForTrailing = 0;
    double stopLevel = orderUtils.convertQuotedPriceInNbrPip((MarketInfo(symbolToTrade, MODE_STOPLEVEL) + MarketInfo(symbolToTrade, MODE_SPREAD))*Point);

    if (TrailingCoverOrdersSLNumberOfPips < stopLevel){
      numberOfPipsForTrailing = stopLevel;
    } else {
      numberOfPipsForTrailing  = TrailingCoverOrdersSLNumberOfPips;
    }

    return numberOfPipsForTrailing;
  }

  void updateTrailingStopLoss(double newSLValueArg){
    orderUtils.updateSLForTicketsOpenWithMagicNumberAndComment(this.typeBuyOrSellOrder, newSLValueArg, this.magicNumberValue, this.orderCommentForBasket);
  }

  void updateTrailingStopLossForCoverOrders(double newSLValueArg){
    orderUtils.updateSLForTicketsOpenWithMagicNumberAndComment(this.getBasketCoverOrderType(), newSLValueArg, this.magicNumberValue, this.orderCommentForBasket);
  }

  void updateSecurityStopLoss(double newSLValueArg){
    orderUtils.updateSLForTicketsOpenWithMagicNumberAndComment(this.typeBuyOrSellOrder, newSLValueArg, this.magicNumberValue, this.orderCommentForBasket);
  }

  bool isInUsed(){
    return getNbrPositionsOpenForThisBasket() > 0;
  }

  void reinitBasketForANewUse(){
    reinitBasketForANewUse(0);
  }

  void reinitBasketForANewUse(double newTPNbrpips){
    if(hasCoverOrdersOpen()){
      buySell.closeAllOpenOrdersForSpecificCurrency(this.getBasketCoverOrderType(), this.symbolToTrade, this.magicNumberValue, this.orderCommentForBasket);
    }
    if(this.isInitialised){
      this.basketSignalStrategy.onClosing(this.typeBuyOrSellOrder, this.basketNumber, this.strategyNumber, this.closedWhenReachMaxNbrOrder);
    }
    if(this.gridCoverStrategy.calculateTrendAfterFirstOrder()){
      this.typeBuyOrSellOrder = OP_BUY;
    }
    this.takeProfitLevel = 0;
    this.takeProfitRecoverLevel = 0;
    this.nextOrderLevel = 0;
    this.nextInversedOrderLevel = 0;
    this.previousOrderLevel = 0;
    this.firstCoverLevelForClosingAllPositions = 0;
    this.typeBuyOrSellOrder = -1;
    this.orderCommentForBasket = NULL;
    this.isInitialised = false;
    this.nbrLotsToTake = this.initialNbrLotsToTake;
    this.trailingActivated = false;
    this.trailingCoverActivated = false;
    this.virtualTrailingSLLevel = 0;
    this.virtualTrailingSLLevelForCoverOrders = 0;
    this.takeProfitLevelForCover = 0;
    this.coverIsActivated = false;
    this.lastCoverOrderNbrLots = 0;
    this.lastOrderNbrLots = 0;
    this.closeAfterReachMaxNbrOrder = this.closeAfterReachMaxNbrOrderInitial;
    this.coverOpenLevel = 0;
    this.initialPrice = 0;
    this.lastTicketNumber = 0;
    this.nextCoverOrderLevel = 0;
    this.currentCoverOrderLevel = 0;
    this.hasGridCoverStarted = false;
    this.closedWhenReachMaxNbrOrder = false;
    if(newTPNbrpips == 0){
      this.TPNbrPips = this.TPNbrPipsInitialValue;
    } else {
      this.TPNbrPips = newTPNbrpips;
      this.TPNbrPipsInitialValue = this.TPNbrPips;
    }
    this.lotMultiplierForNextPosition = this.lotMultiplierForNextPositionInitialValue;
    this.lotAdditionForNextPosition = this.lotAdditionForNextPositionInitialValue;

    saveBasket();
    FileClose(file_handle);
    ObjectDelete("TakeProfitLine");
    ObjectDelete("TakeProfitCoverLine");
  }

  void printData(){
    Print("* basketNumber : "+ string(this.basketNumber));
    Print("* strategyNumber : "+ string(this.strategyNumber));
    Print("* takeProfitLevel : "+ string(this.takeProfitLevel));
    Print("* takeProfitRecoverLevel : "+ string(this.takeProfitRecoverLevel));
    Print("* nextOrderLevel : "+ string(this.nextOrderLevel));
    Print("* previousOrderLevel : "+ string(this.previousOrderLevel));
    Print("* firstCoverLevelForClosingAllPositions : "+ string(this.firstCoverLevelForClosingAllPositions));
    Print("* typeBuyOrSellOrder : "+ string(this.typeBuyOrSellOrder));
    Print("* orderCommentForBasket : "+ string(this.orderCommentForBasket));
    Print("* isInitialised : "+ string(this.isInitialised));
    Print("* nbrLotsToTake : "+string(this.nbrLotsToTake));
    Print("* trailingActivated : "+ string(this.trailingActivated));
    Print("* trailingCoverActivated : "+ string(this.trailingCoverActivated));
    Print("* virtualTrailingSLLevel : "+ string(this.virtualTrailingSLLevel));
    Print("* virtualTrailingSLLevelForCoverOrders : "+ string(this.virtualTrailingSLLevelForCoverOrders));
    Print("* takeProfitLevelForCover : "+ string(this.takeProfitLevelForCover));
    Print("* coverIsActivated : "+ string(this.coverIsActivated));
    Print("* lastCoverOrderNbrLots : "+ string(this.lastCoverOrderNbrLots));
    Print("* lastOrderNbrLots : "+ string(this.lastOrderNbrLots));
    Print("* coverOpenLevel : "+ string(this.coverOpenLevel));
    Print("* initialPrice : "+ string(this.initialPrice));
    Print("* lastTicketNumber : "+ string(this.lastTicketNumber));
    Print("* nextCoverOrderLevel : "+ string(this.nextCoverOrderLevel));
    Print("* currentCoverOrderLevel : "+ string(this.currentCoverOrderLevel));
    Print("* hasGridCoverStarted : "+ string(this.hasGridCoverStarted));
    Print("* TPNbrPipsInitialValue : "+ string(this.TPNbrPipsInitialValue));
    Print("* lotMultiplierForNextPositionInitialValue : "+ string(this.lotMultiplierForNextPositionInitialValue));
    Print("* lotAdditionForNextPositionInitialValue : "+ string(this.lotAdditionForNextPositionInitialValue));
  }

  void openSavingFile(){
    openSavingFile(orderCommentForBasket);
  }

  void openSavingFile(string orderCommentForBasketArg){
    if(!IsTesting()){
      inpFileName = inpDirectoryName + "//" + orderCommentForBasketArg;
      file_handle = FileOpen(inpFileName, FILE_READ|FILE_WRITE|FILE_CSV);
    }
  }

  void deleteSavingFile(){
    if(FileIsExist(inpFileName)){
      FileDelete(inpFileName);
    }
  }

  void saveBasket(){
    if(!IsTesting()){
      if(file_handle!=INVALID_HANDLE){
        FileSeek(file_handle, 0, SEEK_SET);
        FileWrite(file_handle, "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ");
        FileSeek(file_handle, 0, SEEK_SET);
        FileWrite(file_handle,basketNumber, strategyNumber, takeProfitLevel,takeProfitRecoverLevel,nextOrderLevel,
                  previousOrderLevel,firstCoverLevelForClosingAllPositions,typeBuyOrSellOrder,
                  orderCommentForBasket,isInitialised,nbrLotsToTake,trailingActivated,trailingCoverActivated,
                  virtualTrailingSLLevel,virtualTrailingSLLevelForCoverOrders,takeProfitLevelForCover,
                  coverIsActivated,lastCoverOrderNbrLots,lastOrderNbrLots,closeAfterReachMaxNbrOrder,coverOpenLevel,
                  initialPrice, lastTicketNumber, nextCoverOrderLevel, currentCoverOrderLevel, hasGridCoverStarted,
                  TPNbrPipsInitialValue, lotMultiplierForNextPositionInitialValue, lotAdditionForNextPositionInitialValue, nextInversedOrderLevel,
                  typeBuyOrSellOrder, basketNumber, strategyNumber, initialBalanceForAutomaticCalculation, lotMultiplierForNextPosition, gridInPips,
                  TPNbrPips, TrailingCoverOrdersSLNumberOfPips, coverOrdersQuantityRatio, gridCoverInPips, trailingSLType);
        FileFlush(file_handle);
      }
    }
  }

  void loadBasket(string orderCommentForBasketArg){
    if(!IsTesting() && saveAndLoadData){
      openSavingFile(orderCommentForBasketArg);
      if(file_handle!=INVALID_HANDLE){
        FileSeek(file_handle, 0, SEEK_SET);
        this.basketNumber = StrToInteger(FileReadString(file_handle));
        this.strategyNumber = StrToInteger(FileReadString(file_handle));
        this.takeProfitLevel = StrToDouble(FileReadString(file_handle));
        this.takeProfitRecoverLevel = StrToDouble(FileReadString(file_handle));
        this.nextOrderLevel = StrToDouble(FileReadString(file_handle));
        this.previousOrderLevel = StrToDouble(FileReadString(file_handle));
        this.firstCoverLevelForClosingAllPositions = StrToDouble(FileReadString(file_handle));
        this.typeBuyOrSellOrder = StrToInteger(FileReadString(file_handle));
        this.orderCommentForBasket = FileReadString(file_handle);
        this.isInitialised = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;//FileReadBool(file_handle);
        this.nbrLotsToTake = StrToDouble(FileReadString(file_handle));
        this.trailingActivated = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;//FileReadBool(file_handle);
        this.trailingCoverActivated = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;//FileReadBool(file_handle);
        this.virtualTrailingSLLevel = StrToDouble(FileReadString(file_handle));
        this.virtualTrailingSLLevelForCoverOrders = StrToDouble(FileReadString(file_handle));
        this.takeProfitLevelForCover = StrToDouble(FileReadString(file_handle));
        this.coverIsActivated = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;//FileReadBool(file_handle);
        this.lastCoverOrderNbrLots = StrToDouble(FileReadString(file_handle));
        this.lastOrderNbrLots = StrToDouble(FileReadString(file_handle));
        this.closeAfterReachMaxNbrOrder = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;//FileReadBool(file_handle);
        this.coverOpenLevel =  StrToDouble(FileReadString(file_handle));
        this.initialPrice = StrToDouble(FileReadString(file_handle));
        this.lastTicketNumber = StrToInteger(FileReadString(file_handle));
        this.nextCoverOrderLevel = StrToDouble(FileReadString(file_handle));
        this.currentCoverOrderLevel = StrToDouble(FileReadString(file_handle));
        this.hasGridCoverStarted = StringCompare(FileReadString(file_handle), "1") == 0 ? true : false;
        this.TPNbrPipsInitialValue = StrToDouble(FileReadString(file_handle));
        this.lotMultiplierForNextPositionInitialValue = StrToDouble(FileReadString(file_handle));
        this.lotAdditionForNextPositionInitialValue = StrToDouble(FileReadString(file_handle));
        this.nextInversedOrderLevel = StrToDouble(FileReadString(file_handle));

        this.typeBuyOrSellOrder = StrToInteger(FileReadString(file_handle));
        this.basketNumber = StrToInteger(FileReadString(file_handle));
        this.strategyNumber = StrToInteger(FileReadString(file_handle));
        this.initialBalanceForAutomaticCalculation = StrToDouble(FileReadString(file_handle));
        this.lotMultiplierForNextPosition = StrToDouble(FileReadString(file_handle));
        this.gridInPips = StrToDouble(FileReadString(file_handle));
        this.TPNbrPips = StrToDouble(FileReadString(file_handle));
        this.TrailingCoverOrdersSLNumberOfPips = StrToDouble(FileReadString(file_handle));
        this.coverOrdersQuantityRatio = StrToDouble(FileReadString(file_handle));
        this.gridCoverInPips = StrToDouble(FileReadString(file_handle));
        this.trailingSLType = (GridTrailingSLType)StrToInteger(FileReadString(file_handle));
        getNbrPositionsOpenForThisBasket();

        printData();
      }
      if(!isInitialised){
        FileClose(file_handle);
        Print("* BASKET ALREADY CLOSE");
      } else if(nbrPositionsOpen == 0){
        reinitBasketForANewUse();
        Print("* BASKET FOUND BUT NO POSISION CURRENTLY OPEN");
      }
    }
  }

  double getBasketCurrentProfit(){
    double profit = 0;

    for(int i=0; i<OrdersTotal(); i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
        if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0
        && OrderMagicNumber() == magicNumberValue && StringCompare(OrderComment(),orderCommentForBasket) == 0) {
          profit += OrderProfit() + OrderCommission() + OrderSwap();
        }
      }
    }
    return profit;
  }

  private :

  double calculateNbrLots(double nbrLotsToTakeArg){
    double nbrLots = 0;

    if(this.moneyManagementStrategyType == AutomaticAmountLotsDefinedForInitialBalanceInAccountCurrency){
       nbrLots = (AccountBalance() * nbrLotsToTakeArg) / initialBalanceForAutomaticCalculation;
    } else if(this.moneyManagementStrategyType == AutomaticAmountLotsDefinedForInitialBalance_riskDecreasing){
      nbrLots = (AccountBalance() * nbrLotsToTakeArg) / (initialBalanceForAutomaticCalculation + ((((AccountBalance() / initialBalanceForAutomaticCalculation) / 10) / 100) * initialBalanceForAutomaticCalculation));

    } else if(this.moneyManagementStrategyType == CalculateAmountLotsOnPourcentReadyToLose && slInNbrPipsForCalculatingNbrLots > 0 && lossAllowedInAccountPourcentage > 0) {
      //nbrLots = ;
    } else if(this.moneyManagementStrategyType == FixedAmountLots) {
      nbrLots = nbrLotsToTakeArg;
    }

    return NormalizeDouble(nbrLots,2);
  }

  double getNbrLotForAnOrder(){
    return this.calculateNbrLots(this.nbrLotsToTake);
  }

  double getInitialNbrLotForAnOrder(){
    return this.calculateNbrLots(this.initialNbrLotsToTake);
  }

  bool addBuyOrder(){
    bool newOrderAdded = false;
    double nbrLots = orderUtils.getCorrectLotSize(getNbrLotForAnOrder());

    if(buySell.buyAtMarker(symbolToTrade, nbrLots, 0, 0, magicNumberValue, isBroketECN, orderCommentForBasket)){
      lastOrderNbrLots = nbrLots;
      lastTicketNumber = buySell.getLastTicket();
      updateAllTakeProfit();
      startCoverOrderProcess(false);
      updateNextLevelInfosForOpeningPosition();
      newOrderAdded = true;
      this.basketSignalStrategy.onAddNewOrder(this.typeBuyOrSellOrder, this.basketNumber, this.strategyNumber, nbrLots);
      saveBasket();
    }

    return newOrderAdded;
  }

  bool addSellOrder(){
    bool newOrderAdded = false;
    double nbrLots = orderUtils.getCorrectLotSize(getNbrLotForAnOrder());

    if(buySell.sellAtMarker(symbolToTrade, nbrLots, 0, 0, magicNumberValue, isBroketECN, orderCommentForBasket)){
      lastOrderNbrLots = nbrLots;
      lastTicketNumber = buySell.getLastTicket();
      updateAllTakeProfit();
      startCoverOrderProcess(false);
      updateNextLevelInfosForOpeningPosition();
      newOrderAdded = true;
      this.basketSignalStrategy.onAddNewOrder(this.typeBuyOrSellOrder, this.basketNumber, this.strategyNumber, nbrLots);
      saveBasket();
    }

    return newOrderAdded;
  }

  void startCoverOrderProcess(bool forceStarting){

    if(this.gridCoverStrategy.calculateTrendAfterFirstOrder() && !(getNbrPositionsOpenForThisBasket() > this.gridCoverStrategy.getNbrOrdersForStartingCover() + 1 && getNbrPositionsOpenForCoveringThisBasket() == 0)){
      if(nbrPositionsOpen > this.gridCoverStrategy.getNbrOrdersForStartingCover()){
        if(getNbrPositionsOpenForCoveringThisBasket() == 0){
          this.addNewCoverOrder(lastOrderNbrLots, 0, 0);
        } else {
          this.addNewCoverOrder(lastOrderNbrLots, 0, 0);
          double newSlCover = getNewSlCoverOrder();
          if(newSlCover != 0){
            orderUtils.updateSLForTicketsOpenWithMagicNumberAndComment(this.getBasketCoverOrderType(), getNewSlCoverOrder(), this.magicNumberValue, this.orderCommentForBasket);
          }
        }
      }
    } else if(!this.gridCoverStrategy.calculateTrendAfterFirstOrder() || (this.gridCoverStrategy.calculateTrendAfterFirstOrder() && nbrPositionsOpen > this.gridCoverStrategy.getNbrOrdersForStartingCover() + 1 && getNbrPositionsOpenForCoveringThisBasket() == 0)) {
      if(this.gridCoverStrategy.closeOnNewOrder() && hasCoverOrdersOpen()){
        buySell.closeAllOpenOrdersForSpecificCurrency(this.getBasketCoverOrderType(), this.symbolToTrade, this.magicNumberValue, this.orderCommentForBasket);
      }

      if(getNbrPositionsOpenForThisBasket() > nbrOrdersMaxBeforeSecurity || forceStarting) {
          if((this.gridCoverStrategy.isClassicTrailingCoverStop() && !hasCoverOrdersOpen())
          || (this.gridCoverStrategy.isGridSystemTrailingCoverStop() && hasGridCoverStarted == false)
          || (this.gridCoverStrategy.isNonStopEdging())){

            trailingCoverActivated = false;
            double nbrLots = this.gridCoverStrategy.getNbrLots();
            double stopLossForCover = this.gridCoverStrategy.getStopLoss();
            double takeProfitForCover = this.gridCoverStrategy.getTakeProfit();
            takeProfitLevelForCover = takeProfitForCover;
            hasGridCoverStarted = this.gridCoverStrategy.isGridSystemTrailingCoverStop();
            coverOpenLevel = typeBuyOrSellOrder == OP_BUY ? MarketInfo(symbolToTrade,MODE_ASK) : MarketInfo(symbolToTrade,MODE_BID);

            if(!this.gridCoverStrategy.isNonStopEdging()){
              if(this.gridCoverStrategy.closeOnNewOrder() || this.closeCoverOrderOnSignal == true || (addTrailingOnCoverOrders && this.gridCoverStrategy.isClassicTrailingCoverStop())){
                this.displayUtils.drawOrMoveHorizontalLine("TakeProfitCoverLine", takeProfitLevelForCover, Orange);
                takeProfitForCover = 0;
              }
            }

            if(this.addNewCoverOrder(nbrLots, stopLossForCover, takeProfitForCover)){
              currentCoverOrderLevel = this.gridCoverStrategy.getCurrentCoverOrderLevel();
              nextCoverOrderLevel = this.gridCoverStrategy.getNextCoverOrderLevel();
            }
        }
      }
    }
  }

  bool addNewCoverOrder(double nbrLotsArg, double stopLossForCoverArg, double takeProfitForCoverArg){
    bool orderAdded = false;

    if(nbrLotsArg != 0){
      if(typeBuyOrSellOrder == OP_BUY){
        orderAdded = buySell.sellAtMarker(symbolToTrade, orderUtils.getCorrectLotSize(nbrLotsArg), stopLossForCoverArg, takeProfitForCoverArg, magicNumberValue, isBroketECN, orderCommentForBasket);
      } else if(typeBuyOrSellOrder == OP_SELL) {
        orderAdded = buySell.buyAtMarker(symbolToTrade, orderUtils.getCorrectLotSize(nbrLotsArg), stopLossForCoverArg, takeProfitForCoverArg, magicNumberValue, isBroketECN, orderCommentForBasket);
      }
    }

    return orderAdded;
  }

  void updateNextLevelInfosForOpeningPosition(){

    if(this.numberOfOrdersForIncreasingLotMultiplier <= nbrPositionsOpen){
      lotMultiplierForNextPosition += this.LotMultiplierIncresing;
      if(lotMultiplierForNextPosition > 5){
        lotMultiplierForNextPosition = 5;
      }
      lotAdditionForNextPosition += this.LotMultiplierIncresing;
    }

    if(newOrderLotCalculationType == MultiplyPreviousLotQuantity) {
      nbrLotsToTake = nbrLotsToTake * lotMultiplierForNextPosition;
    } else if(newOrderLotCalculationType == AddAmountToPreviousLot) {
      nbrLotsToTake += lotAdditionForNextPosition;
    } else if(newOrderLotCalculationType == MultiplyPreviousLotQuantityANDAddAmountToPreviousLot){
      nbrLotsToTake = nbrLotsToTake * lotMultiplierForNextPosition + lotAdditionForNextPosition;
    }

    double lastOpenPrice = typeBuyOrSellOrder == OP_BUY ? MarketInfo(symbolToTrade,MODE_ASK) : MarketInfo(symbolToTrade,MODE_BID);

    if(isInitialised == false) {
      nbrPips = gridInPips;
    } else {
      if(nbrPositionsOpen >=  numberOfOrdersForRaisingGrid){
        nbrPips = nbrPips * gridMultiplier + gridAddition;
      }
    }

    previousOrderLevel = nextOrderLevel;
    if(typeBuyOrSellOrder == OP_BUY){
      this.nextOrderLevel = NormalizeDouble(lastOpenPrice - orderUtils.convertNbrPipInQuotedPrice(nbrPips),Digits);
      this.nextInversedOrderLevel = NormalizeDouble(lastOpenPrice + orderUtils.convertNbrPipInQuotedPrice(nbrPips),Digits);
    } else {
      this.nextOrderLevel = NormalizeDouble(lastOpenPrice + orderUtils.convertNbrPipInQuotedPrice(nbrPips),Digits);
      this.nextInversedOrderLevel = NormalizeDouble(lastOpenPrice - orderUtils.convertNbrPipInQuotedPrice(nbrPips),Digits);
    }
  }

  void updateAllTakeProfit(){

    if(!(this.gridCoverStrategy.calculateTrendAfterFirstOrder() && nbrPositionsOpen <= this.gridCoverStrategy.getNbrOrdersForStartingCover() + 1)){
      calculateNewTakeProfit();
      Print(orderCommentForBasket+" : New take profit -> "+string(takeProfitLevel));

      if(takeProfitCalcultationType != OnStrategySignal && trailingSLType == noTrailingSL){
        orderUtils.updateTPForTicketsOpenWithMagicNumberAndComment(this.typeBuyOrSellOrder, takeProfitLevel, this.magicNumberValue, this.orderCommentForBasket);
      } else {
        this.displayUtils.drawOrMoveHorizontalLine("TakeProfitLine", takeProfitLevel,Green);
      }
    }
  }

  double getSpreadInPoint(){
    return  MarketInfo(symbolToTrade,MODE_SPREAD) * Point;
  }

  double getNewSlCoverOrder(){
    double amountToReach = 0;

    if(takeProfitCalcultationType == OnAccountBalancePourcentage){
      amountToReach = TPAccountBalancePourcentage * AccountBalance() / 100;
    } else if(takeProfitCalcultationType == OnNbrPips){
      amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(TPNbrPips) * tickCostInAccountCurrencyForOneLot) / tickSize;
    } else if(takeProfitCalcultationType == OnAccountCurrencyAmount){
      amountToReach = TPAmountInAccountCurrency;
    }

    return getSLLevelFromAmountToReachForCoverOrder(amountToReach,false);
  }

  void calculateNewTakeProfit(){
    getNbrPositionsOpenForThisBasket();

    double amountToReach = 0;
    double amountForRecoverting = 0;

    this.takeProfitLevel = 0;
    this.takeProfitRecoverLevel = 0;

    amountForRecoverting = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(1) * tickCostInAccountCurrencyForOneLot) / tickSize;

    if(this.gridCoverStrategy.getCoverType() == Type4){
      if(nbrPositionsOpen == 1){
        amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(TPNbrPips + 2) * tickCostInAccountCurrencyForOneLot) / tickSize;
      } else {
        amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(nbrPositionsOpen + 1) * tickCostInAccountCurrencyForOneLot) / tickSize;
      }
      //amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(TPNbrPips + nbrPositionsOpen + 1) * tickCostInAccountCurrencyForOneLot) / tickSize;
    } else if(takeProfitCalcultationType == OnAccountBalancePourcentage){
      amountToReach = TPAccountBalancePourcentage * AccountBalance() / 100;
    } else if(takeProfitCalcultationType == OnNbrPips){
      if(this.numberOfOrdersForDecreasingTPNbrPips > 0 && this.numberOfOrdersForDecreasingTPNbrPips <= nbrPositionsOpen){
        TPNbrPips = TPNbrPips - this.TPNbrPipsDecreasingValue;
        // if(TPNbrPips < 2){
        //   TPNbrPips = 2;
        // }
        //amountToReach =-AccountBalance() / 100;
      }
      amountToReach = (getInitialNbrLotForAnOrder() * orderUtils.convertNbrPipInQuotedPrice(TPNbrPips) * tickCostInAccountCurrencyForOneLot) / tickSize;
    } else if(takeProfitCalcultationType == OnAccountCurrencyAmount){
      amountToReach = TPAmountInAccountCurrency;
    }

    this.takeProfitLevel = getTakeProfitLevelFromAmountToReach(amountToReach, false);
    this.takeProfitRecoverLevel = getTakeProfitLevelFromAmountToReach(amountForRecoverting, false);
  }

  double getTakeProfitLevelFromAmountToReach(double amountToReachArg, bool takeCommissionIntoAccountArg){
    double takeProfitLevelValue = 0;

    double amountCalculated = amountToReachArg - 1;
    double priceToTest = typeBuyOrSellOrder == OP_BUY ? MarketInfo(symbolToTrade,MODE_BID) : MarketInfo(symbolToTrade,MODE_ASK);
    double currentLostAmount = 0;
    double distance = 0;
    double multiplication = 1;

    if(this.gridCoverStrategy.getCoverType() == Type4 && nbrPositionsOpen > 1){
       currentLostAmount = MathAbs(this.getCurrentProfitOnOpenedPositions());
    }

    while(amountCalculated < amountToReachArg) {

      amountCalculated = 0;

      if(typeBuyOrSellOrder == OP_BUY){
        priceToTest += orderUtils.convertNbrPipInQuotedPrice(0.1);
      } else {
        priceToTest -= orderUtils.convertNbrPipInQuotedPrice(0.1);
      }

      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)) {
            if(OrderType() == this.typeBuyOrSellOrder && OrderCloseTime() == 0
            && OrderMagicNumber() == magicNumberValue && StringCompare(OrderComment(),orderCommentForBasket) == 0
            && (this.gridCoverStrategy.getCoverType() != Type4 || (this.gridCoverStrategy.getCoverType() == Type4 && OrderTicket() == lastTicketNumber))) {
              distance = OrderType() == OP_BUY ? (priceToTest - OrderOpenPrice()) : (OrderOpenPrice() - priceToTest);
              amountCalculated += (OrderLots() * ((distance * tickCostInAccountCurrencyForOneLot) / tickSize) - (takeCommissionIntoAccountArg ? MathAbs(OrderCommission()) : 0)) * multiplication - currentLostAmount;
            }
         }
      }
    }

    if(priceToTest > 0){
      if((amountToReachArg > 0 && amountCalculated > 0) || amountToReachArg < 0)
      takeProfitLevelValue = priceToTest;
    }
    // Print("this.typeBuyOrSellOrder : "+this.typeBuyOrSellOrder);
    // Print("****** priceToTest : "+priceToTest);
    // Print("****** amountToReachArg : "+amountToReachArg);
    // Print("****** amountCalculated : "+amountCalculated);
    // Print("****** takeProfitLevelValue : "+takeProfitLevelValue);
    //amountCalculated > 0 && priceToTest > 0 ? priceToTest : 0;

    return takeProfitLevelValue;
  }

  double getSLLevelFromAmountToReachForCoverOrder(double amountToReachArg, bool takeCommissionIntoAccountArg){
    double takeProfitLevelValue = 0;

    double amountCalculated = amountToReachArg + 1;
    double priceToTest = this.getBasketCoverOrderType() == OP_BUY ? MarketInfo(symbolToTrade,MODE_BID) : MarketInfo(symbolToTrade,MODE_ASK);
    double currentLostAmount = 0;
    double distance = 0;
    double multiplication = 1;

    while(amountCalculated > amountToReachArg) {

      amountCalculated = 0;

      if(this.getBasketCoverOrderType() == OP_BUY){
        priceToTest -= orderUtils.convertNbrPipInQuotedPrice(0.1);
      } else {
        priceToTest += orderUtils.convertNbrPipInQuotedPrice(0.1);
      }

      for(int i = OrdersTotal()-1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)) {
            if(OrderType() == this.getBasketCoverOrderType() && OrderCloseTime() == 0
            && OrderMagicNumber() == magicNumberValue && StringCompare(OrderComment(),orderCommentForBasket) == 0) {
              distance = OrderType() == OP_BUY ? (priceToTest - OrderOpenPrice()) : (OrderOpenPrice() - priceToTest);
              amountCalculated += (OrderLots() * ((distance * tickCostInAccountCurrencyForOneLot) / tickSize) - (takeCommissionIntoAccountArg ? MathAbs(OrderCommission()) : 0)) * multiplication - currentLostAmount;
            }
         }
      }
    }

    if(priceToTest > 0){
      if((amountToReachArg > 0 && amountCalculated > 0) || amountToReachArg < 0)
      takeProfitLevelValue = priceToTest;
    }
    // Print("this.typeBuyOrSellOrder : "+this.typeBuyOrSellOrder);
    // Print("****** priceToTest : "+priceToTest);
    // Print("****** amountToReachArg : "+amountToReachArg);
    // Print("****** amountCalculated : "+amountCalculated);
    // Print("****** takeProfitLevelValue : "+takeProfitLevelValue);
    //amountCalculated > 0 && priceToTest > 0 ? priceToTest : 0;

    return takeProfitLevelValue;
  }

};

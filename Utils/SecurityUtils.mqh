#include <Strategy/Utils/BuySell.mqh>
#include <Strategy/Utils/OrderUtils.mqh>
#include <Strategy/Utils/DisplayUtils.mqh>
#include <Strategy/Utils/NotificationUtils.mqh>
#include <Strategy/Utils/CommunicationOneToOneUtils.mqh>

#include <WinUser32.mqh>

#import "user32.dll"
int GetAncestor(int, int);
int PostMessageA(int hWnd, int msg, int wparam, int lparam);
int GetParent(int hWnd);
#import

#define MT4_WMCMD_EXPERTS  33020
#define WM_CLOSE 16

#define CHANNEL_NAME "ClosingChannel"

#define TITLE               "EA Security Manager"

#define KEY_CTRL           17
#define KEY_C           67

#define X_COLUMN_1           20
#define X_COLUMN_2           300

#define X_COLUMN_3           480
#define X_COLUMN_4           860

#define Y_INITIAL_LINE       20
#define Y_STEP               20

#define BOX_X               10
#define BOX_Y               18
#define BOX_HEIGHT          540
#define BOX_LENGTH          940

#define COLOR_TITLE         White
#define COLOR_LABEL         Black
#define COLOR_INFO_NORMAL   Green
#define COLOR_INFO_WARNING  Orange
#define COLOR_INFO_ALERT    Red

#define COMMAND_CLOSE_MT   "CloseMetaTrader"
#define CHECK_COMMUNICATION   "COMMNUNICATION_CHECK"
#define MESSAGE_RECEIVED   "MESSAGE_RECEIVED"

class SecurityUtils {

  public :

  enum ClosingModeEnum {
    Close_All_Positions_In_Account = 0,
    Close_Positions_For_EA_In_Parameter_Only = 1,
    Close_Positions_For_Currency_In_Parameter_Only = 2,
    ClosePositions_For_EA_AND_Currency_In_Parameter_Only = 3,
  };

  enum ExecutionModeEnum {
    Standalone = 0,
    Master = 1,
    Slave = 2,
  };

  enum UseTypeEnum {
    OutsideAnotherEA = 0,
    InsideAnotherEA = 1,
    InsideAnotherGridEA = 2,
  };

  protected :

  UseTypeEnum useTypeMode;

  double boxX;
  double boxY;
  double boxLength;
  double boxHeight;

  //Parameters
  ExecutionModeEnum executionMode;
  ClosingModeEnum closingMode;
  double protectionPourcentEquityLossMax;
  double protectionAccountTP;
  double protectionMaxNbLotsAllowed;
  double protectionMaxNbrOrdersAllowed;
  double protectionAccountBalanceMin;
  double protectionAccountEquityMin;
  double protectionMaxLeverageAllowed;
  double protectionMaxDrawdownAllowed;
  int protectionMaxLosingOrdersInARow;

  datetime calculateDrawdownFrom;

  int magicNumberToCheck;
  string currencyToCheck;

  bool displayAllInformations;
  bool allowClosingPositions;

  bool deleteCurrentEA;
  bool closeAutoTrading;
  bool closeMetatrader;

  bool alertAtEachNbrOrders;
  bool alertAtEachNbrLots;
  bool alertAtEachNbrLeverageLevel;
  bool alertAtEachNbrLosingOrders;
  bool alertAtEachNbrPourcentEquityLoss;

  bool alertOnNewMaxValue;
  bool initDone;

  int alertNumberOfOrdersValue;
  double alertNumberOfLotsValue;
  double alertLeverageValue;
  int alertLosingStreakValue;
  double alertEquityLossValue;

  bool pushNotification;
  bool emailNotification;
  bool alertNotification;

  //EA Configuration
  int nbrMinutesInfoResfreshing;
  bool hideAllBehind;

  //Intern informations
  string closingModeLabel;
  string communicationModeLabel;
  int closingSelectionUsed;
  double accountBalance;
  double accountEquity;
  double equityLossGainPourcent;
  double equityLossGainValue;
  double accountLeverage;

  int accountNumberOfPositions;
  int eaNumberOfPosisions;
  int currencyNumberOfPositions;

  double accountNumberOfLots;
  double eaNumberOfLots;
  double currencyNumberOfLots;
  int nbrLosingOrdersInARow;

  double currentAccountLeverage;
  double currentAccountDrawdownPourcent;
  double maxAccountBalance;
  int maxNumberPositionsOpened;
  double maxNumberOfLots;
  double maxLeverageUsed;
  double maxEquityLossGainPourcent;
  double maxEquityLossGainValue;
  int biggestLoosingStreak;
  double deposit;
  double earnedOnMagicNumber;
  double earnedOnCurrency;
  double earnedOnAccount;

  double initialYLine;
  string separator;
  bool isWindowOpen;

  bool stopTryingToClose;

  bool communicationIsWorking;

  int alertNumberOfOrdersReached;
  double alertNumberOfLotsReached;
  double alertLeverageReached;
  int alertLosingStreakReached;
  double alertEquityLossReached;

  string windowsTitle;

  //Utils objects
  BuySell *buySell;
  OrderUtils *orderUtils;
  DisplayUtils *displayUtils;
  NotificationUtils *notificationUtils;
  CommunicationOneToOneUtils *communicationOneToOneUtils;
  CommunicationOneToOneUtils *checkCommunication;

  string getSeparator(){
    return "";
  }

  int getIntFromDouble(double toConvert){
    return MathRound(toConvert - MathMod(toConvert,1));
  }

  void notification(string mnsg){
    notificationUtils.sendNotification(mnsg, pushNotification, emailNotification, alertNotification);
  }

  void setStrClosingMode(){
    if(executionMode != Slave) {
      if(allowClosingPositions == false) {
        closingModeLabel = "Closing disabled.";
        closingSelectionUsed = 5;
      } else if(magicNumberToCheck != 0 && closingMode == Close_Positions_For_EA_In_Parameter_Only) {
        closingModeLabel = "Close all orders with magic number "+string(magicNumberToCheck);
        closingSelectionUsed = 1;
      } else if(currencyToCheck != NULL && StringCompare(currencyToCheck, "") != 0 && closingMode == Close_Positions_For_Currency_In_Parameter_Only) {
        closingModeLabel =  "Close all orders done with "+currencyToCheck;
        closingSelectionUsed = 2;
      } else if(currencyToCheck != NULL && StringCompare(currencyToCheck, "") != 0 && magicNumberToCheck != 0 && closingMode == ClosePositions_For_EA_AND_Currency_In_Parameter_Only) {
        closingModeLabel =  "Close all orders done with "+currencyToCheck+" and with magic number "+string(magicNumberToCheck);
        closingSelectionUsed = 3;
      } else {
        closingModeLabel =  "Close all orders in this account.";
        closingSelectionUsed = 0;
      }
    } else {
      closingModeLabel = "All orders are closed by the EA Master.";
      closingSelectionUsed = 5;
    }
  }

  void setStrCommunicationMode(){
    if(executionMode == Standalone){
      communicationModeLabel = "STANDALONE MODE - Manage orders inside this EA. Can be risky";
    } else if(executionMode == Master){
      communicationModeLabel = "MASTER MODE - Command the EA slave to close MT4.";
    } else if(executionMode == Slave) {
      communicationModeLabel = "SLAVE MODE - Don't manage any protections. Listen to EA Master.";
    }
  }

  void initAccountInformations(){
    maxAccountBalance = 0;
    maxNumberPositionsOpened = 0;
    maxNumberOfLots = 0;
    maxLeverageUsed = 0;
    maxEquityLossGainPourcent = 0;
    maxEquityLossGainValue = 0;
    biggestLoosingStreak = 0;

    alertNumberOfOrdersReached = 0;
    alertNumberOfLotsReached = 0;
    alertLeverageReached = 0;
    alertLosingStreakReached = 0;
    alertEquityLossReached = 0;

    earnedOnMagicNumber = 0;
    earnedOnCurrency = 0;
    earnedOnAccount = 0;

    this.setStrClosingMode();
    this.setStrCommunicationMode();

    double accountBalanceInTime = AccountBalance();
    double nbrOrderHistoryTotal = OrdersHistoryTotal();

    for(int i = nbrOrderHistoryTotal - 1; i >= 0; i--)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
          accountBalanceInTime = accountBalanceInTime - (OrderProfit() + OrderCommission() + OrderSwap());

          if(calculateDrawdownFrom <= OrderOpenTime() && maxAccountBalance < accountBalanceInTime) {
            maxAccountBalance = accountBalanceInTime;
          }
       }
     }

    updateAccountInformations();
  }


  void checkLastNbrOrdersLost(){
    nbrLosingOrdersInARow = 0;

    double nbrOrderHistoryTotal = OrdersHistoryTotal();
    for(int i = nbrOrderHistoryTotal - 1; i>=0; i--)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
        if(OrderType()<=5){
          if((OrderProfit() + OrderCommission() + OrderSwap()) < 0){
            ++nbrLosingOrdersInARow;
          } else {
            break;
          }
        }
      }
    }
  }

  void updateEarnedInHistory(){
    earnedOnMagicNumber = 0;
    earnedOnCurrency = 0;
    earnedOnAccount = 0;

    double nbrOrderHistoryTotal = OrdersHistoryTotal();
    for(int i = nbrOrderHistoryTotal - 1; i>=0; i--)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
          if(OrderType()<=5){
            if(magicNumberToCheck == OrderMagicNumber()) {
             earnedOnMagicNumber += OrderProfit() + OrderCommission() + OrderSwap();
            }

            if(StringCompare(OrderSymbol(), currencyToCheck) == 0){
              earnedOnCurrency += OrderProfit() + OrderCommission() + OrderSwap();
            }

            earnedOnAccount += OrderProfit() + OrderCommission() + OrderSwap();
          }
       }
     }
  }

  void updateNumberPositionsAndLots(){
    accountNumberOfPositions = 0;
    eaNumberOfPosisions = 0;
    currencyNumberOfPositions = 0;
    accountNumberOfLots = 0;
    eaNumberOfLots = 0;
    currencyNumberOfLots = 0;

    for(int i = 0; i<OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {

          if(magicNumberToCheck == OrderMagicNumber()) {
            ++eaNumberOfPosisions;
            eaNumberOfLots += OrderLots();
          }

          if(StringCompare(OrderSymbol(), currencyToCheck) == 0){
            ++currencyNumberOfPositions;
            currencyNumberOfLots += OrderLots();
          }

          ++accountNumberOfPositions;
          accountNumberOfLots += OrderLots();
      }
    }
  }

  void updateAccountInformations(){
    accountBalance = AccountBalance();
    accountEquity = AccountEquity();
    accountLeverage = AccountLeverage();
    equityLossGainPourcent = NormalizeDouble(100 - ((accountEquity * 100) / accountBalance), 2);
    equityLossGainValue = NormalizeDouble(accountBalance - accountEquity, 2);
    if(maxAccountBalance != 0){
      currentAccountDrawdownPourcent = NormalizeDouble(100 - ((accountEquity * 100) / maxAccountBalance),2);
    }

    this.updateNumberPositionsAndLots();
    this.checkLastNbrOrdersLost();

    currentAccountLeverage = orderUtils.getRealLeverage();

    deposit =  NormalizeDouble(orderUtils.getDepositsOnAccount(),2);

    if(maxAccountBalance < accountBalance) {
      maxAccountBalance = accountBalance;
    }

    if(maxNumberPositionsOpened < accountNumberOfPositions) {
      maxNumberPositionsOpened = accountNumberOfPositions;
      if(initDone == true && alertOnNewMaxValue == true){
        notification("ALERT - Number of positions reached a new maximum : "+string(maxNumberPositionsOpened));
      }
    }

    if(maxNumberOfLots < accountNumberOfLots) {
      maxNumberOfLots = accountNumberOfLots;
      if(initDone == true && alertOnNewMaxValue == true){
        notification("ALERT - Number of lots reached a new maximum : "+string(maxNumberOfLots));
      }
    }

    if(maxLeverageUsed < currentAccountLeverage) {
      maxLeverageUsed = currentAccountLeverage;
      if(initDone == true && alertOnNewMaxValue == true){
        notification("ALERT - Leverage reached a new maximum : X"+string(maxLeverageUsed));
      }
    }

    if(biggestLoosingStreak < nbrLosingOrdersInARow) {
      biggestLoosingStreak = nbrLosingOrdersInARow;
      if(initDone == true && alertOnNewMaxValue == true){
        notification("ALERT - Number of losing orders in a row reached a new maximum : "+string(biggestLoosingStreak));
      }
    }

    if(equityLossGainPourcent > 0 && maxEquityLossGainPourcent < equityLossGainPourcent) {
      maxEquityLossGainPourcent = equityLossGainPourcent;
      maxEquityLossGainValue = equityLossGainValue;
      if(initDone == true && alertOnNewMaxValue == true){
        notification("ALERT - Loss of equity reached  a new maximum : "+string(maxEquityLossGainPourcent)+" %");
      }
    }


    this.updateEarnedInHistory();
  }

  void manageAlerts(){

    if(alertAtEachNbrOrders == true && (accountNumberOfPositions > (alertNumberOfOrdersReached + alertNumberOfOrdersValue))){
      alertNumberOfOrdersReached += alertNumberOfOrdersValue;
      notification("ALERT - Number of positions reached "+string(alertNumberOfOrdersReached));
    } else if(accountNumberOfPositions < (alertNumberOfOrdersReached - alertNumberOfOrdersValue)){
      alertNumberOfOrdersReached -= alertNumberOfOrdersValue;
    }

    if(alertAtEachNbrLots == true && (accountNumberOfLots > (alertNumberOfLotsReached + alertNumberOfLotsValue))){
      alertNumberOfLotsReached += alertNumberOfLotsValue;
      notification("ALERT - Number of lots reached "+string(alertNumberOfLotsReached));
    } else if(accountNumberOfLots < (alertNumberOfLotsReached - alertNumberOfLotsValue)){
      alertNumberOfLotsReached -= alertNumberOfLotsValue;
    }

    if(alertAtEachNbrLeverageLevel == true && (currentAccountLeverage > (alertLeverageReached + alertLeverageValue))){
      alertLeverageReached += alertLeverageValue;
      notification("ALERT - Leverage reached X"+string(alertLeverageReached));
    } else if(currentAccountLeverage < (alertLeverageReached - alertLeverageValue)){
      alertLeverageReached -= alertLeverageValue;
    }

    if(alertAtEachNbrLosingOrders == true && (nbrLosingOrdersInARow > (alertLosingStreakReached + alertLosingStreakValue))){
      alertLosingStreakReached += alertLosingStreakValue;
      notification("ALERT - Number of losing orders in a row reached "+string(alertLosingStreakReached));
    } else if(nbrLosingOrdersInARow < (alertLosingStreakReached - alertLosingStreakValue)){
      alertLosingStreakReached -= alertLosingStreakValue;
    }

    if(alertAtEachNbrPourcentEquityLoss == true && (equityLossGainPourcent > (alertEquityLossReached + alertEquityLossValue))){
      alertEquityLossReached += alertEquityLossValue;
      notification("ALERT - Loss of equity reached "+string(alertEquityLossReached)+" %");
    } else if(equityLossGainPourcent < (alertEquityLossReached - alertEquityLossValue)){
      alertEquityLossReached -= alertEquityLossValue;
    }
  }

  void addTitle(string nameTitle) {

    ObjectDelete("titleDispalyed");

    ObjectCreate("titleDispalyed", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("titleDispalyed",nameTitle,15, "Verdana", COLOR_TITLE);
    ObjectSet("titleDispalyed", OBJPROP_CORNER, 0);
    ObjectSet("titleDispalyed", OBJPROP_XDISTANCE, X_COLUMN_1);
    ObjectSet("titleDispalyed", OBJPROP_YDISTANCE, initialYLine);

    initialYLine += Y_STEP;
    initialYLine += Y_STEP;
  }

  void addVisualObject(string nameObject, string nameTitle, string value, bool hasProtection, string nameProtectionTitle, string protectionValue){

    ObjectDelete("title_"+nameObject);
    ObjectDelete("value_"+nameObject);

    //Print("ObjectDelete(\"title_"+nameObject+"\");");
    //Print("ObjectDelete(\"value_"+nameObject+"\");");

    ObjectCreate("title_"+nameObject, OBJ_LABEL, 0, 0, 0);
    ObjectSetText("title_"+nameObject,nameTitle,9, "Verdana", COLOR_LABEL);
    ObjectSet("title_"+nameObject, OBJPROP_CORNER, 0);
    ObjectSet("title_"+nameObject, OBJPROP_XDISTANCE, X_COLUMN_1);
    ObjectSet("title_"+nameObject, OBJPROP_YDISTANCE, initialYLine);
    //-------
    ObjectCreate("value_"+nameObject, OBJ_LABEL, 0, 0, 0);
    ObjectSetText("value_"+nameObject,value,9, "Verdana", COLOR_INFO_NORMAL);
    ObjectSet("value_"+nameObject, OBJPROP_CORNER, 0);
    ObjectSet("value_"+nameObject, OBJPROP_XDISTANCE, X_COLUMN_2);
    ObjectSet("value_"+nameObject, OBJPROP_YDISTANCE, initialYLine);

    if(hasProtection && useTypeMode != InsideAnotherGridEA) {
      ObjectDelete("titleProtection_"+nameObject);
      ObjectDelete("valueProtection_"+nameObject);

      //Print("ObjectDelete(\"titleProtection_"+nameObject+"\");");
      //Print("ObjectDelete(\"valueProtection_"+nameObject+"\");");

      ObjectCreate("titleProtection_"+nameObject, OBJ_LABEL, 0, 0, 0);
      ObjectSetText("titleProtection_"+nameObject,nameProtectionTitle,9, "Verdana", COLOR_LABEL);
      ObjectSet("titleProtection_"+nameObject, OBJPROP_CORNER, 0);
      ObjectSet("titleProtection_"+nameObject, OBJPROP_XDISTANCE, X_COLUMN_3);
      ObjectSet("titleProtection_"+nameObject, OBJPROP_YDISTANCE, initialYLine);
      //-------
      ObjectCreate("valueProtection_"+nameObject, OBJ_LABEL, 0, 0, 0);
      ObjectSetText("valueProtection_"+nameObject, protectionValue, 9, "Verdana", COLOR_INFO_NORMAL);
      ObjectSet("valueProtection_"+nameObject, OBJPROP_CORNER, 0);
      ObjectSet("valueProtection_"+nameObject, OBJPROP_XDISTANCE, X_COLUMN_4);
      ObjectSet("valueProtection_"+nameObject, OBJPROP_YDISTANCE, initialYLine);
    }

    initialYLine += Y_STEP;
  }

  void updateVisualObject(string nameObject, color valueColor, string value, bool hasProtection, color protectionColor, string protectionValue){
    ObjectSetText("value_"+nameObject,value,9, "Verdana", valueColor);
    if(hasProtection) {
      ObjectSetText("valueProtection_"+nameObject, protectionValue, 9, "Verdana", protectionColor);
    }
  }

  void addSeparator(string separatorNumber){
    ObjectDelete("separator"+separatorNumber);

    //Print("ObjectDelete(\"separator"+separatorNumber+"\");");

    ObjectCreate("separator"+separatorNumber, OBJ_LABEL, 0, 0, 0);
    ObjectSetText("separator"+separatorNumber,separator,9, "Verdana", COLOR_INFO_ALERT);
    ObjectSet("separator"+separatorNumber, OBJPROP_CORNER, 0);
    ObjectSet("separator"+separatorNumber, OBJPROP_XDISTANCE, X_COLUMN_1);
    ObjectSet("separator"+separatorNumber, OBJPROP_YDISTANCE, initialYLine);

    ObjectDelete("separator"+separatorNumber+"1");
    //Print("ObjectDelete(\"separator"+separatorNumber+"1\");");

    ObjectCreate("separator"+separatorNumber+"1", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("separator"+separatorNumber+"1",separator,9, "Verdana", COLOR_INFO_ALERT);
    ObjectSet("separator"+separatorNumber+"1", OBJPROP_CORNER, 0);
    ObjectSet("separator"+separatorNumber+"1", OBJPROP_XDISTANCE, X_COLUMN_2);
    ObjectSet("separator"+separatorNumber+"1", OBJPROP_YDISTANCE, initialYLine);

    ObjectDelete("separator"+separatorNumber+"2");
    //Print("ObjectDelete(\"separator"+separatorNumber+"2\");");

    ObjectCreate("separator"+separatorNumber+"2", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("separator"+separatorNumber+"2",separator,9, "Verdana", COLOR_INFO_ALERT);
    ObjectSet("separator"+separatorNumber+"2", OBJPROP_CORNER, 0);
    ObjectSet("separator"+separatorNumber+"2", OBJPROP_XDISTANCE, X_COLUMN_3);
    ObjectSet("separator"+separatorNumber+"2", OBJPROP_YDISTANCE, initialYLine);

    ObjectDelete("separator"+separatorNumber+"3");
    //Print("ObjectDelete(\"separator"+separatorNumber+"3\");");

    ObjectCreate("separator"+separatorNumber+"3", OBJ_LABEL, 0, 0, 0);
    ObjectSetText("separator"+separatorNumber+"3",separator,9, "Verdana", COLOR_INFO_ALERT);
    ObjectSet("separator"+separatorNumber+"3", OBJPROP_CORNER, 0);
    ObjectSet("separator"+separatorNumber+"3", OBJPROP_XDISTANCE, X_COLUMN_4);
    ObjectSet("separator"+separatorNumber+"3", OBJPROP_YDISTANCE, initialYLine);

    initialYLine += Y_STEP;
  }

  void createVisualObjects(){

    addTitle("");


    addVisualObject("accountBalance", "Account balance : ", string(this.accountBalance)+" "+AccountCurrency(), true, "Protection account - Balance minimum allowed : ", this.protectionAccountBalanceMin != 0 ? string(this.protectionAccountBalanceMin)+" "+ AccountCurrency() : "NONE");
    addVisualObject("accountEquity", "Account equity : ", string(this.accountEquity)+" "+AccountCurrency(), true, "Protection account - Equity minimum allowed : ", this.protectionAccountEquityMin != 0 ?  string(this.protectionAccountEquityMin)+" "+ AccountCurrency() : "NONE");
    addVisualObject("equityLossGainPourcent", "Equity Loss/Gain : ",(this.accountBalance > this.accountEquity ? "-" : "") + string(this.equityLossGainPourcent)+" % ("+equityLossGainValue+")",   true, "Protection account - Equity protected under : ", this.protectionPourcentEquityLossMax != 0 ? string(this.protectionPourcentEquityLossMax)+" %" : "NONE");

    addSeparator("11");

    addVisualObject("accountNumberOfPositions", "Number of positions : ", string(this.accountNumberOfPositions), true, "Protection account - Max number of positions allowed : ", this.protectionMaxNbrOrdersAllowed != 0 ? string(this.protectionMaxNbrOrdersAllowed) : "NONE");
    addVisualObject("accountNumberOfLots", "Number of lots : ", string(this.accountNumberOfLots), true, "Protection account - Max number of lots allowed : ", this.protectionMaxNbLotsAllowed != 0 ?  string(this.protectionMaxNbLotsAllowed) : "NONE");
    addVisualObject("currentAccountLeverage", "Current leverage : ", "X "+string(this.currentAccountLeverage), true, "Protection account - Biggest leverage allowed : ", this.protectionMaxLeverageAllowed != 0 ? "X "+ string(this.protectionMaxLeverageAllowed) : "NONE");
    if(useTypeMode != InsideAnotherGridEA){
      addVisualObject("losingStreak", "Current losing streak : ", string(this.nbrLosingOrdersInARow), true, "Protection account - Biggest losing streak allowed : ", this.protectionMaxLosingOrdersInARow != 0 ? string(this.protectionMaxLosingOrdersInARow)+" %" : "NONE");
    }
    addVisualObject("currentAccountDrawdownPourcent", "Current drawdown : ", string(this.currentAccountDrawdownPourcent)+" %", true, "Protection account - Biggest drawdown allowed : ", this.protectionMaxDrawdownAllowed != 0 ? string(this.protectionMaxDrawdownAllowed)+" %" : "NONE");

    addSeparator("21");

    addVisualObject("maxNumberPositionsOpened", "Maximum number of positions reached : ", string(this.maxNumberPositionsOpened), true, "Alert - At each "+string(alertNumberOfOrdersValue)+" open orders : ", alertAtEachNbrOrders == true ? "Enabled" : "Disabled");
    addVisualObject("maxNumberOfLots", "Maxumum number of lots used : ", string(this.maxNumberOfLots), true, "Alert - At each "+string(alertNumberOfLotsValue)+" Lot : ", alertAtEachNbrLots == true ? "Enabled" : "Disabled");
    addVisualObject("maxLeverageUsed", "Biggest leverage used : ", "X "+string(this.maxLeverageUsed), true, "Alert - At each leverage X "+string(alertLeverageValue)+" : ", alertAtEachNbrLeverageLevel == true ? "Enabled" : "Disabled");
    if(useTypeMode != InsideAnotherGridEA){
      addVisualObject("maxLosingStreak", "Biggest losing streak : ", string(this.biggestLoosingStreak), true, "Alert - At each "+string(alertLosingStreakValue)+" losing orders in a row : ", alertAtEachNbrLosingOrders == true ? "Enabled" : "Disabled");
    }
    addVisualObject("maxEquityLossGainPourcent", "Maximum equity Loss reached : ", string(this.maxEquityLossGainPourcent)+" %", true, "Alert - At each "+string(alertEquityLossValue)+" % equity loss : ", alertAtEachNbrPourcentEquityLoss == true ? "Enabled" : "Disabled");

    addSeparator("31");

    addVisualObject("deposit", "Deposit : ", string(this.deposit)+" "+AccountCurrency(), false, NULL, NULL);
    if(magicNumberToCheck != 0) {
      addVisualObject("earnedOnMagicNumber", "Earned/Lost with magic number " +magicNumberToCheck+" : ", string(this.earnedOnMagicNumber)+" "+AccountCurrency(), false, NULL, NULL);
    }
    if(currencyToCheck != NULL && StringCompare(currencyToCheck, "") != 0) {
      addVisualObject("earnedOnCurrency", "Earned/Lost on "+string(this.currencyToCheck)+" : ", string(this.earnedOnCurrency)+" "+AccountCurrency(), false, NULL, NULL);
    }
    addVisualObject("earnedOnAccount", "Earned/Lost on this account : ", string(this.earnedOnAccount)+" "+AccountCurrency(), false, NULL, NULL);

    if(useTypeMode == OutsideAnotherEA) {

      addSeparator("41");

      addVisualObject("closingMode", "Closing orders mode : ", closingModeLabel, false, NULL, NULL);
      updateVisualObject("closingMode", closingSelectionUsed == 5 ? COLOR_INFO_ALERT : COLOR_INFO_NORMAL, closingModeLabel, false, NULL, NULL);

      addSeparator("51");

      addVisualObject("EAMode", "EA mode : ", communicationModeLabel, false, NULL, NULL);
      updateVisualObject("EAMode", executionMode == Standalone ? COLOR_INFO_ALERT : COLOR_INFO_NORMAL, communicationModeLabel, false, NULL, NULL);

      if(executionMode == Master) {
        ObjectDelete("value_checkConnection");
        //-------
        ObjectCreate("value_checkConnection", OBJ_LABEL, 0, 0, 0);
        ObjectSetText("value_checkConnection",communicationIsWorking == true ? "Connection to Slave checked" : "Not connected to Slave",9, "Verdana", communicationIsWorking == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT);
        ObjectSet("value_checkConnection", OBJPROP_CORNER, 0);
        ObjectSet("value_checkConnection", OBJPROP_XDISTANCE, X_COLUMN_2);
        ObjectSet("value_checkConnection", OBJPROP_YDISTANCE, initialYLine);

        initialYLine += Y_STEP;
      } else if(executionMode == Slave){
        ObjectDelete("value_checkConnection");
        //-------
        ObjectCreate("value_checkConnection", OBJ_LABEL, 0, 0, 0);
        ObjectSetText("value_checkConnection",communicationIsWorking == true ? "Connection to Master checked" : "Not connected to Master",9, "Verdana", communicationIsWorking == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT);
        ObjectSet("value_checkConnection", OBJPROP_CORNER, 0);
        ObjectSet("value_checkConnection", OBJPROP_XDISTANCE, X_COLUMN_2);
        ObjectSet("value_checkConnection", OBJPROP_YDISTANCE, initialYLine);

        initialYLine += Y_STEP;
      }
    }

    this.updateVisualObjects();
  }

  void deleteAllSecurityObjects(){
    ObjectDelete("value_checkConnection");
    ObjectDelete("titleDispalyed");
    ObjectDelete("title_accountBalance");
    ObjectDelete("value_accountBalance");
    ObjectDelete("titleProtection_accountBalance");
    ObjectDelete("valueProtection_accountBalance");
    ObjectDelete("title_accountEquity");
    ObjectDelete("value_accountEquity");
    ObjectDelete("titleProtection_accountEquity");
    ObjectDelete("valueProtection_accountEquity");
    ObjectDelete("title_equityLossGainPourcent");
    ObjectDelete("value_equityLossGainPourcent");
    ObjectDelete("titleProtection_equityLossGainPourcent");
    ObjectDelete("valueProtection_equityLossGainPourcent");
    ObjectDelete("separator11");
    ObjectDelete("separator111");
    ObjectDelete("separator112");
    ObjectDelete("separator113");
    ObjectDelete("title_accountNumberOfPositions");
    ObjectDelete("value_accountNumberOfPositions");
    ObjectDelete("titleProtection_accountNumberOfPositions");
    ObjectDelete("valueProtection_accountNumberOfPositions");
    ObjectDelete("title_accountNumberOfLots");
    ObjectDelete("value_accountNumberOfLots");
    ObjectDelete("titleProtection_accountNumberOfLots");
    ObjectDelete("valueProtection_accountNumberOfLots");
    ObjectDelete("title_currentAccountLeverage");
    ObjectDelete("value_currentAccountLeverage");
    ObjectDelete("titleProtection_currentAccountLeverage");
    ObjectDelete("valueProtection_currentAccountLeverage");
    ObjectDelete("title_losingStreak");
    ObjectDelete("value_losingStreak");
    ObjectDelete("titleProtection_losingStreak");
    ObjectDelete("valueProtection_losingStreak");
    ObjectDelete("title_currentAccountDrawdownPourcent");
    ObjectDelete("value_currentAccountDrawdownPourcent");
    ObjectDelete("titleProtection_currentAccountDrawdownPourcent");
    ObjectDelete("valueProtection_currentAccountDrawdownPourcent");
    ObjectDelete("separator21");
    ObjectDelete("separator211");
    ObjectDelete("separator212");
    ObjectDelete("separator213");
    ObjectDelete("title_maxNumberPositionsOpened");
    ObjectDelete("value_maxNumberPositionsOpened");
    ObjectDelete("titleProtection_maxNumberPositionsOpened");
    ObjectDelete("valueProtection_maxNumberPositionsOpened");
    ObjectDelete("title_maxNumberOfLots");
    ObjectDelete("value_maxNumberOfLots");
    ObjectDelete("titleProtection_maxNumberOfLots");
    ObjectDelete("valueProtection_maxNumberOfLots");
    ObjectDelete("title_maxLeverageUsed");
    ObjectDelete("value_maxLeverageUsed");
    ObjectDelete("titleProtection_maxLeverageUsed");
    ObjectDelete("valueProtection_maxLeverageUsed");
    ObjectDelete("title_maxLosingStreak");
    ObjectDelete("value_maxLosingStreak");
    ObjectDelete("titleProtection_maxLosingStreak");
    ObjectDelete("valueProtection_maxLosingStreak");
    ObjectDelete("title_maxEquityLossGainPourcent");
    ObjectDelete("value_maxEquityLossGainPourcent");
    ObjectDelete("titleProtection_maxEquityLossGainPourcent");
    ObjectDelete("valueProtection_maxEquityLossGainPourcent");
    ObjectDelete("separator31");
    ObjectDelete("separator311");
    ObjectDelete("separator312");
    ObjectDelete("separator313");
    ObjectDelete("title_deposit");
    ObjectDelete("value_deposit");
    ObjectDelete("title_earnedOnMagicNumber");
    ObjectDelete("value_earnedOnMagicNumber");
    ObjectDelete("title_earnedOnCurrency");
    ObjectDelete("value_earnedOnCurrency");
    ObjectDelete("title_earnedOnAccount");
    ObjectDelete("value_earnedOnAccount");
    ObjectDelete("separator41");
    ObjectDelete("separator411");
    ObjectDelete("separator412");
    ObjectDelete("separator413");
    ObjectDelete("title_closingMode");
    ObjectDelete("value_closingMode");
    ObjectDelete("separator51");
    ObjectDelete("separator511");
    ObjectDelete("separator512");
    ObjectDelete("separator513");
    ObjectDelete("title_EAMode");
    ObjectDelete("value_EAMode");
    ObjectDelete("rectOrders");
    ObjectDelete("rectTitle");
    ObjectDelete("lblTitle");
    ObjectDelete("openCloseButton");
    ObjectDelete("closeAllButton");
  }

  void updateVisualObjects(){

    updateVisualObject("accountBalance", COLOR_INFO_NORMAL, string(this.accountBalance)+" "+AccountCurrency(), true, this.protectionAccountBalanceMin != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT , this.protectionAccountBalanceMin != 0 ? string(this.protectionAccountBalanceMin)+" "+ AccountCurrency() : "NONE");

    updateVisualObject("accountEquity", COLOR_INFO_NORMAL, string(this.accountEquity)+" "+AccountCurrency(), true, this.protectionAccountEquityMin != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT , this.protectionAccountEquityMin != 0 ?  string(this.protectionAccountEquityMin)+" "+ AccountCurrency() : "NONE");

    updateVisualObject("equityLossGainPourcent", this.accountBalance > this.accountEquity ? (this.protectionPourcentEquityLossMax > 0 && this.equityLossGainPourcent > this.protectionPourcentEquityLossMax / 2  ? COLOR_INFO_ALERT : COLOR_INFO_WARNING) : COLOR_INFO_NORMAL,(this.accountBalance > this.accountEquity ? "-" : "+") + string(MathAbs(this.equityLossGainPourcent))+" % ("+MathAbs(equityLossGainValue)+" "+AccountCurrency()+")",   true, this.protectionPourcentEquityLossMax != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT , this.protectionPourcentEquityLossMax != 0 ? string(this.protectionPourcentEquityLossMax)+" %" : "NONE");

    updateVisualObject("accountNumberOfPositions", this.protectionMaxNbrOrdersAllowed > 0 && this.accountNumberOfPositions > this.protectionMaxNbrOrdersAllowed / 2  ? COLOR_INFO_ALERT : (this.accountNumberOfPositions <= 5 ? COLOR_INFO_NORMAL : COLOR_INFO_WARNING), string(this.accountNumberOfPositions), true, this.protectionMaxNbrOrdersAllowed != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT , this.protectionMaxNbrOrdersAllowed != 0 ? string(this.protectionMaxNbrOrdersAllowed) : "NONE");

    updateVisualObject("accountNumberOfLots", this.protectionMaxNbLotsAllowed > 0 && this.accountNumberOfLots > this.protectionMaxNbLotsAllowed / 2  ? COLOR_INFO_ALERT : (this.accountNumberOfLots <= 1 ? COLOR_INFO_NORMAL : COLOR_INFO_WARNING), string(this.accountNumberOfLots), true, this.protectionMaxNbLotsAllowed != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, this.protectionMaxNbLotsAllowed != 0 ?  string(this.protectionMaxNbLotsAllowed) : "NONE");

    updateVisualObject("currentAccountLeverage", this.protectionMaxLeverageAllowed > 0 && this.currentAccountLeverage > this.protectionMaxLeverageAllowed / 2  ? COLOR_INFO_ALERT : (this.currentAccountLeverage <= 10 ? COLOR_INFO_NORMAL : COLOR_INFO_WARNING), "X "+string(this.currentAccountLeverage), true, this.protectionMaxLeverageAllowed != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, this.protectionMaxLeverageAllowed != 0 ? "X "+ string(this.protectionMaxLeverageAllowed) : "NONE");

    if(useTypeMode != InsideAnotherGridEA){
      updateVisualObject("losingStreak", this.protectionMaxLosingOrdersInARow > 0 && this.nbrLosingOrdersInARow > this.protectionMaxLosingOrdersInARow / 2  ? COLOR_INFO_ALERT : (this.nbrLosingOrdersInARow <= 5 ? COLOR_INFO_NORMAL : COLOR_INFO_WARNING), string(this.nbrLosingOrdersInARow), true, this.protectionMaxLosingOrdersInARow != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, this.protectionMaxLosingOrdersInARow != 0 ? string(this.protectionMaxLosingOrdersInARow)+" %" : "NONE");
    }

    updateVisualObject("currentAccountDrawdownPourcent", this.protectionMaxDrawdownAllowed > 0 && this.currentAccountDrawdownPourcent > this.protectionMaxDrawdownAllowed / 2  ? COLOR_INFO_ALERT : (this.currentAccountDrawdownPourcent <= 10 ? COLOR_INFO_NORMAL : COLOR_INFO_WARNING), string(this.currentAccountDrawdownPourcent)+" %", true, this.protectionMaxDrawdownAllowed != 0 ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, this.protectionMaxDrawdownAllowed != 0 ? string(this.protectionMaxDrawdownAllowed)+" %" : "NONE");


    updateVisualObject("maxNumberPositionsOpened", this.maxNumberPositionsOpened > 20 ? COLOR_INFO_ALERT : (this.maxNumberPositionsOpened > 10 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL), string(this.maxNumberPositionsOpened), true, alertAtEachNbrOrders == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, alertAtEachNbrOrders == true ? "Enabled" : "Disabled");

    updateVisualObject("maxNumberOfLots", this.maxNumberOfLots > 2 ? COLOR_INFO_ALERT : (this.maxNumberOfLots > 1 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL), string(this.maxNumberOfLots), true, alertAtEachNbrLots == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, alertAtEachNbrLots == true ? "Enabled" : "Disabled");

    updateVisualObject("maxLeverageUsed", this.maxLeverageUsed > 50 ? COLOR_INFO_ALERT : (this.maxLeverageUsed > 10 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL), "X "+string(this.maxLeverageUsed), true, alertAtEachNbrLeverageLevel == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, alertAtEachNbrLeverageLevel == true ? "Enabled" : "Disabled");

    if(useTypeMode != InsideAnotherGridEA){
      updateVisualObject("maxLosingStreak", this.biggestLoosingStreak > 15 ? COLOR_INFO_ALERT : (this.biggestLoosingStreak > 10 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL), string(this.biggestLoosingStreak), true, alertAtEachNbrLosingOrders == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, alertAtEachNbrLosingOrders == true ? "Enabled" : "Disabled");
    }

    updateVisualObject("maxEquityLossGainPourcent", this.maxEquityLossGainPourcent > 20 ? COLOR_INFO_ALERT : (this.maxEquityLossGainPourcent > 10 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL), string(this.maxEquityLossGainPourcent)+" % ("+maxEquityLossGainValue+" "+AccountCurrency()+")", true, alertAtEachNbrPourcentEquityLoss == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT, alertAtEachNbrPourcentEquityLoss == true ? "Enabled" : "Disabled");

    updateVisualObject("deposit", COLOR_INFO_NORMAL, string(this.deposit)+" "+AccountCurrency(), false, NULL, NULL);
    if(magicNumberToCheck != 0) {
      updateVisualObject("earnedOnMagicNumber", this.earnedOnMagicNumber < 0 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL, string(this.earnedOnMagicNumber)+" "+AccountCurrency(), false, NULL, NULL);
    }
    if(currencyToCheck != NULL && StringCompare(currencyToCheck, "") != 0) {
      updateVisualObject("earnedOnCurrency", this.earnedOnCurrency < 0 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL, string(this.earnedOnCurrency)+" "+AccountCurrency(), false, NULL, NULL);
    }
    updateVisualObject("earnedOnAccount", this.earnedOnAccount < 0 ? COLOR_INFO_WARNING : COLOR_INFO_NORMAL, string(this.earnedOnAccount)+" "+AccountCurrency(), false, NULL, NULL);

    this.updateConnectionStatus();
  }

  void updateConnectionStatus(){
    if(executionMode == Master) {
      ObjectSetText("value_checkConnection",communicationIsWorking == true ? "Connection to Slave checked" : "Not connected to Slave",9, "Verdana", communicationIsWorking == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT);
    } else if(executionMode == Slave){
      ObjectSetText("value_checkConnection",communicationIsWorking == true ? "Connection to Master checked" : "Not connected to Master",9, "Verdana", communicationIsWorking == true ? COLOR_INFO_NORMAL : COLOR_INFO_ALERT);
    }
  }

  void hideAllBehing(){
    this.displayUtils.ChartBackColorSet(Black,0);
    this.displayUtils.ChartForeColorSet(White,0);
    this.displayUtils.ChartShowPeriodSepapatorSet(false,0);
    this.displayUtils.ChartGridColorSet(Black,0);
    this.displayUtils.ChartVolumeColorSet(Black,0);
    this.displayUtils.ChartUpColorSet(Black,0);
    this.displayUtils.ChartDownColorSet(Black,0);
    this.displayUtils.ChartLineColorSet(Black,0);
    this.displayUtils.ChartBullColorSet(Black,0);
    this.displayUtils.ChartBearColorSet(Black,0);
    this.displayUtils.ChartBidColorSet(Black,0);
    this.displayUtils.ChartAskColorSet(Black,0);
    this.displayUtils.ChartLastColorSet(Black,0);
  }

  void initCommunication(){
    this.communicationIsWorking = false;
    if(this.executionMode == Master){
      this.communicationOneToOneUtils = new CommunicationOneToOneUtils(Client1, "SecurityEA"+string(AccountNumber()));
      this.checkCommunication = new CommunicationOneToOneUtils(Client1, "SecurityEACheck"+string(AccountNumber()));
      this.checkCommunication.sendMessage(CHECK_COMMUNICATION);
    } else if(this.executionMode == Slave){
      this.communicationOneToOneUtils = new CommunicationOneToOneUtils(Client2, "SecurityEA"+string(AccountNumber()));
      this.checkCommunication = new CommunicationOneToOneUtils(Client2, "SecurityEACheck"+string(AccountNumber()));
    }
    this.checkCommunicationWorking();
  }

  void checkCommunicationWorking(){

    if(communicationIsWorking == false) {
      if(this.executionMode == Master){
        string messageFromSlave = this.checkCommunication.receiveMessage();
        if(messageFromSlave != NULL && StringCompare(messageFromSlave, MESSAGE_RECEIVED) == 0){
          this.checkCommunication.sendMessage(MESSAGE_RECEIVED);
          communicationIsWorking = true;
          this.updateConnectionStatus();
        } else {
          this.checkCommunication.sendMessage(CHECK_COMMUNICATION);
        }
      } else if(this.executionMode == Slave){
        string messageFromMaster = this.checkCommunication.receiveMessage();
        if(messageFromMaster != NULL && StringCompare(messageFromMaster, CHECK_COMMUNICATION) == 0){
          this.checkCommunication.sendMessage(MESSAGE_RECEIVED);
        } else if(messageFromMaster != NULL && StringCompare(messageFromMaster, MESSAGE_RECEIVED) == 0){
          communicationIsWorking = true;
          this.updateConnectionStatus();
        }
      }
    }
  }

  void addButtonCloseAll(){
    displayUtils.addButtonOnChart("closeAllButton", "Close all positions", boxX + boxLength / 2, boxY + 7, 120, 20, clrWhite, clrBlue);
  }

  void openWindow(){
    isWindowOpen = true;
    //ObjectsDeleteAll();
    this.deleteAllSecurityObjects();
    this.initialYLine = Y_INITIAL_LINE;
    this.displayUtils.DrawBoxWindows(boxX, boxY, boxLength, boxHeight, this.windowsTitle, false, true);
    this.createVisualObjects();
    this.addButtonCloseAll();
  }

  void closeWindow(){
    isWindowOpen = false;
    //ObjectsDeleteAll();
    this.deleteAllSecurityObjects();
    this.initialYLine = Y_INITIAL_LINE;
    this.displayUtils.DrawBoxWindows(boxX, boxY, boxLength, boxHeight, this.windowsTitle, true, true);
    this.addButtonCloseAll();
  }

  public :

  SecurityUtils(){
    this.buySell = new BuySell(false, true, true);
    this.orderUtils = new OrderUtils();
    this.displayUtils = new DisplayUtils();
    this.notificationUtils = new NotificationUtils();

    this.protectionPourcentEquityLossMax = 0.2;
    this.protectionAccountTP = 0;
    this.protectionMaxNbLotsAllowed = 0;
    this.protectionMaxNbrOrdersAllowed = 25;
    this.protectionAccountBalanceMin = 0;
    this.protectionAccountEquityMin = 0;
    this.protectionMaxLeverageAllowed = 100;
    this.protectionMaxDrawdownAllowed = 20;
    this.protectionMaxLosingOrdersInARow = 0;
    this.magicNumberToCheck = 0;
    this.currencyToCheck = "";
    this.displayAllInformations = true;
    this.deleteCurrentEA = false;
    this.closeMetatrader = false;
    this.allowClosingPositions = true;
    this.alertAtEachNbrLots = false;
    this.alertAtEachNbrOrders = false;
    this.alertAtEachNbrPourcentEquityLoss = false;
    this.alertAtEachNbrLeverageLevel = true;
    this.alertAtEachNbrLosingOrders = false;
    this.alertOnNewMaxValue = false;
    this.nbrMinutesInfoResfreshing = 2;
    this.initialYLine = Y_INITIAL_LINE;
    this.separator = this.getSeparator();
    this.hideAllBehind = true;
    this.calculateDrawdownFrom = TimeCurrent();
    this.closingMode = Close_All_Positions_In_Account;
    this.executionMode = Master;
    this.pushNotification = true;
    this.emailNotification = false;
    this.alertNotification = true;
    this.stopTryingToClose = false;

    this.alertNumberOfOrdersValue = 10;
    this.alertNumberOfLotsValue = 1;
    this.alertLeverageValue = 20;
    this.alertLosingStreakValue = 5;
    this.alertEquityLossValue = 10;

    windowsTitle = TITLE;
    useTypeMode = OutsideAnotherEA;
    boxX = BOX_X;
    boxY = BOX_Y;
    boxLength = BOX_LENGTH;
    boxHeight = BOX_HEIGHT;

    this.initCommunication();
  }

  SecurityUtils(double protectionPourcentEquityLossMaxArg,   double protectionAccountTPArg,
    double protectionMaxNbLotsAllowedArg,   double protectionMaxNbrOrdersAllowedArg,   double protectionAccountBalanceMinArg, double protectionAccountEquityMinArg,
    double protectionMaxLeverageAllowedArg, double protectionMaxDrawdownAllowedArg, int protectionMaxLosingOrdersInARowArg, datetime calculateDrawdownFromArg,
    int magicNumberToCheckArg,   string currencyToCheckArg,   bool displayAllInformationsArg,
   bool deleteCurrentEAArg,   bool closeMetatraderArg,
    bool allowClosingPositionsArg,   bool alertAtEachNbrLotsArg,   bool alertAtEachNbrOrdersArg,   bool alertAtEachNbrPourcentEquityLossArg,
    bool alertAtEachNbrLeverageLevelArg,  bool alertAtEachNbrLosingOrdersArg, bool alertOnNewMaxValueArg, double alertNumberOfLotsValueArg,
    int alertNumberOfOrdersValueArg, double alertEquityLossValueArg, double alertLeverageValueArg, int alertLosingStreakValueArg,
    int nbrMinutesInfoResfreshingArg, bool hideAllBehindArg, ClosingModeEnum closingModeArg,
    ExecutionModeEnum executionModeArg, bool pushNotificationArg, bool emailNotificationArg, bool alertNotificationArg, bool closeAutoTradingArg){
      this.buySell = new BuySell(false, true, true);
      this.orderUtils = new OrderUtils();
      this.displayUtils = new DisplayUtils();
      this.notificationUtils = new NotificationUtils();

      this.protectionPourcentEquityLossMax = protectionPourcentEquityLossMaxArg;
      this.protectionAccountTP = protectionAccountTPArg;
      this.protectionMaxNbLotsAllowed = protectionMaxNbLotsAllowedArg;
      this.protectionMaxNbrOrdersAllowed = protectionMaxNbrOrdersAllowedArg;
      this.protectionAccountBalanceMin = protectionAccountBalanceMinArg;
      this.protectionAccountEquityMin = protectionAccountEquityMinArg;
      this.protectionMaxLeverageAllowed = protectionMaxLeverageAllowedArg;
      this.protectionMaxDrawdownAllowed = protectionMaxDrawdownAllowedArg;
      this.protectionMaxLosingOrdersInARow = protectionMaxLosingOrdersInARowArg;
      this.calculateDrawdownFrom = calculateDrawdownFromArg;
      this.magicNumberToCheck = magicNumberToCheckArg;
      this.currencyToCheck = currencyToCheckArg;
      this.displayAllInformations = displayAllInformationsArg;
      this.deleteCurrentEA = deleteCurrentEAArg;
      this.closeMetatrader = closeMetatraderArg;
      this.allowClosingPositions = allowClosingPositionsArg;
      this.alertAtEachNbrLots = alertAtEachNbrLotsArg;
      this.alertAtEachNbrOrders = alertAtEachNbrOrdersArg;
      this.alertAtEachNbrPourcentEquityLoss = alertAtEachNbrPourcentEquityLossArg;
      this.alertAtEachNbrLeverageLevel = alertAtEachNbrLeverageLevelArg;
      this.alertAtEachNbrLosingOrders = alertAtEachNbrLosingOrdersArg;
      this.alertOnNewMaxValue = alertOnNewMaxValueArg;

      this.alertNumberOfOrdersValue = alertNumberOfOrdersValueArg;
      this.alertNumberOfLotsValue = alertNumberOfLotsValueArg;
      this.alertLeverageValue = alertLeverageValueArg;
      this.alertLosingStreakValue = alertLosingStreakValueArg;
      this.alertEquityLossValue = alertEquityLossValueArg;

      this.nbrMinutesInfoResfreshing = nbrMinutesInfoResfreshingArg;

      this.initialYLine = Y_INITIAL_LINE;

      this.separator = this.getSeparator();

      this.hideAllBehind = hideAllBehindArg;

      this.closingMode = closingModeArg;

      this.executionMode = executionModeArg;

      this.pushNotification  = pushNotificationArg;
      this.emailNotification = emailNotificationArg;
      this.alertNotification = alertNotificationArg;

      this.stopTryingToClose = false;

      this.closeAutoTrading = closeAutoTradingArg;

      windowsTitle = TITLE;
      useTypeMode = OutsideAnotherEA;

      boxX = BOX_X;
      boxY = BOX_Y;
      boxLength = BOX_LENGTH;
      boxHeight = BOX_HEIGHT;

      this.initCommunication();
  }

  void init(bool openWindowReducedArg){
    this.init(openWindowReducedArg, TITLE, OutsideAnotherEA);
  }

  void init(bool openWindowReducedArg, string windowsTitleArg, UseTypeEnum useTypeEnumArg){
    initDone = false;
    this.initAccountInformations();

    this.windowsTitle = windowsTitleArg;
    this.useTypeMode = useTypeEnumArg;

    if(this.useTypeMode == InsideAnotherGridEA){
      boxX = 10;
      boxY = 18;
      boxLength = 500;
      boxHeight = 450;
    }

    if(displayAllInformations == true) {
      this.displayUtils.ChartForegroundSet(false, 0);
      if(this.hideAllBehind){
        this.hideAllBehing();
      }
      if(!openWindowReducedArg){
        this.openWindow();
      } else {
        this.closeWindow();
      }
    }
    initDone = true;
  }

  void deinit(){
    delete buySell;
    delete orderUtils;
    delete displayUtils;
    delete notificationUtils;
    //ObjectsDeleteAll();
    this.deleteAllSecurityObjects();
    if(this.communicationOneToOneUtils != NULL) {
      this.communicationOneToOneUtils.deinitCommunications();
    }
    if(this.checkCommunication != NULL) {
      this.checkCommunication.deinitCommunications();
    }
  }

  void displayAccountInformations(){
    if(displayAllInformations == true && isWindowOpen == true) {
      this.checkCommunicationWorking();
      this.updateAccountInformations();
      this.updateVisualObjects();
    }
  }

  void checkAndSecureAccount(){
    this.checkCommunicationWorking();
    this.updateAccountInformations();
    this.checkIfClosingNecessary();
    this.manageAlerts();
  }

  void checkAndDisplayAlerts(){
    this.updateAccountInformations();
    this.manageAlerts();
  }

  void checkIfClosingNecessary(){

    if(executionMode != Slave) {
      if(allowClosingPositions == true && stopTryingToClose == false) {


        bool closePositions = false;

        if((protectionPourcentEquityLossMax != 0 && (protectionPourcentEquityLossMax < equityLossGainPourcent))
        || (protectionAccountTP != 0 && (protectionAccountTP < accountBalance))
        || (protectionMaxNbLotsAllowed != 0 && (protectionMaxNbLotsAllowed < accountNumberOfLots))
        || (protectionMaxNbrOrdersAllowed != 0 && (protectionMaxNbrOrdersAllowed < accountNumberOfPositions))
        || (protectionAccountBalanceMin != 0 && (protectionAccountBalanceMin >= accountBalance))
        || (protectionAccountEquityMin != 0 && (protectionAccountEquityMin >= accountEquity))
        || (protectionMaxLeverageAllowed != 0 && (protectionMaxLeverageAllowed < currentAccountLeverage))
        || (protectionMaxDrawdownAllowed != 0 && (protectionMaxDrawdownAllowed < currentAccountDrawdownPourcent))
        || (protectionMaxLosingOrdersInARow != 0 && (protectionMaxLosingOrdersInARow < nbrLosingOrdersInARow))
      ) {
        closePositions = true;
      }

      if(closePositions == true){

        bool communicationOk = true;
        if(executionMode == Master) {
          //Ask to close Metatrader
          this.communicationOneToOneUtils.sendMessage(COMMAND_CLOSE_MT);
          Sleep(200);
        }

        this.closeAllOrder();
        this.enableDisableAutoTrading();
        this.updateNumberPositionsAndLots();

        int nbrTries = 3;
        if(closingSelectionUsed == 0) {
          while(accountNumberOfPositions > 0 && --nbrTries > 0) {
            this.enableDisableAutoTrading();
            this.closeAllOrder();
            this.enableDisableAutoTrading();
            this.updateNumberPositionsAndLots();
          }
        } else if(closingSelectionUsed == 1) {
          while(eaNumberOfPosisions > 0 && --nbrTries > 0) {
            this.enableDisableAutoTrading();
            this.closeAllOrder();
            this.enableDisableAutoTrading();
            this.updateNumberPositionsAndLots();
          }
        } else if(closingSelectionUsed == 2) {
          while(currencyNumberOfPositions > 0 && --nbrTries > 0) {
            this.enableDisableAutoTrading();
            this.closeAllOrder();
            this.enableDisableAutoTrading();
            this.updateNumberPositionsAndLots();
          }
        } else if(closingSelectionUsed == 3) {
          while(eaNumberOfPosisions + currencyNumberOfPositions > 0 && --nbrTries > 0) {
            this.enableDisableAutoTrading();
            this.closeAllOrder();
            this.enableDisableAutoTrading();
            this.updateNumberPositionsAndLots();
          }
        }

        if(nbrTries == 0){
          notification("Error when trying to close all orders or EA open other orders at the same time. "+GetLastError());
        } else {
          notification("IMPORTANT - All orders has been closed by EA");
        }

        if(executionMode == Standalone) {
          if(deleteCurrentEA){
            deleteEa();
          }

          if(closeMetatrader){
            closeMetatraderTask();
          }
        }
        stopTryingToClose = true;
      }

    }
  } else {
    //slave mode - Close metatrader
    string message = this.communicationOneToOneUtils.receiveMessage();
    if(message != NULL) {
      Print("SLAVE COMMUNICATION : "+message);
    }
    if(message != NULL && StringCompare(message, COMMAND_CLOSE_MT) == 0){
      closeMetatraderTask();
    }
  }
}

  void closeAllOrder(){
    if(closingSelectionUsed == 0) {
      buySell.closeAllOpenOrdersForAllCurrencies();
    } else if(closingSelectionUsed == 1) {
      buySell.closeAllOpenOrdersForAllCurrencies(magicNumberToCheck);
    } else if(closingSelectionUsed == 2) {
      buySell.closeAllOpenOrdersForSpecificCurrency(currencyToCheck);
    } else if(closingSelectionUsed == 3) {
      buySell.closeAllOpenOrdersForSpecificCurrency(currencyToCheck, magicNumberToCheck);
    }
  }

  void deleteEa(){
    ExpertRemove();
  }

  void enableDisableAutoTrading() {
    if(this.closeAutoTrading) {
      int main = GetAncestor(WindowHandle(Symbol(), Period()), 2/*GA_ROOT*/);
      PostMessageA(main, WM_COMMAND,  MT4_WMCMD_EXPERTS, 0 ) ;
    }
  }

  void EneableDisableEAMethod2(){
    keybd_event(17, 0, 0, 0);
    keybd_event(69, 0, 0, 0);
    keybd_event(69, 0, 2, 0);
    keybd_event(17, 0, 2, 0);
  }

  void closeMetatraderTask(){
    PostMessageA(GetParent(GetParent(GetParent(WindowHandle(Symbol(), Period())))), WM_CLOSE, 0, 0);
  }

  int getNbrMinutesInfoResfreshing(){
    return nbrMinutesInfoResfreshing;
  }

  void OnChartEvent(const int id,
    const long &lparam,
    const double &dparam,
    const string &sparam)
    {
      if(id==CHARTEVENT_OBJECT_CLICK)
      {
        if(sparam=="openCloseButton")
        {
          if(displayAllInformations == true){
            if(isWindowOpen == true){
              closeWindow();
            } else {
              openWindow();
            }
          }
        }
        if(sparam=="closeAllButton")
        {
          int messageBoxChoice = MessageBox("Are you sure you want to close all orders ?"
          +"\n\nCurrency : " + string(currencyToCheck == NULL ? "All Currencies" : currencyToCheck)
          +"\nMagic Number : " + string(magicNumberToCheck == 0 ? "Not specified" : magicNumberToCheck)
          ,"Confirmation", MB_YESNO);
          if(messageBoxChoice == IDYES){
            buySell.closeAllOpenOrdersForSpecificCurrency(currencyToCheck, magicNumberToCheck);
          }
        }
      }
    }

};

#include "../List/ElementList.mqh"

class OrderElt  : public ElementList {

  private :

  int OrderTicketValue;
  int ProcessAction;
  string Instrument;
  double EntryPrice;
  double StopLossPrice;
  double TakeProfitPrice;
  double QuantityMultiplier;
  int BuySellType;
  int Channel;
  int magicNumberForOrder;
  double Pourcent80Price;
  double Pourcent10Price;
  bool isProtectionHasBeenActivated;
  bool orderOnMarket;

  public :

  virtual string getId(){
    return string(OrderTicketValue);
  }

  OrderElt(int OrderTicketValueArg,
    int ProcessActionArg,
    string InstrumentArg,
    double EntryPriceArg,
    double StopLossPriceArg,
    double TakeProfitPriceArg){
      this.OrderTicketValue = OrderTicketValueArg;
      this.ProcessAction =ProcessActionArg;
      this.Instrument = InstrumentArg;
      this.EntryPrice = EntryPriceArg;
      this.StopLossPrice = StopLossPriceArg;
      this.TakeProfitPrice = TakeProfitPriceArg;
      this.isProtectionHasBeenActivated = false;
  }

  OrderElt(
          int OrderTicketValueArg,
          int ProcessActionArg,
          string InstrumentArg,
          double EntryPriceArg,
          double StopLossPriceArg,
          double TakeProfitPriceArg,
          double QuantityMultiplierArg,
          int BuySellTypeArg,
          int ChannelArg,
          int magicNumberForOrderArg){
    this.OrderTicketValue = OrderTicketValueArg;
    this.ProcessAction =ProcessActionArg;
    this.Instrument = InstrumentArg;
    this.EntryPrice = EntryPriceArg;
    this.StopLossPrice = StopLossPriceArg;
    this.TakeProfitPrice = TakeProfitPriceArg;
    this.QuantityMultiplier = QuantityMultiplierArg;
    this.BuySellType = BuySellTypeArg;
    this.Channel = ChannelArg;
    this.magicNumberForOrder = magicNumberForOrderArg;
    this.isProtectionHasBeenActivated = false;

    if(this.BuySellType == 0){
      this.orderOnMarket = true;
    } else {
      this.orderOnMarket = false;
    }

    if(StopLossPrice != 0 && TakeProfitPrice != 0 && EntryPrice != 0){
      if(ProcessActionArg == 1 && TakeProfitPrice > EntryPrice && EntryPrice > StopLossPrice) { //Buy
        Pourcent80Price = EntryPrice + ((TakeProfitPrice - EntryPrice) * 0.8);
        Pourcent10Price = EntryPrice + ((TakeProfitPrice - EntryPrice) * 0.1);
      } else if(ProcessActionArg == 2 && TakeProfitPrice < EntryPrice && EntryPrice < StopLossPrice) { // Vente
        Pourcent80Price = EntryPrice - ((EntryPrice - TakeProfitPrice) * 0.8);
        Pourcent10Price = EntryPrice - ((EntryPrice - TakeProfitPrice) * 0.1);
      }
    }
  }

  bool isOrderOnMarket(){
    return this.orderOnMarket;
  }

  void setOrderOnMarket(bool orderOnMarketArg){
    this.orderOnMarket = orderOnMarketArg;
  }

  bool hasProtectionBeenActivated(){
    return this.isProtectionHasBeenActivated;
  }

  void setProtectionHasBeenActivated(bool activation){
    this.isProtectionHasBeenActivated = activation;
  }

  int getOrderTicketValue(){
    return OrderTicketValue;
  }

  int getProcessAction(){
    return ProcessAction;
  }

  string getInstrument(){
    return Instrument;
  }

  double getEntryPrice(){
    return EntryPrice;
  }

  double getStopLossPrice(){
    return StopLossPrice;
  }

  double getTakeProfitPrice(){
    return TakeProfitPrice;
  }

  double getQuantityMultiplier(){
    return QuantityMultiplier;
  }

  int getBuySellType(){
    return BuySellType;
  }

  int getChannel(){
    return Channel;
  }

  int getMagicNumberForOrder(){
    return magicNumberForOrder;
  }

  double getPourcent80Price(){
    return Pourcent80Price;
  }

  double getPourcent10Price(){
    return Pourcent10Price;
  }

  void setOrderTicketValue(int OrderTicketValueArg){
    OrderTicketValue = OrderTicketValueArg;
  }

  void setProcessAction(int ProcessActionArg){
    ProcessAction = ProcessActionArg;
  }

  void setInstrument(string InstrumentArg){
    Instrument = InstrumentArg;
  }

  void setEntryPrice(double EntryPriceArg){
    EntryPrice = EntryPriceArg;
  }

  void setStopLossPrice(double StopLossPriceArg){
    StopLossPrice = StopLossPriceArg;
  }

  void setTakeProfitPrice(double TakeProfitPriceArg){
    TakeProfitPrice = TakeProfitPriceArg;
  }

  void setQuantityMultiplier(double QuantityMultiplierArg){
    QuantityMultiplier = QuantityMultiplierArg;
  }

  void setBuySellType(int BuySellTypeArg){
    BuySellType = BuySellTypeArg;
  }

  void setChannel(int ChannelArg){
    Channel = ChannelArg;
  }

  void setMagicNumberForOrder(int magicNumberForOrderArg){
    magicNumberForOrder = magicNumberForOrderArg;
  }

  void setPourcent80Price(double Pourcent80PriceArg){
    Pourcent80Price = Pourcent80PriceArg;
  }

  void setPourcent10Price(double Pourcent10PriceArg){
    Pourcent10Price = Pourcent10PriceArg;
  }

};

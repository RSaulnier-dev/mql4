class FixedRatioElement {

  protected :

  double balance;
  double lot;
  double maxLoss;
  double riskInPourcent;

  public :

  FixedRatioElement(double balanceArg, double lotArg, double maxLossArg){
    this.balance = balanceArg;
    this.lot = lotArg;
    this.maxLoss = maxLossArg;
    this.riskInPourcent = (this.maxLoss * 100) / this.balance;
  }

  string getElementStr(){
    return "Balance : "+string(this.getBalance()) + " - Lot : "+string(this.getLot())+" - Max Loss : "+string(this.getMaxLoss())+" - Risk in pourcent : "+string(this.getRisk());
  }

  double getBalance(){
    return NormalizeDouble(this.balance,5);
  }

  void setBalance(double balanceArg){
    this.balance = balanceArg;
  }

  double getLot(){
    return NormalizeDouble(this.lot,2);
  }

  void setLot(double lotArg){
    this.lot = lotArg;
  }

  double getMaxLoss(){
    return NormalizeDouble(this.maxLoss,5);
  }

  void setMaxLoss(double maxLossArg){
    this.maxLoss = maxLossArg;
  }

  double getRisk(){
    return NormalizeDouble(riskInPourcent,2);
  }
};

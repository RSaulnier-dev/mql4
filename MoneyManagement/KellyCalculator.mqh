class KellyCalculator {

  public :

  static double calculateRisk(double takeProfitInPipsArg, double stopLossInPipsArg, double winningChanceArg){

    double payoutOnBet = takeProfitInPipsArg / stopLossInPipsArg;

    return ((winningChanceArg * payoutOnBet) - (1 - winningChanceArg)) / (payoutOnBet);
  }

  static double getHalfKelly(double takeProfitInPipsArg, double stopLossInPipsArg, double winningChanceArg){
    return calculateRisk(takeProfitInPipsArg, stopLossInPipsArg, winningChanceArg) / 2;
  }

};

#include "TrailingStopLossStrategy.mqh"

class NoStopLossStrategy : public TrailingStopLossStrategy {

  public :

  NoStopLossStrategy(){
  }

  virtual bool update(int ticket){
    //do nothing
    return true;
  }

};

#include <Strategy/Utils/OrderUtils.mqh>
#include <Strategy/Grid/GridBasket.mqh>
#include <Strategy/Grid/GridCoverTypeDefinition.mqh>

#ifndef HEADER3_H
#define HEADER3_H
class GridBasket;

class GridCoverStrategy {

  protected :

  GridBasket *gridBasket;
  OrderUtils *orderUtils;

  public :

  GridCoverStrategy(){
  }

  void setValues(GridBasket *GridBasketArg){
    gridBasket = GridBasketArg;
    orderUtils = new OrderUtils();
  }

  void release(){
    orderUtils.release();
    delete orderUtils;
  }

  virtual bool isClassicTrailingCoverStop(){return true;};
  virtual bool isGridSystemTrailingCoverStop(){return false;};
  virtual bool isNonStopEdging(){return false;};
  virtual bool closeOnNewOrder(){return false;};
  virtual bool isTrailingAction(){return true;};
  virtual bool isBreakHeavenAction(){return false;};
  virtual double getNbrLots(){return 0;};
  virtual double getStopLoss(){return 0;};
  virtual double getTakeProfit(){return 0;};
  virtual bool displayTP(){return true;};
  virtual double getNextCoverOrderLevel(){return 0;};
  virtual double getCurrentCoverOrderLevel(){return 0;};
  virtual int getNbrOrdersForStartingCover(){return 9999;};
  virtual bool calculateTrendAfterFirstOrder(){return false;};

  double getDefaultNbrLots(){
    double nbrLots = 0;

    if(gridBasket.getCoverLotCalulation() == nbrLotsLastPosition){
      nbrLots = gridBasket.getLastOrderNbrLots() / gridBasket.getCoverOrdersQuantityRatio();
    } else if(gridBasket.getCoverLotCalulation() == NbrLotsInBasket){
      nbrLots = gridBasket.getNbrLotsInThisBasket() / gridBasket.getCoverOrdersQuantityRatio();
    }

    return nbrLots;
  }

  virtual GridCoverType getCoverType(){return Type1;};
};


#endif

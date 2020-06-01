
#include <Strategy/Grid/GridCoverStrategy.mqh>
#include <Strategy/Grid/GridCoverStrategyType1.mqh>
#include <Strategy/Grid/GridCoverStrategyType2.mqh>
#include <Strategy/Grid/GridCoverStrategyType3.mqh>
#include <Strategy/Grid/GridCoverStrategyType4.mqh>
#include <Strategy/Grid/GridCoverStrategyType5.mqh>
#include <Strategy/Grid/GridCoverStrategyType6.mqh>
#include <Strategy/Grid/GridCoverStrategyType7.mqh>
#include <Strategy/Grid/GridCoverStrategyType8.mqh>
#include <Strategy/Grid/GridBasket.mqh>
#include <Strategy/Grid/GridCoverTypeDefinition.mqh>


// #ifndef HEADER2_H
// #define HEADER2_H
// class GridBasket;

class GridCoverStrategyFactory {

  public :

  static GridCoverStrategy *getCoverStrategy(GridCoverType coverTypeArg, GridBasket *GridBasketArg){

    GridCoverStrategy *gridCoverStrategyToCreate;
    if(coverTypeArg == Type1){
      gridCoverStrategyToCreate = new GridCoverStrategyType1();
    } else if(coverTypeArg == Type2){
      gridCoverStrategyToCreate = new GridCoverStrategyType2();
    } else if(coverTypeArg == Type3){
      gridCoverStrategyToCreate = new GridCoverStrategyType3();
    } else if(coverTypeArg == Type4){
      gridCoverStrategyToCreate = new GridCoverStrategyType4();
    } else if(coverTypeArg == Type5){
      gridCoverStrategyToCreate = new GridCoverStrategyType5();
    } else if(coverTypeArg == Type6){
      gridCoverStrategyToCreate = new GridCoverStrategyType6();
    } else if(coverTypeArg == Type7){
      gridCoverStrategyToCreate = new GridCoverStrategyType7();
    } else if(coverTypeArg == Type8){
      gridCoverStrategyToCreate = new GridCoverStrategyType8();
    }
    gridCoverStrategyToCreate.setValues(GridBasketArg);

    return gridCoverStrategyToCreate;
  }

};

// #endif

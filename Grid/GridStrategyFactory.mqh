#include <Strategy/Grid/GridStrategy.mqh>
#include <Strategy/Grid/GridStrategyNonStopEdging.mqh>
#include <Strategy/Grid/GridStrategyNonStopEdging2.mqh>
#include <Strategy/Grid/GridStrategyNonStopEdging3.mqh>
#include <Strategy/Grid/GridStrategyNonStopEdging4.mqh>
#include <Strategy/Grid/GridStrategyNonStopEdging5.mqh>
#include <Strategy/Grid/GridStrategyWavePicky.mqh>
#include <Strategy/Grid/GridStrategyWavePickyWithCover.mqh>
#include <Strategy/Grid/GridStrategyBands.mqh>
#include <Strategy/Grid/GridStrategyBandsAgressive.mqh>
#include <Strategy/Grid/GridStrategyCoverWinner.mqh>
#include <Strategy/Grid/GridStrategyWavePickyMixedWithCoverWinner.mqh>
#include <Strategy/Grid/GridStrategyDiamond.mqh>
#include <Strategy/Grid/GridStrategyDiamondFiltered.mqh>
#include <Strategy/Grid/GridStrategyHedgingSystem.mqh>
#include <Strategy/Grid/GridStrategyAIzig.mqh>
#include <Strategy/Grid/GridStrategyWavePicky_M15.mqh>
#include <Strategy/Grid/GridStrategyPlatinium.mqh>
//#include <Strategy/Grid/GridStrategyInfiniteTrandLine2.mqh>
//#include <Strategy/Grid/GridStrategyUnsustainable.mqh>

class GridStrategyFactory  {

  public :

  enum GridStrategyType {
    GridNonStopEdgingStrategyType = 0,
    GridWavePickyStrategyType = 1,
    GridStrategyBandsType = 2,
    GridStrategyBandsAgressiveType = 3,
    GridStrategyWavePickyWithCoverType = 4,
    GridStrategyCoverWinnerType = 5,
    GridStrategyWavePickyMixedWithCoverWinnerType = 6,
    GridStrategyInfiniteTrandLineType = 7,
    GridStrategyInfiniteTrandLineType2 = 8,
    GridStrategyDiamondType = 9,
    GridStrategyDiamondFilteredType = 10,
    GridNonStopEdgingStrategyType2 = 11,
    GridNonStopEdgingStrategyType3 = 12,
    GridStrategyHedgingSystemType = 13,
    GridNonStopEdgingStrategyType4 = 14,
    GridStrategyAIzigType = 15,
    GridStrategyWavePicky_M15Type = 16,
    GridStrategyPlatiniumType = 17,
    GridNonStopEdgingStrategyType5 = 18,
    //GridStrategyUnsustainableType = 4,
  };

  static GridStrategy *createGridStrategy(GridStrategyType gridStrategyTypeArg){

    if(gridStrategyTypeArg == GridNonStopEdgingStrategyType){
      return new GridStrategyNonStopEdging();
    } else if(gridStrategyTypeArg == GridNonStopEdgingStrategyType2){
      return new GridStrategyNonStopEdging2();
    } else if(gridStrategyTypeArg == GridNonStopEdgingStrategyType3){
      return new GridStrategyNonStopEdging3();
    } else if(gridStrategyTypeArg == GridNonStopEdgingStrategyType4){
      return new GridStrategyNonStopEdging4();
    } else if(gridStrategyTypeArg == GridNonStopEdgingStrategyType5){
      return new GridStrategyNonStopEdging5();
    } else if(gridStrategyTypeArg == GridWavePickyStrategyType){
      return new GridStrategyWavePicky();
    } else if(gridStrategyTypeArg == GridStrategyBandsType){
      return new GridStrategyBands();
    } else if(gridStrategyTypeArg == GridStrategyBandsAgressiveType){
      return new GridStrategyBandsAgressive();
    } else if(gridStrategyTypeArg == GridStrategyWavePickyWithCoverType){
      return new GridStrategyWavePickyWithCover();
    } else if(gridStrategyTypeArg == GridStrategyCoverWinnerType){
      return new GridStrategyCoverWinner();
    } else if(gridStrategyTypeArg == GridStrategyWavePickyMixedWithCoverWinnerType){
      return new GridStrategyWavePickyMixedWithCoverWinner();
    } else if(gridStrategyTypeArg == GridStrategyDiamondType){
      return new GridStrategyDiamond();
    } else if(gridStrategyTypeArg == GridStrategyDiamondFilteredType){
      return new GridStrategyDiamondFiltered();
    } else if(gridStrategyTypeArg == GridStrategyHedgingSystemType){
      return new GridStrategyHedgingSystem();
    } else if(gridStrategyTypeArg == GridStrategyAIzigType){
      return new GridStrategyAIzig();
    } else if(gridStrategyTypeArg == GridStrategyWavePicky_M15Type){
      return new GridStrategyWavePicky_M15();
    } else if(gridStrategyTypeArg == GridStrategyPlatiniumType){
      return new GridStrategyPlatinium();
    }
    // else if(gridStrategyTypeArg == GridStrategyInfiniteTrandLineType2){
    //   return new GridStrategyInfiniteTrandLine2();
    // }
    // else if(gridStrategyTypeArg == GridStrategyUnsustainableType){
    //   return new GridStrategyUnsustainable();
    // }

    return NULL;
  }

};

#include <stdlib.mqh>

static bool isDebugActivated = true;

class ErrorUtils {

  public :

  bool displayAlert;
  bool displayPrinf;
  bool displayNotification;

  ErrorUtils(){
    displayAlert = true;
    displayPrinf = true;
    displayNotification = true;
  }

  ErrorUtils(bool displayAlertArg, bool displayPrinfArg) {
    displayAlert = displayAlertArg;
    displayPrinf = displayPrinfArg;
    displayNotification = false;
  }

  ErrorUtils(bool displayAlertArg, bool displayPrinfArg, bool displayNotificationArg) {
    displayAlert = displayAlertArg;
    displayPrinf = displayPrinfArg;
    displayNotification = displayNotificationArg;
    displayNotification = false;
  }

  void displayError(int noError, string msg){
    string errorDefinition = ErrorDescription(noError);
    string currentTime = string(CurTime());
    if(displayAlert){
      Alert(currentTime+" - "+msg);
      Alert(currentTime+" - "+"no Error : "+string(noError)+" - Definition : "+errorDefinition);
    }
    if(displayPrinf){
      printf(currentTime+" - "+msg+" - no Error : "+string(noError)+" - Definition : "+errorDefinition);
    }
    if(displayNotification){
      SendNotification(currentTime+" - "+msg+" - no Error : "+string(noError)+" - Definition : "+errorDefinition);
    }
  }

  void displayError(string msg){
    string currentTime = string(CurTime());
    if(displayAlert){
      Alert(currentTime+" - "+msg);
    }
    if(displayPrinf){
      printf(currentTime+" - "+msg);
    }
    if(displayNotification){
      SendNotification(currentTime+" - "+msg);
    }
  }

  void printDebug(string info, double value){
    if(isDebugActivated){
      printf("----- DEBUG ----- "+info+" - "+string(value));
    }
  }

  void printDebug(string info, string value){
    if(isDebugActivated){
      printf("----- DEBUG ----- "+info+" - "+value);
    }
  }

  void printDebug(string info, int value){
    if(isDebugActivated){
      printf("----- DEBUG ----- "+info+" - "+string(value));
    }
  }

};

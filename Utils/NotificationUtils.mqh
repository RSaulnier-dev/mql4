class NotificationUtils {

  public :

  void sendNotification(string message, bool push, bool email, bool alert){
    printf("NotificationUtils - sendNotification : "+message);
    if(push == true){
      SendNotification(message);
    }

    if(email == true){
      SendMail("MetaTrader Email Notification", message);
    }

    if(alert == true){
      Alert(message);
    }
  }

};

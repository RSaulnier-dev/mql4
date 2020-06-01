#include "./NotificationUtils.mqh"

#import "FXBlueQuickChannel.dll"
int QC_StartSenderW(string);
int QC_ReleaseSender(int);
int QC_SendMessageW(int, string, int);
int QC_StartReceiverW(string, int);
int QC_ReleaseReceiver(int);
int QC_GetMessages5W(int, uchar&[], int);
int QC_CheckChannelW(string);
int QC_ChannelHasReceiverW(string);
#import

enum ClientIdentificationEnum {
  Client1 = 1,
  Client2 = 2,
};

#define CHANNEL_1_TO_2_NAME "CHANNEL1"
#define CHANNEL_2_TO_1_NAME "CHANNEL2"
#define QC_BUFFER_SIZE 10000

class CommunicationOneToOneUtils {

  private :

  string channelForSending;
  string channelForReceiving;

  int glbHandle;
  int glbHandleClient;
  uchar glbBuffer[];

  string cannalName;

  NotificationUtils *notificationUtils;

  public :

  CommunicationOneToOneUtils(ClientIdentificationEnum clientIdentification, string idCanal){
    glbHandle = 0;
    glbHandleClient = 0;

    notificationUtils = new NotificationUtils();

    if(clientIdentification == Client1) {
      channelForSending = CHANNEL_1_TO_2_NAME+idCanal;
      channelForReceiving = CHANNEL_2_TO_1_NAME+idCanal;
    } else if(clientIdentification == Client2) {
      channelForSending = CHANNEL_2_TO_1_NAME+idCanal;
      channelForReceiving = CHANNEL_1_TO_2_NAME+idCanal;
    }
  }

  void deinitCommunications(){
      if(glbHandle) {
        QC_ReleaseSender(glbHandle);
      }

      if (glbHandleClient) {
        QC_ReleaseReceiver(glbHandleClient);
      }
      glbHandle = 0;
      glbHandleClient = 0;
  }

  void sendMessage(string msg){
    if(!glbHandle) {
      glbHandle = QC_StartSenderW(channelForSending);
    }

    //Print("Sending "+msg+" on channel "+channelForSending+" with glhandle = "+string(glbHandle));
    if (!QC_SendMessageW(glbHandle, msg , 3)) {
      notificationUtils.sendNotification("Remote message sender : Message failed - "+msg, true, false, true);
    }
  }

  string receiveMessage(){
    string messageReceived;

    if (!glbHandleClient) {
        glbHandleClient = QC_StartReceiverW(channelForReceiving, WindowHandle(Symbol(), Period()));
        ArrayResize(glbBuffer, QC_BUFFER_SIZE);
    }

    if (glbHandleClient) {
      int nbrCharactersInMessageReceived = QC_GetMessages5W(glbHandleClient, glbBuffer, QC_BUFFER_SIZE);
      if (nbrCharactersInMessageReceived > 0) {
        messageReceived = CharArrayToString(glbBuffer, 0, nbrCharactersInMessageReceived);
        //Print("Receive message "+messageReceived+" with nb char = "+string(nbrCharactersInMessageReceived));
      }
    } else {
      notificationUtils.sendNotification("Local message receiver : No handle", true, false, true);
    }

    return messageReceived;
  }

};

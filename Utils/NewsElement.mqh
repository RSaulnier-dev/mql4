class NewsElement {

  protected :


  datetime timeEvent;
  int offSetGMTInHour;
  string currency;
  string typeAndComment;

  public :

  NewsElement(string currencyArg, datetime timeEventArg, int offSetGMTInHourArg, string typeAndCommentArg){
    this.currency = currencyArg;
    this.offSetGMTInHour = offSetGMTInHourArg;
    this.timeEvent = timeEventArg;
    this.typeAndComment = typeAndCommentArg;
  }

  datetime  getTimeEvent(){
    return timeEvent;
  }

  int       getOffSetGMTInHour(){
    return offSetGMTInHour;
  }

  string    getCurrency(){
    return currency;
  }

  string    getTypeAndComment(){
    return typeAndComment;
  }

};

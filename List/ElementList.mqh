class ElementList {

  private :

  ElementList *next;
  ElementList *previous;

  public :

  ElementList(){
    next = NULL;
    previous = NULL;
  }

  ElementList *getNext(){
    return next;
  }

  void setNext(ElementList *elementNextArg){
    next = elementNextArg;
  }

  ElementList *getPrevious(){
    return previous;
  }

  void setPrevious(ElementList *elementPreviousArg){
    previous = elementPreviousArg;
  }

  virtual string getId(){return "";};
  virtual void release(){return;};
};

#include <Strategy/List/ElementList.mqh>

#ifndef HEADER2_H
#define HEADER2_H
class ArrayList;

class Iterator {

  private :

  ElementList *currenElement;
  ElementList *listPointer;
  ArrayList *arrayList;


  public :

  Iterator(ElementList *listArg, ArrayList *arrayListArg){
    currenElement = NULL;
    listPointer = listArg;
    arrayList = arrayListArg;
  }

  bool hasNext(){
    bool hasNextElement = false;

    if(currenElement == NULL){
      if(listPointer != NULL && CheckPointer(listPointer) != POINTER_INVALID) {
        hasNextElement = true;
      }
    } else if(CheckPointer(listPointer) != POINTER_INVALID && CheckPointer(listPointer.getNext()) != POINTER_INVALID && listPointer != NULL && listPointer.getNext() != NULL){
        hasNextElement = true;
    }

    return hasNextElement;
  }

  ElementList *next(){
    ElementList *nextElement = NULL;

    if(currenElement == NULL){
      if(listPointer != NULL && CheckPointer(listPointer) != POINTER_INVALID) {
        currenElement = listPointer;
        listPointer = currenElement;
      }
    } else if(CheckPointer(listPointer) != POINTER_INVALID && CheckPointer(listPointer.getNext()) != POINTER_INVALID && listPointer != NULL && listPointer.getNext() != NULL){
        currenElement = listPointer.getNext();
        listPointer = currenElement;
    }

    return currenElement;
  }

  void removeCurrentElement(){
    ElementList *eltToDelete = NULL;
    if(currenElement != NULL && CheckPointer(currenElement) != POINTER_INVALID){
      if(CheckPointer(currenElement.getPrevious()) != POINTER_INVALID && currenElement.getPrevious() != NULL){
        eltToDelete = currenElement;
        currenElement = currenElement.getPrevious();
      } else if(CheckPointer(currenElement.getNext()) != POINTER_INVALID && currenElement.getNext() != NULL){
        eltToDelete = currenElement;
        currenElement = currenElement.getNext();
      } else {
        eltToDelete = currenElement;
        currenElement = NULL;
      }
      arrayList.remove(eltToDelete);
      //eltToDelete.release();
      //delete eltToDelete;
    }
  }

};

#endif

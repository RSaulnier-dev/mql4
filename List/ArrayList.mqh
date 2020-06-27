#include <Strategy/List/Iterator.mqh>
#include <Strategy/List/ElementList.mqh>

class ArrayList {

  private :

  ElementList *FirstElement;

  public :
  ArrayList(){
    FirstElement = NULL;
  }

  void add(ElementList *eltArg){
    ElementList *tempElt = FirstElement;

    if(CheckPointer(eltArg) != POINTER_INVALID){
      if(CheckPointer(tempElt) == POINTER_INVALID || tempElt == NULL){
        FirstElement = eltArg;
      } else {
        while(CheckPointer(tempElt) != POINTER_INVALID && CheckPointer(tempElt.getNext()) != POINTER_INVALID && tempElt.getNext() != NULL){
          tempElt = tempElt.getNext();
        }
        eltArg.setPrevious(tempElt);
        eltArg.setNext(tempElt.getNext());
        tempElt.setNext(eltArg);
      }
    }
  }

  void add(ElementList *eltArg, int positionArg){
    ElementList *tempElt = FirstElement;

    if(CheckPointer(eltArg) != POINTER_INVALID){
      if(CheckPointer(tempElt) == POINTER_INVALID || tempElt == NULL){
        FirstElement = eltArg;
      } else {
        int tmpPosition = 0;
        while(CheckPointer(tempElt) != POINTER_INVALID && CheckPointer(tempElt.getNext()) != POINTER_INVALID && tempElt.getNext() != NULL){
          if(tmpPosition == positionArg){
            break;
          }
          ++tmpPosition;
          tempElt = tempElt.getNext();
        }
        eltArg.setPrevious(tempElt);
        eltArg.setNext(tempElt.getNext());
        tempElt.setNext(eltArg);
      }
    }
  }

  Iterator *iterator(){
    Iterator *it = new Iterator(FirstElement, GetPointer(this));

    return it;
  }

  ElementList *get(int positionArg){
    ElementList *eltToReturn = NULL;
    int tmpPosition = 0;
    if(CheckPointer(FirstElement) != POINTER_INVALID && FirstElement != NULL){
      ElementList *tempElt = FirstElement;
      while(CheckPointer(tempElt) != POINTER_INVALID  && tempElt != NULL){
        if(positionArg == tmpPosition){
          eltToReturn = tempElt;
          break;
        }

        tempElt = tempElt.getNext();
        ++tmpPosition;
      }
    }

    return eltToReturn;
  }

  ElementList *get(string idEltArg){
    ElementList *eltToReturn = NULL;
    if(CheckPointer(FirstElement) != POINTER_INVALID && FirstElement != NULL && idEltArg != NULL){
      ElementList *tempElt = FirstElement;
      while(CheckPointer(tempElt) != POINTER_INVALID && tempElt != NULL){
        if(StringCompare(tempElt.getId(), idEltArg) == 0){
          eltToReturn = tempElt;
          break;
        }
        tempElt = tempElt.getNext();
      }
    }

    return eltToReturn;
  }

  bool isElementWithIdExist(string idEltArg){
    bool isExist = false;

    ElementList* elt = get(idEltArg);

    if(CheckPointer(elt) != POINTER_INVALID){
      isExist = true;
    } else {
      isExist = false;
    }

    return isExist;
  }

  void remove(string idEltArg){
    ElementList *eltToRemove = get(idEltArg);
    rebranchElements(eltToRemove);
  }

  void remove(int positionArg){
    ElementList *eltToRemove = get(positionArg);
    rebranchElements(eltToRemove);
  }

  void remove(ElementList *eltArg){
    rebranchElements(eltArg);
  }

  int size(){
    int nbrElement = 0;
    if(CheckPointer(FirstElement) != POINTER_INVALID && FirstElement != NULL){
      ElementList *tempElt = FirstElement;
      ++nbrElement;
      while(CheckPointer(tempElt.getNext()) != POINTER_INVALID && tempElt.getNext() != NULL){
        tempElt = tempElt.getNext();
        ++nbrElement;
      }
    }

    return nbrElement;
  }

  void release(){
    if(CheckPointer(FirstElement) != POINTER_INVALID && FirstElement != NULL){
      ElementList *tempElt = FirstElement;
      while(CheckPointer(tempElt.getNext()) != POINTER_INVALID && tempElt.getNext() != NULL){
        tempElt = tempElt.getNext();
        delete(tempElt.getPrevious());
        tempElt.setPrevious(NULL);
      }
      delete tempElt;
      FirstElement = NULL;
    }
  }

  bool isEmpty(){
    bool empty = true;

    if(size() > 0){
      empty = false;
    }

    return empty;
  }

  void display(){
    int nbrElement = 0;
    if(CheckPointer(FirstElement) != POINTER_INVALID && FirstElement != NULL){
      Print("------------------------------------");
      ElementList *tempElt = FirstElement;
      ++nbrElement;
      Print("Element no "+string(nbrElement)+" : "+tempElt.getId());
      while(CheckPointer(tempElt.getNext()) != POINTER_INVALID && tempElt.getNext() != NULL){
        tempElt = tempElt.getNext();
        ++nbrElement;
        Print("Element no "+string(nbrElement)+" : "+tempElt.getId());
      }
      Print("------------------------------------");
    }
  }

  private :

  void rebranchElements(ElementList *eltToRemove){
    if(CheckPointer(eltToRemove) != POINTER_INVALID && eltToRemove !=NULL){
      if(CheckPointer(eltToRemove.getPrevious()) != POINTER_INVALID && eltToRemove.getPrevious() != NULL){
        if(CheckPointer(eltToRemove.getNext()) != POINTER_INVALID && eltToRemove.getNext() != NULL){
          eltToRemove.getPrevious().setNext(eltToRemove.getNext());
          eltToRemove.getNext().setPrevious(eltToRemove.getPrevious());
        } else {
          eltToRemove.getPrevious().setNext(NULL);
        }
      } else {
        //First positionArg
        if(CheckPointer(eltToRemove.getNext()) != POINTER_INVALID && eltToRemove.getNext() != NULL){
          FirstElement = eltToRemove.getNext();
          FirstElement.setPrevious(NULL);
        } else {
          //EmptyList
          FirstElement = NULL;
        }
      }
      eltToRemove.release();
      delete eltToRemove;
    }
  }

};

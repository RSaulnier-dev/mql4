class GridBasketSignalStrategy {

    public :

    GridBasketSignalStrategy(){

    }

    virtual void onClosing(int orderTypeArg, int basketNumberArg, int strategyNumberArg, bool closedWhenReachMaxNbrOrderArg){return;};
    virtual void onAddNewOrder(int orderTypeArg, int basketNumberArg, int strategyNumberArg, double nbrLotsArg){return;};

    virtual bool isBuyingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return false;};
    virtual bool isSellingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return false;};
    virtual bool isClosingSignal(int orderTypeArg, int basketNumberArg, int strategyNumberArg){return false;};
    virtual bool isClosingCoverOrderSignal(int orderCoverTypeArg, int basketNumberArg, int strategyNumberArg){return false;};
};

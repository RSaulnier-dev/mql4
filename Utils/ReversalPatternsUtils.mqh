class ReversalPatterns {

  public :

    ReversalPatterns(){
    }

    bool isBullishInsideBar(int i){
      return isBullishCandle(i+1) && High[i+1] >= High[i] && Low[i+1] <= Low[i];
    }

    bool isBearishInsideBar(int i){
      return isBearishCandle(i+1) && High[i+1] >= High[i] && Low[i+1] <= Low[i];
    }

    bool isBullishHalfFormedInvertedHammerCAFPT(int i){
      return isBearishCandle(i+1)
            && getCandleSize(i) > 2 * getCandleBodySize(i)
            // && getUpWickSize(i) / getCandleBodySize(i) > 0.66;
            && ((High[i]-Close[i]) / (High[i]-Low[i])) > 0.66
            && ((High[i]-Open[i]) / (High[i]-Low[i])) > 0.66;
    }

    bool isBullishFullyFormedInvertedHammerCAFPT(int i){
      return isBearishCandle(i+2) && isBullishCandle(i)
            && getCandleSize(i+1) > 2 * getCandleBodySize(i+1)
            // && getUpWickSize(i+1) / getCandleBodySize(i+1) > 0.66;
            && ((High[i+1]-Close[i+1]) / (High[i+1]-Low[i+1])) > 0.66
            && ((High[i+1]-Open[i+1]) / (High[i+1]-Low[i+1])) > 0.66;
    }

    bool isBullishScalpingDoji(int i){
      return checkWicksNearlyEquals(i+1, 25) && getMaxWick(i+1)  >=  getCandleBodySize(i+1) * 2 && getMaxWick(i+1)  <=  getCandleBodySize(i+1) * 10
              && isBearishCandle(i+2) && isBullishCandle(i)
              && getUpWickSize(i) <=  getCandleBodySize(i) / 2 && getDownWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] > Open[i+2];
    }

    bool isBearishScalpingDoji(int i){
      return checkWicksNearlyEquals(i+1, 25) && getMaxWick(i+1)  >=  getCandleBodySize(i+1) * 2 && getMaxWick(i+1)  <=  getCandleBodySize(i+1) * 10
              && isBearishCandle(i) && isBullishCandle(i+2)
              && getDownWickSize(i) <=  getCandleBodySize(i) / 2 && getUpWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] < Open[i+2];
    }

    bool isBullishScalpingLightDoji(int i){
      return checkWicksNearlyEquals(i+1, 50) && getMaxWick(i+1)  >=  getCandleBodySize(i+1) && getMaxWick(i+1)  <=  getCandleBodySize(i+1) * 10
              && isBearishCandle(i+2) && isBullishCandle(i)
              && getUpWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] > Open[i+2];
    }

    bool isBearishScalpingLightDoji(int i){
      return checkWicksNearlyEquals(i+1, 50) && getMaxWick(i+1)  >=  getCandleBodySize(i+1) && getMaxWick(i+1)  <=  getCandleBodySize(i+1) * 10
              && isBearishCandle(i) && isBullishCandle(i+2)
              && getDownWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] < Open[i+2];
    }

    bool isBullishScalpingEngulfing(int i){

      double ma20Value = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);

      return isBullishCandle(i) && isBearishCandle(i+1)
              && Close[i] > Open[i+1] && Open[i] >= Close[i+1]
              && getCandleBodySize(i) >= getCandleBodySize(i+1)
              && getUpWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] >= ma20Value;    }

    bool isBearishScalpingEngulfing(int i){

      double ma20Value = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);

      return isBullishCandle(i+1) && isBearishCandle(i)
              && Close[i] < Open[i+1] && Open[i] <= Close[i+1]
              && getCandleBodySize(i) >= getCandleBodySize(i+1)
              && getDownWickSize(i) <=  getCandleBodySize(i) / 2
              && Close[i] <= ma20Value;
    }

    bool isBullishScalpingLightEngulfing(int i){

      double ma20Value = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);

      return isBullishCandle(i) && isBearishCandle(i+1)
              && Close[i] > Open[i+1]
              && getCandleBodySize(i) >= getCandleBodySize(i+1)
              && getUpWickSize(i) <=  getCandleBodySize(i)
              && Close[i] >= ma20Value;    }

    bool isBearishScalpingLightEngulfing(int i){

      double ma20Value = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);

      return isBullishCandle(i+1) && isBearishCandle(i)
              && Close[i] < Open[i+1]
              && getCandleBodySize(i) >= getCandleBodySize(i+1)
              && getDownWickSize(i) <=  getCandleBodySize(i)
              && Close[i] <= ma20Value;
    }

    bool isBullish3lb(int i){
      return isBearishCandle(i+3) && isBearishCandle(i+2) && isBearishCandle(i+1) && isBullishCandle(i) && Close[i] > High[i+3] && Close[i] > High[i+2] && Close[i] > High[i+1];
    }

    bool isBearish3lb(int i){
      return isBullishCandle(i+3) && isBullishCandle(i+2) && isBullishCandle(i+1) && isBearishCandle(i) && Close[i] < Low[i+3] && Close[i] < Low[i+2] && High[i] < Low[i+1];
    }

    bool isHarami(int i){
       return isBullishHarami(i) || isBearishHarami(i);
    }

    bool isBullishHarami(int i){
         return Open[i+1] > Close[i+1] && Close[i] > Open[i] && Close[i] <= Open[i+1] && Close[i+1] <= Open[i] && Close[i] - Open[i] < Open[i+1] - Close[i+1] && High[i+1] >= High[i] && Low[i+1] <= Low[i];
    }

    bool isBearishHarami(int i){
         return Close[i+1] > Open[i+1] && Open[i] > Close[i] && Open[i] <= Close[i+1] && Open[i+1] <= Close[i] && Open[i] - Close[i] < Close[i+1] - Open[i+1] && High[i+1] >= High[i] && Low[i+1] <= Low[i];
    }

    bool isHalfHarami(int i){
       return isHalfBullishHarami(i) || isHalfBearishHarami(i);
    }

    bool isHalfBullishHarami(int i){
      return Open[i+2] > Close[i+2] && Close[i] > Open[i] && Close[i] <= Open[i+2] && Close[i+2] <= Open[i] && Close[i] - Open[i] < Open[i+2] - Close[i+2] && High[i+2] >= High[i] && Low[i+2] <= Low[i];
    }

    bool isHalfBearishHarami(int i){
      return Close[i+2] > Open[i+2] && Open[i] > Close[i] && Open[i] <= Close[i+2] && Open[i+2] <= Close[i] && Open[i] - Close[i] < Close[i+2] - Open[i+2] && High[i+2] >= High[i] && Low[i+2] <= Low[i];
    }

    bool isEngulfing(int pos){
       return isBearishEngulfing(pos) && isBullishEngulfing(pos);
    }

    bool isBearishEngulfing(int pos){
       return isBullishCandle(pos+1) && isBearishCandle(pos)
              && Open[pos] >= Close[pos+1] && Open[pos+1] >= Close[pos]
              && getCandleBodySize(pos) >= getCandleBodySize(pos+1);
    }

    bool isBullishEngulfing(int pos){
       return isBearishCandle(pos+1) && isBullishCandle(pos)
              && Close[pos] >= Open[pos+1] && Close[pos+1] >= Open[pos]
              && getCandleBodySize(pos) >= getCandleBodySize(pos+1);
    }

    bool isBearishEngulfingBasedOnHighLow(int pos){
       return isBullishCandle(pos+1) && isBearishCandle(pos)
              && High[pos] > High[pos+1] && Low[pos+1] > Low[pos];
    }

    bool isBullishEngulfingBasedOnHighLow(int pos){
       return isBearishCandle(pos+1) && isBullishCandle(pos)
              && High[pos] > High[pos+1] && Low[pos+1] > Low[pos];
    }

    bool isShootingStar(int pos){
       return isBullishCandle(pos+1) && isBearishCandle(pos)
              && getUpWickSize(pos) >= getCandleBodySize(pos) * 2
              && getDownWickSize(pos) <= getCandleBodySize(pos) * 0.25;
    }

    bool isHammer(int pos){
       return isBearishCandle(pos+1) && isBullishCandle(pos)
              && getDownWickSize(pos)  >=  getCandleBodySize(pos) * 2
              && getUpWickSize(pos) <= getCandleBodySize(pos) * 0.25;
    }

    bool isMorningStar(int pos){
       return isBearishCandle(pos+2) && isBullishCandle(pos)
              && 2 * getCandleBodySize(pos+1) <= getCandleBodySize(pos)
              && getCandleBodySize(pos+1) <= getCandleBodySize(pos+2)
              && checkWicksNearlyEquals(pos+1);
    }

    bool isEveningStar(int pos){
       return isBullishCandle(pos+2) && isBearishCandle(pos)
              && 2 * getCandleBodySize(pos+1) <= getCandleBodySize(pos)
              && getCandleBodySize(pos+1) <= getCandleBodySize(pos+2)
              && checkWicksNearlyEquals(pos+1);
    }

    bool isDoji(int pos){
      return checkWicksNearlyEquals(pos) && getDownWickSize(pos)  >=  getCandleBodySize(pos) * 4;
    }

    bool isHegeset(int pos, double sizeMultiplication){

       bool c1 = Close[pos] > Open[pos];
       bool c2 = Close[pos+1] < Open[pos+1];

       bool bullishBearish = c1 && c2;

       bool c3 = Close[pos] < Open[pos];
       bool c4 = Close[pos+1] > Open[pos+1];

       bool bearishBullish = c3 && c4;

       bool isBullishBearishBar0TwiceSizeUp = ((High[pos] - Open[pos]) > sizeMultiplication * (Close[pos] - Low[pos]));
       bool isBullishBearishBar0TwiceSizeDown = (sizeMultiplication * (High[pos] - Open[pos]) < (Close[pos] - Low[pos]));
       bool isBullishBearishBar1TwiceSizeUp =  ((High[pos+1] - Close[pos+1]) > sizeMultiplication * (Open[pos+1] - Low[pos+1]));
       bool isBullishBearishBar1TwiceSizeDown = (sizeMultiplication * (High[pos+1] - Close[pos+1]) < (Open[pos+1] - Low[pos+1]));
       bool isBearishBullishBar0TwiceSizeUp = ((High[pos] - Close[pos]) > sizeMultiplication * (Open[pos] - Low[pos]));
       bool isBearishBullishBar0TwiceSizeDown = (sizeMultiplication * (High[pos] - Close[pos]) < (Open[pos] - Low[pos]));
       bool isBearishBullishBar1TwiceSizeUp =  ((High[pos+1] - Open[pos+1]) > sizeMultiplication * (Close[pos+1] - Low[pos+1]));
       bool isBearishBullishBar1TwiceSizeDown = (sizeMultiplication * (High[pos+1] - Open[pos+1]) < (Close[pos+1] - Low[pos+1]));

       bool isBullishBearishTwiceSize = bullishBearish && ((isBullishBearishBar0TwiceSizeUp && isBullishBearishBar1TwiceSizeDown) || (isBullishBearishBar0TwiceSizeDown && isBullishBearishBar1TwiceSizeUp));
       bool isBearishBullishTwiceSize = bearishBullish && ((isBearishBullishBar0TwiceSizeUp && isBearishBullishBar1TwiceSizeDown) || (isBearishBullishBar0TwiceSizeDown && isBearishBullishBar1TwiceSizeUp));

       bool twiceSize = isBullishBearishTwiceSize || isBearishBullishTwiceSize;

       bool trendChange = bullishBearish || bearishBullish;

       bool c5 = High[pos] > High[pos+1];
       bool c6 = Low[pos] > Low[pos+1];
       bool c7 = High[pos] < High[pos+1];
       bool c8 = Low[pos] < Low[pos+1];

       bool shadows = (c5 && c6) || (c7 && c8);

       bool isHegeset = trendChange && shadows && twiceSize;

       return isHegeset;
    }


private :

   bool isBullishCandle(int pos){
      return Close[pos] >= Open[pos];
    }

    bool isBearishCandle(int pos){
      return Close[pos] < Open[pos];
    }

    double getUpWickSize(int pos){
      return High[pos] - MathMax(Close[pos], Open[pos]);
    }

    double getDownWickSize(int pos){
      return MathMin(Close[pos], Open[pos]) - Low[pos];
    }

    double getCandleBodySize(int pos){
      return MathMax(Close[pos], Open[pos]) - MathMin(Close[pos], Open[pos]);
    }

    double getCandleSize(int pos){
      return High[pos] - Low[pos];
    }

    double checkWicksNearlyEquals(int pos){
      return checkWicksNearlyEquals(pos, 8);
    }

    double checkWicksNearlyEquals(int pos, int pourcentWickDifference){
      return MathAbs(getUpWickSize(pos) - getDownWickSize(pos)) <=  (pourcentWickDifference * getMaxWick(pos)) / 100;
    }

    double getMaxWick(int pos){
      return MathMax(getUpWickSize(pos), getDownWickSize(pos));
    }

};

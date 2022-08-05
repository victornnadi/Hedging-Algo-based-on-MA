#property copyright "victornnadi1998@gmail.com. Created with: ©2021 Visual Strategy Builder"
#property link "https://tools.forextester.com"
#property description "This robot executes trades to hedge my MACROSS strategy when it is not going my way, for mature trades. When it crosses the 200MA against me"
#property strict

datetime currentBar = 0;
int logFileHandle = INVALID_HANDLE;

datetime lastActR1 = 0;
datetime lastActR2 = 0;
datetime lastActR3 = 0;

input bool DebugMode = false; //Write strategy actions to logs
input bool WriteDebugLogToFile = false;


void OnInit()
{
   if(DebugMode && WriteDebugLogToFile)
     logFileHandle = FileOpen(StringConcatenate(MathRand(), "-vsb.log"), FILE_WRITE|FILE_TXT|FILE_SHARE_READ);
}

void OnDeinit(const int reason)
{
   if(logFileHandle != INVALID_HANDLE)
     FileClose(logFileHandle);
}

void WriteDebugLog(string logMessage)
{
   Print(logMessage);

   if (logFileHandle != INVALID_HANDLE && WriteDebugLogToFile)
     FileWriteString(logFileHandle, StringConcatenate(TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), " " ,logMessage, "\r\n"));
}

void OnTick()
{
   currentBar = iTime(NULL, 0, 0);

   if(DebugMode)
	  WriteDebugLog("Process new tick");

      double PriceR1C1O1 = iClose(Symbol(), 0, 0);
   double ValueR1C1O2 = 0.77024;

   if(DebugMode)
   {
      WriteDebugLog("Process rule: Buy");
      WriteDebugLog(StringConcatenate("PriceR1C1O1(iClose(Symbol(), 0, 0)) = ", PriceR1C1O1));
      WriteDebugLog(StringConcatenate("ValueR1C1O2(0.77024) = ", ValueR1C1O2));
      WriteDebugLog("Rule structure: PriceR1C1O1 > ValueR1C1O2");
      WriteDebugLog(StringConcatenate("Rule values: ","",PriceR1C1O1," > ",ValueR1C1O2));
   }

   if(PriceR1C1O1 > ValueR1C1O2)
   {
      if(DebugMode)
      {
         WriteDebugLog("Condition of rule \"Buy\" met");
         WriteDebugLog("Performing actions...");
      }
      if(lastActR1 != currentBar)
      {
         lastActR1 = currentBar;
      
         if(DebugMode)
            WriteDebugLog(StringConcatenate("Try to open Market Order with : Symbol:",Symbol(), " Type:","BUY"," Volume:",0.3," Slippage:",3," SL:",0," TP:",0, "MagicNumber:",4));
         if(!ExistsOrdersWithIdentifier("R1A1"))
         {
            if(OrderSend(Symbol(), 0, 0.3, SymbolInfoDouble(Symbol(), SYMBOL_ASK), 3, 0, 0, "Hedge Trade;R1A1", 4, 0, 65280))  //the identifier is the comment not magic number, i have to make each comment unique
            {
               if(DebugMode)
                  WriteDebugLog("Order opened");
            }
            else
            {
               if(DebugMode)
                  WriteDebugLog("Failed to open order");
            }
         }
   
      PlaySound("alert.wav");
      }
   }
   else
   {
      if (DebugMode)
         WriteDebugLog("Condition of rule \"Buy\" not met");
   }
      double PriceR2C1O1 = iClose(Symbol(), 0, 0);
   double PriceR2C1O1PrevBar = iClose(Symbol(), 0, 1);
   double ValueR2C1O2 = 0.77024;
   double ValueR2C1O2PrevBar = 0.77024;

   if(DebugMode)
   {
      WriteDebugLog("Process rule: Close Buy");
      WriteDebugLog(StringConcatenate("PriceR2C1O1(iClose(Symbol(), 0, 0)) = ", PriceR2C1O1));
      WriteDebugLog(StringConcatenate("PriceR2C1O1PrevBar(iClose(Symbol(), 0, 1)) = ", PriceR2C1O1PrevBar));
      WriteDebugLog(StringConcatenate("ValueR2C1O2(0.77024) = ", ValueR2C1O2));
      WriteDebugLog(StringConcatenate("ValueR2C1O2PrevBar(0.77024) = ", ValueR2C1O2PrevBar));
      WriteDebugLog("Rule structure: ((PriceR2C1O1PrevBar > ValueR2C1O2PrevBar) &&  (PriceR2C1O1<=ValueR2C1O2))");
      WriteDebugLog(StringConcatenate("Rule values: ","", "((",PriceR2C1O1PrevBar," > ",ValueR2C1O2PrevBar,") && ",PriceR2C1O1,"<=",ValueR2C1O2));
   }

   if(((PriceR2C1O1PrevBar > ValueR2C1O2PrevBar) &&  (PriceR2C1O1<=ValueR2C1O2)))
   {
      if(DebugMode)
      {
         WriteDebugLog("Condition of rule \"Close Buy\" met");
         WriteDebugLog("Performing actions...");
      }
      if(lastActR2 != currentBar)
      {
         lastActR2 = currentBar;
      
         CloseAllOrdersByMagicNumber(4);
      }
   }
   else
   {
      if (DebugMode)
         WriteDebugLog("Condition of rule \"Close Buy\" not met");
   }
      double PriceR3C1O1 = iClose(Symbol(), 0, 0);
   double ValueR3C1O2 = 0.77024;

   if(DebugMode)
   {
      WriteDebugLog("Process rule: Close Buy assurance");
      WriteDebugLog(StringConcatenate("PriceR3C1O1(iClose(Symbol(), 0, 0)) = ", PriceR3C1O1));
      WriteDebugLog(StringConcatenate("ValueR3C1O2(0.77024) = ", ValueR3C1O2));
      WriteDebugLog("Rule structure: PriceR3C1O1 < ValueR3C1O2");
      WriteDebugLog(StringConcatenate("Rule values: ","",PriceR3C1O1," < ",ValueR3C1O2));
   }

   if(PriceR3C1O1 < ValueR3C1O2)
   {
      if(DebugMode)
      {
         WriteDebugLog("Condition of rule \"Close Buy assurance\" met");
         WriteDebugLog("Performing actions...");
      }
      if(lastActR3 != currentBar)
      {
         lastActR3 = currentBar;
      
         CloseAllOrdersByMagicNumber(4);
      }
   }
   else
   {
      if (DebugMode)
         WriteDebugLog("Condition of rule \"Close Buy assurance\" not met");
   }
}

double PipPoint(string Currency)
{
	double CalcPoint = 0.0;
	int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
	if(CalcDigits == 2 || CalcDigits == 3) 
		CalcPoint = 0.01;
	else if(CalcDigits == 4 || CalcDigits == 5) 
		CalcPoint = 0.0001;
	
	return (CalcPoint);
}

double CalculateLotsFromPercents(double lotPercent, string symbol)
{
	double minlot = MarketInfo(symbol, MODE_MINLOT);
	double maxlot = MarketInfo(symbol, MODE_MAXLOT);
	double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

	lotPercent = lotPercent / 100.0;
	double lotInMoney = freeMargin * lotPercent;
	double lotInValue = lotInMoney / MarketInfo(symbol,MODE_MARGINREQUIRED);
	if(lotInValue < minlot)
	{
	  lotInValue = minlot;
	}
	else if(lotInValue > maxlot)
	{
	  lotInValue = maxlot;
	}
	
	return (lotInValue);
}

bool ExistsOrdersWithIdentifier(string identifier)
{
   for(int i = 0; i < OrdersTotal(); i++)        
   { 
	   if (OrderSelect(i,SELECT_BY_POS) == false)
		  continue;   
	   if (StringFind(OrderComment(), identifier) == -1)  //is the identifier the same for all same polarity trades?
		  continue; 
		  
	   if(DebugMode)
	   {
		  WriteDebugLog("Order from this action is still open. Skip action");
	   }
	   return true;                                 
   }
   
   return false;
}

void CloseAllOrdersByMagicNumber(int magicNumber)
{
   if(DebugMode)
      WriteDebugLog(StringConcatenate("Try to close orders with magic number: ",magicNumber));


   for (int i = 0; i < OrdersTotal(); i++)
   {
       if (OrderSelect(i, SELECT_BY_POS) == false)
           continue;

       double ExPrice;
       int Tck = OrderTicket();
       RefreshRates();

       if (OrderType() == 0 && OrderMagicNumber() == magicNumber)
       {
           ExPrice = MarketInfo(OrderSymbol(), MODE_BID);
       }
       else if (OrderType() == 1 && OrderMagicNumber() == magicNumber)
       {
           ExPrice = MarketInfo(OrderSymbol(), MODE_ASK);
       }
       else
           continue;

       if (DebugMode)
           WriteDebugLog(StringConcatenate("Try to close order with ticket: ", Tck));

       if (OrderClose(Tck, OrderLots(), ExPrice, 3))
       {
           if (DebugMode)
               WriteDebugLog("Order closed");
       }
       else
       {
           if (DebugMode)
               WriteDebugLog("Order not closed");
       }
   }
}


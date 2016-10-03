@isTest(SeeAllData=true)
public class TestScheduleProducts {
    
  	static testmethod void TestScheduleProductsController() { 
		
        System.debug('Test class: TestScheduleProductsController');
        //Create Country
        Country__c newCountry = new Country__c(Name='Test Country');
        insert newCountry;
        System.debug('Country: '+newCountry);
        
        // Create Account
        Id EMBAccountRTId = [Select Id from RecordType where DeveloperName = 'Economist_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account accEMB =  new Account();
        accEMB.Name = 'Test Account';
        accEMB.RecordTypeId = EMBAccountRTId;
        accEMB.Industry = 'Advertising';
        accEMB.Active_Account__c= true;
        accEMB.BillingStreet = 'Street';
        accEMB.BillingCity = 'London';
        accEMB.BillingCountry = 'Test Country';
        accEMB.BillingPostalCode ='TW33LR';
        insert accEMB;
		System.debug('Account:'+accEMB );
        
        //Create Sales Agent
        Sales_Agent__c SAgentEMB=new Sales_Agent__c();
        SAgentEMB.Name= 'Test Agent';
        SAgentEMB.Sales_Agent_Code__c='1234'; 
        SAgentEMB.Active__c=true;
        SAgentEMB.Region__c='EMEA';
        SAgentEMB.Sales_Department__c='Content Solutions';
        insert SAgentEMB;
        System.debug('Sales Agent:'+SAgentEMB );
        
        //Create Opportunity
        Id EMBOppRTId = [Select Id from RecordType where DeveloperName = 'EMBOpp' AND SObjectType = 'Opportunity' limit 1].Id;
        Opportunity OppEMB=new Opportunity();
        OppEMB.RecordTypeId=EMBOppRTId;
        OppEMB.Name='Test Opp EMB';
        OppEMB.AccountId=accEMB.id;
        OppEMB.EIU_Sales_Agent__c=SAgentEMB.id;
        OppEMB.Region__c='EMEA';
        OppEMB.Sub__c='UK';
        OppEMB.Sales_Department__c='BPS';
        OppEMB.CloseDate=Date.Today().addMonths(4);
        OppEMB.StageName='10% Early discussions'; 
        OppEMB.Amount=0;
        insert OppEMB;
        System.debug('Opportunity:'+OppEMB );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug('Pricebook: ' + testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        aProduct.ProductGroup__c = 'Media';
        aProduct.CurrencyIsoCode = 'GBP';
        insert aProduct;
        System.debug('Product: '+ aProduct);
        
        //Create standard pricebookentry
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry();
		standardPBE.Pricebook2ID = standardPB.Id;
        standardPBE.Product2ID = aProduct.Id;
        standardPBE.UnitPrice = 0;
        standardPBE.isActive = true;
        insert standardPBE;    
        
        //Create pricebook entry
        PricebookEntry testPBEntry = new PricebookEntry();
        testPBEntry.Pricebook2Id = testPB.Id;
        testPBEntry.Product2Id= aProduct.Id;
        testPBEntry.UnitPrice = 0;
        testPBEntry.UseStandardPrice = false;
        testPBEntry.isActive = true;
        insert testPBEntry;
        system.debug('Pricebook Entry: ' + testPBEntry);
        
        //Add product to opportunity
        OpportunityLineItem oppLI = new OpportunityLineItem();
        oppLI.PricebookEntryID = testPBEntry.Id;
        oppLI.OpportunityID = OppEMB.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug('Opportunity Product: ' + oppLI);
      
        //Now actually test it!
        test.startTest();
		ApexPages.currentPage().getParameters().put('oppId', oppEMB.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(oppEMB);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
        
      	list<SelectOption> testSplitOptions = myController.getSplitOptions();
      	list<SelectOption> testTypeOptions = myController.getTypeOptions();        
   		test.stopTest();

   		system.assertEquals(2,testSplitOptions.size());
        system.assertEquals(5,testTypeOptions.size());        
        System.assertEquals(myController.Opp.Id, oppEMB.Id);
        
        
        }
    
    static testmethod void TestScheduleProductsCancel() { 
		
        System.debug('Test class: TestScheduleProductsCancel');
        //Create Country
        Country__c newCountry = new Country__c(Name='Test Country');
        insert newCountry;
        System.debug('New country: '+newCountry);
        
        // Create Account
        Id EMBAccountRTId = [Select Id from RecordType where DeveloperName = 'Economist_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account accEMB =  new Account();
        accEMB.Name = 'Test Account';
        accEMB.RecordTypeId = EMBAccountRTId;
        accEMB.Industry = 'Advertising';
        accEMB.Active_Account__c= true;
        accEMB.BillingStreet = 'Street';
        accEMB.BillingCity = 'London';
        accEMB.BillingCountry = 'Test Country';
        accEMB.BillingPostalCode ='TW33LR';
        insert accEMB;
		System.debug('EMB Account:'+accEMB );
        
        //Create Sales Agent
        Sales_Agent__c SAgentEMB=new Sales_Agent__c();
        SAgentEMB.Name= 'Test Agent';
        SAgentEMB.Sales_Agent_Code__c='1234'; 
        SAgentEMB.Active__c=true;
        SAgentEMB.Region__c='EMEA';
        SAgentEMB.Sales_Department__c='Content Solutions';
        insert SAgentEMB;
        System.debug('SAgentEMB:'+SAgentEMB );
        
        //Create Opportunity
        Id EMBOppRTId = [Select Id from RecordType where DeveloperName = 'EMBOpp' AND SObjectType = 'Opportunity' limit 1].Id;
        Opportunity OppEMB=new Opportunity();
        OppEMB.RecordTypeId=EMBOppRTId;
        OppEMB.Name='Test Opp EMB';
        OppEMB.AccountId=accEMB.id;
        OppEMB.EIU_Sales_Agent__c=SAgentEMB.id;
        OppEMB.Region__c='EMEA';
        OppEMB.Sub__c='UK';
        OppEMB.Sales_Department__c='BPS';
        OppEMB.CloseDate=Date.Today().addMonths(4);
        OppEMB.StageName='10% Early discussions'; 
        OppEMB.Amount=0;
        insert OppEMB;
        System.debug('EMB Opp:'+OppEMB );
         
        List<Opportunity> lstOpty111 =[SELECT Amount,CloseDate from Opportunity where Id =:OppEMB.id];
        System.debug('lstOpty111:'+lstOpty111 );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug(testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        aProduct.ProductGroup__c = 'Media';
        aProduct.CurrencyIsoCode = 'GBP';
        insert aProduct;
        System.debug('A product: '+aProduct);
        
        //Create standard pricebookentry
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry();
		standardPBE.Pricebook2ID = standardPB.Id;
        standardPBE.Product2ID = aProduct.Id;
        standardPBE.UnitPrice = 0;
        standardPBE.isActive = true;
        insert standardPBE;    
        
        //Create pricebook entry
        PricebookEntry testPBEntry = new PricebookEntry();
        testPBEntry.Pricebook2Id = testPB.Id;
        testPBEntry.Product2Id= aProduct.Id;
        testPBEntry.UnitPrice = 0;
        testPBEntry.UseStandardPrice = false;
        testPBEntry.isActive = true;
        insert testPBEntry;
        system.debug(testPBEntry);
        
        //Add product
        OpportunityLineItem oppLI = new OpportunityLineItem();
        oppLI.PricebookEntryID = testPBEntry.Id;
        oppLI.OpportunityID = OppEMB.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug(oppLI);
      
        //Now actually test it!
        test.startTest();
		ApexPages.currentPage().getParameters().put('oppId', oppEMB.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(oppEMB);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
		
        myController.cancel();
        test.stopTest();

        }
    
    static testMethod void TestScheduleProductsAddProducts(){
        
 		System.debug('Test class: TestScheduleProductsAddProducts');
        //Create Country
        Country__c newCountry = new Country__c(Name='Test Country');
        insert newCountry;
        System.debug('New country: '+newCountry);
        
        // Create Account
        Id EMBAccountRTId = [Select Id from RecordType where DeveloperName = 'Economist_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account accEMB =  new Account();
        accEMB.Name = 'Test Account';
        accEMB.RecordTypeId = EMBAccountRTId;
        accEMB.Industry = 'Advertising';
        accEMB.Active_Account__c= true;
        accEMB.BillingStreet = 'Street';
        accEMB.BillingCity = 'London';
        accEMB.BillingCountry = 'Test Country';
        accEMB.BillingPostalCode ='TW33LR';
        insert accEMB;
		System.debug('EMB Account:'+accEMB );
        
        //Create Sales Agent
        Sales_Agent__c SAgentEMB=new Sales_Agent__c();
        SAgentEMB.Name= 'Test Agent';
        SAgentEMB.Sales_Agent_Code__c='1234'; 
        SAgentEMB.Active__c=true;
        SAgentEMB.Region__c='EMEA';
        SAgentEMB.Sales_Department__c='Content Solutions';
        insert SAgentEMB;
        System.debug('SAgentEMB:'+SAgentEMB );
        
        //Create Opportunity
        Id EMBOppRTId = [Select Id from RecordType where DeveloperName = 'EMBOpp' AND SObjectType = 'Opportunity' limit 1].Id;
        Opportunity OppEMB=new Opportunity();
        OppEMB.RecordTypeId=EMBOppRTId;
        OppEMB.Name='Test Opp EMB';
        OppEMB.AccountId=accEMB.id;
        OppEMB.EIU_Sales_Agent__c=SAgentEMB.id;
        OppEMB.Region__c='EMEA';
        OppEMB.Sub__c='UK';
        OppEMB.Sales_Department__c='BPS';
        OppEMB.CloseDate=Date.Today().addMonths(4);
        OppEMB.StageName='10% Early discussions'; 
        OppEMB.Amount=0;
        insert OppEMB;
        System.debug('EMB Opp:'+OppEMB );
         
        List<Opportunity> lstOpty111 =[SELECT Amount,CloseDate from Opportunity where Id =:OppEMB.id];
        System.debug('lstOpty111:'+lstOpty111 );
        
        //Now actually test it
        test.startTest();
        ApexPages.currentPage().getParameters().put('oppId', oppEMB.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(oppEMB);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
        myController.addProductsURL = '/p/opp/SelectSearch?addTo=oppid';
        test.stopTest();
        
        myController.addProduct();
    }
    
    static testmethod void TestScheduleProductsUserJourney() { 
		
        System.debug('Testclass: TestScheduleProductsUserJourney');
        //Create Country
        Country__c newCountry = new Country__c(Name='Test Country');
        insert newCountry;
        System.debug('New country: '+newCountry);
        
        // Create Account
        Id EMBAccountRTId = [Select Id from RecordType where DeveloperName = 'Economist_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account accEMB =  new Account();
        accEMB.Name = 'Test Account';
        accEMB.RecordTypeId = EMBAccountRTId;
        accEMB.Industry = 'Advertising';
        accEMB.Active_Account__c= true;
        accEMB.BillingStreet = 'Street';
        accEMB.BillingCity = 'London';
        accEMB.BillingCountry = 'Test Country';
        accEMB.BillingPostalCode ='TW33LR';
        insert accEMB;
		System.debug('EMB Account:'+accEMB );
        
        //Create Sales Agent
        Sales_Agent__c SAgentEMB=new Sales_Agent__c();
        SAgentEMB.Name= 'Test Agent';
        SAgentEMB.Sales_Agent_Code__c='1234'; 
        SAgentEMB.Active__c=true;
        SAgentEMB.Region__c='EMEA';
        SAgentEMB.Sales_Department__c='Content Solutions';
        insert SAgentEMB;
        System.debug('SAgentEMB:'+SAgentEMB );
        
        //Create Opportunity
        Id EMBOppRTId = [Select Id from RecordType where DeveloperName = 'EMBOpp' AND SObjectType = 'Opportunity' limit 1].Id;
        Opportunity OppEMB=new Opportunity();
        OppEMB.RecordTypeId=EMBOppRTId;
        OppEMB.Name='Test Opp EMB';
        OppEMB.AccountId=accEMB.id;
        OppEMB.EIU_Sales_Agent__c=SAgentEMB.id;
        OppEMB.Region__c='EMEA';
        OppEMB.Sub__c='UK';
        OppEMB.Sales_Department__c='BPS';
        OppEMB.CloseDate=Date.Today().addMonths(4);
        OppEMB.StageName='10% Early discussions'; 
        OppEMB.Amount=0;
        insert OppEMB;
        System.debug('EMB Opp:'+OppEMB );
         
        List<Opportunity> lstOpty111 =[SELECT Amount,CloseDate from Opportunity where Id =:OppEMB.id];
        System.debug('lstOpty111:'+lstOpty111 );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug(testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        aProduct.ProductGroup__c = 'Media';
        aProduct.CurrencyIsoCode = 'GBP';
        aProduct.CanUseRevenueSchedule = true;
        insert aProduct;
        System.debug('A product: '+aProduct);
        
        //Create standard pricebookentry
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry();
		standardPBE.Pricebook2ID = standardPB.Id;
        standardPBE.Product2ID = aProduct.Id;
        standardPBE.UnitPrice = 0;
        standardPBE.isActive = true;
        insert standardPBE;    
        
        //Create pricebook entry
        PricebookEntry testPBEntry = new PricebookEntry();
        testPBEntry.Pricebook2Id = testPB.Id;
        testPBEntry.Product2Id= aProduct.Id;
        testPBEntry.UnitPrice = 0;
        testPBEntry.UseStandardPrice = false;
        testPBEntry.isActive = true;
        insert testPBEntry;
        system.debug(testPBEntry);
        
        //Add product
        OpportunityLineItem oppLI = new OpportunityLineItem();
        oppLI.PricebookEntryID = testPBEntry.Id;
        oppLI.OpportunityID = OppEMB.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug(oppLI);
      
        //Now actually test it!
        test.startTest();
		ApexPages.currentPage().getParameters().put('oppId', oppEMB.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(oppEMB);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
		
        //Tests that is runs with no products selected
		myController.recalculate();
        
        //Selects Products, but still no schedule information
        for (ScheduleProductsController.wrapOLI wOLI : myController.wrapOLIList){
        	wOLI.isSelected = true;    
        }    
        myController.recalculate();
        
        //Ensure products selected and schedule information and iterates through the different options
        myController.tempSch.scheduleType = 'Divide Total Amount For Installments';
        myController.tempSch.installmentType = 2;
        myController.tempSch.startDate = system.today();
        myController.tempSch.numofInstallments = 4;
        myController.recalculate();
        
        myController.tempSch.scheduleType = 'Repeat Total Amount for Installments';
        myController.tempSch.installmentType = 1;
        myController.recalculate();
        
        myController.tempSch.installmentType = 3;
        myController.recalculate();
        
        myController.tempSch.installmentType = 4;
        myController.recalculate();
        
        myController.tempSch.installmentType = 5;
        myController.recalculate();
        
        //Now attempt to save the new schedules
        myController.saveAndMore();
        
        myController.recalculate();
        myController.saveSchedule();
        
        test.stopTest();
        
        System.assertEquals(myController.errorMsgs,null);
        
        }
    
    static testMethod void TestDMLExceptions() {
        
        System.debug('Test class: TestDMLExceptions');
        //Create Country
        Country__c newCountry = new Country__c(Name='Test Country');
        insert newCountry;
        System.debug('Country: '+newCountry);
        
        // Create Account
        Id EMBAccountRTId = [Select Id from RecordType where DeveloperName = 'Economist_Accounts' AND SObjectType = 'Account' limit 1].Id;
        Account accEMB =  new Account();
        accEMB.Name = 'Test Account';
        accEMB.RecordTypeId = EMBAccountRTId;
        accEMB.Industry = 'Advertising';
        accEMB.Active_Account__c= true;
        accEMB.BillingStreet = 'Street';
        accEMB.BillingCity = 'London';
        accEMB.BillingCountry = 'Test Country';
        accEMB.BillingPostalCode ='TW33LR';
        insert accEMB;
		System.debug('Account:'+accEMB );
        
        //Create Sales Agent
        Sales_Agent__c SAgentEMB=new Sales_Agent__c();
        SAgentEMB.Name= 'Test Agent';
        SAgentEMB.Sales_Agent_Code__c='1234'; 
        SAgentEMB.Active__c=true;
        SAgentEMB.Region__c='EMEA';
        SAgentEMB.Sales_Department__c='Content Solutions';
        insert SAgentEMB;
        System.debug('Sales Agent:'+SAgentEMB );
        
        //Create Opportunity
        Id EMBOppRTId = [Select Id from RecordType where DeveloperName = 'EMBOpp' AND SObjectType = 'Opportunity' limit 1].Id;
        Opportunity OppEMB=new Opportunity();
        OppEMB.RecordTypeId=EMBOppRTId;
        OppEMB.Name='Test Opp EMB';
        OppEMB.AccountId=accEMB.id;
        OppEMB.EIU_Sales_Agent__c=SAgentEMB.id;
        OppEMB.Region__c='EMEA';
        OppEMB.Sub__c='UK';
        OppEMB.Sales_Department__c='BPS';
        OppEMB.CloseDate=Date.Today().addMonths(4);
        OppEMB.StageName='10% Early discussions'; 
        OppEMB.Amount=0;
        insert OppEMB;
        System.debug('Opportunity:'+OppEMB );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug('Pricebook: ' + testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        aProduct.ProductGroup__c = 'Media';
        aProduct.CurrencyIsoCode = 'GBP';
        insert aProduct;
        System.debug('Product: '+ aProduct);
        
        //Create standard pricebookentry
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry();
		standardPBE.Pricebook2ID = standardPB.Id;
        standardPBE.Product2ID = aProduct.Id;
        standardPBE.UnitPrice = 0;
        standardPBE.isActive = true;
        insert standardPBE;    
        
        //Create pricebook entry
        PricebookEntry testPBEntry = new PricebookEntry();
        testPBEntry.Pricebook2Id = testPB.Id;
        testPBEntry.Product2Id= aProduct.Id;
        testPBEntry.UnitPrice = 0;
        testPBEntry.UseStandardPrice = false;
        testPBEntry.isActive = true;
        insert testPBEntry;
        system.debug('Pricebook Entry: ' + testPBEntry);
        
        //Add product to opportunity
        OpportunityLineItem oppLI = new OpportunityLineItem();
        oppLI.PricebookEntryID = testPBEntry.Id;
        oppLI.OpportunityID = OppEMB.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug('Opportunity Product: ' + oppLI);
      
        //Now actually test it!
        test.startTest();
		ApexPages.currentPage().getParameters().put('oppId', oppEMB.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(oppEMB);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
        
		//Selects Products and adds the required schedule information
        for (ScheduleProductsController.wrapOLI wOLI : myController.wrapOLIList){
        	wOLI.isSelected = true;    
        }  
        myController.tempSch.scheduleType = 'Divide Total Amount For Installments';
        myController.tempSch.installmentType = 2;
        myController.tempSch.startDate = system.today();
        myController.tempSch.numofInstallments = 4;
        myController.recalculate();        
        myController.saveAndMore();
        
        myController.recalculate();
        myController.saveSchedule();
        
        test.stopTest();
        
    }
    
}
@isTest(SeeAllData=true)
public class TestScheduleProducts {
    
  	static testmethod void TestScheduleProductsController() { 
		
        System.debug('Test class: TestScheduleProductsController');
        
// Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Advertising';
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'Test Country';
        acc.BillingPostalCode ='TW33LR';
        insert acc;
	System.debug('Account: '+acc);
      
//Create Opportunity
        Opportunity Opp=new Opportunity();
        Opp.Name='Test Opp EMB';
        Opp.AccountId=acc.id;
        Opp.CloseDate=Date.Today().addMonths(4);
        Opp.StageName='10% Early discussions'; 
        Opp.Amount=0;
        insert Opp;
        System.debug('Opportunity: '+Opp);
        
//Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug('Pricebook: ' + testPB);
        
//Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
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
        oppLI.OpportunityID = Opp.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug('Opportunity Product: ' + oppLI);
      
//Now actually test it!
        test.startTest();
	ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
        
      	list<SelectOption> testSplitOptions = myController.getSplitOptions();
      	list<SelectOption> testTypeOptions = myController.getTypeOptions();        
   		test.stopTest();
   	system.assertEquals(2,testSplitOptions.size());
        system.assertEquals(5,testTypeOptions.size());        
        System.assertEquals(myController.Opp.Id, opp.Id);
	}
    
    static testmethod void TestScheduleProductsCancel() { 
		
        System.debug('Test class: TestScheduleProductsCancel');
       
        // Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Advertising';
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'Test Country';
        acc.BillingPostalCode ='TW33LR';
        insert acc;
	System.debug('Account: '+acc );
        
        //Create Opportunity
        Opportunity Opp=new Opportunity();
        Opp.Name='Test Opp';
        Opp.AccountId=acc.id;
        Opp.CloseDate=Date.Today().addMonths(4);
        Opp.StageName='10% Early discussions'; 
        Opp.Amount=0;
        insert Opp;
        System.debug('Opp: '+Opp );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug(testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        insert aProduct;
        System.debug('Product: '+aProduct);
        
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
        oppLI.OpportunityID = Opp.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug(oppLI);
      
        //Now actually test it!
        test.startTest();
	ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
		
        myController.cancel();
        test.stopTest();

        }
    
    static testMethod void TestScheduleProductsAddProducts(){
	System.debug('Test class: TestScheduleProductsAddProducts');
        
        // Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Advertising';
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'Test Country';
        acc.BillingPostalCode ='TW33LR';
        insert acc;
		System.debug('Account: '+acc);

        //Create Opportunity
  
        Opportunity Opp=new Opportunity();
        Opp.Name='Test Opp';
        Opp.AccountId=acc.id;
        Opp.CloseDate=Date.Today().addMonths(4);
        Opp.StageName='10% Early discussions'; 
        Opp.Amount=0;
        insert Opp;
        System.debug('Opp: '+Opp );
        
        //Now actually test it
        test.startTest();
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
        ScheduleProductsController myController = new ScheduleProductsController(stdOpp);
        myController.addProductsURL = '/p/opp/SelectSearch?addTo=oppid';
        test.stopTest();
        
        myController.addProduct();
    }
    
    static testmethod void TestScheduleProductsUserJourney() { 
		
        System.debug('Testclass: TestScheduleProductsUserJourney');
        
        // Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Advertising';
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'Test Country';
        acc.BillingPostalCode ='TW33LR';
        insert acc;
		System.debug('Account: '+acc );
        
        //Create Opportunity
        Opportunity Opp=new Opportunity();
        Opp.Name='Test Opp';
        Opp.AccountId=acc.id;
        Opp.CloseDate=Date.Today().addMonths(4);
        Opp.StageName='10% Early discussions'; 
        Opp.Amount=0;
        insert Opp;
        System.debug('Opp: '+Opp );

        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug(testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
        aProduct.CanUseRevenueSchedule = true;
        insert aProduct;
        System.debug('Product: '+aProduct);
        
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
        oppLI.OpportunityID = Opp.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug(oppLI);
      
        //Now actually test it!
        test.startTest();
	ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
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
        
        // Create Account
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Industry = 'Advertising';
        acc.BillingStreet = 'Street';
        acc.BillingCity = 'London';
        acc.BillingCountry = 'Test Country';
        acc.BillingPostalCode ='TW33LR';
        insert acc;
		System.debug('Account: '+acc );
        
        //Create Opportunity
        Opportunity Opp=new Opportunity();
        Opp.Name='Test Opp';
        Opp.AccountId=acc.id;
        Opp.CloseDate=Date.Today().addMonths(4);
        Opp.StageName='10% Early discussions'; 
        Opp.Amount=0;
        insert Opp;
        System.debug('Opportunity: '+Opp );
        
        //Create Pricebook
        Pricebook2 testPB = new Pricebook2();
        testPB.Name='Test Pricebook';
        testPB.isActive = true;
        insert testPB;
        system.debug('Pricebook: ' + testPB);
        
        //Create products
        Product2 aProduct = new Product2();
        aProduct.Name = 'Test Product';
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
        oppLI.OpportunityID = Opp.Id;
        oppLI.Quantity = 1;
        oppLI.UnitPrice = 100;
        insert oppLI;
        system.debug('Opportunity Product: ' + oppLI);
      
        //Now actually test it!
        test.startTest();
	ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
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
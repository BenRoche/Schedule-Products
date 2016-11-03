/*Author: 	Eleanor Matthewman
 * Date:	09 September 2016
 * Version:	1
 * Brief:	Allow salespeople to add the same schedule to multiple products at the same time
 * 			They can select products to apply the schedule to
 *
 * To do:	Make it possibleto choose quantity/revenue/both scheduling
 * 			Use field sets????
 * 			Hide Establish Schedule once establish clicked
 * 			Change cancel button to reyurn Establish schedules and hide new schedules
*/
public class ScheduleProductsController {
//Publically declaring variables
    public List<wrapOLI> wrapOLIList {get; set;}
    public List<OpportunityLineItem> selectedOLIs {get; set;}
    public List<OpportunityLineItem> OLIs {get; set;}
    public List<OpportunityLineItemSchedule> SCHs {get; set;}
    public List<OpportunityLineItemSchedule> oldSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newrSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newqSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newbSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newSCHsFinal {get; set;}
    public List<ApexPages.Message> errorMsgs {get; set;}
    public ID LineItemID {get; set;}
    public integer numOfqI {get; set;}
    public integer numOfrI {get; set;}
    public string OppId{get; set;}
    public Opportunity Opp {get; set;}
    public wrapSchedule tempSCH {get; set;}
    public wrapSchedule tempQSCH {get; set;}
    public wrapSchedule tempRSCH {get; set;}
    public String addProductsURL {get; set;}
    public string sType {get; set;}
    
//The constructor class
    public ScheduleProductsController (ApexPages.StandardController sc) {
	//Gets the opp that button was clicked from
        OppId=ApexPages.currentPage().getParameters().get('Oppid');
        Opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :OppId];
        system.debug('Opportunity Information: ' + Opp);
	//Gets the Line Items of the Opp
        OLIs = [SELECT Name, Id, TotalPrice, Quantity, ProductCode, HasSchedule, OpportunityId, ServiceDate, Product2.CanUseQuantitySchedule, Product2.CanUseRevenueSchedule FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
        system.debug('Line Item Information: ' + OLIs);
	//Creates a wrapper to combine the line items with the select box
        wrapOLIList = new list<wrapOLI>();
        for(OpportunityLineItem o: OLIs){
            wrapOLIList.add(new wrapOLI(o));
        }    
	//Turns the line items IDs into set to use in later SOQL
        Set<Id> OLIsIDs = (new Map<Id, SObject>(OLIs)).keyset();
	//Gets the Line Item Schedules
        SCHs = [SELECT Id, OpportunityLineItem.Name, Quantity, Revenue, ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID in :OLIsIDs];
        system.debug('Existing Schedule Information: ' + SCHs);
	//Creates empty schedule info for CSR to complete
        tempSCH = new wrapSchedule(opp);
        tempQSch = new wrapSchedule(opp);
        tempRSch = new wrapSchedule(opp);
	}
    
//The establish (recalculate) action
    public PageReference recalculate(){
	//Save point in case rollback required
        Savepoint sp = Database.setSavepoint();
	//Variable to check if the action can be performed
        Boolean okay = true;
	//Variable to checks if any Line Items have been selected
        Boolean oppSelected = false;
	//Variable to store the calculated amount for the schedule
        Decimal schAmount;
        Decimal schQuantity;
    //Check schedule type
    	sType = tempSCH.scheduleBy;
    	//qSch = false;
        //rSch = false;
        if(sType=='Quantity Schedule Only'){
            sType = 'Qty';
        }
        if(sType=='Revenue Schedule Only'){
            sType = 'Rev';
        }
        if(sType=='Quantity and Revenue Schedules'){
            sType = 'Both';
        }
        if(sType=='Rev'){
            tempQSch.numOfInstallments = 0;
        }
        if(sType=='Qty'){
            tempRSch.numOfInstallments = 0;
        }
        System.debug('sType:'+sType);
    //Gets the number of quantity installments
        numOfqI = tempQSch.numOfInstallments;
        system.debug('recalculate | Number of quantity installments: ' + numofqI);
        if(sType=='Qty' && (numofqI < 1 || numOfqI == null)) {
            okay=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Number of Quantity Installments must be greater than 0'));
        }
	//Gets the number of revenue installments
        numOfrI = tempRSch.numOfInstallments;
        system.debug('recalculate | Number of revenue installments: ' + numofrI);
        if(sType=='Rev' && (numofrI < 1 || numOfrI == null)) {
            okay=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Number of Revenue Installments must be greater than 0'));
        }
	//Gets the schedule type
		Boolean qmultiply = false;
        Boolean rmultiply = false;
        if(tempqSch.scheduleType=='Repeat Total Amount for Installments') {
            qmultiply = true;
        }
        if(temprSch.scheduleType=='Repeat Total Amount for Installments') {
            rmultiply = true;
        }
        system.debug('recalculate | Quantity Schedule type is multiply: ' + qmultiply);
        system.debug('recalculate | Revenue Schedule type is multiply: ' + rmultiply);
	//Gets installment type
		List <InstallmentType__mdt> tempTypeList = [SELECT Label, Length_Between_Schedules__c, Period_Type__c FROM InstallmentType__mdt WHERE Sort_Order__c = :tempqSch.InstallmentType];
        InstallmentType__mdt qtempType = tempTypeList[0];
        system.debug('recalculate | Time between schedules: ' + qtempType.Length_Between_Schedules__c + ' ' + qtempType.Period_Type__c);
        tempTypeList = [SELECT Label, Length_Between_Schedules__c, Period_Type__c FROM InstallmentType__mdt WHERE Sort_Order__c = :temprSch.InstallmentType];
        InstallmentType__mdt rtempType = tempTypeList[0];
        system.debug('recalculate | Time between schedules: ' + rtempType.Length_Between_Schedules__c + ' ' + rtempType.Period_Type__c);
	//Cleans schedule lists
        oldSCHs = new List<OpportunityLineItemSchedule>();
        newrSCHs = new List<OpportunityLineItemSchedule>();
        newqSCHs = new List<OpportunityLineItemSchedule>();
        newbSChs = new List<OpportunityLineItemSchedule>();
        newSCHs = new List<OpportunityLineItemSchedule>();
	//Gets the selected Line Items
        selectedOLIs=new list<OpportunityLineItem>();
        for(wrapOLI wrapObj:wrapOLIList){
            if(wrapObj.isSelected==true){
                selectedOLIs.add(wrapobj.OLI);
                oppSelected = true;
             }        
        } 
	//If no line items have been selected, error page
        if(oppSelected == false){
            okay = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No products have been selected'));
            system.debug('recalculate | No products were selected');
        }
	//Loop through line items for quantity
        if (sType=='Qty' && numOfqI > 0) {
            for (OpportunityLineItem o : selectedOLIs) {
                if(o.Product2.CanUseQuantitySchedule == true){
                    LineItemID = o.ID;
                    if (qmultiply == true){
                        schQuantity = o.Quantity;}
                    else {schQuantity = o.Quantity / numOfqI;}
                    date tempStartDate = tempqSCH.StartDate;
                //Create the new schedules
                    for (integer i=0;i<numofqI;i++){
                        OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItem=o, OpportunityLineItemID = o.Id, Quantity=schQuantity, ScheduleDate = tempStartDate, Type = 'Quantity');
                        system.debug('recalculate | New schedule created: ' + tempLIS);
                        if(qtempType.Period_Type__c == 'Day'){
                            tempStartDate = tempSCH.StartDate.addDays((i+1)*Integer.valueof(qtempType.Length_Between_Schedules__c));
                        }
                        else if(qtempType.Period_Type__c == 'Month'){
                            tempStartDate = tempSCH.StartDate.addMonths((i+1)*Integer.valueof(qtempType.Length_Between_Schedules__c));
                        }
                        else if(qtempType.Period_Type__c == 'Year'){
                            tempStartDate = tempSCH.StartDate.addYears((i+1)*Integer.valueof(qtempType.Length_Between_Schedules__c));
                        }
                        newqSCHs.add(tempLIS);
                    }
                }
                else {
                    okay = false;
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not all selected products have quantity scheduling enabled'));
            		system.debug('recalculate | No quantity schedule');
                }
            }
        }
	//Loop through line items for revenue
        if (sType=='Rev' && numOfrI > 0) {
            for (OpportunityLineItem o : selectedOLIs) {
                if(o.Product2.CanUseRevenueSchedule == true) {
                    LineItemID = o.ID;
                    if (rmultiply == true){
                        schAmount = o.TotalPrice;}
                    else {schAmount = o.TotalPrice / numOfrI;}
                    date tempStartDate = temprSCH.StartDate;
                //Create the new schedules
                    for (integer i=0;i<numofrI;i++){
                        OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItem=o, OpportunityLineItemID = o.Id, Revenue=schAmount, Quantity=schQuantity, ScheduleDate = tempStartDate, Type = 'Both');
                        system.debug('recalculate | New schedule created: ' + tempLIS);
                        if(rtempType.Period_Type__c == 'Day'){
                            tempStartDate = tempSCH.StartDate.addDays((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        else if(rtempType.Period_Type__c == 'Month'){
                            tempStartDate = tempSCH.StartDate.addMonths((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        else if(rtempType.Period_Type__c == 'Year'){
                            tempStartDate = tempSCH.StartDate.addYears((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        newrSCHs.add(tempLIS);
                    }
                }
            else{                
                    okay = false;
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not all selected products have revenue scheduling enabled'));
            		system.debug('recalculate | No revenue schedule');
            	}
            }
        }
        //Loop through line items for both
        if (sType=='Both' && numOfrI > 0 && numOfqI > 0) {
            for (OpportunityLineItem o : selectedOLIs) {
                if(o.Product2.CanUseRevenueSchedule == true && o.Product2.CanUseQuantitySchedule == true) {
                    LineItemID = o.ID;
                    if (qmultiply == true){
                        schQuantity = o.Quantity;}
                    else {schQuantity = o.Quantity / numOfqI;}
                    if (rmultiply == true){
                        schAmount = o.TotalPrice;}
                    else {schAmount = o.TotalPrice / numOfrI;}
                    date tempStartDate = temprSCH.StartDate;
                //Create the new schedules
                    for (integer i=0;i<numofrI;i++){
                        OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItem=o, OpportunityLineItemID = o.Id, Revenue=schAmount, ScheduleDate = tempStartDate, Type = 'Revenue');
                        system.debug('recalculate | New schedule created: ' + tempLIS);
                        if(rtempType.Period_Type__c == 'Day'){
                            tempStartDate = tempSCH.StartDate.addDays((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        else if(rtempType.Period_Type__c == 'Month'){
                            tempStartDate = tempSCH.StartDate.addMonths((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        else if(rtempType.Period_Type__c == 'Year'){
                            tempStartDate = tempSCH.StartDate.addYears((i+1)*Integer.valueof(rtempType.Length_Between_Schedules__c));
                        }
                        newbSCHs.add(tempLIS);
                    }
                }
            else{                
                    okay = false;
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not all selected products have revenue scheduling enabled'));
            		system.debug('recalculate | No revenue schedule');
            	}
            }
        }
        
        newSCHs.addAll(newqSCHs);
        newSCHs.addAll(newrSCHs);
        newSCHs.addAll(newbSCHs);
        //Get the old schedules
        List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id, ScheduleDate, Revenue, Quantity FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
        oldSCHs.addAll(tempSCHs);
        OLIs = [SELECT Name, Id, TotalPrice, Quantity, ProductCode, HasSchedule, OpportunityId, ServiceDate FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
		Set<Id> OLIsIDs = (new Map<Id, SObject>(OLIs)).keyset();
        SCHs = [SELECT Id, OpportunityLineItem.Name, Quantity, Revenue, ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID in :OLIsIDs];
	//If an error was found
        if(!okay){
            system.debug('recalculate | Error detected, database rolled back');
            Database.RollBack(sp);
            newrSCHs = null;
            newqSCHs = null;
            newbSCHs = null;
            newSCHs = null;
            return null;
        }
		system.debug('recalculate | Establish clicked, new schedules suggested');
	//Else moves to the manual adjustment page
        PageReference oPageRef = Page.ScheduleProducts;
        oPageRef.setRedirect(false);
        return oPageRef;
  	}

//The save action
    public PageReference saveSchedule(){
	//Save point in case rollback required
        Savepoint sp = Database.setSavepoint();
	//Variable to check if the action can be performed
        Boolean okay = true;
	//Variable to checks if any Line Items have been selected
        Boolean oppSelected = false;
	//Cleans schedule lists
        oldSCHs = new List<OpportunityLineItemSchedule>();
        newSCHsFinal = new List<OpportunityLineItemSchedule>();
	//Gets the selected Line Items
        selectedOLIs=new list<OpportunityLineItem>();
        for(wrapOLI wrapObj:wrapOLIList){
            if(wrapObj.isSelected==true){
                selectedOLIs.add(wrapobj.OLI);
                oppSelected = true;
            }        
        }       
	//Loop through line items
        for (OpportunityLineItem o : selectedOLIs) {
            system.debug('saveSchedule | LineItem: ' + o.Name);
            LineItemID = o.ID;            
		//Get the old schedules
            List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
            oldSCHs.addAll(tempSCHs);
        }
		//Loop through line item schedules
            system.debug('saveAndMore | Temporary Schedules: '+ newrSCHs + newqSCHs);
        	if(newrSCHS != null) {
                for (OpportunityLineItemSchedule olis : newrSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, ScheduleDate = olis.ScheduleDate, Type = 'Revenue');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    newSCHsFinal.add(templis);
                }
            }
        	if(newqSCHS != null) {
                for (OpportunityLineItemSchedule olis : newqSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Quantity=olis.Quantity, ScheduleDate = olis.ScheduleDate, Type = 'Quantity');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    newSCHsFinal.add(templis);
                }
            }
        	if(newbSCHS != null) {
                for (OpportunityLineItemSchedule olis : newbSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, Quantity=olis.Quantity, ScheduleDate = olis.ScheduleDate, Type = 'Both');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    newSCHsFinal.add(templis);
                }
            }
        
        	List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
            oldSCHs.addAll(tempSCHs);
	//Display old and new schedules for debugging
        system.debug('saveSchedule | Old Schedules: ' + oldSCHs);
        system.debug('saveSchedule | New Schedules: ' + newSCHsFinal);
	//Check if there are old schedules to delete
        if(oldSCHs != null || oldSCHS.size() > 0){
		//Try deleting schedules
            delete oldSCHs;
            system.debug('saveSchedule | Deletion of old schedules complete');
        }
	//Check if there are schedules to add
        if(newSCHsFinal != null){
		//Try adding schedules
            try{
                insert newSCHsFinal;
                system.debug('saveSchedule | Insertion of new schedules complete');
            } catch(dmlexception e){
                apexpages.addmessages(e);
                okay = false;
                system.debug('saveSchedule | ERROR inserting new schedules');
                system.debug('saveSchedule | ERROR message: ' + e);
            }
        }
	//If an error was found
        if(!okay){            
            system.debug('saveSchedule | Aborting due to error detected');
            Database.RollBack(sp);
            return null;
        }
	//Else returns to the opportunity page
        system.debug('saveSchedule | Product scheduling updated successfully');
        return new PageReference('/' + Opp.Id);
    }

//The save and more action
    public PageReference saveAndMore(){
        
		//Save point in case rollback required
            Savepoint sp = Database.setSavepoint();
        //Variable to check if the action can be performed
        	Boolean okay = true;
        //Variable to checks if any Line Items have been selected
        	Boolean oppSelected = false;
     
        //Cleans schedule lists
            oldSCHs = new List<OpportunityLineItemSchedule>();
            newSCHsFinal = new List<OpportunityLineItemSchedule>();
        
        //Gets the selected Line Items
            selectedOLIs=new list<OpportunityLineItem>();
            for(wrapOLI wrapObj:wrapOLIList){
                if(wrapObj.isSelected==true){
                    selectedOLIs.add(wrapobj.OLI);
                    oppSelected = true;
                 }        
            }       
        
            //Loop through line items
            for (OpportunityLineItem o : selectedOLIs) {
                system.debug('saveAndMore | LineItem: ' + o.Name);
                LineItemID = o.ID;
            }
            
            //Loop through line item schedules
        	if(newrSCHS != null) {
                 for (OpportunityLineItemSchedule olis : newrSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, ScheduleDate = olis.ScheduleDate, Type = 'Revenue');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    if(templis != null){
                        newSCHsFinal.add(templis);
                    }
                }
            }
        	if(newqSCHS != null) {
                for (OpportunityLineItemSchedule olis : newqSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Quantity=olis.Quantity, ScheduleDate = olis.ScheduleDate, Type = 'Quantity');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    if(templis != null){
                        newSCHsFinal.add(templis);
                    }
                }
            }
        	if(newbSCHS != null) {
                for (OpportunityLineItemSchedule olis : newbSCHs) {                        
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, Quantity=olis.Quantity, ScheduleDate = olis.ScheduleDate, Type = 'Both');
                    //system.debug('saveAndMore | New schedule created: ' + tempLIS);
                    if(templis != null){
                        newSCHsFinal.add(templis);
                    }
                }
            }
        
        	List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
            oldSCHs.addAll(tempSCHs);
            //Display old and new shcedules for debugging
            system.debug('saveAndMore | Old Schedules: ' + oldSCHs);
            system.debug('saveAndMore | New Schedules: ' + newSCHsFinal);
            
            //Check if there are old schedules to delete
            if(oldSCHs != null || oldSCHs.size() > 0){
                //Try deleting schedules
                Set<OpportunityLineItemSchedule> myset = new Set<OpportunityLineItemSchedule>();
                List<OpportunityLineItemSchedule> oldSCHsNoDup = new List<OpportunityLineItemSchedule>();
                myset.addAll(oldSCHs);
                oldSCHsNoDup.addAll(myset);
				delete oldSCHsNoDup;
                system.debug('saveAndMore | Deletion of old schedules complete');
			}
            
            //Check if there are schedules to add
            if(newSCHsFinal != null){
                //Try adding schedules
                try{
                    insert newSCHsFinal;
                    system.debug('saveAndMore | Insertion of new schedules complete');
                } catch(dmlexception e){
                    apexpages.addmessages(e);
                    okay = false;
                    system.debug('saveAndMore | ERROR inserting new schedules');
                    system.debug('saveAndMore | ERROR message: ' + e);
                }
            }
        
        //If an error was found
        if(!okay){
            system.debug('saveAndMore | Aborting due to previous error detected');
            Database.RollBack(sp);
            return null;
        }
        //Else returns to the opportunity page
        system.debug('saveSchedule | Product scheduling updated successfully');
        
        OLIs = [SELECT Name, Id, TotalPrice, Quantity, ProductCode, HasSchedule, OpportunityId, ServiceDate FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
		Set<Id> OLIsIDs = (new Map<Id, SObject>(OLIs)).keyset();
        SCHs = [SELECT Id, OpportunityLineItem.Name, Quantity, Revenue, ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID in :OLIsIDs];
        newqSCHs = null;
        newrSCHs = null;
        
        PageReference oPageRef = Page.ScheduleProducts;
        oPageRef.setRedirect(false);
        return oPageRef;
    }

    //The done (cancel) action
    public PageReference cancel(){
        
        //Check if there are schedules to delete
        system.debug('cancel | Scheduling cancelled');
    	return new PageReference('/' + OppId);
  	}
    
    //The add products action
    public PageReference addProduct(){
        PageReference p = new PageReference(addProductsURL);
        p.getParameters().put('addTo',opp.Id);
        p.setRedirect(true);
        return p;
    }
    
    //This gets the schedule options (e.g. split/multiply) from the Schedule Type custom setting
	public List<SelectOption> getSplitOptions () {
        
        List<SelectOption> splitOptions = new List<SelectOption>();
        
        //Values retrieved from the Schedule Type custom setting
   		List<ScheduleType__mdt> sTypes = [SELECT Label FROM ScheduleType__mdt];
   		for(ScheduleType__mdt setting : sTypes){
            splitOptions.add(new SelectOption(setting.Label,setting.Label)); 
        }     
    	
        SelectOptionSorter.doSort(splitOptions, SelectOptionSorter.FieldToSort.Value);
        system.debug('getSplitOption | Options for Type picklist: ' + splitOptions);
        return splitOptions;
    }  
    
    //This gets the schedule options (divide or multiple) from the Schedule Type custom metadata
    public List<SelectOption> getTypeOptions () {
         List<SelectOption> options = new List<SelectOption>();
         
	//This gets the installment options (e.g. daily/weekly) from the Installment Type custom metadata
		List<InstallmentType__mdt> iTypes = [SELECT Label, Sort_Order__c FROM InstallmentType__mdt];
        for(InstallmentType__mdt setting : iTypes){
        	options.add(new SelectOption(String.ValueOf(setting.Sort_Order__c),setting.Label)); 
        }     
         
        SelectOptionSorter.doSort(options, SelectOptionSorter.FieldToSort.Value);
        system.debug('getTypeOption | Options for Schedule Type picklist: ' + options);
        return options;
    }
    
    //This gets the schedule by options (Revenue/Quantity) from the Schedule By custom metadata
    public List<SelectOption> getScheduleByOptions () {
        List<SelectOption> byOptions = new List<SelectOption>();
        List<Schedule_By__mdt> bTypes = [SELECT Label FROM Schedule_By__mdt];
        for(Schedule_By__mdt setting : bTypes){
        	byOptions.add(new SelectOption(setting.Label,setting.Label)); 
        } 
        //SelectOptionSorter.doSort(byOptions, SelectOptionSorter.FieldToSort.Value);
        system.debug('getScheduleByOption | Options for Schedule bY picklist: ' + byoptions);
        return byOptions;
    }
    
    //This creates the wrapper object containing line itmes fields with a checkbox
    public class wrapOLI{
        public OpportunityLineItem OLI{get;set;}
        public Id OLIId{get;set;}
        public string OLIName{get;set;}
        public string OLIProductCode{get;set;}
        public decimal OLIQuantity{get;set;}
        public decimal OLITotalPrice{get;set;}
        public date OLIServiceDate{get;set;}
        public boolean isSelected{get;set;}
        
        //This is the wrapper class to assign the "object" field values
        public wrapOLI(OpportunityLineItem o){
            OLI = o;
            OLIId = o.ID;
            OLIName = o.Name;
            OLIProductCode = o.ProductCode;
            OLIQuantity = o.Quantity;
            OLITotalPrice = o.TotalPrice.setScale(2);
            OLIServiceDate = o.ServiceDate;
            isSelected=false;
        }
    }
   	
    //This creates the wrapper object for the schduling information
    public class wrapSchedule{
        public string scheduleType {get;set;}
        public decimal installmentType {get;set;}
        public date startDate {get;set;}
        public integer numofInstallments {get;set;}
        public string scheduleBy {get;set;}

        
        public wrapSchedule(Opportunity opp){
        	startDate=opp.closeDate;
            scheduleType = 'Divide Total Amount For Installments';
            installmentType = 1;
            scheduleBy = 'Revenue Schedule Only';
        }
    }
}
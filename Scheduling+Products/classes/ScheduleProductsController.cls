/*Author: 	Eleanor Matthewman
 * Date:	09 September 2016
 * Version:	1
 * Brief:	Allow salespeople to add the same schedule to multiple products at the same time
 * 			They can select products to apply the schedule to
 *
*/ 
public class ScheduleProductsController {
	
//Publically declaring variables
    public List<wrapOLI> wrapOLIList {get; set;}
    public List<OpportunityLineItem> selectedOLIs {get; set;}
    public List<OpportunityLineItem> OLIs {get; set;}
    public List<OpportunityLineItemSchedule> SCHs {get; set;}
    public List<OpportunityLineItemSchedule> oldSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newSCHs {get; set;}
    public List<OpportunityLineItemSchedule> newSCHsFinal {get; set;}
    public List<ApexPages.Message> errorMsgs {get; set;}
    public ID LineItemID {get; set;}
    public integer numOfI {get; set;}
    public string OppId{get; set;}
    public Opportunity Opp {get; set;}
    public wrapSchedule tempSCH {get; set;}
    public String addProductsURL {get; set;}
    
//The constructor class
    public ScheduleProductsController (ApexPages.StandardController sc) {
	//Gets the opp that button was clicked from
        OppId=ApexPages.currentPage().getParameters().get('Oppid');
        Opp = [SELECT Id, CloseDate FROM Opportunity WHERE Id = :OppId];
        system.debug('Opportunity Information: ' + Opp);
	//Gets the Line Items of the Opp
        OLIs = [SELECT Name, Id, TotalPrice, Quantity, ProductCode, HasSchedule, OpportunityId, ServiceDate FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
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
	//Gets the number of installments
        numOfI = tempSch.numOfInstallments;
        system.debug('recalculate | Number of installments: ' + numofI);
        if(numofI < 1 || numOfI == null) {
            okay=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Number of Installments must be greater than 0'));
        }
	//Gets the schedule type
        Boolean multiply = false;
        if(tempSch.scheduleType=='Repeat Total Amount for Installments') {
            multiply = true;
        }
        system.debug('recalculate | Schedule type is multiply: ' + multiply);
	//Gets installment type
        List <InstallmentType__mdt> tempTypeList = [SELECT Label, Days_Between_Schedules__c FROM InstallmentType__mdt WHERE Sort_Order__c = :tempSch.InstallmentType];
        InstallmentType__mdt tempType = tempTypeList[0];
        Integer daysToAdd = Integer.valueof(tempType.Days_Between_Schedules__c);
        system.debug('recalculate | Days to add: ' + daysToAdd);
	//Gets start date
        system.debug('recalculate | Start Date: ' + tempSch.StartDate);
	//Cleans schedule lists
        oldSCHs = new List<OpportunityLineItemSchedule>();
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
	//Loop through line items
        if (numOfI > 0) {
            for (OpportunityLineItem o : selectedOLIs) {
                LineItemID = o.ID;
                if (multiply == true){
                    schAmount = o.TotalPrice;}
                else {schAmount = o.TotalPrice / numOfI;}
                date tempStartDate = tempSCH.StartDate;
      		//Create the new schedules
                for (integer i=0;i<numofI;i++){
                    OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItem=o, OpportunityLineItemID = o.Id, Revenue=schAmount, ScheduleDate = tempStartDate, Type = 'Revenue');
                    system.debug('recalculate | New schedule created: ' + tempLIS);
                    if(tempSch.InstallmentType == 1){
                        tempStartDate = tempSCH.StartDate.addDays((i+1)*daysToAdd);
                    }
                    else if(tempSch.InstallmentType == 2){
                        tempStartDate = tempSCH.StartDate.addDays((i+1)*daysToAdd);
                    }
                    else if(tempSch.InstallmentType == 3){
                        tempStartDate = tempSCH.StartDate.addMonths((i+1)*1);
                    }
                    else if(tempSch.InstallmentType == 4){
                        tempStartDate = tempSCH.StartDate.addMonths((i+1)*3);
                    }
                    else if(tempSch.InstallmentType == 5){
                        tempStartDate = tempSCH.StartDate.addYears((i+1)*1);
                    }
                    newSCHs.add(tempLIS);
                }
			//Get the old schedules
                List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id, ScheduleDate, Revenue, Quantity FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
                oldSCHs.addAll(tempSCHs);
            }
        }
        OLIs = [SELECT Name, Id, TotalPrice, Quantity, ProductCode, HasSchedule, OpportunityId, ServiceDate FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
		Set<Id> OLIsIDs = (new Map<Id, SObject>(OLIs)).keyset();
        SCHs = [SELECT Id, OpportunityLineItem.Name, Quantity, Revenue, ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID in :OLIsIDs];
        system.debug('OLIList size: ' + wrapOLIList.size());
	//If an error was found
        if(!okay){
            system.debug('recalculate | Error detected, database rolled back');
            Database.RollBack(sp);
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
        system.debug('saveSchedule | Temporary Schedules: '+ newSCHs);
        for (OpportunityLineItemSchedule olis : newSCHs) {                        
            OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, ScheduleDate = olis.ScheduleDate, Type = 'Revenue');
            system.debug('saveSchedule | New schedule created: ' + tempLIS);
            newSCHsFinal.add(templis);
        }  
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
        if(newSCHs != null){
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
                //Get the old schedules
                List <OpportunityLineItemSchedule> tempSCHs = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID = :LineItemID];
                oldSCHs.addAll(tempSCHs);
            }
            
            //Loop through line item schedules
            system.debug('saveAndMore | Temporary Schedules: '+ newSCHs);
            for (OpportunityLineItemSchedule olis : newSCHs) {                        
                OpportunityLineItemSchedule tempLIS = new OpportunityLineItemSchedule(OpportunityLineItemID=olis.OpportunityLineItemId, Revenue=olis.Revenue, ScheduleDate = olis.ScheduleDate, Type = 'Revenue');
                system.debug('saveAndMore | New schedule created: ' + tempLIS);
                newSCHsFinal.add(templis);
            }  
            //Display old and new shcedules for debugging
            system.debug('saveAndMore | Old Schedules: ' + oldSCHs);
            system.debug('saveAndMore | New Schedules: ' + newSCHsFinal);
            
            //Check if there are old schedules to delete
            if(oldSCHs != null || oldSCHs.size() > 0){
                //Try deleting schedules
				delete oldSCHs;
                system.debug('saveAndMore | Deletion of old schedules complete');
			}
            
            //Check if there are schedules to add
            if(newSCHs != null){
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
        newSCHs = null;
        
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
    
    //This gets the installment options (e.g. daily/weekly) from the Installment Type custom setting
    public List<SelectOption> getTypeOptions () {
         List<SelectOption> options = new List<SelectOption>();
         
	//Values retrieved from the Installment Type custom setting
		List<InstallmentType__mdt> iTypes = [SELECT Label, Sort_Order__c FROM InstallmentType__mdt];
        for(InstallmentType__mdt setting : iTypes){
        	options.add(new SelectOption(String.ValueOf(setting.Sort_Order__c),setting.Label)); 
        }     
         
        SelectOptionSorter.doSort(options, SelectOptionSorter.FieldToSort.Value);
        system.debug('getTypeOption | Options for Schedule Type picklist: ' + options);
        return options;
    }
    
    //This creates the wrapper object containing line itmes fields with a checkbox
    @TestVisible public class wrapOLI{
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
    @TestVisible public class wrapSchedule{
        public string scheduleType {get;set;}
        public decimal installmentType {get;set;}
        public date startDate {get;set;}
        public integer numofInstallments {get;set;}

        
        public wrapSchedule(Opportunity opp){
        	startDate=opp.closeDate;
            scheduleType = 'Divide Total Amount For Installments';
            installmentType = 1;
        }
    }
}

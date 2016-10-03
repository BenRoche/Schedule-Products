Schedule Products
====
Contents:
----
<i>This should successfully deploy to any organisation that does not have multi-currency enabled. You will need to createthe data that sits within the custom settings for this to work successfully.</i>

<a href="https://githubsfdeploy.herokuapp.com?owner=EllieAtWHL&repo=Schedule-Products">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

**Unpackaged**

classes
* [ScheduleProductsController][1] 
* [SelectionOptionSorter] [2] 
* [TestScheduleProducts] [3] (Test Unit)
* [TestSelectOptionSort] [4] (Test Unit)

objects
* [Installment_Type__c] [5] (Custom Setting)
* [Schedule_Type__c][6] (Custom Setting)
* [OpportunityLineItem][7] (Button)

pages
* [ScheduleProducts][8]

[package.xml] [13]

**CSV**
* [InstallmentType][10] (data for custom setting)
* [ScheduleType][11] (data for custom setting)

**Read Me**
* [readme.md][12]

[1]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/ScheduleProductsController.cls
[2]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/SelectOptionSorter.cls
[3]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/TestScheduleProducts.cls
[4]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/TestSelectOptionSorter.cls
[5]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/Installment_Type__c.object
[6]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/Schedule_Type__c.object
[7]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/OpportunityLineItem.object
[8]: https://github.com/EllieAtWHL/Schedule-Productsg/blob/master/Scheduling%2BProducts/pages/ScheduleProducts.page
[10]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/InstallmentType.csv
[11]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/ScheduleType.csv
[12]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/README.md
[13]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/package.xml

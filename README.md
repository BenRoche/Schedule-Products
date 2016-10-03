Schedule Products
====

<i>This should successfully deploy to any organisation that does not have multi-currency enabled. 
You need to ensure that the products used have got Revenue Scheduling enabled.
Please let me know of any bugs or enhancements you discover.</i>

Instructions:
----
In order to use this, just add the 'Schedule Products' button to the Products related list on the relevant Opportunity page layout.

Click the button below and follow the on-screen instructions.

<a href="https://githubsfdeploy.herokuapp.com?owner=EllieAtWHL&repo=Schedule-Products">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Contents:
----
**Unpackaged**

classes
* [ScheduleProductsController][1] 
* [SelectionOptionSorter] [2] 
* [TestScheduleProducts] [3] (Test Unit)
* [TestSelectOptionSort] [4] (Test Unit)

objects
* [Installment_Type__c] [5] (Custom Metadata)
* [Schedule_Type__c][6] (Custom Metadata)
* [OpportunityLineItem][7] (Button)

pages
* [ScheduleProducts][8]

**package**

* [package.xml] [13]

**Read Me**
* [readme.md][12]

[1]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/ScheduleProductsController.cls
[2]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/SelectOptionSorter.cls
[3]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/TestScheduleProducts.cls
[4]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/classes/TestSelectOptionSorter.cls
[5]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/InstallmentType__mdt.object
[6]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/ScheduleType__mdt.object
[7]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/objects/OpportunityLineItem.object
[8]: https://github.com/EllieAtWHL/Schedule-Productsg/blob/master/Scheduling%2BProducts/pages/ScheduleProducts.page
[12]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/README.md
[13]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/Scheduling%2BProducts/package.xml

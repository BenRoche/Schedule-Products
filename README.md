Schedule Products
====
Contents:
----
<i>Please note: This is specifc to my organisation's instance of Salesforce. I am in the process of creating a more generic version that can be deployed to 'any' org.</i>

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

[1]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/classes/ScheduleProductsController.cls
[2]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/classes/SelectOptionSorter.cls
[3]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/classes/TestScheduleProducts.cls
[4]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/classes/TestSelectOptionSorter.cls
[5]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/objects/Installment_Type__c.object
[6]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/objects/Schedule_Type__c.object
[7]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/objects/OpportunityLineItem.object
[8]: https://github.com/EllieAtWHL/Schedule-Productsg/blob/master/unpackaged/pages/ScheduleProducts.page
[10]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/InstallmentType.csv
[11]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/ScheduleType.csv
[12]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/README.md
[13]: https://github.com/EllieAtWHL/Schedule-Products/blob/master/unpackaged/package.xml

@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup static void setup(){
        //UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        //insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE name like '%Admin%' limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'emmersiontestUser@sf.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE name like '%Admin%' limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'leadroundrobin@testuser1.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        User u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE name like '%Admin%' limit 1].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'AEOwnerroundrobin@testuser.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        List<User> userList = new List<User>();
        userlist.add(u);
        userlist.add(u1);
        userlist.add(u2);
        insert userlist;
        System.debug('userlist-->'+userlist);
        System.debug(userlist[0].username+'--userlistID-->'+userlist[0].Id);
        System.debug(userlist[1].username+'--userlistID1-->'+userlist[1].Id);
        System.debug(userlist[2].username+'--userlistID2-->'+userlist[2].Id);
    }
    @isTest
    public static void testMethod1(){
        
        Test.startTest();
        
        Lead_Round_Robin__c checkGeography = new Lead_Round_Robin__c();
        checkGeography.AE_Owner_Round_Robin_Geography__c = true;
        checkGeography.Lead_Owner_Round_Robin_Geography__c = true;
        insert checkGeography;
        
        Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj1 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj1.Name = 'Rec1';
        leadAEOwnerRoundRobinObj1.Geography__c = 'APAC';
        leadAEOwnerRoundRobinObj1.UserName__c = 'AEOwnerroundrobin@testuser.com';
        leadAEOwnerRoundRobinObj1.Segment__c = 'Enterprise';
        
        insert leadAEOwnerRoundRobinObj1;
        
        Lead_Owner_Round_Robin__c leadOwnerRoundRobinObj1 = new Lead_Owner_Round_Robin__c();
        leadOwnerRoundRobinObj1.UserName__c = 'leadroundrobin@testuser1.com';
        leadOwnerRoundRobinObj1.Geography__c = 'APAC';
        leadOwnerRoundRobinObj1.name = 'Rec2';
        insert leadOwnerRoundRobinObj1;
        
        Lead_Owner_Round_Robin__c leadOwnerRoundRobinObj2 = new Lead_Owner_Round_Robin__c();
        leadOwnerRoundRobinObj2.UserName__c = 'leadroundrobin@testuser1.com';
        leadOwnerRoundRobinObj2.Geography__c = 'APAC';
        leadOwnerRoundRobinObj2.name = 'Rec2';
        leadOwnerRoundRobinObj2.Industry__c = 'Automotive';
        insert leadOwnerRoundRobinObj2;
        
        Lead leadObj1 = new Lead();
        leadObj1.Status = 'Round Robin';
        leadObj1.LastName = 'tstLastName';
        leadObj1.Company = 'tstCompany';
        leadObj1.Industry = 'Automotive';
        leadObj1.Geography__c ='APAC';
        leadObj1.Segment__c ='Mid-Market';
        leadObj1.Employee_Range__c = 'Fewer than 100';
        leadObj1.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        insert leadObj1;
        System.debug('leadObj1-->'+leadObj1);
        System.debug('leadObj1-->'+leadObj1.User__c);
        System.debug('leadObj1-->'+leadObj1.OwnerId);
        Lead l1 = new Lead();
        l1 = [select id , ownerId , user__c from lead where Id=:leadObj1.Id];
        System.debug('l1-->'+l1);
        
        
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2(){
        
        Test.startTest();
        
        Lead_Round_Robin__c checkGeography = new Lead_Round_Robin__c();
        checkGeography.AE_Owner_Round_Robin_Geography__c = false;
        checkGeography.Lead_Owner_Round_Robin_Geography__c = false;
        insert checkGeography;
        
        Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj1 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj1.Name = 'Rec1';
        leadAEOwnerRoundRobinObj1.Geography__c = 'APAC';
        leadAEOwnerRoundRobinObj1.UserName__c = 'AEOwnerroundrobin@testuser.com';
        leadAEOwnerRoundRobinObj1.Segment__c = 'Enterprise';
        
        insert leadAEOwnerRoundRobinObj1;
        
        Lead_Owner_Round_Robin__c leadOwnerRoundRobinObj1 = new Lead_Owner_Round_Robin__c();
        leadOwnerRoundRobinObj1.UserName__c = 'leadroundrobin@testuser1.com';
        leadOwnerRoundRobinObj1.Geography__c = 'APAC';
        leadOwnerRoundRobinObj1.name = 'Rec2';
        insert leadOwnerRoundRobinObj1;
        
        Lead leadObj1 = new Lead();
        leadObj1.Status = 'Round Robin';
        leadObj1.LastName = 'tstLastName';
        leadObj1.Company = 'tstCompany';
        leadObj1.Industry = 'Automotive';
        leadObj1.Geography__c ='APAC';
        leadObj1.Employee_Range__c = 'Fewer than 100';
        leadObj1.Segment__c ='Mid-Market';
        leadObj1.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        insert leadObj1;
        System.debug('leadObj1-->'+leadObj1);
        System.debug('leadObj1-->'+leadObj1.User__c);
        System.debug('leadObj1-->'+leadObj1.OwnerId);
        
        
        
        
        Test.stopTest();
    }
    @isTest
    public static void testMethod4(){
        Test.startTest();
        List<Global_List__c> globalList = new List<Global_List__c>();
        Global_List__c rec1 = new Global_List__c();
        rec1.Name ='Rec1';
        rec1.Company__c = '3M';
        Global_List__c rec2 = new Global_List__c();
        rec2.Name ='Rec1';
        rec2.Company__c = '3M';
        
        globalList.add(rec1);//globalList.add(rec2);
        insert globalList;
        
        List<Global_Lead_Round_Robin__c> globalUsersList = new List<Global_Lead_Round_Robin__c>();
        
        Global_Lead_Round_Robin__c userRec1 = new Global_Lead_Round_Robin__c();
        userRec1.Name = 'Rec1';
        userRec1.Geography__c = 'LATAM';
        userRec1.UserName__c = 'AEOwnerroundrobin@testuser.com';
        
        Global_Lead_Round_Robin__c userRec2 = new Global_Lead_Round_Robin__c();
        userRec2.Name = 'Rec2';
        userRec2.Geography__c = 'Unknown';
        userRec2.UserName__c = 'leadroundrobin@testuser1.com';
        globalUsersList.add(userRec1);globalUsersList.add(userRec2);
        insert globalUsersList;
        
        Lead leadObj3 = new Lead();
        leadObj3.Status = 'Round Robin';
        leadObj3.LastName = 'tstLastName';
        leadObj3.Company = '3M';
        leadObj3.Industry = 'Automotive';
        leadObj3.Geography__c ='LATAM';
        leadObj3.Employee_Range__c = 'Fewer than 100';
        leadObj3.Segment__c ='Mid-Market';
        leadObj3.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj31 = new Lead();
        leadObj31.Status = 'Round Robin';
        leadObj31.LastName = 'tstLastName';
        leadObj31.Company = '3M';
        leadObj31.Industry = 'Automotive';
        leadObj31.Geography__c ='Unknown';
        leadObj31.Employee_Range__c = 'Fewer than 100';
        leadObj31.Segment__c ='Mid-Market';
        leadObj31.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        List<lead> leadList = new List<lead>();
        //insert leadObj31;
        leadList.add(leadObj3);
        leadList.add(leadObj31); 
        insert leadList;
        System.debug(leadList.size()+'leadList--<><><><><><>'+leadList);
        Test.stopTest();
    }
    @isTest
    public static void leadGeography1(){
        Test.startTest();
        Lead leadObj1 = new Lead();
        leadObj1.Status = 'Round Robin';
        leadObj1.LastName = 'tstLastName';
        leadObj1.Company = '3M';
        leadObj1.Industry = 'Automotive';
        leadObj1.Geography__c ='Unknown';
        leadObj1.Employee_Range__c = 'Fewer than 100';
        leadObj1.Segment__c ='Mid-Market';
        leadObj1.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj2 = new Lead();
        leadObj2.Status = 'Round Robin';
        leadObj2.LastName = 'tstLastName';
        leadObj2.Company = '3M';
        leadObj2.country = 'argentina';
        leadObj2.Industry = 'Automotive';
        leadObj2.Geography__c ='Unknown';
        leadObj2.Employee_Range__c = 'Fewer than 100';
        leadObj2.Segment__c ='Mid-Market';
        leadObj2.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj3 = new Lead();
        leadObj3.Status = 'Round Robin';
        leadObj3.country = 'algeria';
        leadObj3.LastName = 'tstLastName';
        leadObj3.Company = '3M';
        leadObj3.Industry = 'Automotive';
        leadObj3.Geography__c ='Unknown';
        leadObj3.Employee_Range__c = 'Fewer than 100';
        leadObj3.Segment__c ='Mid-Market';
        leadObj3.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj4 = new Lead();
        leadObj4.Status = 'Round Robin';
        leadObj4.country = 'albania';
        leadObj4.LastName = 'tstLastName';
        leadObj4.Company = '3M';
        leadObj4.Industry = 'Automotive';
        leadObj4.Geography__c ='Unknown';
        leadObj4.Employee_Range__c = 'Fewer than 100';
        leadObj4.Segment__c ='Mid-Market';
        leadObj4.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj5 = new Lead();
        leadObj5.Status = 'Round Robin';
        leadObj5.country = 'afghanistan';
        leadObj5.LastName = 'tstLastName';
        leadObj5.Company = '3M';
        leadObj5.Industry = 'Automotive';
        leadObj5.Geography__c ='Unknown';
        leadObj5.Employee_Range__c = 'Fewer than 100';
        leadObj5.Segment__c ='Mid-Market';
        leadObj5.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj6 = new Lead();
        leadObj6.Status = 'Round Robin';
        leadObj6.country = 'micronesia';
        leadObj6.LastName = 'tstLastName';
        leadObj6.Company = '3M';
        leadObj6.Industry = 'Automotive';
        leadObj6.Geography__c ='Unknown';
        leadObj6.Employee_Range__c = 'Fewer than 100';
        leadObj6.Segment__c ='Mid-Market';
        leadObj6.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj7 = new Lead();
        leadObj7.Status = 'Round Robin';
        leadObj7.country = 'cyprus';
        leadObj7.LastName = 'tstLastName';
        leadObj7.Company = '3M';
        leadObj7.Industry = 'Automotive';
        leadObj7.Geography__c ='Unknown';
        leadObj7.Employee_Range__c = 'Fewer than 100';
        leadObj7.Segment__c ='Mid-Market';
        leadObj7.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj8 = new Lead();
        leadObj8.Status = 'Round Robin';
        leadObj8.country = '3M';
        leadObj8.LastName = 'tstLastName';
        leadObj8.Company = '3M';
        leadObj8.Industry = 'Automotive';
        leadObj8.Geography__c ='Unknown';
        leadObj8.Employee_Range__c = 'Fewer than 100';
        leadObj8.Segment__c ='Mid-Market';
        leadObj8.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj9 = new Lead();
        leadObj9.Status = 'Round Robin';
        leadObj9.country = 'philippines';
        leadObj9.LastName = 'tstLastName';
        leadObj9.Company = '3M';
        leadObj9.Industry = 'Automotive';
        leadObj9.Geography__c ='Unknown';
        leadObj9.Employee_Range__c = 'Fewer than 100';
        leadObj9.Segment__c ='Mid-Market';
        leadObj9.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        
        Lead leadObj10 = new Lead();
        leadObj10.Status = 'Round Robin';
        leadObj10.country = '3M';
        leadObj10.LastName = 'tstLastName';
        leadObj10.Company = '3M';
        leadObj10.Industry = 'Automotive';
        leadObj10.Geography__c ='Unknown';
        leadObj10.Employee_Range__c = 'Fewer than 100';
        leadObj10.Segment__c ='Mid-Market';
        leadObj10.Industry = 'Automotive';
        leadObj10.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        List<lead> leadList = new List<lead>{leadObj1,leadObj2,leadObj3,leadObj4,leadObj5,leadObj6,leadObj7,leadObj8,leadObj9,leadObj10};
        //leadList.add(leadObj1); 
        insert leadList;
        Test.stopTest();
    }
    @isTest
    public static void roundRobin(){
        
        Test.startTest();
        
        Lead_Round_Robin__c checkGeography = new Lead_Round_Robin__c();
        checkGeography.AE_Owner_Round_Robin_Geography__c = false;
        checkGeography.Lead_Owner_Round_Robin_Geography__c = false;
        insert checkGeography;
        
        List<Lead_AE_Owner_Round_Robin__c> leadAEOwnerRoundRobinList ;
        Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj1 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj1.Name = 'Rec1';
        leadAEOwnerRoundRobinObj1.UserName__c = 'AEOwnerroundrobin@testuser.com';
        leadAEOwnerRoundRobinObj1.Segment__c = 'Enterprise';

		Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj2 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj2.Name = 'Rec2';
        leadAEOwnerRoundRobinObj2.Geography__c = 'APAC';
        leadAEOwnerRoundRobinObj2.UserName__c = 'AEOwnerroundrobin@testuser.com';
        leadAEOwnerRoundRobinObj2.Segment__c = 'Enterprise';
        leadAEOwnerRoundRobinObj2.Industry__C= 'Automotive';
        
        Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj4 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj4.Name = 'Rec4';
        leadAEOwnerRoundRobinObj4.Geography__c = 'APAC';
        leadAEOwnerRoundRobinObj4.UserName__c = 'AEOwnerroundrobin@testuser.com';
        
        Lead_AE_Owner_Round_Robin__c leadAEOwnerRoundRobinObj5 = new Lead_AE_Owner_Round_Robin__c();
        leadAEOwnerRoundRobinObj5.Name = 'Rec5';
        leadAEOwnerRoundRobinObj5.Catch_All__c = TRUE;
        leadAEOwnerRoundRobinObj5.UserName__c = 'AEOwnerroundrobin@testuser.com';
        
        
       
        leadAEOwnerRoundRobinList = new List<Lead_AE_Owner_Round_Robin__c>{leadAEOwnerRoundRobinObj1,leadAEOwnerRoundRobinObj2,leadAEOwnerRoundRobinObj4,leadAEOwnerRoundRobinObj5};
            insert leadAEOwnerRoundRobinList;
        
        Lead leadObj1 = new Lead();
        leadObj1.Status = 'Round Robin';
        leadObj1.LastName = 'tstLastName';
        leadObj1.Company = 'tstCompany';
        leadObj1.Industry = 'Automotive';
        leadObj1.Geography__c ='APAC';
        leadObj1.Employee_Range__c = 'Fewer than 100';
        leadObj1.Segment__c ='Mid-Market';
        leadObj1.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        insert leadObj1;
        System.debug('leadObj1-->'+leadObj1);
        System.debug('leadObj1-->'+leadObj1.User__c);
        System.debug('leadObj1-->'+leadObj1.OwnerId);
        
        
        
        
        Test.stopTest();
    }
    @isTest
    public static void testMethod5(){
        EDU_Round_Robin__c eduObj1 =  new EDU_Round_Robin__c();
        eduObj1.Geography__c = 'APAC';
        eduObj1.User_name__c = 'test@user.comTEST';
        eduObj1.Name = 'test';
        insert eduObj1;
        Test.startTest();
        Lead leadObj10 = new Lead();
        leadObj10.Status = 'Round Robin';
        leadObj10.country = '3M';
        leadObj10.LastName = 'tstLastName';
        leadObj10.Company = '3M';
        leadObj10.Industry = 'Automotive';
        leadObj10.Geography__c ='Unknown';
        leadObj10.Employee_Range__c = 'Fewer than 100';
        leadObj10.Segment__c ='Mid-Market';
        leadObj10.Industry = 'Automotive';
        leadObj10.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        insert leadObj10;
        Test.StopTest();
    }
    
}
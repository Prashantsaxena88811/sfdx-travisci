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
    
}
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
        //checkGeography.AE_Owner_Round_Robin_Geography__c = true;
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
        leadObj1.Geography__c ='APAC';
        leadObj1.Segment__c ='Enterprise';
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
        //checkGeography.AE_Owner_Round_Robin_Geography__c = false;
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
        leadObj1.Geography__c ='APAC';
        leadObj1.Segment__c ='Enterprise';
        leadObj1.OwnerId = [Select Id from user where username ='emmersiontestUser@sf.com'].Id;
        insert leadObj1;
        System.debug('leadObj1-->'+leadObj1);
        System.debug('leadObj1-->'+leadObj1.User__c);
        System.debug('leadObj1-->'+leadObj1.OwnerId);
        
       
        
        
        Test.stopTest();
    }
    
}
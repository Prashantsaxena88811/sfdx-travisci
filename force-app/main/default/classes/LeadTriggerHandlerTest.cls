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
        insert u;
        System.debug('u-->'+u);
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
        leadAEOwnerRoundRobinObj1.Geography__c = 'LATAM';
        leadAEOwnerRoundRobinObj1.UserName__c = 'leadroundrobin@testuser.com';
        leadAEOwnerRoundRobinObj1.Segment__c = 'Enterprise';
        
        insert leadAEOwnerRoundRobinObj1;
        
        Lead_Owner_Round_Robin__c leadOwnerRoundRobinObj1 = new Lead_Owner_Round_Robin__c();
        //leadOwnerRoundRobinObj1.
        
        Lead leadObj1 = new Lead();
        leadObj1.Status = 'Round Robin';
        
        
        
        
        Test.stopTest();
    }
    
}
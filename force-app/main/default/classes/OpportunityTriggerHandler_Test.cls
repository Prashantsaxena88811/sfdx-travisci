@isTest
public class OpportunityTriggerHandler_Test {
    
    @isTest
    public static void populateSDRFromCloseWonOppTest(){
        
        Account aa = new Account();
        aa.name = 'test';
        insert aa;
        system.debug('aa->'+aa);
        
        RecordType recordType = new RecordType();
        RecordType recordType1 = new RecordType();
        
        recordType = [select id from recordtype where DeveloperName = 'Existing_Business' and SobjectType = 'Opportunity'];
        recordType1 = [select id from recordtype where DeveloperName = 'New_Logo' and SobjectType = 'Opportunity'];
        
        Profile prof = [select id from profile where name LIKE '%admin%' limit 1];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'testEmmersion@test.com';
        user.email = 'test@test.com';
        user.Alias = 'standt';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Los_Angeles';
        user.Alias = 'standt';
        user.Alias = 'standt';
        insert user;
        
        Opportunity op1 = new Opportunity();
        op1.Name ='test op';
        op1.closedate = date.today();
        op1.stagename ='Closed Won';
        op1.AccountId = aa.Id;
        op1.Type = 'New Logo';
        op1.RecordtypeId = recordType1.Id;
        op1.SDR__c = user.id;
        insert op1;
        system.debug('op1------>'+op1);
        
        Opportunity op = new Opportunity();
        op.Name ='test op';
        op.Type = 'New Logo';
        op.closedate = date.today();
        op.stagename ='Discovery';
        op.AccountId = aa.Id;
        op.RecordtypeId = recordType.Id;
        insert op;
        System.debug('op------>'+op.Id);
        
    }
    
    @isTest
    public static void createDualOpportunitiesTest(){
        
        RecordType recordType1 = new RecordType();
        recordType1 = [select id from recordtype where DeveloperName = 'New_Logo' and SobjectType = 'Opportunity'];
        
        Account aa = new Account();
        aa.name = 'test';
        insert aa;
        system.debug('aa->'+aa);
        
        Profile prof = [select id from profile where name LIKE '%admin%' limit 1];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.username = 'testEmmersion@test.com';
        user.email = 'test@test.com';
        user.Alias = 'standt';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Los_Angeles';
        user.Alias = 'standt';
        user.Alias = 'standt';
        insert user;
        
        
        Opportunity op1 = new Opportunity();
        op1.Name ='test op';
        op1.Type = 'New Logo';
        op1.closedate = date.today();
        op1.stagename ='Closed Won';
        op1.AccountId = aa.Id;
        op1.Future_Opp__c = true;
        op1.RecordtypeId = recordType1.Id;
        op1.SDR__c = user.id;
        insert op1;
        system.debug('op1------>'+op1);
    }
}
@isTest
public class OpportunityTriggerHandlerSPIF_Test {
    
    @testSetup static void testData() {
        
        List<UserRole> userRolelistSDR = new List<UserRole>();
        List<UserRole> userRolelistAE = new List<UserRole>();
        
        // get the role Id of SDR
        userRolelistSDR = [Select Id,Name from UserRole where DeveloperName=:'SDR' limit 1];
        // get the role Id of AE (Account_Executive)
        userRolelistAE = [Select Id,Name from UserRole where DeveloperName=:'Account_Executive' limit 1];
        System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);
        
        String profileId  = [SELECT Id FROM Profile WHERE name like '%Admin%' limit 1].Id;
        User u = new User(
            ProfileId = profileId,
            UserRoleID = userRolelistSDR[0].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'SDRUser1@sf.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        User u1 = new User(
            ProfileId = profileId,
            UserRoleID = userRolelistSDR[0].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'SDRUser2@sf.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        User u2 = new User(
            ProfileId = profileId,
            UserRoleID = userRolelistAE[0].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'AEUser1@sf.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        User u4 = new User(
            ProfileId = profileId,
            UserRoleID = userRolelistAE[0].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'AEUser2@sf.com',
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
        userlist.add(u4);
        insert userlist;
        System.debug('userlist-->'+userlist);
        System.debug(userlist[0].username+'--userlistID-->'+userlist[0].Id);
        System.debug(userlist[1].username+'--userlistID1-->'+userlist[1].Id);
        System.debug(userlist[2].username+'--userlistID2-->'+userlist[2].Id);
    }
    
    @isTest static void myTest() {
        Test.startTest();
        SPIF_Activity_Records__c SPIF_ActivityObj1 = new SPIF_Activity_Records__c();
        SPIF_ActivityObj1.Name = 'Rec1';
        SPIF_ActivityObj1.Points__c = 5;
        SPIF_ActivityObj1.Activity_Name__c = 'New Opportunity';
        SPIF_ActivityObj1.Rep_Role__c = 'SDR';
        
        SPIF_Activity_Records__c SPIF_ActivityObj2 = new SPIF_Activity_Records__c();
        SPIF_ActivityObj2.Name = 'Rec2';
        SPIF_ActivityObj2.Points__c = 5;
        SPIF_ActivityObj2.Activity_Name__c = 'New Opportunity';
        SPIF_ActivityObj2.Rep_Role__c = 'Account Executive';
        
        List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
        spifActivityRecords.add(SPIF_ActivityObj1);
        spifActivityRecords.add(SPIF_ActivityObj2);
        
        insert spifActivityRecords;
        
        Account accountObj1 = new Account();
        accountObj1.Name ='test1';
        accountObj1.Products__c = 'TrueNorth';
        accountObj1.Industry = 'Automotive';
        accountObj1.Geography__c = 'LATAM';
        accountObj1.Segment__c = 'Enterprise';
        accountObj1.Top_25_Account__c =  [Select Id from user where username ='SDRUser1@sf.com'].Id;
        // insert accountObj1;
        
        Account accountObj2 = new Account();
        accountObj2.Name ='test1';
        accountObj2.Products__c = 'TrueNorth';
        accountObj2.Industry = 'Automotive';
        accountObj2.Geography__c = 'LATAM';
        accountObj2.Segment__c = 'Enterprise';
        accountObj2.Top_25_Account__c = [Select Id from user where username ='AEUser1@sf.com'].Id;
        // insert accountObj2;
        
        List<Account> accList = new List<Account>();
        accList.add(accountObj1);
        accList.add(accountObj2);
        insert accList;
        
        Opportunity op1 = new Opportunity();
        op1.AccountId = accList[0].Id;
        op1.Name ='optest1';
        //op1.CampaignId = '7010q0000004CsU';
        op1.Type = 'New Logo';
        op1.CloseDate = Date.today();
        op1.StageName = 'Demo';
        op1.CreatedById =  [Select Id from user where username ='AEUser1@sf.com'].Id;
        
        Opportunity op2 = new Opportunity();
        op2.AccountId = accList[1].Id;
        op2.Name ='optest1';
        //op1.CampaignId = '7010q0000004CsU';
        op2.Type = 'New Logo';
        op2.CloseDate = Date.today();
        op2.StageName = 'Demo';
        op2.CreatedById =  [Select Id from user where username ='SDRUser1@sf.com'].Id;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(op1);
        oppList.add(op2);
        
        insert oppList;
        
        Test.stopTest();
        
        
    }
    
}
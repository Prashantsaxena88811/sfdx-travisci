@isTest
public class EventTriggerHandlerTest {
    
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
        SPIF_ActivityObj1.Activity_Name__c = 'Set a Meeting';
        SPIF_ActivityObj1.Rep_Role__c = 'SDR';
        
        SPIF_Activity_Records__c SPIF_ActivityObj2 = new SPIF_Activity_Records__c();
        SPIF_ActivityObj2.Name = 'Rec2';
        SPIF_ActivityObj2.Points__c = 5;
        SPIF_ActivityObj2.Activity_Name__c = 'Set a Meeting';
        SPIF_ActivityObj2.Rep_Role__c = 'Account Executive';
        
        List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
        spifActivityRecords.add(SPIF_ActivityObj1);
        spifActivityRecords.add(SPIF_ActivityObj2);
        
        insert spifActivityRecords;
        
        Lead leadobj = new Lead();
        leadObj.LastName = 'testlead1';
        leadObj.Company = 'testcompany1';
        leadObj.Status = 'Raw Lead';
        leadObj.Top_25_Account__c = [Select Id from user where username ='SDRUser1@sf.com'].Id;
        //insert leadObj;
        
        Lead leadobj1 = new Lead();
        leadobj1.LastName = 'testlead1';
        leadobj1.Company = 'testcompany1';
        leadobj1.Status = 'Raw Lead';
        leadobj1.Top_25_Account__c = [Select Id from user where username ='AEUser1@sf.com'].Id;
        //insert leadobj1;
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(leadobj);
        leadList.add(leadobj1);
        insert leadList;
        
        Event ev1 = new Event();
        ev1.subject ='test1';
        ev1.Meeting_source__c ='Email';
        ev1.startdatetime =datetime.now();
        ev1.Enddatetime =datetime.now();
        ev1.Event_Type__c ='Disco';
        ev1.ownerId =[Select Id from user where username ='SDRUser1@sf.com'].Id;
        ev1.whoId = leadList[0].Id;
        
        Event ev2 = new Event();
        ev2.subject ='test2';
        ev2.Event_Type__c ='Disco';
        ev2.Meeting_source__c ='Email';
        ev2.startdatetime =datetime.now();
        ev2.Enddatetime =datetime.now();
        ev2.ownerId =[Select Id from user where username ='AEUser1@sf.com'].Id;
        ev2.whoId = leadList[1].Id;
        
        List<Event> eventList = new List<Event>();
        eventList.add(ev1);
        eventList.add(ev2);
        insert eventList;
        
        List<Spif__c> spifRecord =  new List<Spif__c>();
        spifRecord = [select OwnerId,Id from spif__c];
        System.debug(spifRecord.size()+'spifRecord-->'+spifRecord);
        
        
        Test.stopTest();
        
        
    }
}
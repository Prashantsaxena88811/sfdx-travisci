@isTest
public class OpportunityTriggerHelperTest {
	static testMethod void opportunityTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test Opp';
        opp.Type = 'New Logo';
        opp.CloseDate = Date.today();
        opp.StageName = 'Closed Won';
        opp.AccountId = acc.Id;
        insert opp;
        
        List<Case> caseRecList = [Select Id from case];
        //system.assertEquals(1,caseRecList.size());
    }
}
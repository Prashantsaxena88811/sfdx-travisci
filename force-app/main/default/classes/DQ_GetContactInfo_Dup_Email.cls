public class DQ_GetContactInfo_Dup_Email implements Queueable  {
    public void execute(QueueableContext context) {
        try{
            
            
            AggregateResult[] countByEmailList = [select count(id),email from contact where email!=null group by email  having count(id)>1 ]; 
            Set<String> emailSet = new Set<String>();
            for(AggregateResult ag:countByEmailList){
                emailSet.add(String.valueOf(ag.get('Email')));
            }
            
            if(!emailSet.isEmpty()){
                //System.debug('=total Count==>'+[Select count(Id) from Contact where Email IN :emailSet]);
                
                List<Contact> contactList = new List<Contact>();
                contactList = [Select Id,FirstName,LastName,Gigya_UID__c,npo02__NumberOfClosedOpps__c,Email from Contact where EMAIL IN :emailSet];   
                
                List<String> csvRowValues = new List<String>();
                for(Contact con :contactList ){
                    String FirstName = con.FirstName!=null ? String.valueOf(con.FirstName ).replace(',', ''): '**BLANK**';
                    String LastName = con.LastName!=null ? String.valueOf(con.LastName ).replace(',', ''): '**BLANK**';
                    
                    String Gigya_UID = con.Gigya_UID__c!=null ? String.valueOf(con.Gigya_UID__c).replace(',', '') : '**BLANK**';
                    String gift = con.npo02__NumberOfClosedOpps__c!=null ? String.valueOf(con.npo02__NumberOfClosedOpps__c).replace(',', '') : '**BLANK**';
                    String rowVal = con.Id+','+FirstName+','+LastName+','+Gigya_UID+','+gift+','+con.Email;
                    csvRowValues.add(rowVal);  
                }
                String csvColumnHeader = 'Id,FirstName,LastName,Gigya_UID,gift,Email  \n';
                String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
                Attachment at = new Attachment();
                at.parentId = '0012C00000XRMii';
                at.Name = 'duplicate_EMAIL-'+datetime.now()+'.csv';
                at.Body = Blob.valueOf(csvFile);
                insert at;
                System.debug('at->'+at);
                
            }
        }catch(Exception e){
            System.debug('get exeption on line number->'+e.getLineNumber()+' error is->'+e.getMessage()+' trace=>'+e.getStackTraceString());
        }
    }
    
}
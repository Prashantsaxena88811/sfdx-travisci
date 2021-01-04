global class Lead_OwnerCustomsorting implements Comparable{
    
    public Lead_Owner_Round_Robin__c userRec;
    
    // Constructor
    public Lead_OwnerCustomsorting(Lead_Owner_Round_Robin__c op) {
        userRec = op;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        Lead_OwnerCustomsorting compareToOppy = (Lead_OwnerCustomsorting)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (userRec.Date__c > compareToOppy.userRec.Date__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (userRec.Date__c < compareToOppy.userRec.Date__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
    
}
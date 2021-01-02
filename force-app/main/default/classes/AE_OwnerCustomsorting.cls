global class AE_OwnerCustomsorting implements Comparable{
    
    public Lead_AE_Owner_Round_Robin__c userRec;
    
    // Constructor
    public AE_OwnerCustomsorting(Lead_AE_Owner_Round_Robin__c op) {
        userRec = op;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        AE_OwnerCustomsorting compareToOppy = (AE_OwnerCustomsorting)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (userRec.Lead_Assigned_DateTime__c > compareToOppy.userRec.Lead_Assigned_DateTime__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (userRec.Lead_Assigned_DateTime__c < compareToOppy.userRec.Lead_Assigned_DateTime__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
    
}
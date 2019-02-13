trigger ManageAccounts on Account (before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate) {
             ManageAccounts.CheckForAddressChanges(Trigger.New, Trigger.Old); 
    }
     
}
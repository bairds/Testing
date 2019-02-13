trigger UpdateCampaignMemberStatus on Campaign (after insert) {
    List<CampaignMemberStatus> newCampaignMemberStatus = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> oldCampaignMemberStatus = new List<CampaignMemberStatus>();
    List<String> campaignIds = new List<String>();
    List<CampaignMemberStatus> checkCampaignMemberStatus = new List<CampaignMemberStatus>();

    if(trigger.size==1) {
        // For single record processing, need to check to see if the campaign member status values already
        // exist.  If the new campaign is being created as a result of the "Clone" operation from within
        // the web interface, the campaign member status values will already exist and the user will get an
        // error if this trigger tries to insert them again.
        
        // Retrieve the existing campaign member status values.
        checkCampaignMemberStatus = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :trigger.new[0].Id];
        for (CampaignMemberStatus c : checkCampaignMemberStatus) {
            system.debug('CampaignMemberStatus is ' + c);
        }
        
        
        Set<String> statusValues = new Set<String>();
        // Create a set of campaign member status values
        for (Integer i=0; i<checkCampaignMemberStatus.size(); i++) {
            String statusFormatted=checkCampaignMemberStatus[i].Label;
            statusFormatted.toUpperCase();
            statusFormatted = statusFormatted.toUpperCase();
            statusValues.Add(statusFormatted);
            
            // Check for the default values.  If they exist, remove them.
            if(checkCampaignMemberStatus[i].Label=='Sent' || checkCampaignMemberStatus[i].Label=='Responded') {
                oldCampaignMemberStatus.add(checkCampaignMemberStatus[i]);
            }
        }
        
        // ENSURE EVERY CAMPAIGN HAS AT LEAST TWO STATUS VALUES - ADDED TO CAMPAIGN & RESPONDED YES        
        // Check to see if the values that need to be added already exist.  If they do not exist, add them.
        
        if (!statusValues.contains('ADDED TO CAMPAIGN')) {
            // Add campaign member status for "Added to campaign"
            CampaignMemberStatus added = new CampaignMemberStatus();
            added.CampaignId=trigger.new[0].Id;
            added.HasResponded=FALSE;
            added.IsDefault=TRUE;
            added.Label='Added to campaign';
            added.SortOrder=3;
            newCampaignMemberStatus.add(added);         
        }
        
        if (!statusValues.contains('RESPONDED YES')) {
            // Add campaign member status for "Responded Yes"
            CampaignMemberStatus respondYes = new CampaignMemberStatus();
            respondYes.CampaignId=trigger.new[0].Id;
            respondYes.HasResponded=TRUE;
            respondYes.IsDefault=FALSE;
            respondYes.Label='Responded Yes';
            respondYes.SortOrder=4;
            newCampaignMemberStatus.add(respondYes);  
        }  
        
        //ADD ALL THE OTHER CAMPAIGN STATI IN THE CAMPAIGNSTATI__C CUSTOM SETTING
        List<CampaignStatiMDT__mdt> CSMDTs = [select MasterLabel, HasResponded__c from CampaignStatiMDT__mdt];
        Map<string, CampaignStatiMDT__mdt> CSMap = new Map<string, CampaignStatiMDT__mdt>();
        For (CampaignStatiMDT__mdt c : CSMDTs) CSMap.put(c.MasterLabel,c);
        //system.debug('CampaignStati to be added from custom setting are ' + CSs);
        integer i=0;
        for (string s : CSMap.keyset()) {
            if (!statusValues.contains(s.toUpperCase())) {
                CampaignStatiMDT__mdt CS = CSMap.get(s);
                // Add campaign member status for "Communication sent"
                CampaignMemberStatus CMS = new CampaignMemberStatus();
                CMS.CampaignId=trigger.new[0].Id;
                CMS.HasResponded=CS.HasResponded__c;
                CMS.IsDefault=FALSE;
                CMS.Label=s;
                CMS.SortOrder=i+5;
                newCampaignMemberStatus.add(CMS); 
                i=i+1;
            }
            
        }
        
        if (!newCampaignMemberStatus.isEmpty() && !trigger.new[0].isClone()) {
            System.debug('About to create ' + newCampaignMemberStatus);
            insert newCampaignMemberStatus;
        }
        
        if (!oldCampaignMemberStatus.isEmpty()) {
            System.debug('About to delete ' + oldCampaignMemberStatus);
            delete oldCampaignMemberStatus;
        }  
        
    }
    
    else {

        List<CampaignStatiMDT__mdt> CSMDTs = [select MasterLabel, HasResponded__c from CampaignStatiMDT__mdt];
        Map<string, CampaignStatiMDT__mdt> CSMDTMap = new Map<string, CampaignStatiMDT__mdt>();
        For (CampaignStatiMDT__mdt c : CSMDTs) CSMDTMap.put(c.MasterLabel,c);

        Map<Id, List<CampaignMemberStatus> > cmsMap = new Map<Id, List<CampaignMemberStatus> > ();
        for (CampaignMemberStatus cms : [Select Id, label, isDefault, CampaignId from CampaignMemberStatus WHERE 
                                         CampaignId IN :trigger.new] ) {
            List<CampaignMemberStatus> tempCMS;
            if (cmsMap.Containskey(cms.CampaignId)) {
                tempCMS = cmsMap.get(cms.CampaignId);
            }
            else {
                tempCMS = new List<CampaignMemberStatus> ();
            }
            tempCMS.add(cms);
            cmsMap.put(cms.CampaignId, tempCMS);
        }
        system.debug(cmsMap);
        
        for (Campaign c : trigger.new) {
            // Add campaign ids to list for removal of campaign member status values
            campaignIds.add(c.id); 
            system.debug('Now going through campaign ' + c.id);
/*        List<CampaignMemberStatus> CMSList = cmsMap.get(c.Id);
            for (CampaignMemberStatus cms : CMSList) {
            system.debug('CampaignMemberStatus is ' + cms);
        }
*/

        Set<String> statusValues = new Set<String>();
        // Create a set of campaign member status values
        for (Integer i=0; i<checkCampaignMemberStatus.size(); i++) {
            String statusFormatted=checkCampaignMemberStatus[i].Label;
            statusFormatted.toUpperCase();
            statusFormatted = statusFormatted.toUpperCase();
            statusValues.Add(statusFormatted);
            
            // Check for the default values.  If they exist, remove them.
            if(checkCampaignMemberStatus[i].Label=='Sent' || checkCampaignMemberStatus[i].Label=='Responded') {
                oldCampaignMemberStatus.add(checkCampaignMemberStatus[i]);
            }
        }
        
        // ENSURE EVERY CAMPAIGN HAS AT LEAST TWO STATUS VALUES - ADDED TO CAMPAIGN & RESPONDED YES        
        // Check to see if the values that need to be added already exist.  If they do not exist, add them.
        
        if (!statusValues.contains('ADDED TO CAMPAIGN')) {
            // Add campaign member status for "Added to campaign"
            CampaignMemberStatus added = new CampaignMemberStatus();
            added.CampaignId=c.Id;
            added.HasResponded=FALSE;
            added.IsDefault=TRUE;
            added.Label='Added to campaign';
            added.SortOrder=3;
            newCampaignMemberStatus.add(added);         
        }
        
        if (!statusValues.contains('RESPONDED YES')) {
            // Add campaign member status for "Responded Yes"
            CampaignMemberStatus respondYes = new CampaignMemberStatus();
            respondYes.CampaignId=c.Id;
            respondYes.HasResponded=TRUE;
            respondYes.IsDefault=FALSE;
            respondYes.Label='Responded Yes';
            respondYes.SortOrder=4;
            newCampaignMemberStatus.add(respondYes);  
        }  
        
        //ADD ALL THE OTHER CAMPAIGN STATI IN THE CampaignStatiMDT__mdt CUSTOM Metadata
            List<CampaignStatiMDT__mdt> SettingCMs = [select Label, HasResponded__c from CampaignStatiMDT__mdt];
            Map<string, CampaignStatiMDT__mdt> CSMs = new Map<string, CampaignStatiMDT__mdt>();
            integer i=0;
            For (CampaignStatiMDT__mdt csm : SettingCMs){
            if (!statusValues.contains(csm.label.toUpperCase())) {
                // CampaignStati__c CS = CSs.get(csm.label);
                // Add campaign member status for "Communication sent"
                CampaignMemberStatus CMS = new CampaignMemberStatus();
                CMS.CampaignId=c.Id;
                CMS.HasResponded=csm.HasResponded__c;
                CMS.IsDefault=FALSE;
                CMS.Label=csm.label;
                CMS.SortOrder=i+5;
                newCampaignMemberStatus.add(CMS); 
                i=i+1;
            }
        }              
            // SOQL query to retrieve the default campaign member status values which will be removed after the new values are inserted.
            oldCampaignMemberStatus = [select cms.id, campaignId, label, isDefault from CampaignMemberStatus cms where cms.CampaignId in :campaignIds];
        } // END TRIGGER LOOP
        
        if (!newCampaignMemberStatus.isEmpty()) {
            for (CampaignMemberStatus cms : newCampaignMemberStatus) {
                system.debug('Campaign: ' + cms.CampaignId + ', NewCMS: ' + cms);
            }
            insert newCampaignMemberStatus;
        }
        
        if (!oldCampaignMemberStatus.isEmpty()) {
            for (CampaignMemberStatus cms : oldCampaignMemberStatus) {
                system.debug('Campaign: ' + cms.CampaignId + ', OldCMS: ' + cms);
            }
            delete oldCampaignMemberStatus;
        }
    } // end else TRIGGER SIZE > 1
    
} // END TRIGGER
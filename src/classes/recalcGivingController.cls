public class recalcGivingController {
    
    public recalcGivingController(ApexPages.StandardController stdController) {
    }

public void RecalcGiving() {
List<contact> contacts = [Select Id, LastName, 
(select OpportunityID, Opportunity.CloseDate, 
 Opportunity.Amount from OpportunityContactRoles
 where Opportunity.IsWon = true Order by Opportunity.CloseDate DESC)
 from contact ORDER BY LastName];
system.debug(contacts);

List<contact> contactResults = new List<Contact>();
For (Contact c : contacts) {
    c = contribTotals(c);
    contactResults.add(c);
    }
try {
    update contactResults; 
    sendCompletionEmail();
    }
    Catch (Exception Ex) {system.debug(Ex);}
} // end recalcGiving
    
public static Contact contribtotals(Contact c) {
    List<OpportunityContactRole> colist = new List<OpportunityContactRole> ();
    
    colist = c.OpportunityContactRoles; 
        Decimal ltgiving = 0;   
        Decimal lastgift = 0; //Most recent gift amount
        Date lastgiftdate; //most recent gift date  
        Decimal largestgift = 0;
        Date largestgiftdate;   
        Decimal ytdgiving = 0; //YTD Giving and count
        Decimal pytdgiving = 0; //Last Year Giving and Count
        Decimal ppytdgiving = 0;
        Integer thisyear = system.today().year();
        
        if (colist.size() > 0) {
            For (OpportunityContactRole o: colist) {
                if (o.opportunity.amount > 0) ltgiving = ltgiving + o.opportunity.amount;
                
                //check if lastgift is still null
                if (lastgiftdate == null) {
                    lastgiftdate = o.opportunity.closedate;
                    lastgift = o.opportunity.amount;
                    } 
                // otherwise update date if this opportunity is more recent
                else {
                    if (o.opportunity.closedate > lastgiftdate) {
                        lastgiftdate = o.opportunity.closedate;
                        lastgift = o.opportunity.amount;
                        }
                    else {} // do nothing
                    } // end else for find last gift
                
                
                //check if largestgift is still null
                if (largestgiftdate == null) {
                    largestgiftdate = o.opportunity.closedate;
                    largestgift = o.opportunity.amount;
                    } 
                // otherwise update if this opportunity.amount is more larger
                else {
                    if (o.opportunity.amount > largestgift) {
                        largestgiftdate = o.opportunity.closedate;
                        largestgift = o.opportunity.amount;
                        }
                    else {} // do nothing
                    } // end else for find largest gift 
                
                //year to date giving
                if (o.opportunity.amount > 0) {
                if (o.opportunity.closedate.year() == thisyear) 
                    ytdgiving = ytdgiving + o.opportunity.amount;   
                else {
                    if (o.opportunity.closedate.year() == (thisyear -1 )) {
                        pytdgiving = pytdgiving + o.opportunity.amount; }
                    else {
                        if (o.opportunity.closedate.year() == (thisyear -2 )) {
                        ppytdgiving = ppytdgiving + o.opportunity.amount; }
                        else {} // do nothing
                    } // end else ppytdgiving
                } // end else pytdgiving
            } // end if o.opportunity.amount > 0
                            
                    
            system.debug('LTGiving is now '+ ltgiving);
            } //end loop
        } //end if
    c.Lifetime_Giving__c = ltgiving;
    c.Last_Contrib_Amt__c = lastgift;
    c.Last_Contrib_Date__c = lastgiftdate;
    c.Largest_Contrib_Amt__c = largestgift;
    c.Largest_Contrib_Date__c = largestgiftdate;
    c.YeartoDate_Giving__c = ytdgiving;
    c.Last_Year_Giving__c = pytdgiving;
    c.Year_Before_Last_Giving__c = ppytdgiving;
    return c;
    } //end contribTotals
    
public void sendCompletionEmail() {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setReplyTo('baird@leadgreen.org');
    mail.setSenderDisplayName('WaterGrass');
    mail.setSubject('Giving has been recalculated');
    mail.setPlainTextBody('Contact giving totals have been recalculated.  They will be accurate unless you have added new contributions since you clicked the Recalculate Giving button.');
    mail.saveAsActivity = false;
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } // End CompletionEmail
} //
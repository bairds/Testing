// Last edit Baird 12 Apr 2015
// Invoked by Contribution Trigger 
// When new contribution is created or when contribution is edited
// update the related account 
// recalculate the primary contributor's donation totals
// Update the last membership amount only if the closedate > account_membership_expires__c - 365
// if they are a campaign member, update the campaign member status to "paid" - is this necessary?  Is anyone using this feature?
// insert, update, or remove the contact role
// Calculates first_membership_source for accounts (6 Apr 2015)
// Change calculation of Contrib.type to Contrib.membership_type__c 20 April 2015
// Insert Test.isTestRunning() to create Individual_Cotnribution_Types 24 April 2015
// Add last_contrib_date__c, last_donate_date__c, last_membership_date__c 12 Apr 2015
// Correct so that when all contribs are deleted all summary fields are 0 1 Dec 2015
// Add Next_Payment_Date__c calculation as part of calculate pledge method 4 Dec 2015, expand 8 Dec 2015
// First_donation_date and last_donate_date corrected 5 Jan 2016
// 3 Feb 2017 Filter out contributions where closed!=false
// Apr 2017 Add recalcContactMethod
// Apr 2018 Added Contact rollups
// May 2018 Added first_member_date
// Aug 2018 Revised contact.first_contrib_cat and source, which weren't working before.
// Aug 2018 Revisions for 2018 Upgrade.  Lifetime_Donations__c now calculated, not rollup.  First_member_date corrected.
// Sept 2018 If Campaign.Account_Line_Item is populated, populate Contrib.Account_Line_Item
// May 2019 Add "yearly" to the periodicity values for recurring payments, in recurring payment section

public class ManageContributions{
    public static Set<Id> AccountIds;
    public static Set<Id> PledgeIds;
    public static Set<Id> ContactIDs;
    public static Id membershipRTID;
    public static Id PledgeRTID;
    public static Set<Id> DonationRTIDs;
    public static Id UnknownCampaignId;
    // NOTE: REDUCE FOLLOWING 2 SOQL QUERIES TO ONE LIST QUERY.
    public static void beforeDelete(Opportunity []  Contribs) {
        AccountIds = new Set<Id>();
        ContactIds = new Set<Id>();
        PledgeIds = new Set<Id>();
        for (Opportunity o : Contribs) {
            AccountIds.add(o.AccountId);
            ContactIds.add(o.Contact__c);
            System.debug('List to delete includes opportunities in ' + AccountIds.size() + ' separate accounts.');
            if (o.Matches_Which_Challenge_or_Pledge__c!=null) PledgeIds.add(o.Matches_Which_Challenge_or_Pledge__c);
        }
        if (ContactIDs!=null) {
            System.debug('In beforeDelete() PledgeIDs list has  ' + PledgeIds.size() + ' members. ');
        }
    }

    public static void afterDelete() {
        System.debug('Just entered ManageContributions.afterDelete().');
        membershipRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        PledgeRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        DonationRTIDs = new Set<Id>();
        List<IndividualContribTypes__mdt> DonationRTtypes = [select label from IndividualContribTypes__mdt];

        // List<Individual_Contrib_Types__c> DonationRTtypes = Individual_Contrib_Types__c.getAll().values();
        List<String> DonationRTstrings = new List<String>();
        // for (Individual_Contrib_Types__c ict : DonationRTtypes) DonationRTstrings.add(ict.);
        for (IndividualContribTypes__mdt ict : DonationRTtypes) DonationRTstrings.add(ict.Label);
        for (String s : DonationRTstrings)  DonationRTIDs.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId());
        AvoidRecursiveContributionTrigger.setWorking();
        ManageContributions.recalcAccountMethod(AccountIds);
        ManageContributions.recalcContactMethod(ContactIds);
        AvoidRecursiveContributionTrigger.setClosed();
        if (PledgeIds.size()>0) updatePledges(PledgeIds);
    }

    public static void afterInsert(Opportunity [] Contribs) {
        AccountIds = new Set<Id>();
        PledgeIds = new Set<Id>();
        System.debug('Just entered ManageContributions.afterInsert().');
        membershipRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        PledgeRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        DonationRTIDs = new Set<Id>();
        List<IndividualContribTypes__mdt> DonationRTtypes = [select label from IndividualContribTypes__mdt];
        List<String> DonationRTstrings = new List<String>();
        for (IndividualContribTypes__mdt ict : DonationRTtypes) DonationRTstrings.add(ict.Label);

        for (String s : DonationRTstrings)  {
            system.debug('s is ' + s);
            system.debug('Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId() is ' + Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId());
            DonationRTIDs.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId());
        }
        System.debug('DonationRTIDs is ' + DonationRTIDs);
        ManageContributions.setContribOrder(Contribs);
        for (Opportunity o : Contribs) {
            if (o.Matches_Which_Challenge_or_Pledge__c!=null) {
                PledgeIds.add(o.Matches_Which_Challenge_or_Pledge__c);
            } else {
                if (o.RecordTypeId == PledgeRTID) PledgeIds.add(o.Id);
            }
        }
        System.debug('AfterInsert list of PledgeIDs to update is ' + PledgeIds);
        if (PledgeIds.size()>0) updatePledges(PledgeIds);
    } //end after insert

    public static void setContribOrder(Opportunity [] Contribs) {

        // If there are multiple donations from one person, we have to know which is the most recent.
        // Because all triggers fire before roll-ups are recalculated, we can't rely on roll-ups.
        // (see http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_triggers_order_of_execution.htm)
        // We have to order donations by account into a map and filter out the most recent.

        Set<Id> ContribsByAcctID = new Set<Id>();
        Set<Id> ContribsByCtctId = new Set<Id>();
        for (Opportunity o : Contribs) {
            ContribsByAcctID.add(o.AccountId);
            ContribsByCtctId.add(o.Contact__c);
        }
        ManageContributions.recalcAccountMethod(ContribsByAcctID);
        ManageContributions.recalcContactMethod(ContribsByCtctId);
        // The updatePrimaryContribCampStatus should be built into the recalcContactMethod to be more efficient.
        // It doesn't update contact, account, or contrib so it won't trigger recalculation again.
        updatePrimaryContributorCampaignStatus.UpdateCMStatus(Contribs);
    }

    public static void recalcAccountMethod(Set<Id> acctIDs) {
        if (PledgeIds == null) PledgeIds = new Set<Id>();
        // Get the list of fields considered individual contributions from the custom setting
        DonationRTIDs = new Set<Id>();
        membershipRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        List<IndividualContribTypes__mdt> DonationRTtypes = [select label from IndividualContribTypes__mdt];
        List<String> DonationRTstrings = new List<String>();
        for (IndividualContribTypes__mdt ict : DonationRTtypes) DonationRTstrings.add(ict.Label);
        for (String s : DonationRTstrings)  DonationRTIDs.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId());

        List<Account> ContribsByAcct = [select Id, Name, Last_Contrib_Date__c, Last_Donate_Date__c,
                Account_Membership_Expires__c, (select Id, Membership_End_Date__c,
                Amount, CloseDate, RecordTypeId, RecordType.Name, CampaignId, Campaign.Name, Periodicity__c,
                Start_Date__c, Number_of_Payments__c from Opportunities WHERE (IsWon=true OR StageName LIKE '%Won')
        order by CloseDate DESC, Amount DESC)
        from Account where Id in :acctIDs];

        Map<Id,Integer> MembershipsInAcct = new Map<Id,Integer>{};
        for (Account a : ContribsByAcct) {
            Integer oppcount = 0;
            For (Opportunity o : a.Opportunities) {
                if (o.RecordTypeId == membershipRTID) oppcount += 1;
            }
            MembershipsInAcct.put(a.Id,oppcount);
        }

        List<Opportunity> UpdateContribs = new List<Opportunity>();
        List<Account> updateAccts = new List<Account>();

        //Loop through each account
        For (Account a : ContribsByAcct) {
            System.debug('At start of Account loop, Account is now ' + a);
            Boolean foundDonation = false;
            Integer MembershipCnt = 1;
            Date nextMembershipDate;
            Date nextDonationDate;
            a.Lifetime_Donations__c = 0;
            a.Lifetime_Donation_Count__c = 0;
            a.Largest_Contrib__c = 0;
            a.Largest_Contrib_Date__c = null;
            a.Last_Contrib_Amount__c = 0;
            a.Last_Contrib_Date__c = null;
            a.Last_Donate_Amount__c = 0;
            a.Last_Membership_Amount__c = 0;
            a.Last_Donate_Date__c = null;
            a.First_Donate_Date__c = null;
            a.First_Donate_Amount__c = 0;
            a.Last_Membership_Date__c = null;
            a.First_Member_Date__c = null;
            a.First_Member_Source__c = null;
            Decimal ytddonations = 0; //YTD Giving and count
            Decimal pytddonations = 0; //Last Year Giving and Count
            Decimal ppytddonations = 0;
            Decimal Three3YearAgoDonations = 0;
            Decimal Four4YearAgoDonations = 0;
            Decimal Five5YearAgoDonations = 0;
            Integer thisyear = System.today().year();

            if(a.Opportunities.size() > 0) {

                // For the last contrib date and amount, we simply take the most recent contribution
                // even if it's a payment or a volunteer task, which means the amount may be 0.
                a.Last_Contrib_Amount__c = a.Opportunities[0].Amount;
                a.Last_Contrib_Date__c = a.Opportunities[0].CloseDate;
                a.Last_Contrib_Source__c = a.Opportunities[0].Campaign.Name;

                //iterate through the opportunities from the most recent to the oldest
                System.debug(a + ' has ' + a.Opportunities.size() + ' contributions.');
                for(Integer i=0; i<a.Opportunities.size(); i++) {
                    // Assign pledges to PledgeIds for further processing
                    if (a.Opportunities[i].RecordTypeId == PledgeRTID) PledgeIds.add(a.Opportunities[i].Id);
                    // Set contribOrder
                    a.Opportunities[i].ContribOrder__c = a.Opportunities.size()-i;

                    System.debug('Donation ' + i + ' is ' + a.Opportunities[i].RecordType.Name + ' ' + a.Opportunities[i].RecordTypeId + ' of amount ' + a.Opportunities[i].Amount + ' on date ' + a.Opportunities[i].CloseDate + ' and DonationRTIDs is ' + DonationRTIDs );
                    // Set Lapse Till Next Donation
                    // Only process individual donation records now
                    if (DonationRTIDs.contains(a.Opportunities[i].RecordTypeId) && (a.Opportunities[i].amount != null)) {
                        // We are iterating from most recent to oldest,
                        // so the last iteration will have the oldest date and the first the most recent
                        If (foundDonation == false) {
                            a.Last_Donate_Amount__c = a.Opportunities[i].Amount;
                            a.Last_Donate_Date__c = a.Opportunities[i].CloseDate;
                            foundDonation = true;
                        }
                        a.First_Donate_Amount__c = a.Opportunities[i].Amount;
                        a.First_Donate_Date__c = a.Opportunities[i].CloseDate;
                        a.Lifetime_Donations__c += a.Opportunities[i].Amount;
                        a.Lifetime_Donation_Count__c += 1;
                        // Is this the most recent donation?
                        if (nextDonationDate==null) {
                            //This is the most recent donation set Lapse to null
                            a.Opportunities[i].Donate_Lapse__c = null;
                        } else {
                            System.debug('Found that there is another donation so can calculate lapse.');
                            a.Opportunities[i].Donate_Lapse__c = a.Opportunities[i].CloseDate.daysBetween(nextDonationDate);
                            nextDonationDate = a.Opportunities[i].CloseDate;
                            System.debug('For Donation ' + i + ' of amount ' + a.Opportunities[i].Amount + ' found a lapse of ' + a.Opportunities[i].Donate_Lapse__c);
                        }
                        // Increment NextDonationDate
                        nextDonationDate = a.Opportunities[i].CloseDate;
                        // Set Lapse for Membership
                        system.debug('Opp.recordTypeId is ' + a.Opportunities[i].RecordTypeId + ' and membershipRTID is ' + membershipRTID);
                        if (a.Opportunities[i].RecordTypeId == membershipRTID) {
                            a.First_Member_Date__c = a.Opportunities[i].CloseDate;
                            a.First_Member_Source__c = a.Opportunities[i].Campaign.Name;
                            System.debug('MembershipCnt is ' + MembershipCnt + ' and MembershipsInAcct.get(a.id) is ' + MembershipsInAcct.get(a.Id));
                            if (MembershipCnt == MembershipsInAcct.get(a.Id))  {
                                a.Opportunities[i].Membership_Type__c = 'New Membership';
                                // a.first_member_source__c = a.opportunities[i].campaign.Name;
                                // a.First_Member_Date__c = a.Opportunities[i].CloseDate;
                                System.debug('In MembershipCnt==MembershipsInacct.get(a.Id) and set First_Member_Date__c to ' + a.First_Member_Date__c);
                            } else {
                                a.Opportunities[i].Membership_Type__c = 'Renewal';
                            }
                            if (nextMembershipDate == null) {
                                a.Opportunities[i].Member_Lapse__c = null;
                                a.Last_Membership_Amount__c = a.Opportunities[i].Amount;
                                a.Last_Membership_Date__c = a.Opportunities[i].CloseDate;
                            } else {
                                a.Opportunities[i].Member_Lapse__c = a.Opportunities[i].CloseDate.daysBetween(nextMembershipDate);
                            }
                            MembershipCnt = MembershipCnt+1;
                            nextMembershipDate = a.Opportunities[i].CloseDate;
                        }
                        // Calculate yearly donations
                        if (a.Opportunities[i].Amount != null) {
                            if (a.Opportunities[i].CloseDate.year() == thisyear)
                                ytddonations = ytddonations + a.Opportunities[i].Amount;
                            else if(a.Opportunities[i].CloseDate.year() == (thisyear -1 ))
                                pytddonations = pytddonations + a.Opportunities[i].Amount;
                            else if(a.Opportunities[i].CloseDate.year() == (thisyear -2 ))
                                ppytddonations = ppytddonations + a.Opportunities[i].Amount;
                            else if(a.Opportunities[i].CloseDate.year() == (thisyear -3 ))
                                Three3YearAgoDonations += a.Opportunities[i].Amount;
                            else if(a.Opportunities[i].CloseDate.year() == (thisyear -4 ))
                                Four4YearAgoDonations += a.Opportunities[i].Amount;
                            else if(a.Opportunities[i].CloseDate.year() == (thisyear -5 ))
                                Five5YearAgoDonations += a.Opportunities[i].Amount;
                        }
                        // end update last_membership_amt
                    } // end if a.opportunities[i].recordTypeId in DonationRTIDs
                    // Make sure opportunity has a campaign name
                    if (a.Opportunities[i].Campaign.Name == null) {
                        a.Opportunities[i].CampaignId = UnknownCampaignId == null?
                            WGHelpers.getUnknownCampaignID() : UnknownCampaignId;
                    }
                    //

                    UpdateContribs.add(a.Opportunities[i]);

                    // Update account summary fields.
                    // for donations and for memberships, we have to check for the RTID to make sure this is an individual donation.
                    // if(i=1) set first_contrib_source, first_contrib_cat
                    // Update last_donate_amt if foundDonation is false;
                    System.debug('Is RTID considered an indiv donation?' + DonationRTIDs.contains(a.Opportunities[i].RecordTypeId));
                    if (DonationRTIDs.contains(a.Opportunities[i].RecordTypeId)){

//                         update first_donation_date.  We are iterating from most recent to oldest,
//                        // so the last iteration will have the oldest date and the first the most recent
//                        a.First_Donate_Date__c = a.opportunities[i].closeDate;
//                        system.debug('XXX Just before Last_Donate_Amt update foundDonation is ' + foundDonation);
//                        // update last_donate_date
//                        if (foundDonation == false) {
//                            a.Last_Donate_Amount__c = a.opportunities[i].amount;
//                            system.debug('XXX Last_Donate_Amt is ' + a.Last_Donate_Amt__c);
//                            a.Last_Donate_Date__c = a.opportunities[i].closeDate;
//                            foundDonation = true;
//                        } // end update last_donate_amt__c


                    }
                    if (i==a.Opportunities.size()-1) {
                        a.First_Contrib_Source__c = a.Opportunities[i].Campaign.Name;
                        a.First_Contrib_Cat__c = a.Opportunities[i].RecordType.Name;
                    }
                    //Largest contribution
                    if(a.Largest_Contrib__c < a.Opportunities[i].Amount) {
                        a.Largest_Contrib__c = a.Opportunities[i].Amount;
                        a.Largest_Contrib_Date__c = a.Opportunities[i].CloseDate;
                    }
                } // end opportunity loop
            } // end if (a.Opportunities.size() > 0)
            //Giving over past years.  This section is outside the a.Opportunities.size() > 0 loop because
            //if there are no contributions then all these totals should be set to 0.
            a.YearToDate_Donations__c = ytddonations;
            a.Last_Year_Donations__c = pytddonations;
            a.Year_Before_Last_Donations__c = ppytddonations;
            a.X3_Years_Ago_Donations__c = Three3YearAgoDonations;
            a.X4_Years_Ago_Donations__c = Four4YearAgoDonations;
            a.X5_Years_Ago_Donations__c = Five5YearAgoDonations;

            updateAccts.add(a);
        } // end account loop
        try {
            update updateAccts;
        }
        // Caution: Because of the try/catch, in some cases, the previous changes saved (ie the update UpdateOpps in the method)
        // won't be rolled back.  In this case, that wouldn't be a problem.  Try/catch overrides normal rollback behavior.
        Catch (Exception Ex) {System.debug(Ex);}
        System.debug('UpdateContribs is ' + UpdateContribs);
        AvoidRecursiveContributionTrigger.setWorking();
        update UpdateContribs;
        AvoidRecursiveContributionTrigger.setClosed();
    } // end method

    public static void recalcContactMethod(Set<Id> ctctIDs) {
        DonationRTIDs = new Set<Id>();
        List<IndividualContribTypes__mdt> DonationRTtypes = [select label from IndividualContribTypes__mdt];
        List<String> DonationRTstrings = new List<String>();
        for (IndividualContribTypes__mdt ict : DonationRTtypes) DonationRTstrings.add(ict.Label);
        for (String s : DonationRTstrings)  DonationRTIDs.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(s).getRecordTypeId());

        List<Opportunity> Contribs = [select Id, Membership_End_Date__c, Hours_Actual__c,
                Amount, CloseDate, RecordTypeId, Contact__c, RecordType.Name, CampaignId, Campaign.Name, Periodicity__c,
                Start_Date__c, Number_of_Payments__c from Opportunity WHERE (IsWon=true OR StageName LIKE '%Won') AND
        Contact__c in :ctctIDs ORDER BY CloseDate DESC, Amount DESC];
        System.debug('List of Contributions for this Contact is ' + Contribs);
        // Populate a map of all the contacts;
        List<Id> CtctIdList = new List<Id>();
        For (Opportunity o : Contribs) CtctIdList.add(o.Contact__c);
        Map<Id,Contact> CtctListMap = new Map<Id,Contact>();
        List<Contact> CtctList = [select Id, Name from Contact where Id in: CtctIdList];
        for (Contact c : CtctList) {
            CtctListMap.put(c.Id,c);
        }
        System.debug('CtctListMap is ' + CtctListMap);
        // Create a map of <contact,List<Opportunity>> ordered by CloseDate;
        Map<Id,List<Opportunity>> ContribsByCtctId = new Map<Id,List<Opportunity>>();
        For (Opportunity o : Contribs){
            if (ContribsByCtctId.containsKey(o.Contact__c)) {
                ContribsByCtctId.get(o.Contact__c).add(o);
            } else {
                List<Opportunity> newOppList = new List<Opportunity>();
                newOppList.add(o);
                ContribsByCtctId.put(o.Contact__c,newOppList);
            }
        }
        /*    CONSULT WITH CARL WHETHER WE SHOULD PUT MEMBERSHIP EXPIRATION DATE ON CONTACT
List<Account> MembershipsByAcct = [select id, name, (select id from Opportunities
where recordTypeId=:MembershipRTID) from Account where id in :acctIDs];
Map<id,integer> MembershipsInAcct = new Map<id,integer>{};
for (Account a : MembershipsByAcct) {MembershipsInAcct.put(a.id, a.opportunities.size());
system.debug('Account ' + a.name + ' has ' + MembershipsInAcct.get(a.id) + ' memberships.');
}
*/
        List<Opportunity> UpdateContribs = new List<Opportunity>();
        List<Contact> updateCtcts = new List<Contact>();

        //Loop through each contact
        For (Contact c : CtctList) {
            String FirstMemberSource = null;
            Boolean foundCtctDonation = false;
            Integer MembershipCnt = 1;
            Date nextMembershipDate;
            Date nextDonationDate;
            c.Lifetime_Giving__c = 0;
            c.Lifetime_Donation_Count__c = 0;
            c.Largest_Contrib_Amt__c = 0;
            c.Largest_Contrib_Date__c = null;
            c.Last_Contrib_Amt__c = 0;
            c.Last_Contrib_Date__c = null;
            c.Last_Donate_Amt__c = 0;
            c.Last_Donate_Date__c = null;
            c.First_Donate_Amount__c = 0;
            c.First_Donate_Date__c = null;
            Decimal ytddonations = 0; //YTD Giving and count
            Decimal pytddonations = 0; //Last Year Giving and Count
            Decimal ppytddonations = 0;
            Decimal Three3YearAgoDonations = 0;
            Decimal Four4YearAgoDonations = 0;
            Decimal Five5YearAgoDonations = 0;
            Integer Vol_Event_Count = 0;
            Decimal LifetimeVolHours = 0.00;
            Decimal ytdvolhours = 0;
            Decimal pytdvolhours = 0;
            Decimal ppytdvolhours = 0;
            Decimal Three3YearAgovolhours = 0;
            Decimal Four4YearAgovolhours = 0;
            Decimal Five5YearAgovolhours = 0;
            Integer thisyear = System.today().year();

            if(ContribsByCtctId.get(c.Id) != null) {
                List<Opportunity> OppsForThisCtct = ContribsByCtctId.get(c.Id);

                // For the last contrib date and amount, we simply take the most recent contribution
                // even if it's a payment or a volunteer task, which means the amount may be 0.
                c.Last_Contrib_Amt__c = OppsForThisCtct[0].Amount;
                c.Last_Contrib_Date__c = OppsForThisCtct[0].CloseDate;

                //iterate through the opportunities from the most recent to the oldest
                for(Integer i=0; i<OppsForThisCtct.size(); i++) {

                    if (OppsForThisCtct[i].Amount > 0) {
                        c.Lifetime_Giving__c += OppsForThisCtct[i].Amount;
                    }
                    c.First_Contrib_Source__c = OppsForThisCtct[i].Campaign.Name;
                    c.First_Contrib_Cat__c = OppsForThisCtct[i].RecordType.Name;

                    // Assign pledges to PledgeIds for further processing
                    if (OppsForThisCtct[i].RecordTypeId == PledgeRTID) PledgeIds.add(OppsForThisCtct[i].Id);

                    // Set Lapse Till Next Donation
                    // Only process individual donation records now
                    if (DonationRTIDs.contains(OppsForThisCtct[i].RecordTypeId )) {
                        c.Lifetime_Donation_Count__c += 1;
/*                        // Is this the most recent donation?
                        if (NextDonationDate==null) {
                            //This is the most recent donation set Lapse to null
                            OppsForThisCtct[i].Donate_Lapse__c = null;
                        } else {
                            System.debug('Found that there is another donation so can calculate lapse.');
                            OppsForThisCtct[i].Donate_Lapse__c = OppsForThisCtct[i].closedate.daysBetween(NextDonationDate);
                            NextDonationDate = OppsForThisCtct[i].closeDate;
                            System.debug('For Donation ' + i + ' of amount ' + OppsForThisCtct[i].amount + ' found a lapse of ' + OppsForThisCtct[i].Donate_Lapse__c);
                        }
                        // Increment NextDonationDate
                        NextDonationDate = OppsForThisCtct[i].closeDate;
*/
                        // Don't handle memberships at the contact level
                        // Calculate yearly donations
                        if (OppsForThisCtct[i].Amount != null) {
                            if (OppsForThisCtct[i].CloseDate.year() == thisyear)
                                ytddonations = ytddonations + OppsForThisCtct[i].Amount;
                            else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -1 ))
                                pytddonations = pytddonations + OppsForThisCtct[i].Amount;
                            else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -2 ))
                                ppytddonations = ppytddonations + OppsForThisCtct[i].Amount;
                            else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -3 ))
                                Three3YearAgoDonations += OppsForThisCtct[i].Amount;
                            else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -4 ))
                                Four4YearAgoDonations += OppsForThisCtct[i].Amount;
                            else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -5 ))
                                Five5YearAgoDonations += OppsForThisCtct[i].Amount;
                        }
                    } // end if OppsForThisCtct[i].recordTypeId in DonationRTIDs
                    // Calculate volunteer hours
                    if (OppsForThisCtct[i].Hours_Actual__c != null) {
                        // Need to add LifetimeVolHours, Vol_Event_Count to contact
                        LifetimeVolHours += OppsForThisCtct[i].Hours_Actual__c;
                        Vol_Event_Count += 1;
                        if (OppsForThisCtct[i].CloseDate.year() == thisyear)
                            ytdvolhours = ytdvolhours + OppsForThisCtct[i].Hours_Actual__c;
                        else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -1 ))
                            pytdvolhours = pytdvolhours + OppsForThisCtct[i].Hours_Actual__c;
                        else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -2 ))
                            ppytdvolhours = ppytdvolhours + OppsForThisCtct[i].Hours_Actual__c;
                        else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -3 ))
                            Three3YearAgovolhours += OppsForThisCtct[i].Hours_Actual__c;
                        else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -4 ))
                            Four4YearAgovolhours += OppsForThisCtct[i].Hours_Actual__c;
                        else if(OppsForThisCtct[i].CloseDate.year() == (thisyear -5 ))
                            Five5YearAgovolhours += OppsForThisCtct[i].Hours_Actual__c;
                    }

                    // Update contact summary fields.
                    // for donations, we have to check for the RTID to make sure this is an individual donation.
                    // if(i=1) set first_contrib_source, first_contrib_cat
                    // Update last_donate_amt if foundDonation is false;
                    System.debug('Is RTID considered an indiv donation?' + DonationRTIDs.contains(OppsForThisCtct[i].RecordTypeId));
                    if (DonationRTIDs.contains(OppsForThisCtct[i].RecordTypeId)){
                        // update first_donation_date each time, since we loop through in decreasing order
                        c.First_Donate_Date__c = OppsForThisCtct[i].CloseDate;
                        c.First_Donate_Amount__c = OppsForThisCtct[i].Amount;

                        // update last_donate_date only once
                        if (foundCtctDonation == false) {
                            c.Last_Donate_Amt__c = OppsForThisCtct[i].Amount;
                            c.Last_Donate_Date__c = OppsForThisCtct[i].CloseDate;
                            foundCtctDonation = true;
                        } // end update last_donate_amt__c
                    }
                   //Largest contribution
                    if(c.Largest_Contrib_Amt__c < OppsForThisCtct[i].Amount) {
                        c.Largest_Contrib_Amt__c = OppsForThisCtct[i].Amount;
                        c.Largest_Contrib_Date__c = OppsForThisCtct[i].CloseDate;
                    }
                } // end opportunity loop
            } // end if (OppsForThisCtct.size() > 0)
            //Giving over past years.  This section is outside the OppsForThisCtct.size() > 0 loop because
            //if there are no contributions then all these totals should be set to 0.
            c.YeartoDate_Donations__c = ytddonations;
            c.Last_Year_Donations__c = pytddonations;
            c.Year_Before_Last_Donations__c = ppytddonations;
            c.X3_Years_Ago_Donations__c = Three3YearAgoDonations;
            c.X4_Years_Ago_Donations__c = Four4YearAgoDonations;
            c.X5_Years_Ago_Donations__c = Five5YearAgoDonations;
            c.YearToDate_VolHours__c = ytdvolhours;
            c.Last_Year_VolHours__c = pytdvolhours;
            c.Year_Before_Last_VolHours__c = ppytdvolhours;
            c.X3_Years_Ago_VolHours__c = Three3YearAgovolhours;
            c.X4_Years_Ago_VolHours__c = Four4YearAgovolhours;
            c.X5_Years_Ago_VolHours__c = Five5YearAgovolhours;
            c.LifetimeVolhours__c = LifetimeVolHours;
            c.Vol_Event_Count__c = Vol_Event_Count;
            updateCtcts.add(c);
        } // end contact loop
        try{
            AvoidRecursiveContactTrigger.setWorking();
            update updateCtcts;
            AvoidRecursiveContactTrigger.setClosed();
        }
        // Caution: Because of the try/catch, in some cases, the previous changes saved (ie the update UpdateOpps in the method)
        // won't be rolled back.  In this case, that wouldn't be a problem.  Try/catch overrides normal rollback behavior.
        Catch (Exception Ex) {System.debug(Ex);}
        System.debug('UpdateCtcts is ' + updateCtcts);
        //  BAIRD CAN I DISABLE THE CONTACT TRIGGER FOR ALL THIS?
        // AvoidRecursiveContributionTrigger.setWorking();
    } // end updateContacts

    public static void updatePledges(Set<Id> pledgeIdsToUpdate) {
        System.debug('Just entered updatePledges().');
        List<Opportunity> updateOpps = new List<Opportunity>();
        Map<Id,Opportunity> PledgeMap = new Map<Id,Opportunity>([select Id, Periodicity__c, Number_of_Payments__c, Next_Payment_Date__c, Total_Paid__c,
                Start_Date__c, CloseDate, Pledge_Amount__c from Opportunity where Id in :pledgeIdsToUpdate]);
        AggregateResult[] TotalsByPledge = [SELECT Matches_Which_Challenge_or_Pledge__c pledge, count(Amount) NrPayments,
                Sum(Amount) sum, Max(CloseDate) LastPaymentDate FROM Opportunity where Matches_Which_Challenge_or_Pledge__c
                in :pledgeIdsToUpdate
        GROUP BY Matches_Which_Challenge_or_Pledge__c];

        For (AggregateResult ar : TotalsByPledge) {
            system.debug('For this pledge, I found ' + (Decimal)ar.get('NrPayments') + ' payments.');
            Opportunity opp = PledgeMap.get((id)ar.get('pledge'));
            opp.Total_Paid__c = (Decimal)ar.get('sum');
            System.debug('Total_Paid__c is ' + opp.Total_Paid__c + ' and Pledge Amount is ' + opp.Pledge_Amount__c);
            if (opp.Total_Paid__c >= opp.Pledge_Amount__c && opp.Number_of_Payments__c!=999) {
                opp.StageName = 'Pledge Fulfilled';
                opp.Next_Payment_Date__c = null;
            } else {
                opp.StageName = 'Pledge Recorded';
                Date LastPaymentDate = (Date)ar.get('LastPaymentDate');
                system.debug('before updating the pledge, LastPaymentDate is ' + LastPaymentDate);
                opp.Next_Payment_Date__c = CalcNextPaymentDate(opp.Periodicity__c, LastPaymentDate);
            }
            system.debug('Periodicity is ' + opp.Periodicity__c + ' and Next_Payment_Date__c is ' + opp.Next_Payment_Date__c);

            PledgeMap.put((id)ar.get('pledge'),opp);
            AvoidRecursiveContributionTrigger.setWorking();
            updateOpps.add(opp);
            AvoidRecursiveContributionTrigger.setClosed();
        }
        // Now set Next_Payment_Date for new pledges
        For (Opportunity o : PledgeMap.values()) {
            if (o.Start_Date__c==null) o.Start_Date__c = o.CloseDate;
            if (o.Total_Paid__c == null || o.Total_Paid__c == 0) {
                o.Next_Payment_Date__c = CalcNextPaymentDate(o.Periodicity__c, o.Start_Date__c);
                updateOpps.add(o);
            }
        }
        AvoidRecursiveContributionTrigger.setWorking();
        Update updateOpps;
        AvoidRecursiveContributionTrigger.setClosed();
    }

    public static Date CalcNextPaymentDate(String periodicity, Date LastPaymentDate){
        // The text values most mirror the values in the Periodicity Global Picklist
        Date NextPaymentDate;
        if (periodicity=='Daily') {
            NextPaymentDate = LastPaymentDate.addDays(1);
        } else if (periodicity=='Weekly') {
            NextPaymentDate = LastPaymentDate.addDays(7);
        } else if (periodicity=='Every 2 Weeks') {
            NextPaymentDate = LastPaymentDate.addDays(14);
        } else if (periodicity=='Monthly') {
            NextPaymentDate = LastPaymentDate.addMonths(1);
        } else if (periodicity=='Every 2 Months') {
            NextPaymentDate = LastPaymentDate.addMonths(2);
        } else if (periodicity=='Quarterly') {
            NextPaymentDate = LastPaymentDate.addMonths(3);
        } else if (periodicity=='Every 6 Months') {
            NextPaymentDate = LastPaymentDate.addMonths(6);
        } else if (periodicity=='Annually' || periodicity=='Yearly') {
            NextPaymentDate = LastPaymentDate.addYears(1);}
        else if (periodicity=='Irregularly') {
            NextPaymentDate = null;
        } else {
            NextPaymentDate = null;
        }
        system.debug('At end of CalcNextPaymentDate, NextPaymentDate is ' + NextPaymentDate);
        return NextPaymentDate;
    }
}
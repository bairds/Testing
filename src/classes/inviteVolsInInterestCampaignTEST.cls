/**
 * Created by Baird on 8/9/2020.
 */

@IsTest
private class inviteVolsInInterestCampaignTEST {

    @IsTest
    static void OneCampaignMember(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign VolIntCampaign = ctv.fetchTestCampaign();
        VolIntCampaign.Name = 'Stream Cleanups';
        VolIntCampaign.Type = 'Volunteer Interest';
        Update VolIntCampaign;
        Campaign Subcampaign = new Campaign(
                name = 'Subcampaign',
                Vol_Interest_Campaign__c = VolIntCampaign.Id,
                Description_Long__c = 'Come join the Stream Cleanup.  Details details details',
                Description = 'We will have fun in this stream cleanups.',
                Event_Date_Time__c = datetime.newInstance(2021,10,06,10,0,0)
        );
        insert Subcampaign;
        // Put subcampaign in stdController
        Contact Testcontact = ctv.fetchTestContact();
        CampaignMember Testcm = new CampaignMember(
                contactId = Testcontact.Id,
                campaignId = VolIntCampaign.Id,
                status = 'Responded Yes'
        );
        Insert Testcm;
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(SubCampaign);
        inviteVolsInInterestCampaign eVIIC = new inviteVolsInInterestCampaign(stdcontroller);
        eVIIC.sendInvitationEmails();
        // system.assertEquals(true, eVIIC.results[0].success);


// additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)


    }
}
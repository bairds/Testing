/*
Classes
- eACC_backup
- ContactCustom
- OpportunityCustom
- FieldSetCustom
- Print
- Thanks_Template_Controller
- Autocomplete

Tests
- EnterAccountContactContributionTest
- PrintTest
- Thanks_Template_Test
- AutocompleteV2Test

Components
- Autocomplete
- Loading

Static Resources
- jQueryUI
- EnterAccountContactJS
- JoseJS
- JoseCSS


Also replace the first line in all thank you letter templates with:
<apex:page renderAs="{!renderAs}" showHeader="false" standardController="Opportunity" extensions="Thanks_Template_Controller" applyHTMLtag="false" standardStylesheets="false" >

*/

public class EACCLightningJS
{
    public String a { get; set; } // Set initially to 1, to view contacts; to 3 if updating contact; to 2 if at entering contrib step.
    public String a2 { get; set; }
    public String q { get; set; }
    public String step { get; set; }
    public String t { get; set; }
    public String tq { get; set; }
    public PageReference pr { get; set; }
    public String ContactsInAccount {get; set;} // replaces Contacts_In_Account__c

    public String personId { get; set; }
    public String cId { get; set; }
    public String acId {get; set;}   // Baird added this for the accountId
    public String pcId {get; set;}  // Baird added this for PrimaryContactId
    public String oRT { get; set; }
    public Lead l { get; set; }
    public Contact co { get; set; }
    public Contact co2 { get; set; }
    // public ContactCustom coc { get; set; }  // Can I delete this?
    public Account acct { get; set; }
    public Contact PrimaryContributor { get; set; }
    private List<Contact> cos;
    public List<ContactCustom> cocs { get; set; }
    public Opportunity o { get; set; }
    public Opportunity CompMembership { get; set; }
    public OpportunityCustom oc { get; set; }
    public List<FieldSetCustom> ofs { get; set; }

    public Map<String, Boolean> showField { get; set; }
    public Map<String, String> fieldLabel { get; set; }
    public Boolean CreateDummyContact { get; set; }  // Set to true to create dummy contact for account

    public EACCLightningJS()
    {
        step = System.currentPageReference().getParameters().get('step');
        if(String.isEmpty(step))
            step = System.currentPageReference().getParameters().get('c__step');
        if(String.isEmpty(step))
            step = '1';

        a = System.currentPageReference().getParameters().get('a');
        if(String.isEmpty(a)) a = System.currentPageReference().getParameters().get('c__a');
        if(String.isEmpty(a))
            a = '1';

        a2 = System.currentPageReference().getParameters().get('a2');
        if(String.isEmpty(a2)) a2 = System.currentPageReference().getParameters().get('c__a2');
        if(String.isEmpty(a2))
            a2 = '1';

        CreateDummyContact = false;
        system.debug('step is ' + step + ' and a is ' + a + ' and a2 is ' + a2);
    }

    public void setEnterContrib()
    {
        if (acId==null) acId = System.currentPageReference().getParameters().get('ac');

        if(String.isNotBlank(acId)) {
            tq = 'ac';
            personId = acId;
            system.debug('At top of setEnterContrib, acid is ' + acid);
        }

        String pcId = System.currentPageReference().getParameters().get('pc');

        if(String.isNotBlank(pcId))
            PrimaryContributor = [ SELECT Id, FirstName, LastName, Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Account.Name FROM Contact WHERE Id =: pcId ];

        cId = System.currentPageReference().getParameters().get('c');
        oRT = System.currentPageReference().getParameters().get('rt');

        if(step == '2') {
            acct = new Account();
            co = new Contact();

            String lId = System.currentPageReference().getParameters().get('l');
            String coId = System.currentPageReference().getParameters().get('co');
            system.debug('lId is ' + lId + ' and coId is ' + coId);
            String q = 'SELECT ';

            if(String.isNotBlank(lId)) {
                l = [ SELECT Id, FirstName, LastName, Name, Email, RecordType.Name, Phone, Street, City, State, PostalCode, Company, IsConverted FROM Lead WHERE Id =: lId ];
                t = 'Lead';
                tq = 'l';
                personId = lId;
            }
            else if(String.isNotBlank(coId)) {
                for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.eACContactFields.getFields())
                    q += f.getFieldPath() + ', ';

                q += 'Id, FirstName, LastName, Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Account.Name FROM Contact WHERE Id = \'' + coId + '\'';

                try{
                    co = Database.query(q);
                } catch(QueryException qe){
                    if (qe.getMessage().CONTAINS('duplicate field selected')) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You have a duplicate field listed in your fieldlist contact.enteracc.  Probably you have included one of the following already listed fields in your fieldset: Id, FirstName, LastName, Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, AccountId, Account.Name.  If so, please remove that field from the fieldset.'));
                    } else {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,qe.getMessage()));
                    }
                }
                t = 'Contact';
                tq = 'co';
                personId = coId;

            }
            else if(String.isNotBlank(acId)) {
                for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.eACAccountFields.getFields()) {
                    q += f.getFieldPath() + ', ';
                }

                q += 'Id, Name, RecordType.Name, Phone, Dear__c, Addressee__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Contacts_in_Account__c FROM Account WHERE Id = \'' + acId + '\'';

                acct = Database.query(q);
                t = 'Account';
                system.debug('ContactsinAccount variable is ' + ContactsinAccount);

                cos = [ SELECT Id, Name, Protected__c FROM Contact WHERE AccountId =: acct.Id ];

                if(a == '1') {
                    if(a2 == '1') {
                        cocs = new List<ContactCustom>();

                        for(Contact co : cos) {
                            ContactCustom coc = new ContactCustom();
                            coc.id = co.Id;
                            coc.name = co.Name;

                            List<AccountContactRole> acrs = [ SELECT Role, IsPrimary FROM AccountContactRole WHERE ContactId =: co.Id AND AccountId =: acct.Id LIMIT 1];

                            if(acrs.size() > 0)
                                coc.acr = acrs[0];

                            cocs.add(coc);
                        }

                        if(PrimaryContributor == null)
                            PrimaryContributor = new Contact();
                    }
                    else {
                        if(a2 == '2') {
                            co.AccountId = acct.Id;
                            co.Phone = acct.Phone;
                            co.MailingStreet = acct.BillingStreet;
                            co.MailingCity = acct.BillingCity;
                            co.MailingState = acct.BillingState;
                            co.MailingPostalCode = acct.BillingPostalCode;
                        }
                        else if(a2 == '3') {
                            co = PrimaryContributor;
                            co.AccountId = acct.Id;
                        }
                    }
                }
            }
            else if(a == '2') {
                ContactsInAccount = '1';
                CreateDummyContact = false;
            }
        }
        else if(step == '3') {
            if (acct==null) acct = [ SELECT Id, Name FROM Account WHERE Id =: acId ];

            o = new Opportunity();
            o.CloseDate = Date.today();
            o.AccountId = acct.Id;
            oc = new OpportunityCustom();
            oc.setRecordTypes();

            if(PrimaryContributor != null && String.isNotBlank(PrimaryContributor.Id))
                o.Contact__c = PrimaryContributor.Id;

            if(String.isNotBlank(oRT)) {
                oc.recordType = [ SELECT Id, Name FROM RecordType WHERE Id =: oRT ];
                o.RecordTypeId = oc.recordType.Id;

                if(String.isNotBlank(cId))
                    o.CampaignId = cId;

                showField = new Map<String, Boolean>();
                fieldLabel = new Map<String, String>();

                showField.put('ChallengeOrPledge', true);

                if(oc.recordType.Name == 'Event' || oc.recordType.Name == 'InKind' || oc.recordType.Name == 'Pledge' || oc.recordType.Name == 'Volunteer Task')
                    showField.put('ChallengeOrPledge', false);

                showField.put('PaymentType', true);
                fieldLabel.put('Amount', 'amount');

                if(oc.recordType.Name == 'InKind' || oc.recordType.Name == 'Pledge' || oc.recordType.Name == 'Volunteer Task')  {
                    showField.put('PaymentType', false);

                    if(oc.recordType.Name == 'InKind')
                        fieldLabel.put('Amount', 'in kind value');
                    else if(oc.recordType.Name == 'Pledge')
                        fieldLabel.put('Amount', 'pledge amount');
                    else
                            fieldLabel.put('Amount', 'hours');
                }

                oc.setThankYouLetters();
                oc.setThankYouLetterFormats(PrimaryContributor);

                CompMembership = new Opportunity();

                ofs = FieldSetCustom.getList(Opportunity.sObjectType.getDescribe(), oc.recordType.Name.replace(' ', '_'));
            }
        }
    }

    public PageReference step2(){
        step = '2';
        a = '2';
        String url = '/apex/EACCLightningPage?step=' + step;
        url += '&a=' + a;
        pr = new PageReference(url);
        pr.setRedirect(true);
        system.debug('Redirect() sets URL to ' + pr);
        return pr;
    }

    public PageReference redirect()
    {
        String url = '/apex/EACCLightningPage?step=' + step;

        if(String.isNotEmpty(a))
            url += '&a=' + a;

        if(String.isNotEmpty(a2))
            url += '&a2=' + a2;

       if(String.isNotEmpty(acId))
            url += '&ac=' + acId;

        if(String.isNotEmpty(personId))
            url += '&'+ tq + '=' + personId;

        if(PrimaryContributor != null && PrimaryContributor.Id != null)
            url += '&pc=' + PrimaryContributor.Id;

        if(String.isNotBlank(oRT))
            url += '&rt=' + oRT;

        if(String.isNotBlank(cId))
            url += '&c=' + cId;

        if(String.isNotEmpty(q))
            url += '&' + q;

        pr = new PageReference(url);
        pr.setRedirect(true);
        system.debug('Redirect() sets URL to ' + pr);
        return pr;
    }

    public PageReference selectPerson()
    {
        String i = personId.left(3);
        tq = 'l';

        if(i == '001') {// Account
            tq = 'ac';
            acid = personId;
        }
        else if(i == '003') // Contact
            tq = 'co';

        a = '1';
        step = '2';
        PrimaryContributor = null;
        o = null;
        system.debug('SelectPerson sets account to ' + acid + ' and contact to ' + tq=='co' ? personId : null);
        return redirect();
    }

    public PageReference selectPrimaryContributor()
    {
        // This method can assume that PersonId is a Contact Id because the
        // AutoCompleteV2 soql query only searches on Contact
        system.debug('Top of selectPrimaryContributor(), PersonId is ' + PersonId + ' and acid is ' + acId);
        a = '1';
        step = '3';
        tq = 'co';
        PrimaryContributor.Id = PersonId;
        pcId = PersonId;
        o = null;
        system.debug('selectPrimaryContributor sets PrimaryContributor.Id to ' + PrimaryContributor.Id + ' and acid to ' + acid);
        return redirect();
    }

    public PageReference selectAccount()
    {
        a = '1';
        step = '2';
        tq = 'ac';
        PrimaryContributor = null;

        return redirect();
    }

    public PageReference selectContact()
    {
        a = '1';
        step = '2';
        a2 = null;
        tq = 'co';
        PrimaryContributor = null;

        return redirect();
    }

    public void setContacts()
    {
        system.debug('CreateDummyContact is ' + CreateDummyContact);
        if(CreateDummyContact) {
            co = new Contact(
            FirstName = 'Sir',
            LastName = 'Unknown',
            Dear__c = 'Sir');
        }
        else {
            if(ContactsInAccount != '0') {
                co = new Contact();

                if(ContactsInAccount == '2')
                    co2 = new Contact();
                else
                        co2 = null;
            }
            else {
                co = null;
                co2 = null;
            }
        }
    }

    public PageReference saveAccountContacts()
    {
        system.debug('Is account null? ' + acct==null);
        ID FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        if(acct==null) acct = new Account(RecordTypeId=FamilyRTID); // Baird added this line.
        if(String.isBlank(acct.Name)) {
            system.debug('Before assigning name, account is ' + acct);
            if(acct.RecordTypeId == FamilyRTID) {
                if(co2 == null)
                    acct.Name = co.LastName + ', ' + co.FirstName + ' Household';
                else {
                    if(co.LastName == co2.LastName)
                        acct.Name = co.LastName + ', ' + co.FirstName + ' and ' + co2.FirstName + ' Household';
                    else
                            acct.Name = co.LastName + ', ' + co.FirstName + ' and ' + co2.FirstName + ' ' + co2.LastName + ' Household';
                }
            }
        }

        if(acct.Addressee__c == null) {
            if(ContactsInAccount != '0') {
                if(co2 == null)
                    acct.Addressee__c = co.FirstName + ' ' + co.LastName;
                else {
                    if(co.LastName == co2.LastName)
                        acct.Addressee__c = co.FirstName + ' and ' + co2.FirstName + ' ' + co.LastName;
                    else
                            acct.Addressee__c = co.FirstName + ' ' + co.LastName + ' and ' + co2.FirstName + ' ' + co2.LastName;
                }
            }
            else
                    acct.Addressee__c = '';
        }

        acct.ShippingStreet = acct.BillingStreet;
        acct.ShippingCity = acct.BillingCity;
        acct.ShippingPostalCode = acct.BillingPostalCode;
        acct.ShippingState = acct.BillingState;

        if(acct.Dear__c == null) {
            if (ContactsInAccount != '0') {
                if (co2 == null)
                    acct.Dear__c = co.Dear__c == null ? co.FirstName : co.Dear__c;
                else {
                    acct.Dear__c = co.Dear__c == null ? co.FirstName : co.Dear__c;
                    acct.Dear__c += ' and ';
                    acct.Dear__c += co2.Dear__c == null ? co2.FirstName : co2.Dear__c;
                }
            }
        }
        //else
        //  acct.Dear__c = co.Dear__c;

        insert acct;

        if(ContactsInAccount != '0') {
            co.AccountId = acct.Id;
            co.MailingStreet = acct.BillingStreet;
            co.MailingCity = acct.BillingCity;
            co.MailingPostalCode = acct.BillingPostalCode;
            co.MailingState = acct.BillingState;
            co.Dear__c = co.Dear__c == null ? co.FirstName : co.Dear__c;

            if(co.Phone == '')
                co.Phone = acct.Phone;

            insert co;

            if(ContactsInAccount == '2') {
                co2.AccountId = acct.Id;
                co2.MailingStreet = acct.BillingStreet;
                co2.MailingCity = acct.BillingCity;
                co2.MailingPostalCode = acct.BillingPostalCode;
                co2.MailingState = acct.BillingState;
                co2.Dear__c = co2.Dear__c == null ? co2.FirstName : co2.Dear__c;

                if(co2.Phone == '')
                    co2.Phone = acct.Phone;

                insert co2;

                AccountContactRole acr = new AccountContactRole();
                acr.AccountId = acct.Id;
                acr.ContactId = co2.Id;
                acr.Role = 'Second contact';

                insert acr;
            }
        }

        tq = 'ac';
        personId = acct.Id;
        a = '1';

        return redirect();
    }

    public PageReference updatePerson()
    {
        a = '3';

        return redirect();
    }

    public PageReference updatePrimaryContributor()
    {
        a2 = '3';

        return redirect();
    }

    public PageReference resetPrimaryContributor()
    {
        a2 = '1';
        PrimaryContributor = new Contact();
        return redirect();
    }

    public PageReference savePerson()
    {
        if(a == '3') {
            a = '1';

            if(l != null)
                update l;
            else if(co != null && co.Id != null)
                update co;
            else if(acct.id != null) {
                if(CreateDummyContact) {
                    for(Contact co : cos) {
                        if(!co.Protected__c) {
                            co.Phone = acct.Phone;
                            co.MailingStreet = acct.BillingStreet;
                            co.MailingCity = acct.BillingCity;
                            co.MailingState = acct.BillingState;
                            co.MailingPostalCode = acct.BillingPostalCode;
                        }
                    }

                    update cos;
                }

                 update acct;
            }
        }
        else {
            if(a2 == '2')
                insert co;
            else
                    update co;

            a2 = '1';

            co = null;
        }

        return redirect();
    }


    public PageReference addContact()
    {
        a2 = '2';
        return redirect();
    }

    public PageReference enterContribution()
    {
        step = '3';
        a = '2';

        if(acct.Id == null) {
            tq = 'ac';

            if(l != null)
                co = [ SELECT Id, AccountId FROM Contact WHERE Id =: ConvertLeadToContact.ConvertLeadToContact(l.Id) ];

            if(co != null) {
                personId = co.AccountId;
                PrimaryContributor = co;
            }
        }

        return redirect();
    }

    public void submitContribution()
    {
        o.Name = 'autofill';
        o.StageName = 'Donation Received';

        for(FieldSetCustom fsc : ofs) {
            if(fsc.Type != 'field') {
                if(fsc.Type == 'MULTIPICKLIST') {
                    if(fsc.Value.StrL.size() > 0)
                        o.put(fsc.Name, String.valueOf(fsc.Value.StrL).substringBetween('(', ')').replace(',', ';'));
                    else
                            o.put(fsc.Name, null);
                }
                else
                        o.put(fsc.Name, fsc.Value.Str);
            }
        }

        insert o;

        if(CompMembership.Membership_Start_Date__c != null && CompMembership.Membership_End_Date__c != null) {
            RecordType rt = [ SELECT Id FROM RecordType WHERE Name = 'Membership' ];

            CompMembership.RecordTypeId = rt.Id;
            CompMembership.Name = PrimaryContributor.Name + ' ' + Date.today().format() + ' comp mmbr';
            CompMembership.CampaignId = o.CampaignId;
            CompMembership.StageName = 'Completed';
            CompMembership.CloseDate = o.CloseDate;
            CompMembership.Contribution__c = o.Id;
            CompMembership.Contact__c = o.Contact__c;
            CompMembership.AccountId = o.AccountId;

            CompMembership.Type = 'Complimentary Membership';

            insert CompMembership;
        }

        cId = o.CampaignId;
        oRT = o.RecordTypeId;
    }

    public PageReference next()
    {
        step = '1';
        a = null;
        a2 = null;
        personId = null;
        PrimaryContributor = null;

        return redirect();
    }

    public PageReference exit()
            {
            pr = new PageReference('/006/o');
    pr.setRedirect(true);

    return pr;
}

public void attachLetter()
{
Print.saveAttach(o.Id, oc.thankYouLetter);
}

public void sendEmail() {
    List<ApexPage> ts = [SELECT Id, Name FROM ApexPage WHERE Id = :oc.thankYouLetter];

    if (ts.size() > 0) {
        ApexPage t = ts[0];
        String[] to = new String[]{
                PrimaryContributor.Email
        };
        system.debug('Recipient list is ' + to);

        PageReference p = new PageReference(t);
        p.getParameters().put('id', o.Id);
        p.getParameters().put('ra', 'html');

        Blob b;

        try {
            b = p.getContent();
        } catch (Exception e) {

        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setBccSender(false);
        mail.setUseSignature(false);

        mail.setSenderDisplayName(System.UserInfo.getOrganizationName());
        mail.setReplyTo(System.UserInfo.getUserEmail());
        mail.setToAddresses(to);
        mail.setSubject('Thanks for your contribution');
        mail.setWhatId(o.Id);
        mail.setTargetObjectId(PrimaryContributor.Id);

        if (b != null) {
            mail.setHtmlBody(b.toString());
            mail.setPlainTextBody(b.toString().stripHtmlTags());
        } else
                mail.setHtmlBody('');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}

public List<SelectOption> getNrContacts() {
List<SelectOption> NrContacts = new List<SelectOption>();
NrContacts.add(new SelectOption('0','0'));
NrContacts.add(new SelectOption('1','1'));
NrContacts.add(new SelectOption('2','2'));
return NrContacts;
}
}
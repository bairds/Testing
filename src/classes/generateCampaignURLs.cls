/**
 * Created by Baird on 2/15/2019.
 * Uses Register_Template and Select_Template to choose the VFPage for signups and construct the URL
 * Register_TEmplate and Select_Template store the Id as text
 */

public with sharing class generateCampaignURLs {
    public Id CampId { get; set; }
    public Campaign Camp {get; set;}
    public Site Sitio { get; set; }
    public List<selectOption> SelectCampaignOptions {set;}
    public List<selectOption> RegisterOptions {set;}
    public Map<string,apexPage> VFPageMap {get; set;}
    public string VFPageMapJSON {get; set;}
    public string SitioJSON {get; set;}
    public string DomainString {get; set;}
    public string SalesforceBaseUrl {get; set;}
    public string BaseUrl {get; set;}

    public generateCampaignURLs(ApexPages.standardController stdController) {
        Campaign c = (Campaign)stdController.getRecord();
        CampId = c.Id;
        Camp = [SELECT name, Signup_Template__c, Select_Template__c, Register_Template__c from Campaign WHERE Id = :CampId];
        System.debug('Generating the CampaignURLs the campaign Camp is ' + camp);
        VFPageMap = new Map<string,apexpage>();
        getSelectCampaignOptions();
        getRegisterOptions();
        system.debug('Just before parsing, VFPageMap is now ' + VFPageMap);
        VFPageMapJSON = JSON.serialize(VFPageMap);
        DomainString = 'https://'+URL.getSalesforceBaseURL().getHost();
        system.debug('After serializing VFPageMapJSON is ' + VFPageMapJSON);
        Try {
            Sitio = [select MasterLabel, Name, Status, Subdomain, Description, UrlPathPrefix, GuestUserId from Site where MasterLabel = :'Signup' LIMIT 1];
            String path = '/sites/servlet.SiteDebugMode';
            PageReference pr = new PageReference(path);
            pr.getParameters().put('guid', Sitio.GuestUserId);
            pr.getParameters().put('sitedebugmode', 'x');
            if(Test.isRunningTest()){
                BaseURL = 'BaseURL';
            }else{
                BaseUrl = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
                system.debug('In controller, BaseURL is calculated to be ' + BaseURL);
            }


            SitioJSON = JSON.serialize(Sitio);
        } catch (QueryException e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Sorry, cannot find the site named Signup, which is required for WG signup pages.  Please go to Setup / Sites and rename your default site to Signup.'));
        }
        SalesforceBaseUrl = URL.getSalesforceBaseUrl().getHost();
    }

    public List<SelectOption> getSelectCampaignOptions() {
        List<SelectOption> SelectCampaignOptions = new List<SelectOption>();
        SelectCampaignOptions.add(new SelectOption('','-none-'));
        List<apexPage> VFPages = [select Name, id, Description from apexPage WHERE Name like '%select%' ORDER BY Description];
        For (apexPage p : VFPages) if (p.Description != null) {
            SelectCampaignOptions.add(new selectOption(p.id,String.ValueOf(p.description).LEFT(50)));
            VFPageMap.put(p.Id,p);
        }
        return SelectCampaignOptions;
    }

    public List<SelectOption> getRegisterOptions() {
        List<SelectOption> RegisterOptions = new List<SelectOption>();
        RegisterOptions.add(new SelectOption('','-none-'));
        List<apexPage> VFPages = [select Name, id, Description from apexPage WHERE ((Name like '%register%') OR (Name like '%event_signup%')) AND (NOT Description LIKE 'Default Force.com User%') ORDER BY Description];
        For (apexPage p : VFPages) if (p.Description != null) {
            RegisterOptions.add(new selectOption(p.id,String.ValueOf(p.description).LEFT(50)));
            VFPageMap.put(p.Id,p);
        }
        System.debug('Does RegisterOptions have legit values? ' + RegisterOptions);
        return RegisterOptions;
    }
}
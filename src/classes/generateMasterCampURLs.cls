/**
 * Created by Baird on 2/27/2019.
 * Page section for the Master Campaign Detail page.
 * Allows users to easily find the URL for the Signup page for all campaigns in this master caxmpaign.
 */

public with sharing class generateMasterCampURLs {
    public Id MCampId { get; set; }
    public Master_campaign__c MCamp { get; set; }
    public Site Sitio { get; set; }
    public List<selectOption> SelectCampaignOptions { set; }
    public Map<string, apexPage> VFPageMap { get; set; }
    public string VFPageMapJSON { get; set; }
    public string SitioJSON { get; set; }
    public string DomainString { get; set; }
    public string BaseUrl { get; set; }

    public generateMasterCampURLs(ApexPages.standardController stdController) {
        Master_campaign__c mc = (Master_campaign__c) stdController.getRecord();
        MCampId = mc.Id;
        VFPageMap = new Map<string, apexpage>();
        getSelectCampaignOptions();
        system.debug('Just before parsing, VFPageMap is now ' + VFPageMap);
        VFPageMapJSON = JSON.serialize(VFPageMap);
        DomainString = 'https://' + URL.getSalesforceBaseURL().getHost();
        system.debug('After serializing VFPageMapJSON is ' + VFPageMapJSON);
        Try {
            Sitio = [select MasterLabel, Name, Status, Subdomain, Description, UrlPathPrefix, GuestUserId from Site where MasterLabel = :'Signup' LIMIT 1];
            String path = '/sites/servlet.SiteDebugMode';
            PageReference pr = new PageReference(path);
            pr.getParameters().put('guid', Sitio.GuestUserId);
            pr.getParameters().put('sitedebugmode', 'x');
            if (Test.isRunningTest()) {
                BaseURL = 'BaseURL';
            } else {
                BaseUrl = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
            }

            SitioJSON = JSON.serialize(Sitio);
        } catch (QueryException e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Sorry, cannot find the site named Signup, which is required for WG signup pages.  Please go to Setup / Sites and rename your default site to Signup.'));
        }
    }

    public List<SelectOption> getSelectCampaignOptions() {
        List<SelectOption> SelectCampaignOptions = new List<SelectOption>();
        SelectCampaignOptions.add(new SelectOption('', '-none-'));
        List<apexPage> VFPages = [select Name, id, Description from apexPage WHERE (Name like '%select%' OR Description like '%MCampaignURLList%') AND (NOT Description LIKE 'Default Force.com User%') AND (NOT Description like '%Deprecated%') ORDER BY Description];
        For (apexPage p : VFPages) if (p.Description != null && !p.Description.TOUPPERCASE().CONTAINS('DEPRECATED')) {
            SelectCampaignOptions.add(new selectOption(p.id, String.ValueOf(p.description).LEFT(50)));
            VFPageMap.put(p.Id, p);
        }
        return SelectCampaignOptions;
    }

}
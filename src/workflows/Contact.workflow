<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Original_Contact_LeadSource</fullName>
        <field>Original_LeadSource__c</field>
        <formula>TEXT(LeadSource)</formula>
        <name>Update_Original_Contact_LeadSource</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate_Original_Contact_LeadSource</fullName>
        <actions>
            <name>Update_Original_Contact_LeadSource</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.LeadSource</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Original_LeadSource__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>The first time leadsource is created, populate this field.  Then don&apos;t overwrite it.  Only Admins can edit it.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

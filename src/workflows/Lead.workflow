<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Original_LeadSource</fullName>
        <field>Original_LeadSource__c</field>
        <formula>TEXT(LeadSource)</formula>
        <name>Update Original_LeadSource</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Populate_Original_Lead_LeadSource</fullName>
        <actions>
            <name>Update_Original_LeadSource</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Original_LeadSource__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>The first time leadsource is created, populate this field.  Then don&apos;t overwrite it.  Only Admins can edit it.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

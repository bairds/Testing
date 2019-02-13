<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Confirm_Corporate_Event_for_Volunteer</fullName>
        <description>Confirm Corporate Event for Volunteer</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Corporate_Event_Confirm</template>
    </alerts>
    <alerts>
        <fullName>Confirm_Corporate_Leader_Signup</fullName>
        <description>Confirm Corporate Leader Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Corporate_Leader_Confirm_w_Link</template>
    </alerts>
    <rules>
        <fullName>Confirm Corporate Signup to Leader</fullName>
        <actions>
            <name>Confirm_Corporate_Leader_Signup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Type</field>
            <operation>equals</operation>
            <value>Corporate volunteer event</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Role__c</field>
            <operation>equals</operation>
            <value>Group leader</value>
        </criteriaItems>
        <description>Confirmation email to the person who signed up the corporation for the event. Includes link for colleagues to sign up.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Confirm Corporate Signup to Volunteer</fullName>
        <actions>
            <name>Confirm_Corporate_Event_for_Volunteer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Type</field>
            <operation>equals</operation>
            <value>Corporate volunteer event</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Role__c</field>
            <operation>notEqual</operation>
            <value>Group leader</value>
        </criteriaItems>
        <description>Confirmation email to the person who signed up the corporation for the event. Includes link for colleagues to sign up.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

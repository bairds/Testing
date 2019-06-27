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
    <alerts>
        <fullName>Confirm_Public_Event_Signup</fullName>
        <description>Confirm Public Event Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Event_Templates/Confirm_Public_Event_Signup</template>
    </alerts>
    <alerts>
        <fullName>Confirm_Volunteer_Event_Signup</fullName>
        <description>Confirm Volunteer Event Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Confirm_Volunteer_Event_Signup</template>
    </alerts>
    <alerts>
        <fullName>Confirm_Volunteer_Signup</fullName>
        <description>Confirm Volunteer Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Confirm_Volunteer_Event_Signup</template>
    </alerts>
    <alerts>
        <fullName>Remind_Public_Event_Signup</fullName>
        <description>Remind Public Event Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public_Event_Templates/Remind_Public_Event_Signup</template>
    </alerts>
    <alerts>
        <fullName>Remind_Volunteer_Event_Signup</fullName>
        <description>Remind Volunteer Event Signup</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Remind_Volunteer_Event_Signup</template>
    </alerts>
    <alerts>
        <fullName>Remind_Volunteer_Event_Tomorrow</fullName>
        <description>Remind Volunteer Event Tomorrow</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Volunteer_Event_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Volunteer_Hours_TY_with_Message_and_Follow_On_Event</fullName>
        <description>Volunteer Hours TY with Message and Follow On Event</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Volunteer_Mgmt_Emails/Thanks_for_Volunteer_Hours</template>
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
    <rules>
        <fullName>Confirm and Remind Public Signup</fullName>
        <actions>
            <name>Confirm_Public_Event_Signup</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Campaign_Member_Source__c</field>
            <operation>equals</operation>
            <value>Web signup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Public Event</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Remind_Public_Event_Signup</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CampaignMember.Event_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Confirm and Remind Volunteer Signup</fullName>
        <actions>
            <name>Confirm_Volunteer_Signup</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Campaign_Member_Source__c</field>
            <operation>equals</operation>
            <value>Web signup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Volunteer Event</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Remind_Volunteer_Event_Tomorrow</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CampaignMember.Event_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>

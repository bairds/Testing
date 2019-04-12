<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Thanks_for_signing_up_e_newsletter_Ctct</fullName>
        <description>Thanks for signing up e-newsletter Ctct</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contact_Mgmt_Emails/Email_Signup_Response_Contact</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Original_LeadSource</fullName>
        <description>The first time leadsource is created, populate this field. Then don&apos;t overwrite it. Only Admins can edit it.</description>
        <field>Original_LeadSource__c</field>
        <formula>TEXT(LeadSource)</formula>
        <name>Update Original_LeadSource</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alternate_Email_to_Email</fullName>
        <field>Email</field>
        <formula>Other_Email__c</formula>
        <name>Alternate Email to Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_to_Preferred_Email</fullName>
        <description>Puts the Preferred Email value into the standard Email field</description>
        <field>Email</field>
        <formula>CASE(
            Preferred_Email__c,
            &quot;Work&quot;,
            Work_Email__c,
            &quot;Personal&quot;,
            Personal_Email__c,
            &quot;Alternate&quot;,
            Other_Email__c,
            &quot;&quot;
            )</formula>
        <name>Email to Preferred Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Personal_Email_to_Email</fullName>
        <field>Email</field>
        <formula>Personal_Email__c</formula>
        <name>Personal Email to Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Preferred_Email_as_Alternate</fullName>
        <field>Preferred_Email__c</field>
        <literalValue>Alternate</literalValue>
        <name>Preferred Email as Alternate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Preferred_Email_as_Personal</fullName>
        <field>Preferred_Email__c</field>
        <literalValue>Personal</literalValue>
        <name>Preferred Email as Personal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Preferred_Email_as_Work</fullName>
        <field>Preferred_Email__c</field>
        <literalValue>Work</literalValue>
        <name>Preferred Email as Work</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Work_Email_to_Email</fullName>
        <field>Email</field>
        <formula>Work_Email__c</formula>
        <name>Work Email to Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email List Signup Contact</fullName>
        <actions>
            <name>Thanks_for_signing_up_e_newsletter_Ctct</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Mailing_Lists__c</field>
            <operation>includes</operation>
            <value>e-newsletter</value>
        </criteriaItems>
        <description>If an existing contact signs up for the e-newsletter, send them an acknowledgement email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate_Original_Contact_LeadSource</fullName>
        <actions>
            <name>Update_Original_LeadSource</name>
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
        <description>The first time leadsource is created, populate this field. Then don&apos;t overwrite it. Only Admins can edit it.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Primary Contact for Account</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Addressee__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>The first time a contact is created for an account, populate the account.contact role with the contact.  Populate the Dear__ field with contact.firstname unless it is already filled.  Subsequently, do not make any changes.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EAltEmail third</fullName>
        <actions>
            <name>Alternate_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Preferred_Email_as_Alternate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Personal_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Other_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If the alternate email is populated, personal and work isn&apos;t, and no preferred selection is made, make it the preferred email.  Part of a set of three rules that automatically choose the preferred email when a preferred selection is not made already.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EAlternateEmail only</fullName>
        <actions>
            <name>Alternate_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Preferred_Email_as_Alternate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Personal_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Other_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When the only email provided is &quot;Alternate&quot;, set the preferred phone field to &quot;Alternate&quot;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EPersonalEmail only</fullName>
        <actions>
            <name>Personal_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Preferred_Email_as_Personal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Personal_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Other_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When the only email provided is &quot;Personal&quot;, set the preferred phone field to &quot;Personal&quot;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EPersonalEmail second</fullName>
        <actions>
            <name>Personal_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Preferred_Email_as_Personal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Personal_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If the personal email is populated, work isn&apos;t, and no preferred selection is made, make it the preferred email. Part of a set of three rules that automatically choose the preferred email when a preferred selection is not made already.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EPreferred Email Changed</fullName>
        <actions>
            <name>Email_to_Preferred_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow overwrites the existing value in the standard Email field when the Preferred Email field value changes (for when other fields do not change).</description>
        <formula>ISCHANGED( Preferred_Email__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EWorkEmail first</fullName>
        <actions>
            <name>Preferred_Email_as_Work</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Work_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If the work email is populated and no preferred selection is made, make it the preferred email.  Part of a set of three rules that run and automatically choose the preferred email when a preferred selection is not made already.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%2EWorkEmail only</fullName>
        <actions>
            <name>Preferred_Email_as_Work</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Work_Email_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Personal_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Work_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Other_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When the only email provided is &quot;Work&quot;, set the preferred phone field to &quot;Work&quot;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>SendBirthdayCard</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send Birthday Card</subject>
    </tasks>
</Workflow>
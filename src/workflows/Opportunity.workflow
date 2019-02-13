<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Next_Step_Reminder_Email</fullName>
        <description>Next Step Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WaterGrass_Fundraising_Templates/Renewal_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>CreateContributionName</fullName>
        <description>If Contribution Name is left blank, create a contribution name by concatenating Account &amp; CloseDate &amp; Campaign</description>
        <field>Name</field>
        <formula>CASE( RecordType.Name, &apos;Pledge&apos;, Account.Name  &amp; &quot; &quot;  &amp;  TEXT(CloseDate) &amp; &quot; Pledge for &quot; &amp; Campaign.Name, Account.Name  &amp; &quot; &quot;  &amp;  TEXT(CloseDate) &amp; &quot; &quot; &amp;   Campaign.Name)</formula>
        <name>Create Contribution Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Membership_End_Date</fullName>
        <field>Membership_End_Date__c</field>
        <formula>IF (  OR(ISNULL( Account.Account_Membership_Expires__c),
Account.Account_Membership_Expires__c + 90 &lt; CloseDate),
CloseDate + 365 , Account.Account_Membership_Expires__c + 365)</formula>
        <name>Membership End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Membership_Start_Date</fullName>
        <field>Membership_Start_Date__c</field>
        <formula>IF( OR(ISNULL( Account.Account_Membership_Expires__c), Account.Account_Membership_Expires__c + 90 &lt;  CloseDate ),
CloseDate, Account.Account_Membership_Expires__c)</formula>
        <name>Membership Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Note_Reminder_Sent</fullName>
        <description>When WaterGrass sends reminder to Contrib Owner, a note goes into the Description field.</description>
        <field>Description</field>
        <formula>Description  &amp; &quot; WG Sent Reminder &quot; &amp;  Text($System.OriginDateTime)</formula>
        <name>Note: Reminder Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OrphanNoMore</fullName>
        <description>When a volunteer signs up for a task, reset its &quot;stage&quot; from &quot;orphan&quot; to &quot;adopted.&quot;</description>
        <field>StageName</field>
        <literalValue>Adopted</literalValue>
        <name>OrphanNoMore</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto fill in Contribution Name</fullName>
        <actions>
            <name>CreateContributionName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>equals</operation>
            <value>autofill</value>
        </criteriaItems>
        <description>If Contribution Name says &quot;autofill&quot;, create a contribution name by concatenating Account &amp; CloseDate &amp; Campaign</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Start and End Dates</fullName>
        <actions>
            <name>Membership_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Membership_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 or 3) and 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Membership</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Installment_Nr__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Installment_Nr__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Membership_Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If closedate() &gt; account.account_memberhsip_expires__c + 90, startdate is closedate(), otherwise account.account_membership_expires__c.  Likewise end date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Next Step Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Next_Step_Deadline__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If today = the date of the next step reminder - 2, then send an email reminder to the Contribution Owner.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

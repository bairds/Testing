/**
 * Created by Baird on 11/22/2020.
 * To use with the execute anonymous window.
 * For each existing ACRole, it creates a matching ACRelationship.
 * Necessary for switching WG from Roles to Relationships.
 */

public with sharing class CopyACRolesToACRelationships {
    public List<AccountContactRelation> ACRelations;
    public List<AccountContactRole> ACRoles;
    Map<Id, Map<Id, AccountContactRole>> MapRoles;
    Map<Id, Map<Id, AccountContactRelation>> MapRelations;

    public CopyACRolesToACRelationships() {
    }

    public List<AccountContactRelation> SimpleCopyRolesToRelations(List<Id> acctIds) {
        List<AccountContactRelation> AddACRelations = new List<AccountContactRelation>();
        List<AccountContactRelation> UpdateACRelations = new List<AccountContactRelation>();

        // Create a map of all the ACRoles
        ACRoles = [
                SELECT ContactId,AccountId,IsPrimary,Role
                FROM AccountContactRole
                WHERE AccountId IN: acctIds
        ];
        MapRoles = new Map<Id, Map<Id, AccountContactRole>>();
        For (AccountContactRole ACRole : ACRoles) {
            Map<Id, AccountContactRole> M = new Map<Id, AccountContactRole>();
            system.debug('Map is ' + M + ' and ACRole is ' + ACRole);
            M.put(ACRole.ContactId, ACRole);
            MapRoles.put(ACRole.AccountId, M);
        }
        // Create a map of all the ACRelations
        ACRelations = [
                SELECT ContactId,AccountId,IsPrimary__c,Roles
                FROM AccountContactRelation
                WHERE AccountId IN: acctIds
        ];

        MapRelations = new Map<Id, Map<Id, AccountContactRelation>>();
        For (AccountContactRelation ACRelation : ACRelations) {
            Map<Id, AccountContactRelation> M = new Map<Id, AccountContactRelation>();
            M.put(ACRelation.ContactId, ACRelation);
            if (MapRelations.get(ACRelation.AccountId)==null) {
                MapRelations.put(ACRelation.AccountId, M);
            } else {
            MapRelations.get(ACRelation.AccountId).put(ACRelation.ContactId,ACRelation);
        }
        }
        For (AccountContactRole ACRole : ACRoles){
            system.debug('ACRole is ' + ACRole);
            //Is there a corresponding ACRelation?
            // AccountContactRole ACRo = MapRoles.get(ACRole.AccountId).get(ACRole.ContactId);
            Id AcctId = ACRole.AccountId;
            Id CtctId = ACRole.ContactId;
            system.debug('CtctId is ' + CtctId);
            system.debug('Before checking to see whether ACRelation already exists, MapRelations is ' + MapRelations);
            system.debug('MapRelations.get(AcctId) is ' + MapRelations.get(AcctId));
            system.debug('MapRelations.get(AcctId).get(CtctId) is ' + MapRelations.get(AcctId).get(CtctId));
            if (MapRelations.get(AcctId).get(CtctId)!=null) {
                AccountContactRelation ACRe = MapRelations.get(AcctId).get(CtctId);
            if (ACRole.isPrimary == true)
                ACRe.IsPrimary__c = true;
            if (ACRole.Role != null)
                ACRe.Roles = ACRole.Role;
            UpdateACRelations.add(ACRe);
                system.Debug('Updated ACRelation is ' + ACRe);
        } else {
            //Add a new AccountContactRelation
                AccountContactRelation ACRe = new AccountContactRelation(
                        AccountId = AcctId,
                        ContactId = CtctId,
                        IsPrimary__c = ACRole.isPrimary==true ? true : false,
                        Roles = String.ISBLANK(ACRole.Role) ? null : ACRole.Role
                );
                        AddACRelations.add(ACRe);
                system.Debug('New ACRelation is ' + ACRe);
            }
        }
        database.update(UpdateACRelations,false);
        database.insert(AddACRelations, false);
        return ADdACRelations;
    }

/*
//  DON'T KNOW WHY THE SUBQUERIES IN THIS DON'T WORK
    public void CopyACRolesToACRelationships() {
        List<AccountContactRelation> AddACRelations = new List<AccountContactRelation>();
        // Pick all the Accounts which don't already have ACRelationships;
        LIST<Account> Accts = [
                SELECT iD,
                (SELECT Id, ContactId, IsPrimary, Role, AccountId FROM AccountContactRoles),
                (SELECT Id FROM AccountContactRelations)
                FROM Account WHERE Name = 'LeadGreen'
        ];
        system.debug('Selected ' + Accts.size() + ' accounts ' + Accts);
        For (Account a : Accts) {
            if (a.AccountContactRelations.size() == 0) {
                for (AccountContactRole acrole : a.AccountContactRoles) {
                    AccountContactRelation acrelation = new AccountContactRelation(
                            accountId = a.Id,
                            contactId = acrole.ContactId,
                            isPrimary__c = acrole.isPrimary,
                            Roles = acrole.Role
                    );
                    AddACRelations.add(acrelation);
                }
            }
        }
        system.debug('AddACRelations is ' + AddACRelations);
    }
 */
}
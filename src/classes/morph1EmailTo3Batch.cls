/**
 * Created by Baird on 6/17/2020.
 */

public class morph1EmailTo3Batch implements Database.Batchable<SObject>{

        public string query;
        public string step;

        public Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
        }

        public void execute(Database.BatchableContext jobId, List<SObject> scope)
        {
            List<ID> CLIDs = new List<ID>();
            for (SObject s : scope) {
                CLIDs.add((Id)s.get('Id'));
            }
            morph1Emailto3 m1E3 = new morph1EmailTo3();
            m1E3.arrangeEmails(CLIds);
        }

        public void finish(Database.BatchableContext jobId)
        {
            if (step=='processContacts') {
                step='processLeads';
                morph1EmailTo3InvokeBatchForLeads ME3 = new morph1EmailTo3InvokeBatchForLeads();
                mE3.invokeBatch();
            }
        }
    }
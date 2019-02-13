/**
 * Created by Baird on 10/25/2018.
 */

global with sharing class scheduleAccountContactRecalc implements Schedulable
    {
        public static String CRON_EXP = '0 0 0 * * ?';

        global void execute(SchedulableContext ctx)
        {
            String jobName = 'Accounts and Contacts - Recalculate Contributions';

            recalcAccountBatch RAB = new recalcAccountBatch();
            RAB.query = 'select id from Account';

            ID batchprocessid = database.executeBatch(RAB);
            System.debug('Returned batch process ID: ' + batchProcessId);
        }

    }
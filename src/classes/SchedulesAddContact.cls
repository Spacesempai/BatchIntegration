/**
 * Created by Alexey Dmytrenko on 18.08.2021.
 */

//ContactIntegrationScheduler
global with sharing class SchedulesAddContact implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('test');
        //there is a limit of selection 50000 records in sync Apex. Batchable jobs can bypass this limit, but selection records directly here can fail on large records amount
        //pass String query to Batch instead
        //you can see examples here: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch_interface.htm
        List <Contact> conList = [SELECT FirstName, LastName, Title, Description FROM Contact WHERE isUpdated__c = TRUE];   //IsUpdated
        BatchAddContact batchClass = new BatchAddContact(conList);
        //you have Limit of 100 callouts per transaction for both sync and async operations. decrease chunk size to 50 (while you need extra requests for record existence checking)
        Database.executeBatch(batchClass, 200); //Limits: https://developer.salesforce.com/docs/atlas.en-us.232.0.apexcode.meta/apexcode/apex_gov_limits.htm
        //String CRON_EXP = '0 0 * * * ?';
        //SchedulesAddContact sch = new SchedulesAddContact();
        //system.schedule('Hourly Batch', CRON_EXP, sch);
    }
}
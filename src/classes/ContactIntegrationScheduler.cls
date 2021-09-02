/**
 * Created by Alexey Dmytrenko on 18.08.2021.
 */

global with sharing class ContactIntegrationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query = 'SELECT FirstName, LastName, Title, Description FROM Contact WHERE isUpdated__c = TRUE';
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch(query);
        Database.executeBatch(batchClass, 30);
        //String CRON_EXP = '0 0 * * * ?';
        //ContactIntegrationScheduler sch = new ContactIntegrationScheduler();
        //system.schedule('Hourly Batch', CRON_EXP, sch);
    }

}
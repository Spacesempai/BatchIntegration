/**
 * Created by Alexey Dmytrenko on 18.08.2021.
 */

global with sharing class ContactIntegrationScheduler implements Schedulable {

//    private String objectName;
//
//    ContactIntegrationScheduler(String objectName) {
//        this.objectName = objectName;
//    }

    global void execute(SchedulableContext sc) {
        IntegrationConfiguration__mdt mtdObj = [SELECT Object__c, queryCondition__c FROM IntegrationConfiguration__mdt WHERE Object__c='Contact' LIMIT 1];
        String query = ContactIntegrationBatchHelper.getQuery(mtdObj);
        String endpoint = ContactIntegrationBatchHelper.getEndpoint(mtdObj);
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch(query,endpoint);
        Database.executeBatch(batchClass, 30);
        //String CRON_EXP = '0 0 * * * ?';
        //ContactIntegrationScheduler sch = new ContactIntegrationScheduler();
        //system.schedule('Hourly Batch', CRON_EXP, sch);
    }

}
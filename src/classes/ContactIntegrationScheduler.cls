/**
 * Created by Alexey Dmytrenko on 18.08.2021.
 */

global with sharing class ContactIntegrationScheduler implements Schedulable {
    public ContactIntegrationScheduler(String objectName) {
        this.objectName = objectName;
    }
    private String objectName;
    global void execute(SchedulableContext sc) {
//        IntegrationConfiguration__mdt mtdObj = [SELECT object__c,queryCondition__c FROM IntegrationConfiguration__mdt WHERE Object__c = :String.escapeSingleQuotes(objectName) LIMIT 1];
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch(objectName);
        Database.executeBatch(batchClass, 30);
        //String CRON_EXP = '0 0 * * * ?';
        //ContactIntegrationScheduler sch = new ContactIntegrationScheduler();
        //system.schedule('Hourly Batch', CRON_EXP, sch);
    }

}
/**
 * Created by Alexey Dmytrenko on 18.08.2021.
 */

global with sharing class SchedulesAddContact implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('test');
        List <Contact> conList = [SELECT FirstName, LastName, Title, Description FROM Contact WHERE isUpdated__c = TRUE];
        BatchAddContact batchClass = new BatchAddContact(conList);
        Database.executeBatch(batchClass, 200);
        //String CRON_EXP = '0 0 * * * ?';
        //SchedulesAddContact sch = new SchedulesAddContact();
        //system.schedule('Hourly Batch', CRON_EXP, sch);
    }
}
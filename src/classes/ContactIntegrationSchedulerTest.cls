/**
 * Created by Alexey Dmytrenko on 20.08.2021.
 */

@IsTest
private class ContactIntegrationSchedulerTest {

    @IsTest
    static void testScheduleBatch() {
//        List<IntegrationConfiguration__mdt> testIntegrationConfiguration = (List<IntegrationConfiguration__mdt>)Json.deserialize(
//            '[{"object__c": "Contact","queryCondition__c": "isUpdated == true"}]', List<IntegrationConfiguration__mdt>.class);
        Test.startTest();
//        ContactIntegrationBatchHelper.integrationConfiguration = testIntegrationConfiguration;
        ContactIntegrationScheduler scheduler= new ContactIntegrationScheduler('Contact');
        String jobId = System.schedule('myJobTestJobName', '0 0 0 ? * * *', scheduler);
        scheduler.execute(null);
        Test.stopTest();
    }
}
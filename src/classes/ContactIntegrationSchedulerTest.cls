/**
 * Created by Alexey Dmytrenko on 20.08.2021.
 */

@IsTest
private class ContactIntegrationSchedulerTest {
    @IsTest
    static void testScheduleBatch() {
        Test.startTest();
        ContactIntegrationScheduler scheduler= new ContactIntegrationScheduler();
        String jobId = System.schedule('myJobTestJobName', '0 0 0 ? * * *', scheduler);
        scheduler.execute(null);
        Test.stopTest();
    }
}
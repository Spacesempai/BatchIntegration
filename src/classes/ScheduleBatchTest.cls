/**
 * Created by Alexey Dmytrenko on 20.08.2021.
 */

@IsTest
private class ScheduleBatchTest {
    @IsTest
    static void testScheduleBatch() {
        Test.startTest();
        SchedulesAddContact scheduler= new SchedulesAddContact();
        String jobId = System.schedule('myJobTestJobName', '0 0 0 ? * * *', scheduler);
        scheduler.execute(null);
        Test.stopTest();
        //assert
    }
}
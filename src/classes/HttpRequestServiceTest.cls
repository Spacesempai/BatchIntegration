/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

@IsTest
private class HttpRequestServiceTest {
    @IsTest
    public static void testTokenOk() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"access_token":"qwerty","instance_url":"https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com",' +
                '"id":"https://login.salesforce.com/id/00D0900000AEwt1EAD/00509000007yvGXAAY",' +
                '"token_type":"Bearer","issued_at":"1629441232617","signature":"uFJFM/ZSsiq0mEWCPxAEMfRRbyftkV2HSJCq03vjAwA="}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        String token = ContactIntegrationBatchHelper.getAccessToken();
        Test.stopTest();
        System.assertEquals(token, 'qwerty');
    }
    @IsTest
    public static void testBatchPatch() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"totalSize":2,"done":true,"records":[{"attributes":' +
                '{"type":"Contact","url":"/services/data/v52.0/sobjects/Contact/0030900000VW2tVAAT"},"Id":"0030900000VW2tVAAT","Name":"Azx Azx"},' +
                '{"attributes":{"type":"Contact","url":"/services/data/v52.0/sobjects/Contact/0030900000VW4uxAAD"},' +
                '"Id":"0030900000VW4uxAAD","Name":"Mikky Mouse"}]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        List <Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName = 'Azx', LastName = 'Azx'));
        conList.add(new Contact(FirstName = 'Mikky', LastName = 'Mouse'));
        insert conList;
        Contact cont = [SELECT FirstName FROM Contact WHERE FirstName = 'Azx'];
        Contact cont2 = [SELECT FirstName FROM Contact WHERE FirstName = 'Mikky'];
        System.debug('cont ' + cont);
        System.debug('cont2 ' + cont2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        ContactIntegrationBatchHelper.getAccessToken();
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch('Contact');
        Database.executeBatch(batchClass, 30);
        Test.stopTest();
    }
    @IsTest
    public static void testBatchPost2() {
                List<IntegrationConfiguration__mdt> testIntegrationConfiguration = (List<IntegrationConfiguration__mdt>)Json.deserialize(
            '[{"object__c": "Contact","queryCondition__c": "isUpdated__c== true"}]', List<IntegrationConfiguration__mdt>.class);
                System.debug(ContactIntegrationBatchHelper.integrationConfiguration = testIntegrationConfiguration);
        List<IntegrationConfigFields__mdt> testIntegrationConfigFields = (List<IntegrationConfigFields__mdt>)Json.deserialize(
            '[{"fieldName__c": "lastName"}]', List<IntegrationConfigFields__mdt>.class);
        System.debug(ContactIntegrationBatchHelper.integrationConfigFields = testIntegrationConfigFields);
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"totalSize":0,"done":true,"records":[]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        List <Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName = 'Azx', LastName = 'Azx'));
        conList.add(new Contact(FirstName = 'Mikky', LastName = 'Mouse'));
        insert conList;
        Contact cont = [SELECT FirstName FROM Contact WHERE FirstName = 'Azx'];
        Contact cont2 = [SELECT FirstName FROM Contact WHERE FirstName = 'Mikky'];
        System.debug('cont ' + cont);
        System.debug('cont2 ' + cont2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        ContactIntegrationBatchHelper.getAccessToken();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch('Contact');
        Database.executeBatch(batchClass, 200);
        Test.stopTest();
    }
    @IsTest
    public static void testFailedBatch() {
        List<IntegrationConfiguration__mdt> testIntegrationConfiguration = (List<IntegrationConfiguration__mdt>)Json.deserialize(
            '[{"object__c": "Contact","queryCondition__c": "isUpdated__c== true"}]', List<IntegrationConfiguration__mdt>.class);
        System.debug(ContactIntegrationBatchHelper.integrationConfiguration = testIntegrationConfiguration);
        List<IntegrationConfigFields__mdt> testIntegrationConfigFields = (List<IntegrationConfigFields__mdt>)Json.deserialize(
            '[{"fieldName__c": "lastName"}]', List<IntegrationConfigFields__mdt>.class);
        System.debug(ContactIntegrationBatchHelper.integrationConfigFields = testIntegrationConfigFields);
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(400,
            'Error',
            '{"totalSize":0,"done":false,"records":[]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        List <Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName = 'Azx', LastName = 'Azx'));
        conList.add(new Contact(FirstName = 'Mikky', LastName = 'Mouse'));
        insert conList;
        Contact cont = [SELECT FirstName FROM Contact WHERE FirstName = 'Azx'];
        Contact cont2 = [SELECT FirstName FROM Contact WHERE FirstName = 'Mikky'];
        System.debug('cont ' + cont);
        System.debug('cont2 ' + cont2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        ContactIntegrationBatchHelper.getAccessToken();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        ContactIntegrationBatch batchClass = new ContactIntegrationBatch('Contact');
        Database.executeBatch(batchClass, 200);
        Test.stopTest();
    }


}
/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

@IsTest
private class HttpRequestHelperTest {
    @IsTest
    public static void testCheckContactOne() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"records":[{"attributes":{"type":"Contact",' +
                '"url":"/services/data/v52.0/sobjects/Contact/0030900000VW2tVAAT"},' +
                '"Id":"0030900000VW2tVAAT","Name":"Azx Azx"}]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        Set<Id> ids = BatchAddContactHelper.checkContactExistence(new Contact(FirstName = 'Azx', LastName = 'Azx'));
        Test.stopTest();
        System.assertEquals(ids.size(), 1);
    }
    @IsTest
    public static void testCheckContactMulti() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"totalSize":2,"done":true,"records":[{"attributes":' +
                '{"type":"Contact","url":"/services/data/v52.0/sobjects/Contact/0030900000VW2tVAAT"},"Id":"0030900000VW2tVAAT","Name":"Azx Azx"},' +
                '{"attributes":{"type":"Contact","url":"/services/data/v52.0/sobjects/Contact/0030900000VW4uxAAD"},' +
                '"Id":"0030900000VW4uxAAD","Name":"Azx Azx"}]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        Set<Id> ids = BatchAddContactHelper.checkContactExistence(new Contact(FirstName = 'Azx', LastName = 'Azx'));
        Test.stopTest();
        System.assertEquals(ids.size(), 2);
    }
    @IsTest
    public static void testCheckContactNone() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"totalSize":0,"done":true,"records":[]}]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        Set<Id> ids = BatchAddContactHelper.checkContactExistence(new Contact(FirstName = 'A24zx', LastName = 'Az12ax'));
        Test.stopTest();
        System.assertEquals(ids, null);
    }
    @IsTest
    public static void testCheckContactNullBody() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(200,
            'OK',
            '{"totalSize":0,"done":true,"records":[]}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        Set<Id> ids = BatchAddContactHelper.checkContactExistence(new Contact(FirstName = 'A24zx', LastName = 'Az12ax'));
        Test.stopTest();
        System.assertEquals(ids, null);
    }
    @IsTest
    public static void testCheckContactFailed() {
        RestHttpCalloutMock fakeContactResponse = new RestHttpCalloutMock(400,
            'Failed',
            '{"message":"INVALID_HEADER_TYPE","errorCode":"INVALID_AUTH_HEADER"}',
            null);
        Credentials__c newCredentials = new Credentials__c(Token__c = 'test', Username__c = 'Test', Password__c = 'Test',
            Secret__c = 'Test', Key__c = 'Test');
        insert newCredentials;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeContactResponse);
        Set<Id> ids = BatchAddContactHelper.checkContactExistence(new Contact(FirstName = 'A24zx', LastName = 'Az12ax'));
        System.debug(ids);
        Test.stopTest();
        System.assertEquals(ids, null);
    }
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
        BatchAddContactHelper.getAccessToken();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        Test.stopTest();
        System.assertEquals(credentials.Access_Token__c, 'qwerty');
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
        BatchAddContactHelper.getAccessToken();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        BatchAddContact batchClass = new BatchAddContact(conList);
        Database.executeBatch(batchClass, 200);
        Test.stopTest();
    }
    @IsTest
    public static void testBatchPost() {
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
        BatchAddContactHelper.getAccessToken();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        BatchAddContact batchClass = new BatchAddContact(conList);
        Database.executeBatch(batchClass, 200);
        Test.stopTest();
    }

//    private static List<Contact> createContacts() {
//
//    }


}
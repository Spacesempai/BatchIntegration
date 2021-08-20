/**
 * Created by Alexey Dmytrenko on 17.08.2021.
 */

// try to follow naming convention: <ObjectName><Feature><Handler|Service|Batch|Selector|Controller...etc.]>
// ContactIntegrationBatch
public with sharing class BatchAddContact implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Contact> source;
//    Credentials__c credentials { get {
//        if (credentials == null) {
//            credentials = Credentials__c.getOrgDefaults();
//        }
//        return credentials;
//    } private set; }
    public BatchAddContact(List<Contact> records) {
        source = records;   //passing records to a batch is a wrong approach. The purpose of using batch is to process large amount of data. In this case, records must be selected depending on IsUpdated__c custom field, set by workflow
    }
    public List<Contact> start(Database.BatchableContext context) {
        return source; //Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, SObject[] scope) {
        //Credentials__c creds = Credentials__c.getOrgDefaults();
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c]; //use getOrgDefaults() instead of Select https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_customsettings.htm
        //getAccessToken();
        System.debug(source);   //remove all System.debugs after completing work
        System.debug(credentials);
        for (Contact contact : source) {
            Map<String, Object> contactMap = new Map<String, Object>(contact.getPopulatedFieldsAsMap());
            Id contactId = contact.Id;
            System.debug('Id:' + contactId);
            //delete unnecessary rows instead of commenting - you can always restore them from git
//            contactMap.remove('LastModifiedDate');
//            contactMap.remove('IsDeleted');
//            contactMap.remove('IsEmailBounced');
//            contactMap.remove('SystemModstamp');
//            contactMap.remove('CreatedById');
//            contactMap.remove('CreatedDate');
//            contactMap.remove('LastModifiedById');
            contactMap.remove('Id');
            System.debug('contactMap' + contactMap);
            String body = JSON.serialize(contactMap);
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + credentials.Access_Token__c);
            headers.put('Content-Type', 'application/json');
            headers.put('accept', 'application/json');
            System.debug('BODY' + body);
            Set<Id> contactIds = new Set<Id>();
            contactIds = BatchAddContactHelper.checkContactExistence(contact);//move out of loop; bulkify
            System.debug('set!!!' + contactIds);
            System.debug('ID!!!' + contactIds);
            if (contactIds !=null) {    //!contactIds.isEmpty()
                System.debug('Exist!!!');
                for (Id id : contactIds) {
                    String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/sobjects/contact/'
                        + id + '?_HttpMethod=PATCH';
                    HttpRequestHelper reqHelper = new HttpRequestHelper('POST', body, endpoint, credentials, headers);
                    HttpResponse response = reqHelper.handleRestCall();
                    System.debug('response ' + response);
                    System.debug('RESPONSE_BODY ' + response.getBody());
                    System.debug('RESPONSE_BODY Null? ' + response.getBody() == '');

                    Contact con = [SELECT LastName FROM Contact WHERE Id = :contactId];  //avoid selects in loop; unnecessary code
                    System.debug('Con ' + con);
                }
            } else {
                System.debug('Not Exist!!!');
                String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/sobjects/contact';
                HttpRequestHelper reqHelper = new HttpRequestHelper('POST', body, endpoint, credentials, headers);
                HttpResponse response = reqHelper.handleRestCall();
                System.debug(response);
                System.debug('RESPONSE_BODY' + response.getBody());
                Contact con = [SELECT LastName FROM Contact WHERE Id = :contactId]; //avoid selects in loop; unnecessary code
                System.debug('Con ' + con);
            }
        }
    }
    public void finish(Database.BatchableContext context) {
    }
}
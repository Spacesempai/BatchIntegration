/**
 * Created by Alexey Dmytrenko on 17.08.2021.
 */

public with sharing class BatchAddContact implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Contact> source;
    public BatchAddContact(List<Contact> records) {
        source = records;
    }
    public List<Contact> start(Database.BatchableContext context) {
        return source;
    }
    public void execute(Database.BatchableContext context, SObject[] scope) {
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        System.debug(source);
        System.debug(credentials);
        for (Contact contact : source) {
            Map<String, Object> contactMap = new Map<String, Object>(contact.getPopulatedFieldsAsMap());
            Id contactId = contact.Id;
            System.debug('Id:' + contactId);
//            contactMap.remove('LastModifiedDate');
//            contactMap.remove('IsDeleted');
//            contactMap.remove('IsEmailBounced');
//            contactMap.remove('SystemModstamp');
//            contactMap.remove('CreatedById');
//            contactMap.remove('CreatedDate');
//            contactMap.remove('LastModifiedById');
            contactMap.remove('Id');
//            contactMap.remove('OwnerId');
            System.debug('contactMap' + contactMap);
            String body = JSON.serialize(contactMap);
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', 'Bearer ' + credentials.Access_Token__c);
            headers.put('Content-Type', 'application/json');
            headers.put('accept', 'application/json');
            System.debug('BODY' + body);
            Set<Id> contactIds = new Set<Id>();
            contactIds = BatchAddContactHelper.checkContactExistence(contact);
            System.debug('set!!!' + contactIds);
            System.debug('ID!!!' + contactIds);
            if (contactIds !=null) {
                System.debug('Exist!!!');
                for (Id id : contactIds) {
                    String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/sobjects/contact/'
                        + id + '?_HttpMethod=PATCH';
                    HttpRequestHelper reqHelper = new HttpRequestHelper('POST', body, endpoint, credentials, headers);
                    HttpResponse response = reqHelper.handleRestCall();
                    System.debug('response ' + response);
                    System.debug('RESPONSE_BODY ' + response.getBody());
                    System.debug('RESPONSE_BODY Null? ' + response.getBody() == '');

                    Contact con = [SELECT LastName FROM Contact WHERE Id = :contactId];
                    System.debug('Con ' + con);
                }
            } else {
                System.debug('Not Exist!!!');
                String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/sobjects/contact';
                HttpRequestHelper reqHelper = new HttpRequestHelper('POST', body, endpoint, credentials, headers);
                HttpResponse response = reqHelper.handleRestCall();
                System.debug(response);
                System.debug('RESPONSE_BODY' + response.getBody());
                Contact con = [SELECT LastName FROM Contact WHERE Id = :contactId];
                System.debug('Con ' + con);
            }
        }
    }
    public void finish(Database.BatchableContext context) {
    }
}
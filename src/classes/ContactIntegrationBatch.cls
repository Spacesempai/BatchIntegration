/**
 * Created by Alexey Dmytrenko on 17.08.2021.
 */

public with sharing class ContactIntegrationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private String token = ContactIntegrationBatchHelper.getAccessToken();
    public String query;
    public ContactIntegrationBatch(String query) {
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Contact> source) {
        for (Contact contact : source) {
            Map<String, Object> contactMap = new Map<String, Object>(contact.getPopulatedFieldsAsMap());
            contactMap.remove('Id');
            String body = JSON.serialize(contactMap);
            String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/sobjects/contact/ExtId__c/'
                + contact.Id;
            HttpRequestHandler reqHandler = new HttpRequestHandler();
            HttpResponse response = reqHandler.handleRestCallout(token,endpoint,body,'PATCH');
        }
    }

    public void finish(Database.BatchableContext context) {
    }

}
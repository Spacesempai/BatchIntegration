/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

//make a subclass of ContactIntegrationBatch
//OperationResult
public with sharing class ResponseHandler {
    public Boolean done;
    public Integer totalSize;
    public List<Contact> records;
}
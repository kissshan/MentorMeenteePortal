public with sharing class SearchController {
    public SearchController() {

    }

    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        system.debug('objectName::'+objectName);
        System.debug('fields::'+fields);
        System.debug('searchTerm::'+searchTerm);
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }

    @AuraEnabled(cacheable=true)
    public static list<Course_Enrollment__c> courseEnrollmentDetails(String courseId){
        try {
            if(courseId != null && courseId != ''){
                return [select id,Applied_by__c,Contact__c,contact__r.name,contact__r.Email,contact__r.MailingState,Course_Master__c,Mentor__c,Status__c from Course_Enrollment__c
                    where Course_Master__c =: courseId and (Status__c = 'Requested by Student' or Status__c = 'Requested by Mentor')];
            }else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}

public class FirestoreUploadAttachment {
    @AuraEnabled
    public static void saveChunk(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        blob Body = EncodingUtil.base64Decode(base64Data);
        sendAttachmentToFirestoreDatabase(Body,fileName,parentId);
    }
    @auraEnabled
    public static void sendAttachmentToFirestoreDatabase(blob body,String fileName, string mentorCourseScheduleId){
        //string mentorCourseScheduleId = [SELECT Id FROM Mentor_Course_Schedule__c WHERE Course_Session__c =: sessionId].id;
        String folderName = [Select Name From Mentor_Course_Schedule__c where Id =: mentorCourseScheduleId].Name;
        string endPoint = 'https://firebasestorage.googleapis.com/v0/b/utilitarian-3bee4.appspot.com/o?uploadType=media&name=';
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setBodyAsBlob(body);
        system.debug('Enpointss=>'+endPoint+folderName+'/'+fileName);
        req.setEndpoint(endPoint+folderName+'/'+fileName);
        req.setHeader('Content-Type', 'image/png');
        HttpResponse response = http.send(req);
        system.debug('response'+response.getStatusCode());
        system.debug('response'+response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            string fireBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/';
            string fileDownloadUrl = fireBaseUrl+results.get('bucket')+'/o/'+results.get('name')+'?alt=media&token='+results.get('downloadTokens');
            system.debug('fileDownloadUrl'+fileDownloadUrl);
            /*Course_Schedule__c courseSchedule = new Course_Schedule__c();
courseSchedule.Id = sessionId;                      
courseSchedule.Download_File_URL__c = fileDownloadUrl;
upsert courseSchedule;*/
            
            Session_Attachment__c sessionAttchment = new Session_Attachment__c();
            sessionAttchment.Name = String.valueOf(results.get('name'));
            //sessionAttchment.Attachment_Type__c = String.valueOf(results.get('contentType'));
            //	sessionAttchment.Video_Id__c = ;
            sessionAttchment.Mentor_Course_Schedule__c = mentorCourseScheduleId;
            sessionAttchment.FILE_URL__c = fileDownloadUrl; 
            insert sessionAttchment;
            system.debug('sessionAttchment::'+sessionAttchment.Id);
        }
    }
    @auraEnabled
    public static void downloadFileFromFireStoreDatabase(String mentorCourseScheduleId){
        List<string> endpointURLList = new List<string>();
        string endpointUrl;
        List<Session_Attachment__c> sessionAttachmentList = [Select id,FILE_URL__c From Session_Attachment__c Where Mentor_Course_Schedule__c =:mentorCourseScheduleId];
        for(Session_Attachment__c sessionAttachment : sessionAttachmentList){
            endpointURLList.add(sessionAttachment.FILE_URL__c);// = sessionAttachment.FILE_URL__c;
            //sessionAttachmnetId = sessionAttachment.Id;
        }
        for(String endpoint : endpointURLList){
            endpointUrl = endpoint;
        }
            //system.debug('sessionAttachmnetId'+sessionAttachmnetId);
            system.debug('endpoint'+endpointURLList);
            //string endpoint = [Select Download_File_URL__c From Course_Schedule__c Where Id =: sessionId].Download_File_URL__c;
            Http http = new Http();
            HttpRequest req =new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(endpointUrl);
            HttpResponse response = http.send(req);
            system.debug('response'+response.getBodyAsBlob());
            system.debug('response'+response.getStatusCode());
            
            String responseBody = EncodingUtil.base64Encode(response.getBodyAsBlob());
            system.debug('boddy'+responseBody);
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(responseBody);
            cv.Title = 'untitled';
            cv.PathOnClient = 'untitled';
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = mentorCourseScheduleId;
            insert cdl;
        
    }
    @auraEnabled 
    public static Map<Course_Offering__c, List<Course_Schedule__c>> getCourseModuleAndSession(String courseMasterId){
        List<Course_Offering__c> courseModuleList =  [SELECT Name,Id,(select id,Module_Name__c from Course_Schedules__r) FROM Course_Offering__c WHERE Course_Master__c =: courseMasterId];
        Map<id, Course_Offering__c> courseModuleMapById = new Map<id, Course_Offering__c>();
        for(Course_Offering__c courseOffering : courseModuleList){
            courseModuleMapById.put(courseOffering.Id, courseOffering);
        }
        List<Course_Schedule__c> courseScheduleList = [SELECT id,Course_Offering__c,Name,Module_Name__c FROM Course_Schedule__c];
        Map<Course_Offering__c, List<Course_Schedule__c>> mapOfCourseOfferingAndSession = new Map<Course_Offering__c, List<Course_Schedule__c>>(); 
        for(Course_Schedule__c courseSchedule : courseScheduleList ){
            List<Course_Schedule__c> courseScheduledList = new List<Course_Schedule__c>();
            if(courseModuleMapById.containsKey(courseSchedule.Course_Offering__c)){
                if(mapOfCourseOfferingAndSession.containsKey(courseModuleMapById.get(courseSchedule.Course_Offering__c))){
                    courseScheduledList = mapOfCourseOfferingAndSession.get(courseModuleMapById.get(courseSchedule.Course_Offering__c));
                    courseScheduledList.add(courseSchedule);
                    mapOfCourseOfferingAndSession.put(courseModuleMapById.get(courseSchedule.Course_Offering__c),courseScheduledList);
                }
                else{
                    mapOfCourseOfferingAndSession.put(courseModuleMapById.get(courseSchedule.Course_Offering__c),new List<Course_Schedule__c>{courseSchedule});
                }
            }
        }
        system.debug('mapOfCourseOfferingAndSession::'+mapOfCourseOfferingAndSession);
        system.debug('courseModuleMapById::'+courseModuleMapById);
        return mapOfCourseOfferingAndSession;
    }    
}
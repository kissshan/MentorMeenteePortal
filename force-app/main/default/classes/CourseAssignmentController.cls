public with sharing class CourseAssignmentController {
    
    public CourseAssignmentController() {

    }

    @AuraEnabled
    public static list<CourseAssignmentWrapper> getAssignmentStats(list<Course_Enrollment__c> studentRecords,list<Course_Enrollment__c> mentorRecords,string subQuery){
        try {
            System.debug('studentRecords::'+studentRecords);
            System.debug('studentRecords::'+mentorRecords);
            string courseMasterId = 'a0b6D000001P7hT';
            if(subQuery == ''){
                return studentAssignment(studentRecords,mentorRecords,courseMasterId);
            }else if(subQuery == 'Location'){
                return studentAssignmentBasedonLocation(studentRecords,mentorRecords,courseMasterId);
            }
            return new List<CourseAssignmentWrapper>();
            
            //return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static list<CourseAssignmentWrapper> studentAssignment(list<Course_Enrollment__c> studentRecords,list<Course_Enrollment__c> mentorRecords,string courseMasterId){
        list<string> mentorRecordsIds = new list<String>();
        map<Id,list<Course_Enrollment__c>> mapOfidbyStudentlist = new map<Id,list<Course_Enrollment__c>>();
         List<CourseAssignmentWrapper> courseWreapperList = new List<CourseAssignmentWrapper>();
        map<Id,Integer> mapofIdbyStudentCount = new map<id,Integer>();
        map<Id,list<CourseAssignmentWrapper>> mapofMentorIdbyStudent = new map<Id,list<CourseAssignmentWrapper>>();
        list<Course_Enrollment__c> assignedStudent = new list<Course_Enrollment__c>();

        if(!mentorRecords.isEmpty()){
            for(Course_Enrollment__c course : mentorRecords){
                mentorRecordsIds.add(course.Contact__c);
            }
            
        }

        assignedStudent = [select id,Mentor__c from Course_Enrollment__c where Course_Master__c =: courseMasterId and Mentor__c in : mentorRecordsIds and Applied_by__c ='Student' and 
        Status__c != 'Requested by Mentor'];
        System.debug('assignedStudent::'+assignedStudent);
        if(assignedStudent.size() > 0){
            for(Course_Enrollment__c courseEn : assignedStudent){
                if(mapOfidbyStudentlist.containsKey(courseEn.Mentor__c)){
                    mapOfidbyStudentlist.get(courseEn.Mentor__c).add(courseEn);
                }else{
                    mapOfidbyStudentlist.put(courseEn.Mentor__c,new list<Course_Enrollment__c>{courseEn});
                }
            }
        }
        system.debug('mapOfidbyStudentlist::'+mapOfidbyStudentlist);
        if(!mapOfidbyStudentlist.isEmpty()){
            for(string mentorId : mapOfidbyStudentlist.keySet()){
                mapofIdbyStudentCount.put(mentorId,mapOfidbyStudentlist.get(mentorId).size());
            }
        }
        System.debug('mapofIdbyStudentCount::'+mapofIdbyStudentCount);
        integer studentCount = 0;
        integer maxCount = 0;
        string keyValue = '';
        
        for(integer i=0;i<studentRecords.size();i++){
            integer sCount = 0;
            integer count = 0;
            map<id,Course_Enrollment__c> mapofMentor = new map<id,Course_Enrollment__c>();
            CourseAssignmentWrapper courseWreapper = new CourseAssignmentWrapper();
            for(Course_Enrollment__c mentorRec : mentorRecords){
                if(mapofIdbyStudentCount.get(mentorRec.Contact__c) == null){
                    mapofIdbyStudentCount.put(mentorRec.Contact__c,0);
                }
                if(count == 0){
                    ++count; 
                     sCount = mapofIdbyStudentCount.get(mentorRec.Contact__c);
                 }

                 if(sCount >= mapofIdbyStudentCount.get(mentorRec.Contact__c)){
                    sCount = mapofIdbyStudentCount.get(mentorRec.Contact__c);
                    keyValue = mentorRec.Contact__c;
                    mapofMentor.put(keyValue,mentorRec);
                 }
            }
                integer onMap = mapofIdbyStudentCount.get(keyValue) + 1;
                mapofIdbyStudentCount.put(keyValue,onMap);

                courseWreapper.studentName = studentRecords[i].contact__r.name;
                courseWreapper.studentEmail = studentRecords[i].contact__r.email;
                courseWreapper.mentorName = mapofMentor.get(keyValue).Contact__r.name;
                courseWreapper.mentorEmail = mapofMentor.get(keyValue).Contact__r.email;
                courseWreapper.mentorId = mapofMentor.get(keyValue).Contact__c;
                courseWreapper.studentId = studentRecords[i].Contact__c;
                courseWreapper.courseEnrollmentId = studentRecords[i].id;
                courseWreapperList.add(courseWreapper);
        }

        System.debug('courseWreapperList::'+courseWreapperList);
        return courseWreapperList;

    }

    public static list<CourseAssignmentWrapper> studentAssignmentBasedonLocation(list<Course_Enrollment__c> studentRecords,list<Course_Enrollment__c> mentorRecords,string courseMasterId){
        list<string> mentorRecordsIds = new list<String>();
        map<Id,list<Course_Enrollment__c>> mapOfidbyStudentlist = new map<Id,list<Course_Enrollment__c>>();
         List<CourseAssignmentWrapper> courseWreapperList = new List<CourseAssignmentWrapper>();
        map<Id,Integer> mapofIdbyStudentCount = new map<id,Integer>();
        map<Id,list<CourseAssignmentWrapper>> mapofMentorIdbyStudent = new map<Id,list<CourseAssignmentWrapper>>();
        list<Course_Enrollment__c> assignedStudent = new list<Course_Enrollment__c>();

        if(!mentorRecords.isEmpty()){
            for(Course_Enrollment__c course : mentorRecords){
                mentorRecordsIds.add(course.Contact__c);
            }
            
        }

        assignedStudent = [select id,Mentor__c from Course_Enrollment__c where Course_Master__c =: courseMasterId and Mentor__c in : mentorRecordsIds and Applied_by__c ='Student' and 
        Status__c != 'Requested by Mentor'];
        System.debug('assignedStudent::'+assignedStudent);
        if(assignedStudent.size() > 0){
            for(Course_Enrollment__c courseEn : assignedStudent){
                if(mapOfidbyStudentlist.containsKey(courseEn.Mentor__c)){
                    mapOfidbyStudentlist.get(courseEn.Mentor__c).add(courseEn);
                }else{
                    mapOfidbyStudentlist.put(courseEn.Mentor__c,new list<Course_Enrollment__c>{courseEn});
                }
            }
        }
        system.debug('mapOfidbyStudentlist::'+mapOfidbyStudentlist);
        if(!mapOfidbyStudentlist.isEmpty()){
            for(string mentorId : mapOfidbyStudentlist.keySet()){
                mapofIdbyStudentCount.put(mentorId,mapOfidbyStudentlist.get(mentorId).size());
            }
        }
        System.debug('mapofIdbyStudentCount::'+mapofIdbyStudentCount);
        integer studentCount = 0;
        integer maxCount = 0;
        
        
        for(integer i=0;i<studentRecords.size();i++){
            integer sCount = 0;
            integer count = 0;
            string keyValue = '';
            map<id,Course_Enrollment__c> mapofMentor = new map<id,Course_Enrollment__c>();
            CourseAssignmentWrapper courseWreapper = new CourseAssignmentWrapper();
            for(Course_Enrollment__c mentorRec : mentorRecords){
                if(studentRecords[i].contact__r.MailingState == mentorRec.contact__r.MailingState){
                    if(mapofIdbyStudentCount.get(mentorRec.Contact__c) == null){
                        mapofIdbyStudentCount.put(mentorRec.Contact__c,0);
                    }
                    if(count == 0){
                        ++count; 
                         sCount = mapofIdbyStudentCount.get(mentorRec.Contact__c);
                     }
    
                     if(sCount >= mapofIdbyStudentCount.get(mentorRec.Contact__c)){
                        sCount = mapofIdbyStudentCount.get(mentorRec.Contact__c);
                        keyValue = mentorRec.Contact__c;
                        mapofMentor.put(keyValue,mentorRec);
                     }
                }
            }
            if(keyValue != ''){
                integer onMap = mapofIdbyStudentCount.get(keyValue) + 1;
                mapofIdbyStudentCount.put(keyValue,onMap);
    
                courseWreapper.studentName = studentRecords[i].contact__r.name;
                courseWreapper.studentEmail = studentRecords[i].contact__r.email;
                courseWreapper.mentorName = mapofMentor.get(keyValue).Contact__r.name;
                courseWreapper.mentorEmail = mapofMentor.get(keyValue).Contact__r.email;
                courseWreapper.mentorId = mapofMentor.get(keyValue).Contact__c;
                courseWreapper.studentId = studentRecords[i].Contact__c;
                courseWreapper.courseEnrollmentId = studentRecords[i].id;
                courseWreapperList.add(courseWreapper);
            }
            
        }

        System.debug('courseWreapperList::'+courseWreapperList);
        return courseWreapperList;

    }



    @AuraEnabled
    public static string assignMentorToStudent(string courseAssignmentString,string name){
        try {
            list<Course_Enrollment__c> courseEnrollList = new list<Course_Enrollment__c>();
            system.debug('courseAssignmentString::'+courseAssignmentString);
            List<CourseAssignmentWrapper> courseAssignmentList = (List<CourseAssignmentWrapper>)System.JSON.deserialize(courseAssignmentString, List<CourseAssignmentWrapper>.class);
            system.debug('courseAssignmentList::'+courseAssignmentList);
            for(CourseAssignmentWrapper courseWrap : courseAssignmentList){
                if(courseWrap.mentorId != null && courseWrap.mentorId != ''){
                    Course_Enrollment__c courseEnrollmentTobeUpdate = new Course_Enrollment__c();
                    courseEnrollmentTobeUpdate.Id = courseWrap.courseEnrollmentId;
                    courseEnrollmentTobeUpdate.Mentor__c = courseWrap.mentorId;
                    courseEnrollmentTobeUpdate.Status__c = 'Allocated for Mentoring';
                    courseEnrollList.add(courseEnrollmentTobeUpdate);
                }

            }
            system.debug('courseEnrollList::'+courseEnrollList);
            if(courseEnrollList.size()>0)
                update courseEnrollList;

                return 'success';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
}

public class BatchForCoureEnrollment implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Applied_by__c,Contact__c,Course_Master__r.Name,Enrollment_Date__c,Id,Name,RecordTypeId,Schedule_Start_Date__c,Status__c FROM Course_Enrollment__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<Course_Enrollment__c> courseEnrollmentList){
        set<String> courseEnrollmentType = new set<String>();
        Map<String ,List<Course_Enrollment__c>> mentorEnrolledForCourse = new Map<String ,List<Course_Enrollment__c>>();
        Map<String ,List<Course_Enrollment__c>> studentsEnrolledForCourse = new Map<String ,List<Course_Enrollment__c>>();
        List<Course_Student_Association__c> StudentToBeAsignedToMentor = new  List<Course_Student_Association__c>();
        
        string MentorrecTypeID = Schema.SobjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Mentor').getRecordTypeId();
        string MenteerecTypeID = Schema.SobjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        system.debug('MentorrecTypeID'+MentorrecTypeID + 'MenteerecTypeID'+MenteerecTypeID);
        
        for(Course_Enrollment__c courseEnrollmentRec : courseEnrollmentList){
            courseEnrollmentType.add(courseEnrollmentRec.Course_Master__r.Name);// course master name
            system.debug('courseEnrollmentRec.RecordTypeId'+courseEnrollmentRec.RecordTypeId+'courseEnrollmentRec.Status__c'+courseEnrollmentRec.Status__c);
            if(courseEnrollmentRec.RecordTypeId == MentorrecTypeID && courseEnrollmentRec.Status__c =='Requested by Mentor'){
                system.debug('Mentor');
                if(mentorEnrolledForCourse.containsKey(courseEnrollmentRec.Course_Master__r.Name)){
                    List<Course_Enrollment__c> newCourseEnrollmentList = mentorEnrolledForCourse.get(courseEnrollmentRec.Course_Master__r.Name);
                    newCourseEnrollmentList.add(courseEnrollmentRec);
                    mentorEnrolledForCourse.put(courseEnrollmentRec.Course_Master__r.Name,newCourseEnrollmentList);  
                }else{
                    mentorEnrolledForCourse.put(courseEnrollmentRec.Course_Master__r.Name,new List<Course_Enrollment__c>{courseEnrollmentRec});
                }
            }
            if(courseEnrollmentRec.RecordTypeId == MenteerecTypeID && courseEnrollmentRec.Status__c == 'Requested by Student'){
                system.debug('Student');
                if(studentsEnrolledForCourse.containsKey(courseEnrollmentRec.Course_Master__r.Name)){
                    system.debug('in if');
                    List<Course_Enrollment__c> newCourseEnrollmentList = studentsEnrolledForCourse.get(courseEnrollmentRec.Course_Master__r.Name);
                    newCourseEnrollmentList.add(courseEnrollmentRec);
                    studentsEnrolledForCourse.put(courseEnrollmentRec.Course_Master__r.Name,newCourseEnrollmentList);  
                    system.debug('studentsEnrolledForCourse'+studentsEnrolledForCourse);
                }else{
                    system.debug('in else');
                    studentsEnrolledForCourse.put(courseEnrollmentRec.Course_Master__r.Name,new List<Course_Enrollment__c>{courseEnrollmentRec});
                    system.debug('studentsEnrolledForCourse'+studentsEnrolledForCourse);
                }
            }
        }
        system.debug('studentsEnrolledForCourse'+studentsEnrolledForCourse);
        Map<String,String> CourseEnrollIdsByType = new Map<String,String>();// course master name and course enrollment id
        for(String str:courseEnrollmentType){
            CourseEnrollIdsByType.put(str, mentorEnrolledForCourse.get(str)[0].Id);
            String CorseEnrollId = mentorEnrolledForCourse.get(str)[0].Id;
            List<Mentor_Course_Schedule__c> CourseScheduleList = [SELECT Id,Mentor__c FROM Mentor_Course_Schedule__c WHERE Course_Enrollment__c =:CorseEnrollId ];
            
            for(Course_Enrollment__c ce:studentsEnrolledForCourse.get(str)){
                system.debug('studentsEnrolledForCourse::'+studentsEnrolledForCourse.get(str));
                system.debug('studentsEnrolledForCourse::'+str);
                Course_Student_Association__c csa = new Course_Student_Association__c();
                csa.Mentor_Course_Schedule__c = CourseScheduleList[0].Id;
                csa.Student__c = ce.Contact__c;
                StudentToBeAsignedToMentor.add(csa);
            }
        }
        insert StudentToBeAsignedToMentor;
        system.debug('studentsEnrolledForCourse@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+studentsEnrolledForCourse);
        system.debug('MentorEnrolledForCourse@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mentorEnrolledForCourse);
        
        List<Course_Enrollment__c> listToBeUpdated = new  List<Course_Enrollment__c>();
        List<Course_Enrollment__c> courseEnrollList = [SELECT Id,Status__c FROM Course_Enrollment__c Where  Status__c = 'Requested by Mentor' OR Status__c = 'Requested by Student'];
        for(Course_Enrollment__c courseEnrollment : courseEnrollList){
            if(courseEnrollment.Status__c == 'Requested by Mentor'){
                courseEnrollment.Status__c = 'Student Allocated';
                listToBeUpdated.add(courseEnrollment);
            }
            else if(courseEnrollment.Status__c == 'Requested by Student'){
                courseEnrollment.Status__c = 'Allocated for Mentoring';
                listToBeUpdated.add(courseEnrollment);
            }
        }
        upsert listToBeUpdated;
        
    }
    
    
    public void finish(Database.BatchableContext BC){
    }
}
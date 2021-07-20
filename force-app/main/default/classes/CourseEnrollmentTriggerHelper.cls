public class CourseEnrollmentTriggerHelper {
    public static void createMentorCourseSchedule(map<id, Course_Enrollment__c> newCourseEnrollmentMap){
        try{
            system.debug('newCourseEnrollmentMap'+newCourseEnrollmentMap);
            string contactIdonCourse ;
            Set<id> courseMasterId = new Set<id>();
            string courseEnrollmentId;
            for(Course_Enrollment__c courseEnrollment : newCourseEnrollmentMap.values()){
                contactIdonCourse = courseEnrollment.Contact__c;
                courseMasterId.add(courseEnrollment.Course_Master__c);
                courseEnrollmentId = courseEnrollment.Id;
            }
            system.debug('courseEnrollmentId::'+courseEnrollmentId);
            system.debug('contactIdonCourse::'+contactIdonCourse);
            system.debug('courseMasterId::'+courseMasterId);
            List<Mentor_Course_Schedule__c> mentorCOurseScheduleListToBeInserted = new List<Mentor_Course_Schedule__c>();
            List<Course_Offering__c> courseModuleListWithCourseSchedules = [SELECT Course_Master__c,Description__c,Id,Module_Agenda__c,Name,(select Name,Module_Name__c,Id From Course_Schedules__r) FROM Course_Offering__c Where Course_Master__c in : courseMasterId];
            system.debug('courseModuleListWithCourseSchedules'+courseModuleListWithCourseSchedules);
            for(Course_Offering__c courseOffering : courseModuleListWithCourseSchedules){
                for(Course_Schedule__c courseSchedule : courseOffering.Course_Schedules__r){
                    Mentor_Course_Schedule__c mentorCourseSchedule = new Mentor_Course_Schedule__c();
                    mentorCourseSchedule.Name = courseOffering.Name;
                    mentorCourseSchedule.Course_Enrollment__c = courseEnrollmentId;
                    mentorCourseSchedule.Course_Module__c = courseOffering.Id;
                    mentorCourseSchedule.Course_Session__c = courseSchedule.Id;
                    mentorCourseSchedule.Mentor__c =  contactIdonCourse;
                    mentorCourseSchedule.Status__c = 'CREATED';
                    mentorCOurseScheduleListToBeInserted.add(mentorCourseSchedule);
                }
            }
            system.debug('mentorCOurseScheduleListToBeInserted'+mentorCOurseScheduleListToBeInserted);
            insert mentorCOurseScheduleListToBeInserted;
        }
        catch(exception ex){
            system.debug('Error==>'+ex.getMessage()+'Error==>'+ex.getLineNumber());
        }
        
    }
    
}
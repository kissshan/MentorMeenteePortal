trigger CourseEnrollmentTrigger on Course_Enrollment__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        system.debug('After Insert');
        CourseEnrollmentTriggerHelper.createMentorCourseSchedule(trigger.newMap);
    }
}
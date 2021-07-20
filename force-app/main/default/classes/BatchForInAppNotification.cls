public class BatchForInAppNotification implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Course_Enrollment__c,Course_Module__c,Course_Session__c,Meetting_Link__c,Mentor__c,Name,Planned_Date__c,Replanned_Date__c,Start_DateTime__c,Status__c FROM Mentor_Course_Schedule__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<Mentor_Course_Schedule__c> mentorCourseScheduleList){
        
        for(Mentor_Course_Schedule__c mentorCourseSchedule : mentorCourseScheduleList){
            Date sessionStartDAte = mentorCourseSchedule.Start_DateTime__c.date();
            Date newDate = sessionStartDAte.addDays(-1);
            integer timeAvailable = 1;
            if(newDate.isSameDay(system.today()) || (mentorCourseSchedule.Start_DateTime__c.hour() - system.now().time().hour()) <= timeAvailable){
                FireBaseCalloutForInAppNotification.makeHTTPrequestToFirebaseToNotify();
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}
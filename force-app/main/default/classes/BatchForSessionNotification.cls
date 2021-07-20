public class BatchForSessionNotification implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Start_Time__c,Start_Date__c,Session_Agenda__c From Course_Schedule__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<Course_Schedule__c> courseScheduleList){
        Map<id,String> mentorCourseScheduleMapById = new Map<id,String>();
        List<Mentor_Course_Schedule__c> mentorCourseScheduleList = [SELECT Course_Enrollment__c,Id FROM Mentor_Course_Schedule__c];
        for(Mentor_Course_Schedule__c mentorCourseSchedule : mentorCourseScheduleList){
            mentorCourseScheduleMapById.put(mentorCourseSchedule.Id,mentorCourseSchedule.Course_Enrollment__c);
        }
        Map<id,String> courseEnrollmentMapById = new Map<id,String>();
        List<Course_Enrollment__c> courseEnrollmentList = [SELECT Contact__c,Id FROM Course_Enrollment__c];
        for(Course_Enrollment__c courseEnrollmet : courseEnrollmentList){
            courseEnrollmentMapById.put(courseEnrollmet.Id,courseEnrollmet.Contact__c);
        }
        Map<id,Contact> contactMapById = new Map<id,Contact>();
        List<Contact> contactList = [Select FirstName,LastName,Email,Phone from Contact];
        for(Contact conRec : contactList){
            contactMapById.put(conRec.Id,conRec);
        }
        Map<id, Course_Schedule__c> mapByContactIdValueCourseAgendaAndStartTime = new Map<id, Course_Schedule__c>();
        for(Course_Schedule__c courseSchedule : courseScheduleList){
            Date sessionStartDAte = courseSchedule.Start_Date__c;
            Date newDate = sessionStartDAte.addDays(-1);
            integer timeAvailable = 1;
            if(newDate.isSameDay(system.today()) || (courseSchedule.Start_Time__c.Hour() - system.now().time().hour()) <= timeAvailable){
                if(mentorCourseScheduleMapById.containsKey(courseSchedule.Id)){
                    String courseEnrollmentId = mentorCourseScheduleMapById.get(courseSchedule.Id);
                    if(courseEnrollmentMapById.containsKey(courseEnrollmentId)){
                        String ContactId = courseEnrollmentMapById.get(courseEnrollmentId);
                        if(contactMapById.containsKey(contactId)){
                            contactList.add(contactMapById.get(contactId));
                            mapByContactIdValueCourseAgendaAndStartTime.put(contactId,courseSchedule);
                        }
                    }   
                }
            }
        }
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        EmailTemplate emailTemplate = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate Where Name = 'Reminder For Session'];
        for (Contact contact : contactList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> recipients = new List<String>();
            recipients.add(contact.Email);
            system.debug('recipients------'+recipients);
            mail.setToAddresses(recipients);
            mail.setSenderDisplayName('Skill development and testing team');
            
            String htmlBody = emailTemplate.body;
            if( contact.FirstName != null && contact.LastName != null){
                htmlBody = htmlBody.replace('{!Contact.FirstName}', contact.FirstName);
                htmlBody = htmlBody.replace('{!Contact.LastName}', contact.LastName);
                Course_Schedule__c courseScheduleRec =  mapByContactIdValueCourseAgendaAndStartTime.get(contact.Id);
                htmlBody = htmlBody.replace('{!Session.Agenda}', courseScheduleRec.Session_Agenda__c);
                String str = string.valueOf(courseScheduleRec.Start_Time__c);
                String sessionStartTime = str.substring(0, 5);
                htmlBody = htmlBody.replace('{!Session.StartTime}', sessionStartTime);
            }
            system.debug('htmlBody==>'+htmlBody);
            mail.setSubject(emailTemplate.Subject);
            mail.setHtmlBody(htmlBody);
            
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    
    public void finish(Database.BatchableContext BC){
    }
}
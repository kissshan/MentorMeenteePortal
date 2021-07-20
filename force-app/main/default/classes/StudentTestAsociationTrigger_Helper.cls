public class StudentTestAsociationTrigger_Helper {
    public static void SendEmailForTestAssociation(Map<id, Student_Test_Association__c> studentTestAssociationMap){
        system.debug('studentTestAssociationMap'+studentTestAssociationMap);
        set<id> conId = new set<id>();
        if(studentTestAssociationMap != null){
            for(Student_Test_Association__c studentTestAssRec : studentTestAssociationMap.values()){
                conId.add(studentTestAssRec.Contact__c);
            }
        }
        if(conId != null){
            List<Contact> contactDetailsList = [Select Id,FirstName,LastName,Email From Contact where id in: conId];
            
            EmailTemplate emailTemplateRec = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Name = 'Email For Test Master'];
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
            
            for (Contact contact : contactDetailsList) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> recipients = new List<String>();
                recipients.add(contact.Email);
                system.debug('recipients------'+recipients);
                mail.setToAddresses(recipients);
                mail.setSenderDisplayName('Utilitarian Labs');
                
                String htmlBody = emailTemplateRec.HtmlValue;
                if( contact.FirstName != null && contact.LastName != null){
                    htmlBody = htmlBody.replace('{!Contact.FirstName}', contact.FirstName);
                    htmlBody = htmlBody.replace('{!Contact.LastName}', contact.LastName);
                    htmlBody = htmlBody.replace('{!Contact.Id}', contact.Id);
                }
                system.debug('htmlBody==>'+htmlBody);
                mail.setSubject(emailTemplateRec.Subject);
                mail.setHtmlBody(htmlBody);
                
                mails.add(mail);
            }
            Messaging.sendEmail(mails);    
        }
    }
    
}
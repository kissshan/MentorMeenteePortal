public class EmailSendController {
    // return email of contact on doinit
    @AuraEnabled 
    public static String getContactEmail(String conId){
        String email = [Select Email from Contact where Id =: conId].Email;
        return email;
    }
    // return email template list on doinit
    @AuraEnabled 
    public static List<EmailTemplate> getEmailTempaltes(){
        List<EmailTemplate> emailTemplateList = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate];
        return emailTemplateList;
    }
   // send mail when send button is pressed
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody,String conId){
       List<Contact> contactList = new List<Contact>();
        if(conId != null){
            contactList = [select id,FirstName,LastName From Contact where Id =:conId];
            system.debug('contactList==>'+contactList);            
        }
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        for (Contact contact : contactList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> recipients = new List<String>();
            recipients.add(mMail);
            system.debug('recipients------'+recipients);
            mail.setToAddresses(recipients);
            mail.setSenderDisplayName('Skill development and testing team');
            
            String htmlBody = mbody;
            if( contact.FirstName != null && contact.LastName != null){
                htmlBody = htmlBody.replace('{!Contact.FirstName}', contact.FirstName);
                htmlBody = htmlBody.replace('{!Contact.LastName}', contact.LastName);
                htmlBody = htmlBody.replace('{!Contact.Id}', contact.Id);
            }
            system.debug('htmlBody==>'+htmlBody);
            mail.setSubject(mSubject);
            mail.setHtmlBody(htmlBody);
            
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }   
}
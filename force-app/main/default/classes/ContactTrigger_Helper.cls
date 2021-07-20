public class ContactTrigger_Helper {
    public static void sendEmailNotificationOnStatusChange(Map<id, Contact> newContactMap, Map<id, Contact> oldContactMap){
        if(oldContactMap == null){
            // contact is inserted i.e. oldmap will be empty
            system.debug('Contact inserted');
            
        }
        else {
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
            List<EmailTemplateForStudent__c> emailTempCustomSettingList = [SELECT Email_Template__c,Id,Name,Status__c,Test_Associated__c FROM EmailTemplateForStudent__c];
            map<String, EmailTemplateForStudent__c> templateByStatus = new map<String, EmailTemplateForStudent__c>(); 
            for(EmailTemplateForStudent__c emailTempCustomSettingRec : emailTempCustomSettingList){
                templateByStatus.put(emailTempCustomSettingRec.Status__c, emailTempCustomSettingRec);
            }
            system.debug('templateByStatus'+templateByStatus);
            List<EmailTemplate> emailTemplateList = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate ];
            map<String, EmailTemplate> templateByName = new map<String, EmailTemplate>();
            for(EmailTemplate emailTemplateRec : emailTemplateList){
                templateByName.put(emailTemplateRec.Name, emailTemplateRec);
            }
            system.debug('templateByName'+templateByName);
            map<String, List<Student_Test_Association__c>> studentTestAssociationByContactId = new map<String, List<Student_Test_Association__c>>();
            List<Contact> StudentAssDatafromContact  = [SELECT Id,(select Id,Status__c,Template__c,Test_Master__c from Student_Test_Associations__r)  FROM Contact where id in : newContactMap.keyset()];
            list<Student_Test_Association__c> studentAssRecList = new List<Student_Test_Association__c>();
            for(Contact con : StudentAssDatafromContact){
                studentAssRecList.clear();
                for(Student_Test_Association__c sta : con.Student_Test_Associations__r){
                    studentAssRecList.add(sta);
                }
                studentTestAssociationByContactId.put(con.id,studentAssRecList);
            }
            system.debug('Map for studentAssTest by contactId'+studentTestAssociationByContactId);
            
            for(Contact con : newContactMap.values()){
                if(con.Status__c != oldContactMap.get(con.Id).Status__c){
                    system.debug('con.Status__c'+con.Status__c);
                    boolean isTrue = templateByStatus.ContainsKey(con.Status__c);
                    system.debug('isTrue'+isTrue);
                    EmailTemplateForStudent__c emailTemplateCustomSetting = templateByStatus.get(con.Status__c);
                    system.debug('emailTemplateCustomSetting'+emailTemplateCustomSetting);
                    EmailTemplate emailTemplate = templateByName.get(emailTemplateCustomSetting.Email_Template__c);
                    
                    // custom setting
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    List<String> recipients = new List<String>();
                    recipients.add(con.Email);
                    system.debug('recipients------'+recipients);
                    mail.setToAddresses(recipients);
                    mail.setSenderDisplayName('UtilitarianLab');
                    
                    String htmlBody = emailTemplate.HtmlValue;
                    String studentTestAssociationId ;
                    if(studentTestAssociationByContactId.containsKey(con.Id)){
                        List<Student_Test_Association__c> testMasterListAssociatedWithContact = studentTestAssociationByContactId.get(con.Id);
                        system.debug('testMasterListAssociatedWithContact'+testMasterListAssociatedWithContact);
                        for(Student_Test_Association__c studentTestAss : testMasterListAssociatedWithContact){
                            system.debug('tempName'+studentTestAss);
                            if(emailTemplateCustomSetting.Test_Associated__c == studentTestAss.Template__c ){
                                studentTestAssociationId = studentTestAss.Id;
                                system.debug('studentTestAssociationId'+studentTestAssociationId);
                            }
                        }
                    }
                    if( con.FirstName != null && con.LastName != null){
                        htmlBody = htmlBody.replace('{!Contact.FirstName}', con.FirstName);
                        htmlBody = htmlBody.replace('{!Contact.LastName}', con.LastName);
                        htmlBody = htmlBody.replace('{!Contact.Id}', studentTestAssociationId);// student test association id 
                    }
                    system.debug('htmlBody==>'+htmlBody);
                    mail.setSubject(emailTemplate.Subject);
                    mail.setHtmlBody(htmlBody);
                    
                    mails.add(mail);
                    system.debug('mails.size'+mails.size());
                }
            }
            Messaging.sendEmail(mails);
        }
    }
    
}
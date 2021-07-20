trigger StudentTestAsociationTrigger on Student_Test_Association__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        StudentTestAsociationTrigger_Helper.SendEmailForTestAssociation(trigger.newMap);
    }
}
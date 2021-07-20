trigger ResultCategory on Student_Assessment_Result__c(after insert, after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            system.debug('in Trigger,Fired ');
            ResultCategory_Helper.updateResultCategory(trigger.newMap);
    }
}
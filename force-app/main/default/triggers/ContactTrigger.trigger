trigger ContactTrigger on Contact (after insert,after update) {
    if(trigger.isAfter &&(trigger.isInsert || trigger.isUpdate)){
        ContactTrigger_Helper.sendEmailNotificationOnStatusChange(trigger.newMap, trigger.oldMap);
    }
}
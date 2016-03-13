trigger TestObjectTrigger on testobject__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if (DataChangeApprovalHandler.enablesTrigger) {if (Trigger.isBefore && Trigger.isInsert) {
    DataChangeApprovalHandler.checkFieldsForApprovalNew(Trigger.new);
} else if (Trigger.isAfter && Trigger.isInsert) {
    DataChangeApprovalHandler.checkFieldsForApprovalNewSendEmail(Trigger.new);
} else if (Trigger.isBefore && Trigger.isUpdate) {
    DataChangeApprovalHandler.isClonedStatusUpdate(Trigger.oldMap, Trigger.new);
    DataChangeApprovalHandler.checkFieldsForApprovalEdit(Trigger.oldMap, Trigger.new);
} else if (Trigger.isBefore && Trigger.isDelete) {
    DataChangeApprovalHandler.isClonedStatusDelete(Trigger.oldMap);
}
}
}
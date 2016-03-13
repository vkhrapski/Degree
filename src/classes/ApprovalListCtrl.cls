public with sharing class ApprovalListCtrl {
	public String userName {get; set;}
	
	
	public List<Approval_List__c> getApprovalList() {
		List<Approval_List__c> approvalList = [
			SELECT Object__c, User_Link__c, User_Name__c, Link_to_Record__c, Approval_Link__c, Record_Name__c, CreatedDate
			FROM Approval_List__c
		];
		
		return approvalList;
	}
}
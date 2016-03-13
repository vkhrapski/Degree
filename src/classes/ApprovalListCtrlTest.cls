@isTest
private class ApprovalListCtrlTest {
	@isTest 
    private static void testGetApprovalList() {
    	Test.startTest();
    	ApprovalListCtrl controller = new ApprovalListCtrl();  	
    	System.assertNotEquals(null,controller.getApprovalList());
    	Test.stopTest();
    }
}
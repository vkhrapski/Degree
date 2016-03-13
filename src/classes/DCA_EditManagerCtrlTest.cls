@isTest 
public class DCA_EditManagerCtrlTest {

    static DCA_Object__c dcaObj;
    static DCA_Manager__c dcaMem;
    static DCA_Filter__c dcaFilter;
    static DCA_Filter__c dcaFilter2;

    private static void init() {

        dcaObj = new DCA_Object__c(
            Name = 'Account',
            Record_Types__c = 'testRecrdTypeForApproval');
        
        insert dcaObj;


        dcaMem = new DCA_Manager__c(
            Name = 'Test',
            Type__c = 'Profile',
            Profile__c = 'System Administrator',
            Objects__c = 'Account,Contact,TestObject'
        );
        insert dcaMem;

        dcaFilter = new DCA_Filter__c(
            DCA_Manager__c = dcaMem.Id, 
            Field__c = 'Test__c',
            Operator__c = 'equals',
            Value__c = '25', 
            Object_Name__c = 'TestObject',
            Object_Label__c = 'TestObject'
        );
        insert dcaFilter;

        dcaFilter2 = new DCA_Filter__c(
            DCA_Manager__c = dcaMem.Id, 
            Field__c = 'Test__c',
            Operator__c = 'not equals',
            Value__c = '40', 
            Object_Name__c = 'TestObject',
            Object_Label__c = 'TestObject'
        );
        insert dcaFilter2;
    }

	@isTest 
    private static void mainTestMethod() {
    	Test.startTest();
        User thisUser = [   SELECT Id   
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init(); 
        	ApexPages.currentPage().getParameters().put('mId', dcaMem.Id);
        	
        	DCA_EditManagerCtrl controller = new DCA_EditManagerCtrl();
        	controller.init();
        	controller.displayObjects();
        	controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.addFilters();

            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean flagAssert = false;
            for(Apexpages.Message msg: msgs){
                flagAssert = msg.getDetail().contains('You can select no more than ten objects.');
                if (flagAssert) {
                    break;
                }
            }
            System.assert(flagAssert);

            controller.selectedObjects.clear();

            controller.addFilters();

            msgs = ApexPages.getMessages();
            flagAssert = false;
            for(Apexpages.Message msg: msgs){
                flagAssert = msg.getDetail().contains('Objects are not selected.');
                if (flagAssert) {
                    break;
                }
            }
            System.assert(flagAssert);

            controller.init();

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
            
            controller.addFilters();
            controller.addNewFilter();

            ApexPages.currentPage().getParameters().put('obj', 'TestObject');
            ApexPages.currentPage().getParameters().put('fltr', '1');

            Integer beforeRemove;
            for (Integer i = 0; i< controller.dcaFilterWrapperList.size(); i++) {
                if (controller.dcaFilterWrapperList.get(i).objectName == 'TestObject') {
                    beforeRemove = controller.dcaFilterWrapperList.get(i).filterList.size();
                }
            }
             
            controller.removeFilter();

            Integer afterRemove;
            for (Integer i = 0; i< controller.dcaFilterWrapperList.size(); i++) {
                if (controller.dcaFilterWrapperList.get(i).objectName == 'TestObject') {
                    afterRemove = controller.dcaFilterWrapperList.get(i).filterList.size();
                }
            }

            System.assert(afterRemove != beforeRemove);

            controller.selectedObjects.clear();

            controller.doSave();

            msgs = ApexPages.getMessages();
            flagAssert = false;
            for(Apexpages.Message msg: msgs){
                flagAssert = msg.getDetail().contains('Objects are not selected.');
                if (flagAssert) {
                    break;
                }
            }
            System.assert(flagAssert);

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));
        	controller.doSave();

            controller.doCancel();

        }
    	Test.stopTest();
    }
}
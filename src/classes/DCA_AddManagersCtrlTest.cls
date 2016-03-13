@isTest 
public class DCA_AddManagersCtrlTest {

    static DCA_Object__c dcaObj;
    static DCA_Manager__c dcaManager;

    private static void init() {
        dcaObj = new DCA_Object__c(
            Name = 'Account',
            Record_Types__c = 'testRecrdTypeForApproval');
        
        insert dcaObj;

        dcaManager = new DCA_Manager__c(
            Profile__c = 'Test_Profile',
            Public_Group__c = 'Test_Group',
            UserRole__c = 'Test_UserRole',
            User__c = 'Test_User'
            );

        insert dcaManager;
 
        Group testGroup = new Group(
            Name = 'Test Group DCA');
        insert testGroup;

    }

    @isTest 
    private static void testMethod_displayObjects() {
        Test.startTest();
        User thisUser = [   SELECT Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init();
            DCA_AddManagersCtrl controller = new DCA_AddManagersCtrl();
            controller.init();

            controller.currentType = 'Profile';
            controller.displayMembers();
            System.assert(controller.allMembersSO.size() > 0);

            controller.currentType = 'Public Group';
            controller.displayMembers();
            System.assert(controller.allMembersSO.size() > 0);

            controller.currentType = 'UserRole';
            controller.displayMembers();
            System.assert(controller.allMembersSO.size() > 0);

            controller.currentType = 'User';
            controller.displayMembers();
            System.assert(controller.allMembersSO.size() > 0);
        }
        Test.stopTest();

    }

    @isTest 
    private static void testMethod_doSearch() {
        Test.startTest();
        User thisUser = [   SELECT Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init();
            DCA_AddManagersCtrl controller = new DCA_AddManagersCtrl();

            controller.init();
            controller.searchString = 'Test_';
            controller.currentType = 'Profile';
            controller.doSearch();
            System.assert(controller.allMembersSO.size() > 0);

            controller.currentType = 'Public Group';
            controller.doSearch();
            System.assert(controller.allMembersSO.size() > 0);

            controller.currentType = 'UserRole';
            controller.doSearch();
            System.assert(controller.allMembersSO.size() == 0);

            controller.currentType = 'User';
            controller.doSearch();
            System.assert(controller.allMembersSO.size() > 0);

        }
        Test.stopTest();

    }

    @isTest 
    private static void testMethod_FiltersAndSave() {
        Test.startTest();
        User thisUser = [   SELECT Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init();
            DCA_AddManagersCtrl controller = new DCA_AddManagersCtrl();

            controller.init();

            controller.selectedMembersSO.clear();
            controller.addFilters();

            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean flagAssert = false;
            for(Apexpages.Message msg: msgs) {
                flagAssert = msg.getDetail().contains('Managers are not selected.');
                if (flagAssert) {
                    break;
                }
            }
            System.assert(flagAssert);

            controller.selectedObjects.clear();
            controller.selectedMembersSO.add(
                new SelectOption('System Administrator','Profile:System Administrator'));
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

            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));
            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.addFilters();

            msgs = ApexPages.getMessages();
            flagAssert = false;
            for(Apexpages.Message msg: msgs){
                flagAssert = msg.getDetail().contains('You can select no more than ten objects.');
                if (flagAssert) {
                    break;
                }
            }
            // System.assert(flagAssert);

            controller.selectedObjects.clear();

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.addFilters();

            msgs = ApexPages.getMessages();
            flagAssert = false;
            for(Apexpages.Message msg: msgs){
                flagAssert = msg.getDetail().contains('You can select no more than ten managers.');
                if (flagAssert) {
                    break;
                }
            }
            // System.assert(flagAssert);

            controller.selectedMembersSO.clear();
            controller.selectedObjects.clear();

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Profile:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('Opportunity','Profile:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('System Administrator','Public Group:System Administrator'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Public Group:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('System Administrator','UserRole:System Administrator'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','UserRole:Opportunity'));

            controller.selectedMembersSO.add(
                new SelectOption('System Administrator','User:System Administrator'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','User:Opportunity'));

            controller.selectedObjects.add(
                new SelectOption('Opportunity','Opportunity'));

            controller.addFilters();

            ApexPages.currentPage().getParameters().put('mnger', 'Profile:System Administrator');
            ApexPages.currentPage().getParameters().put('obj', 'Opportunity');
            controller.addNewFilter();

            for (List<DCA_AddManagersCtrl.objectFilterWrapper> ofWList : controller.dcaFilterMap.values()) {
                for (DCA_AddManagersCtrl.objectFilterWrapper ofW : ofWList) {
                    for (DCA_Filter__c dcaF : ofW.filterList) {
                        dcaF.Field__c = 'Name';
                        dcaF.Operator__c = 'equals';
                        dcaF.Value__c = '25';
                    } 
                }   
            }

            PageReference pageRefTest = controller.doAdd();
            System.assert(pageRefTest != null);

            pageRefTest = controller.doCancel();
            System.assert(pageRefTest != null);

        }
        Test.stopTest();

    }

	@isTest 
    private static void addManagers() {
    	DCA_AddManagersCtrl controller = new DCA_AddManagersCtrl();
        init();
    	controller.init();
    	controller.searchString = 'System';
    	controller.currentType = 'Profile';
    	controller.displayMembers();
    	controller.doSearch();
    	controller.currentType = 'Public Group';
    	controller.displayMembers();
    	controller.doSearch();
    	controller.currentType = 'UserRole';
    	controller.displayMembers();
    	controller.doSearch();
    	controller.currentType = 'User';
    	controller.displayMembers();
    	controller.doSearch();
    	
    }
}
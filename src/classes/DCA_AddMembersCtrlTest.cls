@isTest 
public class DCA_AddMembersCtrlTest {

    static DCA_Object__c dcaObj;
    static DCA_Member__c dcaMember;

    private static void init() {
        dcaObj = new DCA_Object__c(
            Name = 'testRecordForApproval',
            Record_Types__c = 'testRecrdTypeForApproval');
        
        insert dcaObj;

        dcaMember = new DCA_Member__c(
            Profile__c = 'Test_Profile',
            Public_Group__c = 'Test_Group',
            UserRole__c = 'Test_UserRole',
            User__c = 'Test_User'
            );

        insert dcaMember;
 
        Group testGroup = new Group(
            Name = 'Test Group DCA');
        insert testGroup;

    }

	@isTest 
    private static void testMethod_addMembers() {

        Test.startTest();
        User thisUser = [   SELECT Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init();
        	DCA_AddMembersCtrl controller = new DCA_AddMembersCtrl();
        	controller.init();
        	
        	controller.selectedMembersSO.add(
                new SelectOption('System Administrator','Profile:System Administrator'));

            controller.selectedObjects.add(
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

        	controller.doAdd();

            List<DCA_Member__c> testIntoBaseRecords = [ SELECT Id
                                                        FROM DCA_Member__c];
            System.assert(testIntoBaseRecords.size() > 1);

            PageReference result = controller.doCancel();
            System.assertNotEquals(null, result);
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
            DCA_AddMembersCtrl controller = new DCA_AddMembersCtrl();
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
    private static void testMethod_displayMembers() {

        Test.startTest();
        User thisUser = [   SELECT Id 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            init();
            DCA_AddMembersCtrl controller = new DCA_AddMembersCtrl();
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


}
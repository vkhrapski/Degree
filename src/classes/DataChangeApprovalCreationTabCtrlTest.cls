@isTest
public class DataChangeApprovalCreationTabCtrlTest {

    static DCA_Object__c dcaObject {get; set;}
    static Approval_Result__c appResult {get; set;}
    static DCA_Member__c dcaMem {get; set;}
    static DCA_Manager__c dcaMan {get; set;}
    static DCA_Manager__c testMan {get; set;}
    static DCA_Filter__c dcaFilter {get; set;}
    static PageReference testCurrentPage {get; set;}
    static Approval_List__c testAppList {get; set;}
    static TestObject__c testObject {get; set;}
    static void init() {
        dcaObject = new DCA_Object__c(
            Name = 'test',
            Record_Types__c = 'None',
            Start_Time__c = DateTime.now()
        );
        insert dcaObject;

        testobject = new TestObject__c();
        insert testObject;

        appResult = new Approval_Result__c(
            Approver__c = UserInfo.getUserId(),
            Comments__c = 'test comments',
            Link_to_Record__c = 'test rec link/' + dcaObject.Id,
            Object__c = 'test',
            Record_Name__c = dcaObject.Name,
            Result__c = 'test result'
        );
        insert appResult;

        testAppList = new Approval_List__c(
            Approval_Link__c = 'test link',
            Link_to_Record__c = 'test rec link/' + dcaObject.Id,
            Object__c = 'DCA_Object__c',
            Record_Name__c = dcaObject.Name,
            Record_Type_Name__c = dcaObject.Record_Types__c,
            User__c = UserInfo.getUserId(),
            User_Link__c = 'test user link',
            User_Name__c = 'test user name'
        );
        insert testAppList;

        dcaMem = new DCA_Member__c(
            Name = 'textDCA',
            Profile__c = 'test profile',
            Public_Group__c = 'test group',
            User__c = 'test user',
            UserRole__c = 'test user role',
            Objects__c = 'TestObject__c'
        );
        insert dcaMem;

        dcaMan = new DCA_Manager__c(
            Name = 'testDCA',
            Objects__c = 'DCA_Object__c;None',
            Profile__c = 'test profile',
            Public_Group__c = 'test group',
            User__c = UserInfo.getUserId(),
            UserRole__c = 'test user role'
        );
        insert dcaMan;

        testMan = new DCA_Manager__c(
            Name = 'testMan',
            Objects__c = ',TestObject__c,TestObject__c,'
        );
        insert testMan;

        dcaFilter = new DCA_Filter__c(
            DCA_Manager__c = testMan.Id,
            Field__c = 'Name',
            Operator__c = 'equals',
            Value__c = 't',
            Object_Name__c = 'DCA_Object__c;None',
            Object_Label__c = 'DCA_Object__c;None'
        );
        insert dcaFilter;

        testCurrentPage = page.DataChangeApprovalCreationTab;
        testCurrentPage.getParameters().put('object', 'User');
        testCurrentPage.getParameters().put('delAR', appResult.Id);
        testCurrentPage.getParameters().put('delMember', dcaMem.Id);
        testCurrentPage.getParameters().put('editMember', dcaMem.Id);
        testCurrentPage.getParameters().put('delManager', dcaMan.Id);
        testCurrentPage.getParameters().put('editManager', dcaMan.Id);
        testCurrentPage.getParameters().put('sortFieldDCAM', 'Name');
        testCurrentPage.getParameters().put('sortOrderDCAM', 'DESC');
        testCurrentPage.getParameters().put('deleteObject', 'TestObject');
        testCurrentPage.getParameters().put('sortFieldAL', 'Object__c');
        testCurrentPage.getParameters().put('sortOrderAL', 'DESC');
        testCurrentPage.getParameters().put('sortFieldAR', 'Object__c');
        testCurrentPage.getParameters().put('sortOrderAR', 'DESC');
        testCurrentPage.getParameters().put('sortFieldMAN', 'Name');
        testCurrentPage.getParameters().put('sortOrderMAN', 'DESC');
        testCurrentPage.getParameters().put('objectName', 'test');
        testCurrentPage.getParameters().put('tabsNumber', '1');


    }

    @isTest
    static void testAllMethodsInInitMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        Test.setCurrentPage(testCurrentPage);
        con.DCAMemberWrapperList.add(new DataChangeApprovalCreationTabCtrl.DCAMemberWrapper(dcaMem));
        con.approvalList.add(testAppList);
        con.approvalResults.add(appResult);
        con.dcaObjectRecTypeMap.put('dca_object__c', 'All');
        con.dcaFilterMap.put(dcaMan.Id, new List<DCA_Filter__c> {dcaFilter});
        con.init();
        System.assertEquals(false, con.apexTriggersNameSet.size() == 0);
        Test.stopTest();
    }

    @isTest
    static void testRefreshTabMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        Test.setCurrentPage(testCurrentPage);
        con.refreshTab();
        testCurrentPage.getParameters().put('tabsNumber', '2');
        Test.setCurrentPage(testCurrentPage);
        con.refreshTab();
        testCurrentPage.getParameters().put('tabsNumber', '3');
        Test.setCurrentPage(testCurrentPage);
        con.refreshTab();
        testCurrentPage.getParameters().put('tabsNumber', '4');
        Test.setCurrentPage(testCurrentPage);
        con.refreshTab();
        testCurrentPage.getParameters().put('tabsNumber', '5');
        Test.setCurrentPage(testCurrentPage);
        con.refreshTab();
        Test.stopTest();
    }

    @isTest
    static void testMethodWichOnlyReturnPageRef() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        System.assertEquals(false, con.goToAddMember() == null);
        System.assertEquals(false, con.goToAdd() == null);
        Test.stopTest();
    }

    @isTest
    static void testDeleteApprovalsResultMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.deleteApprovalResult();
        System.assertEquals(4, con.activeTab);
        Test.stopTest();
    }

    @isTest
    static void testDeleteDCAMemberMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.deleteDCAMember();
        System.assertEquals(1, con.activeTab);
        Test.stopTest();
    }

    @isTest
    static void testEditDCAMemberMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        System.assertEquals(false, con.editDCAMember() == null);
        Test.stopTest();
    }

    @isTest
    static void testDeleteManagerMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        System.assertEquals(false, con.editDCAMember() == null);
        Test.stopTest();
    }

    @isTest
    static void testEditManagerMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        System.assertEquals(false, con.editManager() == null);
        Test.stopTest();
    }

    @isTest
    static void testDeleteManager() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.deleteManager();
        System.assertEquals(2, con.activeTab);
        Test.stopTest();
    }


    @isTest
    static void testDoAddObjectMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.init();
        con.currentObject = 'TestObject__c';
        con.selectedObjects.add(new DataChangeApprovalCreationTabCtrl.ObjectWrapper(dcaObject.Name, new List<String> {'test'}, 'TestObject__c',
                                new Map<String, DCA_Object__c> (), new Set<String> {'test'}));
        RecordType testRt = [SELECT SobjectType, Name FROM RecordType WHERE SobjectType = :con.currentObject LIMIT 1];
        con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, true));
        con.selectedFields.add(new SelectOption('Name', dcaObject.Name));
        con.currentLabelWithoutSpaces = 'testtesttesttesttesttesttesttesttesttesttesttesttesttest';
        for (DataChangeApprovalCreationTabCtrl.ObjectWrapper ow : con.selectedObjects) {
            ow.Status = 'Completed';
        }
        con.doAddObject();
        con.selectedFields.clear();
        // con.selectedFields.add(new SelectOption('Name', dcaObject.Name));
        con.recordTypeSOList.clear();
        // con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, false));
        for (DataChangeApprovalCreationTabCtrl.ObjectWrapper ow : con.selectedObjects) {
            ow.Status = 'Completed';
        }
        con.doAddObject();
        for (DataChangeApprovalCreationTabCtrl.ObjectWrapper ow : con.selectedObjects) {
            ow.Status = 'Completed';
        }
        con.currentObject = 'TestObject__c';
        // con.objectIsSelected = true;
        con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, true));
        con.selectedFields.clear();
        con.doAddObject();
        for (DataChangeApprovalCreationTabCtrl.ObjectWrapper ow : con.selectedObjects) {
            ow.Status = 'Completed';
        }
        con.currentObject = 'TestObject__c';
        con.dcaObjectRecTypeMap.put('TestObject__c' , 'All');
        con.displayFields();
        con.currentObject = 'None';
        con.displayFields();
        con.currentObject = 'TestObject__c';
        con.dcaObjectRecTypeMap.put('TestObject__c' , 'Full');
        dcaObject.Record_Types__c = 'Full';
        con.displayFields();
        con.currentObject = 'Account';
        con.displayFields();
        con.currentObject = 'TestObject__c';
        con.putSelectedCurrentObject('TestObject__c');
        con.deleteFields(con.currentObject);
        con.deleteFieldSet(null);
        // con.putSelectedCurrentObject(dcaObject.Name);
        Test.stopTest();
    }

    @isTest
    static void testDeleteObjectMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.init();
        Test.setCurrentPage(testCurrentPage);
        con.dcaObjectRecTypeMap.put('testobject__c' , 'Done');
        con.deleteObject();
        dcaMem.Objects__c = 'TestObject';
        update dcaMem;
        con.DCAMemberList.add(dcaMem);
        con.dcaObjectRecTypeMap.put('testobject__c' , 'None');
        con.deleteObject();
        DCA_Member__c testMem = new DCA_Member__c(
            Name = 'testMem',
            Profile__c = 'test profile',
            Public_Group__c = 'test group',
            User__c = 'test user',
            UserRole__c = 'test user role',
            Objects__c = '_left_TestObject_right_'
        );
        insert testMem;
        con.DCAMemberList.add(testMem);
        con.dcaObjectRecTypeMap.put('testobject__c' , 'None');
        con.dcaFilterMap.put(testMem.Id, new List<DCA_Filter__c> {dcaFilter});
        con.deleteObject();
        Test.stopTest();
    }

    @isTest
    static void testDeleteDCAObject() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.deleteDCAObject();
        con.statusObj = 'Completed';
        con.deleteDCAObject();
        Test.stopTest();
    }

    @isTest
    static void testDoApproveAllbyDeletedObject() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.approvalList.add(testAppList);
        con.doApproveAllbyDeletedObject(testAppList.Object__c);
        Test.stopTest();
    }

    @isTest
    static void testAddRecordTypes() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.forRecTypeObject = 'test';
        RecordType testRt = [SELECT SobjectType, Name FROM RecordType WHERE SobjectType = :'TestObject__c' LIMIT 1];
        con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, true));
        con.addRecordTypes();
        Test.stopTest();
    }

    @isTest
    static void testCreateFieldSetMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.selectedFields.add(new SelectOption('test', 'test'));
        System.assertEquals(true, con.createFieldSet() == null);
        Test.stopTest();
    }

    @isTest
    static void testUpdateFieldSetMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.currentObject = 'TestObject__c';
        con.selectedFields.add(new SelectOption('test', 'test'));
        con.updateFieldSet();
        Test.stopTest();
    }

    @isTest
    static void testCreateFieldsMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.currentObject = 'TestObject__c';
        System.assertEquals(true, con.createFields() == null);
        Test.stopTest();
    }

    @isTest
    static void testAddLookupToDataChangeActivity() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.currentObject = 'TestObject__c';
        System.assertEquals(true, con.addLookupToDataChangeActivity() == null);
        con.currentObject = 'TestObject';
        System.assertEquals(true, con.addLookupToDataChangeActivity() == null);
        Test.stopTest();
    }

    @isTest
    static void testCheckSelectedObjectsMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.selectedObjects.add(new DataChangeApprovalCreationTabCtrl.ObjectWrapper('TestObject', new List<String> {'test'}, 'None',
                                new Map<String, DCA_Object__c> (), new Set<String> {'test'}));
        con.checkSelectedObjects('DCA_Object__c');
        con.checkSelectedObjects('TestObject__c');
        Test.stopTest();
    }

    @isTest
    static void testPutSelectedCurrentObjectMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.putSelectedCurrentObject('Opportunity');
        con.selectedFields.add(new SelectOption('Test', 'test'));
        RecordType testRt = [SELECT SobjectType, Name FROM RecordType WHERE SobjectType = :'TestObject__c' LIMIT 1];
        con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, true));
        con.putSelectedCurrentObject('TestObject__c');
        Test.stopTest();
    }



    @isTest
    static void testAddTriggerMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.currentLabelWithoutSpaces = 'testeasdasdasdadasadsdasdasdassdasdasdasdassdasdasdasdasdasdasdasd';
        con.addTrigger();
        Test.stopTest();
    }

    @isTest
    static void testRefreshTriggerMethod() {
        Test.startTest();
        init();
        Test.setCurrentPage(testCurrentPage);
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        con.init();
        con.currentLabelWithoutSpaces = 'testeasdasdasdadasadsdasdasdassdasdasdasdassdasdasdasdasdasdasdasd';
        con.refreshTrigger();
        Test.stopTest();
    }

    @isTest
    static void testSelectAllRecTypesMethod() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        RecordType testRt = [SELECT SobjectType, Name FROM RecordType WHERE SobjectType = :'TestObject__c' LIMIT 1];
        con.recordTypeSOList.add(new DataChangeApprovalCreationTabCtrl.recordTypeWrapper(testRt, true));
        con.selectAllRecTypes();
        Test.stopTest();
    }

    @isTest
    static void testCheckFilterForRecord() {
        Test.startTest();
        init();
        DataChangeApprovalCreationTabCtrl con = new DataChangeApprovalCreationTabCtrl();
        dcaFilter.Operator__c = 'not equals to';
        System.assert(DataChangeApprovalCreationTabCtrl.checkFilterForRecord(dcaObject, dcaFilter, Schema.getGlobalDescribe().get('DCA_Object__c').getDescribe().fields.getMap()));
        dcaFilter.Operator__c = 'starts with';
        System.assert(DataChangeApprovalCreationTabCtrl.checkFilterForRecord(dcaObject, dcaFilter, Schema.getGlobalDescribe().get('DCA_Object__c').getDescribe().fields.getMap()));
        dcaFilter.Operator__c = 'contains';
        System.assert(DataChangeApprovalCreationTabCtrl.checkFilterForRecord(dcaObject, dcaFilter, Schema.getGlobalDescribe().get('DCA_Object__c').getDescribe().fields.getMap()));
        dcaFilter.Operator__c = 'does not contain';
        dcaFilter.Value__c = 'a';
        System.assert(DataChangeApprovalCreationTabCtrl.checkFilterForRecord(dcaObject, dcaFilter, Schema.getGlobalDescribe().get('DCA_Object__c').getDescribe().fields.getMap()));
        Test.stopTest();
    }

}
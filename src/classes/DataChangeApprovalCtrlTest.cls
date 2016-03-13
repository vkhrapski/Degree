@isTest 
public class DataChangeApprovalCtrlTest {

    static TestObject__c tempTestObject() {

        RecordType recType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Test' AND SobjectType = 'TestObject__c'
        ];

        TestObject__c testObject = new TestObject__c (
            Test__c = 'Test',
            Test_Checkbox__c = true,
            RecordTypeId = recType.Id, 
            Staff_User_email__c = 'test@mail.com'
        );
        
        return testObject;
    }
    
    @isTest 
    private static void testApprove() {
         
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name='Account Manager - MCD']; 
	  	User user = new User(Alias = 'standt', Email='testtest@mail.com', 
	  		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	  		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
	  		TimeZoneSidKey='America/Los_Angeles', UserName='testtest@mail.com');
        
        System.runAs(user) {
            DCA_Object__c dcaObj = new DCA_Object__c(
                Name = 'testobject__c',
                Record_Types__c = 'Test');
            
            insert dcaObj;

            DCA_Member__c dcaMember = new DCA_Member__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject (Test)'
            );
            insert dcaMember;
            
            DCA_Manager__c dcaManager = new DCA_Manager__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject;Test'
            );
            insert dcaManager;

            RecordType recType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Test' AND SobjectType = 'TestObject__c'
            ];


        	Test.startTest();
            System.debug('::::UserInfo.getProfileId()::::' + UserInfo.getProfileId());
            System.debug('::::user.ProfileId::::' + user.ProfileId);

	        TestObject__c testObject = tempTestObject();
	        insert testObject;

            System.debug('::::testObject::::' + testObject);
            System.debug('::::testObject.Is_Locked__c::::' + testObject.Is_Locked__c);
	        
	        ApexPages.currentPage().getParameters().put('Id', testObject.Id);
	        DataChangeApprovalCtrl controller = new DataChangeApprovalCtrl();
	        controller.init();
            controller.globalComment = 'test comment';
	        controller.doApproveCreate();
            System.debug('::::testObject.Is_Locked__c:2:::' + testObject.Is_Locked__c);
            
	        testObject.Test__c = 'Newnow';
	        update testObject;

	        TestObject__c childTest = [
	        	SELECT Id
	        	FROM TestObject__c
	        	WHERE Original_Record_Id__c = :testObject.Id
	        	LIMIT 1
	        ];
	        
	        ApexPages.currentPage().getParameters().put('Id', childTest.Id);
	        DataChangeApprovalCtrl controllerTwo = new DataChangeApprovalCtrl();
            controller.globalComment = 'test comment';
	        controllerTwo.objectWrapperFields.get(0).currentState = false;
			controllerTwo.doApprove();
			
		/*	testObject.Test__c = 'qwerty';
			update testObject;
			
			TestObject__c childTest_1 = [
	        	SELECT Id
	        	FROM TestObject__c
	        	WHERE Original_Record_Id__c = :testObject.Id
	        	LIMIT 1
	        ];
	        
			ApexPages.currentPage().getParameters().put('Id', childTest_1.Id);
			DataChangeApprovalCtrl controllerThree = new DataChangeApprovalCtrl(new ApexPages.StandardController(new TestObject__c()));
			controllerThree.objectWrapperFields.get(0).currentState = true;
			controllerThree.doApprove();
			
			testObject.Test__c = '1234567';
			update testObject;
			
			TestObject__c childTest_2 = [
	        	SELECT Id
	        	FROM TestObject__c
	        	WHERE Original_Record_Id__c = :testObject.Id
	        	LIMIT 1
	        ];
			
			ApexPages.currentPage().getParameters().put('Id', childTest_2.Id);
			DataChangeApprovalCtrl controllerFour = new DataChangeApprovalCtrl(new ApexPages.StandardController(new TestObject__c()));
			controllerFour.objectWrapperFields.get(0).currentState = true;
			controllerFour.doApprove();
			controllerFour.doReject();*/
			Test.stopTest();
        }
    }
    
    @isTest 
    private static void testApprove2() {
         
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name='Account Manager - MCD']; 
	  	User user = new User(Alias = 'standt', Email='testtest@mail.com', 
	  		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	  		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id, 
	  		TimeZoneSidKey='America/Los_Angeles', UserName='testtest@mail.com');
        
        System.runAs(user) {
            DCA_Object__c dcaObj = new DCA_Object__c(
                Name = 'testobject__c',
                Record_Types__c = 'Test');
            
            insert dcaObj;

            DCA_Member__c dcaMember = new DCA_Member__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject (Test)'
            );
            insert dcaMember;
            
            DCA_Manager__c dcaManager = new DCA_Manager__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject;Test'
            );
            insert dcaManager;

            DCA_Filter__c dcaFilter = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'equals',
                Value__c = '25', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter;

            DCA_Filter__c dcaFilter2 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'not equals',
                Value__c = '40', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter2;

            DCA_Filter__c dcaFilter3 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'starts with',
                Value__c = '2', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter3;

            DCA_Filter__c dcaFilter4 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'contains',
                Value__c = '2', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter4;

            DCA_Filter__c dcaFilter5 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'does not contain',
                Value__c = '17', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter5;

            DCA_Filter__c dcaFilter6 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'less than',
                Value__c = '17', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter6;

            DCA_Filter__c dcaFilter9 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'greater than',
                Value__c = '17', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter9;

            DCA_Filter__c dcaFilter7 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'less or equal',
                Value__c = '17', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter7;

            DCA_Filter__c dcaFilter8 = new DCA_Filter__c(
                DCA_Manager__c = dcaManager.Id, 
                Field__c = 'Test__c',
                Operator__c = 'greater or equal',
                Value__c = '17', 
                Object_Name__c = 'TestObject;Test',
                Object_Label__c = 'TestObject'
            );
            insert dcaFilter8;

            DCA_Object__c dcaObject = new DCA_Object__c(
                Name = 'TestObject__c',
                Record_Types__c = 'All'
            );
            insert dcaObject;

        	Test.startTest();
	        TestObject__c testObject = tempTestObject();
	        insert testObject;
	        
	        ApexPages.currentPage().getParameters().put('Id', testObject.Id);
	        DataChangeApprovalCtrl controller = new DataChangeApprovalCtrl();
	        controller.init();
            controller.globalComment = 'test comment';
	        controller.doApproveCreate();
	        
	        testObject.Test__c = 'Newnow';
	        update testObject;
	        
	        TestObject__c childTest = [
	        	SELECT Id
	        	FROM TestObject__c
	        	WHERE Original_Record_Id__c = :testObject.Id
	        	LIMIT 1
	        ];
	        
	        ApexPages.currentPage().getParameters().put('Id', childTest.Id);
	        DataChangeApprovalCtrl controllerTwo = new DataChangeApprovalCtrl();
	        controllerTwo.objectWrapperFields.get(0).currentState = true;
            controller.globalComment = 'test comment';
			controllerTwo.doApprove();
			
			Test.stopTest();
        }
    }
    
    @isTest 
    private static void testRejectRecord() {
         
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name='Account Manager - MCD'];
	  	User user = new User(Alias = 'standt', Email='testtest@mail.com', 
	  		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	  		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
	  		TimeZoneSidKey='America/Los_Angeles', UserName='testtest@mail.com');
        
        System.runAs(user) {

            DCA_Member__c dcaMember = new DCA_Member__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject'
            );
            insert dcaMember;
            
            DCA_Manager__c dcaManager = new DCA_Manager__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject'
            );
            insert dcaManager;

            DCA_Object__c dcaObject = new DCA_Object__c(
                Name = 'TestObject__c',
                Record_Types__c = 'None'
            );
            insert dcaObject;

        	Test.startTest();
	        TestObject__c testObject = tempTestObject();
	        insert testObject;
	        
	        ApexPages.currentPage().getParameters().put('Id', testObject.Id);
	        DataChangeApprovalCtrl controller = new DataChangeApprovalCtrl();
	        controller.init();
	        controller.doRejectCreate();
	        controller.doCancelCreate();
	        
        	Test.stopTest();
        }
    }
    
    @isTest 
    private static void testReject() {
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name='Account Manager - MCD'];
	  	User user = new User(Alias = 'standt', Email='testtest@mail.com', 
	  		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	  		LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
	  		TimeZoneSidKey='America/Los_Angeles', UserName='testtest@mail.com');
        
        System.runAs(user) {
            DCA_Member__c dcaMember = new DCA_Member__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject'
            );
            insert dcaMember;
            
            DCA_Manager__c dcaManager = new DCA_Manager__c(
                Name = 'System Administrator',
                Profile__c = p.Id,
                Type__c = 'Profile',
                Objects__c = 'TestObject'
            );
            insert dcaManager;

            DCA_Object__c dcaObject = new DCA_Object__c(
                Name = 'TestObject__c',
                Record_Types__c = 'None'
            );
            insert dcaObject;
            
        	Test.startTest(); 
	        TestObject__c testObject = tempTestObject();
	        insert testObject;
	        ApexPages.currentPage().getParameters().put('Id', testObject.Id);
	        DataChangeApprovalCtrl controller = new DataChangeApprovalCtrl();
	        controller.init();
            controller.globalComment = 'test comment';
	        controller.doApproveCreate();
	        
	        testObject.Test__c = 'Newnow';
	        update testObject;
	        
	        TestObject__c childTest = [
	        	SELECT Id
	        	FROM TestObject__c
	        	WHERE Original_Record_Id__c = :testObject.Id
	        	LIMIT 1
	        ];
	        
	        ApexPages.currentPage().getParameters().put('Id', childTest.Id);
	        DataChangeApprovalCtrl controllerTwo = new DataChangeApprovalCtrl();
	        controllerTwo.init();
            controller.globalComment = 'test comment';
	        controllerTwo.doReject();
            controllerTwo.doCancelApprove();
	        Test.stopTest();
        }
    }
}
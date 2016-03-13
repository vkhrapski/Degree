public class DataChangeApprovalCreationTabCtrl {

	// public List<SelectOption> countRecordOptionsUser {get; set;}
//    public String selectedCountRecordsUser {get; set;}
	// public Integer countRecordsUser {get; set;}
	// public Integer pageIndexUser {get; set;}
	// public Integer countOfPageUser {get; set;}

	// public List<User> viewUsers {get; set;}
	// public List<User> selectedUsers {get; set;}
	// public Integer allRecordsUser {get; set;}

	// public List<userWrapper> allUserWrappers {get; set;}
	// public List<userWrapper> userWrappers {get; set;}

	public List<SelectOption> allObjects { get; set; }
	public List<SelectOption> allFields { get; set; }
	public List<SelectOption> selectedFields { get; set; }

	public String currentObject {get; set;}
	// public List<String> webLinks {get; set;}

	public List<objectWrapper> selectedObjects {get; set;}

	public String userName {get; set;}

	public String currentLabel;
	public String currentLabelWithoutSpaces {get; set;}
	// public String executionType {get; set;}
	// public List<SelectOption> execTypes {get; set;}
	// public Boolean editButtonWasDeleted;

	// public String ZipData { get; set; }
	// public MetadataService.AsyncResult AsyncResult {get; private set;}

	/*	public String TriggerMetadata {get; set;}
		public String TriggerText {get; set;}
		public String PackageXml {get; set;}*/

	public Integer activeTab {get; set;}

	public List<DCAMemberWrapper> DCAMemberWrapperList {get; set;}
	public List<DCA_Member__c> DCAMemberList {get; set;}
	public List<DCAManagerWrapper> DCAManagerWrapperList {get; set;}
	public List<DCA_Manager__c> DCAManagerList {get; set;}

	// public String testClassBody;
	// public String classBody;
	// public ApexService.CompileAndTestRequest request;
//    public ApexService.CompileAndTestResult result;

	// public String searchString {get; set;}
	// public List<String> letters {get; set;}

	public String sortFieldAL {get; set;}
	public String sortOrderAL {get; set;}
	public String sortFieldAR {get; set;}
	public String sortOrderAR {get; set;}
	public String sortFieldSM {get; set;}
	public String sortOrderSM {get; set;}
	public String sortFieldDCAM {get; set;}
	public String sortOrderDCAM {get; set;}
	public String sortFieldMAN {get; set;}
	public String sortOrderMAN {get; set;}
	public String sortFieldAU {get; set;}
	public String sortOrderAU {get; set;}

	public List<Approval_List__c> approvalList {get; set;}
	public List<approvalListWrapper> alWrapperList {get; set;}
	public List<Approval_Result__c> approvalResults {get; set;}
	public List<approvalResultWrapper> arWrapperResult {get; set;}

	public Boolean objectIsSelected;
	public Boolean allRecTypeSelected {get; set;}

	public List<recordTypeWrapper> recordTypeSOList {get; set;}
	public Map<String, String> dcaObjectRecTypeMap;
	Map<String, DCA_Object__c> dcaObjectMap;

	public String forRecTypeObject {get; set;}

	public Set<String> apexTriggersNameSet;
	public Map<String, List<DCA_Filter__c>> dcaFilterMap;

	public DCA_Object__c dcaObjectDelete;
	public List<DCA_Filter__c> dcaFilterObjDeleteList;

	public String statusObj;

	private Boolean cantDeleteDCAObject;

	public DataChangeApprovalCreationTabCtrl() {
		// viewUsers = new List<User>();
		// selectedUsers = new List<User>();
		// allUserWrappers = new List<userWrapper>();
		// userWrappers = new List<userWrapper>();
		selectedFields = new List<SelectOption>();
		allFields = new List<SelectOption>();
		allObjects = new List<SelectOption>();
		selectedObjects = new List<objectWrapper>();
		DCAMemberWrapperList = new List<DCAMemberWrapper>();
		DCAMemberList = new List<DCA_Member__c>();
		DCAManagerWrapperList = new List<DCAManagerWrapper>();
		DCAManagerList = new List<DCA_Manager__c>();
		approvalList = new List<Approval_List__c>();
		approvalResults = new List<Approval_Result__c>();
		alWrapperList = new List<approvalListWrapper>();
		arWrapperResult = new List<approvalResultWrapper>();

		recordTypeSOList = new List<recordTypeWrapper>();
		dcaObjectRecTypeMap = new Map<String, String>();
		dcaObjectMap = new Map<String, DCA_Object__c>();

		apexTriggersNameSet = new Set<String>();
		dcaFilterMap = new Map<String, List<DCA_Filter__c>>();
		dcaObjectDelete = new DCA_Object__c();
		dcaFilterObjDeleteList = new List<DCA_Filter__c>();

		// User
		// countRecordOptionsUser = new List<SelectOption> {
		//     new SelectOption('10','10'),
		//     new SelectOption('20','20'),
		//     new SelectOption('50','50'),
		//     new SelectOption('100','100'),
		//     new SelectOption('200','200')
		// };
		// selectedCountRecordsUser = '10';

		//       execTypes = new List<SelectOption> {
		//           new SelectOption('New','New'),
		//           new SelectOption('Edit','Edit'),
		//           new SelectOption('New & Edit','New & Edit')
		//       };
		// executionType = 'New';

		// letters = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',
		// 							'U','V','W','X','Y','Z','All'};

		// pageIndexUser = 1;
		// countOfPageUser = 1;
		// countRecordsUser = 10;

		currentObject = 'None';

		sortFieldAL = 'CreatedDate';
		sortOrderAL = 'DESC';
		sortFieldAR = 'CreatedDate';
		sortOrderAR = 'DESC';
		sortFieldSM = 'Name';
		sortOrderSM = 'ASC';
		sortFieldDCAM = 'Name';
		sortOrderDCAM = 'ASC';
		sortFieldMAN = 'Name';
		sortOrderMAN = 'ASC';
		sortFieldAU = 'Name';
		sortOrderAU = 'ASC';

		// editButtonWasDeleted = false;
		objectIsSelected = false;
		allRecTypeSelected = true;
		this.cantDeleteDCAObject = false;

	}

	public void init() {

		List<DCA_Object__c> dcaObjectList = new List<DCA_Object__c>();
		dcaObjectList = [
		                    SELECT Name, Record_Types__c, Start_Time__c
		                    FROM DCA_Object__c
		                ];

		if (! dcaObjectList.isEmpty()) {
			for (DCA_Object__c dcaObj : dcaObjectList) {
				dcaObjectRecTypeMap.put(dcaObj.Name, dcaObj.Record_Types__c);
				dcaObjectMap.put(dcaObj.Name, dcaObj);
			}
		}

		getTriggersNames();

		activeTab = 0;

		checkSelectedManagers();
		checkDCAMembers();
		checkApprovalList();
		checkApprovalResults();
		checkSelectedObjects(null);
		checkAllObjects(null);
	}

	private void getTriggersNames() {

		if (! apexTriggersNameSet.isEmpty()) {
			apexTriggersNameSet.clear();
		}

		String queryString = 'SELECT a.Name';
		queryString += ' FROM ApexTrigger a';

		List<ApexTrigger> listTriggers = Database.query(queryString);
		for (ApexTrigger at : listTriggers) {
			apexTriggersNameSet.add(at.Name);
		}
	}

	public void checkDCAMembers() {
		if (! DCAMemberWrapperList.isEmpty()) {
			DCAMemberWrapperList.clear();
		}

		String f = ApexPages.currentPage().getParameters().get('sortFieldDCAM');
		String o = ApexPages.currentPage().getParameters().get('sortOrderDCAM');

		if (! String.isEmpty(f) && ! String.isEmpty(o)) {
			sortFieldDCAM = f;
			sortOrderDCAM = o;
		}

		Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.DCA_Member__c.fields.getMap();
		String queryString = 'SELECT ';
		for (Schema.SObjectField field : fieldMap.Values()) {
			queryString += field.getDescribe().getName() + ',';
		}
		queryString = queryString.removeEnd(',');
		queryString += ' FROM DCA_Member__c';
		queryString += ' ORDER BY ' + sortFieldDCAM + ' ' + sortOrderDCAM;

		DCAMemberList = Database.query(queryString);

		if (! DCAMemberList.isEmpty()) {
			for (DCA_Member__c dcam : DCAMemberList) {
				DCAMemberWrapperList.add(new DCAMemberWrapper(dcam));
			}
		}
	}

	public void checkAllObjects(String curObj) {
		if (! allObjects.isEmpty()) {
			allObjects.clear();
		}

		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		Map<String, Selectoption> mapping = new Map<String, Selectoption>();
		for (String objectName : mapSObjects.keySet()) {
			// if (objectName != curObj) {
			Schema.DescribeSObjectResult objResult = mapSObjects.get(objectName).getDescribe();

			List<Schema.SObjectField> objectAllFields = objResult.fields.getMap().values();
			Boolean customFlag = objResult.isCustom();
			Boolean createableFlag = objResult.isCreateable();
			Boolean searchFlag = objResult.isSearchable();
			Boolean customSettingFlag = objResult.isCustomSetting();
			List<String> splitList = new List<String>();
			splitList = objectName.split('__');
			if (! objectAllFields.isEmpty() && (customFlag || createableFlag) && ! customSettingFlag && searchFlag && splitList.size() < 3) {
				String objectLabel = objResult.getLabel();
				String labelField;
				String valueField;
				if (objectName != 'Opportunity') {
					labelField = objectLabel;
					valueField = objectName;
				} else {
					labelField = 'Opportunity';
					valueField = 'Opportunity';
				}
				SelectOption selBuf = new SelectOption(valueField, labelField);
				allObjects.add(selBuf);
				mapping.put(labelField , selBuf);
			}
			// }
		}


		List<RecordType> recordTypeList = new List<RecordType>();
		recordTypeList = [SELECT Id, SobjectType, Name FROM RecordType LIMIT 10000];

		Map<String, List<RecordType>> recordTypeMap = new Map<String, List<RecordType>>();
		if (! recordTypeList.isEmpty()) {
			for (RecordType recType : recordTypeList) {
				if (recordTypeMap.containsKey(recType.SobjectType)) {
					recordTypeMap.get(recType.SobjectType).add(recType);
				} else {
					List<RecordType> newRecTypeList = new List<RecordType>();
					newRecTypeList.add(recType);

					recordTypeMap.put(String.valueOf(recType.SobjectType).toLowerCase(), newRecTypeList);
				}
			}
		}

		System.debug('::::recordTypeMap:::::' + recordTypeMap);

		// for (Selectoption opt : allObjects) {
		// 	if (opt.getLabel() != 'TestObject') {
		// 		Boolean isSelObj = false;
		// 		for (objectWrapper ow : selectedObjects) {
		// 			if (opt.getLabel() == ow.Name) {
		// 				List<Schema.FieldSetMember> sFields = new List<Schema.FieldSetMember>();
		// 				Schema.DescribeSObjectResult objResult = mapSObjects.get(opt.getValue()).getDescribe();
		// 				if (objResult.fieldSets.getMap().get('ApprovalFieldSet') != null) {
		// 					sFields = objResult.fieldSets.getMap().get('ApprovalFieldSet').getFields();
		// 				}
		// 				List<Schema.SObjectField> aFields = objResult.fields.getMap().values();
		// 				List<Schema.SObjectField> aVisibleFields = new List<Schema.SObjectField>();
		// 				for (Schema.SObjectField fr : aFields) {
		// 					Schema.DescribeFieldResult fldResult = fr.getDescribe();
		//    					if ((! fldResult.isAutoNumber()) && fldResult.isUpdateable() && fldResult.isAccessible() && fr.getDescribe().isCreateable() &&
		//    						fldResult.getName() != 'Clone_Record_Id__c' && fldResult.getName() != 'Original_Record_Id__c'
		//    						&& fldResult.getName() != 'Is_cloned__c' && fldResult.getName() != 'Is_locked__c' &&
		// 						fldResult.getName() != 'Staff_User_email__c' && fldResult.getName() != 'Parent_Record__c') {
		//    							aVisibleFields.add(fr);
		//    						}
		// 				}
		// 				Integer sfSize = sFields.size();
		// 				Integer avfSize = aVisibleFields.size();

		// 				if (avfSize <= sfSize && ! recordTypeMap.containsKey(opt.getValue().toLowerCase())) {
		// 					isSelObj = true;
		// 					break;
		// 				}
		// 			}
		// 		}
		// 		if (isSelObj == false) {
		// 			mapping.put((opt.getLabel()), opt);
		// 		}
		// 	}
		// }

		List<String> sortKeys = new List<String>();
		sortKeys.addAll(mapping.keySet());
		sortKeys.sort();
		// clear the original collection to rebuilt it
		allObjects.clear();

		for (String key : sortKeys) {
			allObjects.add(mapping.get(key));
		}

	}


	public void checkSelectedManagers() {
		if (! DCAManagerWrapperList.isEmpty()) {
			DCAManagerWrapperList.clear();
			dcaFilterMap.clear();
		}

		String f = ApexPages.currentPage().getParameters().get('sortFieldMAN');
		String o = ApexPages.currentPage().getParameters().get('sortOrderMAN');

		if (! String.isEmpty(f) && ! String.isEmpty(o)) {
			sortFieldMAN = f;
			sortOrderMAN = o;
		}

		Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.DCA_Manager__c.fields.getMap();
		String queryString = 'SELECT ';
		for (Schema.SObjectField field : fieldMap.Values()) {
			queryString += field.getDescribe().getName() + ',';
		}
		queryString = queryString.removeEnd(',');
		queryString += ' FROM DCA_Manager__c';
		queryString += ' ORDER BY ' + sortFieldMAN + ' ' + sortOrderMAN;

		DCAManagerList = Database.query(queryString);

		if (! DCAManagerList.isEmpty()) {
			List<DCA_Filter__c> dcaFilterList = new List<DCA_Filter__c>([
			            SELECT Object_Name__c, Field__c, Operator__c, Value__c, DCA_Manager__c, Object_Label__c, Field_Label__c
			            FROM DCA_Filter__c
			            ORDER BY Object_Name__c
			        ]);

			if (! dcaFilterList.isEmpty()) {
				for (DCA_Filter__c filter : dcaFilterList) {
					if (! dcaFilterMap.containsKey(filter.DCA_Manager__c)) {
						List<DCA_Filter__c> filterList = new List<DCA_Filter__c> {filter};
						dcaFilterMap.put(filter.DCA_Manager__c, filterList);
					} else {
						dcaFilterMap.get(filter.DCA_Manager__c).add(filter);
					}
				}
			}

			Set<Id> manIdSet = new Set<Id>();
			for (DCA_Manager__c dcam : DCAManagerList) {
				manIdSet.add(dcam.Id);

				if (dcaFilterMap.containsKey(dcam.Id)) {
					DCAManagerWrapperList.add(new DCAManagerWrapper(dcam, dcaFilterMap.get(dcam.Id)));
				} else {
					DCAManagerWrapperList.add(new DCAManagerWrapper(dcam, new List<DCA_Filter__c>()));
				}

			}
		}
	}

	public void refreshTab() {
		String tabNumber = ApexPages.currentPage().getParameters().get('tabsNumber');

		system.debug('tabNumber === ' + tabNumber);

		if ('1'.equals(tabNumber)) {
			getTriggersNames();
			checkSelectedObjects(null);

		} else if ('2'.equals(tabNumber)) {
			checkDCAMembers();

		} else if ('3'.equals(tabNumber)) {
			checkSelectedManagers();

		} else if ('4'.equals(tabNumber)) {
			checkApprovalList();

		} else if ('5'.equals(tabNumber)) {
			checkApprovalResults();
		}
	}

	public void checkSelectedObjects(String curObj) {
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();

		system.debug('selectedObjects1 === ' + selectedObjects);

		if (! selectedObjects.isEmpty()) {
			selectedObjects.clear();
		}

		system.debug('selectedObjects2 === ' + selectedObjects);

		List<String> objSet = new List<String>();
		for (String objectName : mapSObjects.keySet()) {
			if (objectName != 'TestObject__c') {

				if (objectName == curObj) {
					putSelectedCurrentObject(objectName);
				} else {
					Set<String> objectAllFields = mapSObjects.get(objectName).getDescribe().fields.getMap().keySet();
					if (objectAllFields.contains('is_cloned__c')) {
						objSet.add(objectName);
					}
				}
			}
		}

		objSet.sort();
		for (String objectName : objSet) {
			putSelectedObject(objectName);
		}

		system.debug('selectedObjects3 === ' + selectedObjects);
	}

	public void putSelectedCurrentObject(String curObject) {
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult objResult = mapSObjects.get(curObject).getDescribe();

		String objLabel;
		if (curObject == 'Opportunity') {
			objLabel = 'Opportunity';
		} else {
			objLabel = objResult.getLabel();
		}

		List<Schema.FieldSetMember> objectFields = new List<Schema.FieldSetMember>();
		if (objResult.fieldSets.getMap().get('ApprovalFieldSet') != null) {
			objectFields = objResult.fieldSets.getMap().get('ApprovalFieldSet').getFields();
			List<String> objFields = new List<String>();
			for (Schema.FieldSetMember fs : objectFields) {
				objFields.add(fs.getLabel());
			}

			for (SelectOption f : selectedFields) {
				Boolean isField;
				for (Schema.FieldSetMember fs : objectFields) {
					isField = false;
					if (f.getLabel() == fs.getLabel()) {
						isField = true;
						break;
					}
				}
				if (isField == false) {
					objFields.add(f.getLabel());
				}
			}

			String recTypesString = '';
			if (! recordTypeSOList.isEmpty()) {
				for (recordTypeWrapper rtWR : recordTypeSOList) {
					if (rtWR.isChecked) {
						recTypesString += rtWR.recType.Name + ',';
					}
				}
				recTypesString = recTypesString.removeEnd(',');
			} else {
				recTypesString = 'None';
			}

			selectedObjects.add(new objectWrapper(objLabel, objFields, recTypesString, dcaObjectMap, apexTriggersNameSet));
		}
	}

	public void putSelectedObject(String curObject) {

		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult objResult = mapSObjects.get(curObject).getDescribe();

		String objLabel;
		if (curObject == 'Opportunity') {
			objLabel = 'Opportunity';
		} else {
			objLabel = objResult.getLabel();
		}
		List<Schema.FieldSetMember> objectFields = new List<Schema.FieldSetMember>();

		if (objResult.fieldSets.getMap().get('ApprovalFieldSet') != null) {
			objectFields = objResult.fieldSets.getMap().get('ApprovalFieldSet').getFields();
			List<String> objFields = new List<String>();
			for (Schema.FieldSetMember fs : objectFields) {
				objFields.add(fs.getLabel());
			}

			String recTypesString;

			if (dcaObjectRecTypeMap.containsKey(curObject)) {
				recTypesString = dcaObjectRecTypeMap.get(curObject);
			} else {
				recTypesString = 'None';
			}

			selectedObjects.add(new objectWrapper(objLabel, objFields, recTypesString, dcaObjectMap, apexTriggersNameSet));
		}
	}

	public PageReference goToAddMember() {
		String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
		                           '/apex/DCA_AddMembers';
		PageReference pr = new PageReference(viewDataChangeURL);

		return pr;
	}

	public void deleteApprovalResult() {
		String arId = apexPages.currentPage().getParameters().get('delAR');

		if (! String.isEmpty(arId)) {
			List<Approval_Result__c> arList = [
			                                      SELECT Id
			                                      FROM Approval_Result__c
			                                      WHERE Id = : arId
			                                              LIMIT 1
			                                  ];

			if (! arList.isEmpty()) {
				delete arList;

				checkApprovalResults();
				activeTab = 4;
			}
		}
	}

	public void deleteDCAMember() {
		String memId = apexPages.currentPage().getParameters().get('delMember');

		List<DCA_Member__c> memList = [
		                                  SELECT Id
		                                  FROM DCA_Member__c
		                                  WHERE Id = :memId
		                                          LIMIT 1
		                              ];

		if (! memList.isEmpty()) {
			delete memList.get(0);
			checkDCAMembers();

			activeTab = 1;
		}
	}

	public PageReference editDCAMember() {
		String memId = apexPages.currentPage().getParameters().get('editMember');

		String editMemberURL = URL.getSalesforceBaseUrl().toExternalForm() +
		                       '/apex/DCA_EditMember';

		PageReference pr = new PageReference(editMemberURL);
		pr.getParameters().put('mId', memId);

		return pr;
	}

	public void deleteManager() {
		String manId = apexPages.currentPage().getParameters().get('delManager');

		Map<Id, DCA_Manager__c> allManMap = new Map<Id, DCA_Manager__c>([
		            SELECT Id
		            FROM DCA_Manager__c
		        ]);

		if (allManMap.size() > 1) {
			if (allManMap.containsKey(manId)) {

				DCA_Manager__c manage = allManMap.get(manId);

				delete manage;

				List<DCA_Filter__c> dcaFilterDeleteList = new List<DCA_Filter__c>([
				            SELECT Id
				            FROM DCA_Filter__c
				            WHERE DCA_Manager__c = :manId
				                                   LIMIT 1000
				        ]);

				if (! dcaFilterDeleteList.isEmpty()) {
					delete dcaFilterDeleteList;
				}

				checkSelectedManagers();

				activeTab = 2;
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Impossible to delete. Should be at least one manager.'));
			activeTab = 2;
		}
	}

	public PageReference editManager() {
		String manId = apexPages.currentPage().getParameters().get('editManager');

		String editManagerURL = URL.getSalesforceBaseUrl().toExternalForm() +
		                        '/apex/DCA_EditManager';

		PageReference pr = new PageReference(editManagerURL);
		pr.getParameters().put('mId', manId);

		return pr;
	}

	public PageReference goToAdd() {
		String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
		                           '/apex/DCA_AddManagers';
		PageReference pr = new PageReference(viewDataChangeURL);

		return pr;
	}

	public void displayFields() {
		allFields.clear();
		selectedFields.clear();
		if (! String.isEmpty(currentObject) && currentObject != 'None') {
			Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
			Schema.DescribeSObjectResult objResult = mapSObjects.get(currentObject).getDescribe();

			List<Schema.SObjectField> objectAllFields =  objResult.fields.getMap().values();
			List<Schema.FieldSetMember> sFields = new List<Schema.FieldSetMember>();
			if (objResult.fieldSets.getMap().get('ApprovalFieldSet') != null) {
				sFields = objResult.fieldSets.getMap().get('ApprovalFieldSet').getFields();
			}

			for (Schema.SObjectField fr : objectAllFields) {
				Schema.DescribeFieldResult fldResult = fr.getDescribe();

				if ((! fldResult.isAutoNumber()) && fldResult.isUpdateable() && fldResult.isAccessible() && fr.getDescribe().isCreateable() &&
				        fldResult.getName() != 'Clone_Record_Id__c' && fldResult.getName() != 'Original_Record_Id__c' &&
				        fldResult.getName() != 'Is_cloned__c' && fldResult.getName() != 'Is_locked__c' &&
				        fldResult.getName() != 'Staff_User_email__c' && fldResult.getName() != 'Parent_Record__c') {
					Boolean isField = false;
					if (! sFields.isEmpty()) {
						objectIsSelected = true;
						for (FieldSetMember fs : sFields) {
							if (fldResult.getName() == fs.getFieldPath()) {
								isField = true;
								break;
							}
						}
					}

					if (isField == false) {
						allFields.add(new SelectOption(fldResult.getName(), fldResult.getLabel()));
					}
				}
			}
			allFields.sort();

			for (FieldSetMember fs : sFields) {
				selectedFields.add(new SelectOption(fs.getFieldPath(), fs.getLabel()));
			}

			for (SelectOption so : allObjects) {
				if (so.getValue() == currentObject) {
					currentLabel = so.getLabel();
					currentLabelWithoutSpaces = currentLabel.replaceAll( '\\s+', '');

					String regex = '[^a-zA-Z0-9]';
					currentLabelWithoutSpaces = currentLabelWithoutSpaces.replaceAll(regex, '');
				}
			}
			/*	TriggerMetadata = generateTriggerMetadata();
				TriggerText = generateTriggerText();
				PackageXml = generatePackageXml();*/

			List<RecordType> recordTypeList = new List<RecordType>();
			recordTypeList = [SELECT Id, SobjectType, Name FROM RecordType WHERE SobjectType = :currentObject];


			recordTypeSOList.clear();

			if (! recordTypeList.isEmpty()) {
				if (dcaObjectRecTypeMap.containsKey(currentObject)) {
					allRecTypeSelected = false;

					for (RecordType rt : recordTypeList) {
						if (dcaObjectRecTypeMap.get(currentObject) == 'All') {
							allRecTypeSelected = true;
							recordTypeSOList.add(new recordTypeWrapper(rt, true));
						} else {
							if (dcaObjectRecTypeMap.get(currentObject).contains(rt.Name)) {
								recordTypeSOList.add(new recordTypeWrapper(rt, true));
							} else {
								recordTypeSOList.add(new recordTypeWrapper(rt, false));
							}
						}

					}
				} else {
					for (RecordType rt : recordTypeList) {
						recordTypeSOList.add(new recordTypeWrapper(rt, true));
					}
					allRecTypeSelected = true;
				}
			}
		} else if (! String.isEmpty(currentObject) && currentObject == 'None') {
			recordTypeSOList.clear();
			allFields.clear();
		}
	}

	public void addRecordTypes() {
		try {
			List<DCA_Object__c> dcaObjList = new List<DCA_Object__c>();
			dcaObjList = [
			                 SELECT Name, Record_Types__c, Start_Time__c
			                 FROM DCA_Object__c
			                 WHERE Name = :forRecTypeObject
			                              LIMIT 1
			             ];

			DCA_Object__c dcaObject = new DCA_Object__c();
			if (! dcaObjList.isEmpty()) {
				dcaObject = dcaObjList.get(0);
			}

			dcaObject.Name = forRecTypeObject;
			dcaObject.Start_Time__c = Datetime.now();

			if (! recordTypeSOList.isEmpty()) {
				String recTypes = '';
				Integer selectedCount = 0;
				List<String> selectedRecTypes = new List<String>();

				for (recordTypeWrapper rt : recordTypeSOList) {
					if (rt.isChecked) {
						selectedCount++;

						selectedRecTypes.add(rt.recType.Name);
					}
				}

				if (selectedCount == recordTypeSOList.size()) {
					recTypes += '[All]' + ',';
				}
				for (String recTypeName : selectedRecTypes) {
					recTypes += recTypeName + ',';
				}
				recTypes = recTypes.removeEnd(',');
				// }

				dcaObject.Record_Types__c = recTypes;


			} else {
				dcaObject.Record_Types__c = 'None';
			}

			upsert dcaObject;

			dcaObjectRecTypeMap.put(dcaObject.Name, dcaObject.Record_Types__c);

			recordTypeSOList.clear();
			this.init();
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
		}

	}

	public String createFieldSet() {
		// create FieldSet
		MetadataService.MetadataPort service = createService();
		MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
		fieldSet.fullName = currentObject + '.ApprovalFieldSet';
		fieldSet.label = 'ApprovalFieldSet';
		fieldSet.description = 'for Data Change Approval';
		fieldSet.displayedFields = new List<MetadataService.FieldSetItem>();

		for ( SelectOption so : selectedFields ) {
			MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
			myAvailableField.field = so.getValue() ;
			myAvailableField.isFieldManaged = true;
			myAvailableField.isRequired = false;

			fieldSet.displayedFields.add(myAvailableField);
		}

		if (! Test.isRunningTest()) {
			List<MetadataService.SaveResult> results = service.createMetadata(
			            new MetadataService.Metadata[] { fieldSet });
			try {
				handleSaveResults(results[0]);
			} catch (Exception e) {
				return e.getMessage();
			}
		}

		return null;
	}

	public void updateFieldSet() {
		// create FieldSet
		MetadataService.MetadataPort service = createService();
		MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
		fieldSet.fullName = currentObject + '.ApprovalFieldSet';
		fieldSet.label = 'ApprovalFieldSet';
		fieldSet.description = 'for Data Change Approval';
		fieldSet.displayedFields = new List<MetadataService.FieldSetItem>();

		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		System.debug('=================' + currentObject);
		// List<Schema.FieldSetMember> sFields = mapSObjects.get(currentObject).getDescribe().fieldSets.getMap().get('ApprovalFieldSet').getFields();
		// for ( Schema.FieldSetMember fs : sFields) {
		// 	MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
		// 	myAvailableField.field = fs.getFieldPath();
		// 	myAvailableField.isFieldManaged = true;
		// 	myAvailableField.isRequired = false;

		// 	fieldSet.displayedFields.add(myAvailableField);
		// }

		for ( SelectOption so : selectedFields ) {
			MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
			myAvailableField.field = so.getValue() ;
			myAvailableField.isFieldManaged = true;
			myAvailableField.isRequired = false;

			fieldSet.displayedFields.add(myAvailableField);
		}

		if (! Test.isRunningTest()) {
			List<MetadataService.SaveResult> results =
			    service.updateMetadata(
			        new MetadataService.Metadata[] { fieldSet });
			handleSaveResults(results[0]);
		}
	}

	public String createFields() {
		MetadataService.MetadataPort service = createService();

		// create Clone Record Id field
		MetadataService.CustomField customFieldCR = new MetadataService.CustomField();
		customFieldCR.fullName = currentObject + '.Clone_Record_Id__c';
		customFieldCR.label = 'Clone Record Id';
		customFieldCR.type_x = 'Text';
		customFieldCR.length = 100;

		// create Original Record Id field
		MetadataService.CustomField customFieldOR = new MetadataService.CustomField();
		customFieldOR.fullName = currentObject + '.Original_Record_Id__c';
		customFieldOR.label = 'Original Record Id';
		customFieldOR.type_x = 'Text';
		customFieldOR.length = 100;

		// create Parent Record field
		MetadataService.CustomField customFieldPR = new MetadataService.CustomField();
		customFieldPR.fullName = currentObject + '.Parent_Record__c';
		customFieldPR.label = 'Parent Record';
		customFieldPR.type_x = 'Text';
		customFieldPR.length = 100;

		// create Staff User email field
		MetadataService.CustomField customFieldSU = new MetadataService.CustomField();
		customFieldSU.fullName = currentObject + '.Staff_User_email__c';
		customFieldSU.label = 'Staff User email';
		customFieldSU.type_x = 'Text';
		customFieldSU.length = 100;

		// create Is cloned field
		MetadataService.CustomField customFieldIC = new MetadataService.CustomField();
		customFieldIC.fullName = currentObject + '.Is_cloned__c';
		customFieldIC.label = 'Is cloned';
		customFieldIC.type_x = 'Checkbox';
		customFieldIC.defaultValue = 'false';

		// create Is locked field
		MetadataService.CustomField customFieldIL = new MetadataService.CustomField();
		customFieldIL.fullName = currentObject + '.Is_locked__c';
		customFieldIL.label = 'Is locked';
		customFieldIL.type_x = 'Checkbox';
		customFieldIL.defaultValue = 'false';

		if (! Test.isRunningTest()) {
			List<MetadataService.SaveResult> results =
			    service.createMetadata(
			        new MetadataService.Metadata[] { customFieldCR, customFieldOR, customFieldPR, customFieldSU, customFieldIC, customFieldIL });
			try {
				handleSaveResults(results[0]);
			} catch (Exception e) {
				return e.getMessage();
			}
		}

		return null;

	}

	public String addLookupToDataChangeActivity() {
		MetadataService.MetadataPort service = createService();

		// add lookup to Data Change Activity
		MetadataService.CustomField customFieldDCA = new MetadataService.CustomField();
		if (currentObject.endsWith('__c')) {
			customFieldDCA.fullName = 'Data_Change_Activity__c.' + currentObject;
		} else {
			customFieldDCA.fullName = 'Data_Change_Activity__c.' + currentObject + '__c';
		}


		System.debug('::::label:::dca:::::' + currentLabel);
		customFieldDCA.label = currentLabel;
		customFieldDCA.type_x = 'Text';
		customFieldDCA.length = 100;


		// customFieldDCA.relationshipLabel = 'DataChangeActivities';
		// customFieldDCA.relationshipName = 'DataChangeActivities';
		// customFieldDCA.referenceTo = currentObject;

		if (! Test.isRunningTest()) {
			List<MetadataService.SaveResult> resultsDCA =
			    service.createMetadata(
			        new MetadataService.Metadata[] { customFieldDCA });
			try {
				handleSaveResults(resultsDCA[0]);
			} catch (Exception e) {
				return e.getMessage();
			}
		}

		return null;
	}

	public void doAddObject() {
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		// List<Schema.SObjectField> objectAllFields = mapSObjects.get(currentObject).getDescribe().fields.getMap().values();
		Boolean inProgress = false;
		System.debug('::selectedObjects::::' + selectedObjects);
		System.debug('::inProgress::::' + inProgress);
		if (! selectedObjects.isEmpty()) {
			for (objectWrapper ow : selectedObjects) {
				if (ow.Status == 'In Progress') {
					inProgress = true;
					System.debug('::inProgress:2:::' + inProgress);
					break;
				}
			}
		}
		System.debug('::::selectedObjects3::::' + selectedObjects);
		System.debug(':::currentObject::::' + currentObject);
		if (inProgress != true) {
			if (! String.isEmpty(currentObject) && currentObject != 'None') {
				try {
					System.debug(':::selectedFields:::' + selectedFields);
					if (! selectedFields.isEmpty()) {
						Boolean rtSelected = false;
						System.debug(':::recordTypeSOList:::' + recordTypeSOList);
						if (! recordTypeSOList.isEmpty()) {
							for (recordTypeWrapper rtWrapper : recordTypeSOList) {
								if (rtWrapper.isChecked) {
									rtSelected = true;
								}
							}
						} else {
							rtSelected = true;
						}

						if (rtSelected) {

							// List<DCA_Manager__c> dcaManList = [
							// 	SELECT Id
							// 	FROM DCA_Manager__c
							// ];

							// if (! dcaManList.isEmpty()) {
							if (objectIsSelected == false) {
								String stateOnExistFieldSets = createFieldSet();
								String stateOnExistField = createFields();
								String stateOnExistLookup = addLookupToDataChangeActivity();
								if (stateOnExistLookup != null
								        && stateOnExistFieldSets != null
								        && stateOnExistField != null) {

								}

								addTrigger();
							} else {
								updateFieldSet();
							}

							checkSelectedObjects(currentObject);
							checkAllObjects(currentObject);

							forRecTypeObject = currentObject;
							currentObject = 'None';
							selectedFields = new List<SelectOption>();
							// List<DCA_Manager__c> debugList;
							// debugList.add(new DCA_Manager__c());
							allFields = new List<SelectOption>();
							objectIsSelected = false;
							// } else {
							// 	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please add at first managers for Data Change approval.'));
							// }
						} else {
							ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Record Types are not selected.'));
						}
					} else {
						Schema.DescribeSObjectResult objResult = mapSObjects.get(currentObject).getDescribe();

						if (recordTypeSOList.isEmpty() && objResult.fieldSets.getMap().get('ApprovalFieldSet') == null) {
							ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Fields are not selected.'));
						} else {
							Boolean rtSelected = false;
							for (recordTypeWrapper rtWrapper : recordTypeSOList) {
								if (rtWrapper.isChecked) {
									rtSelected = true;
								}
							}

							if (! rtSelected) {
								ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Record Types are not selected.'));
							} else {
								checkSelectedObjects(currentObject);
								checkAllObjects(currentObject);

								forRecTypeObject = currentObject;
								currentObject = 'None';
								selectedFields = new List<SelectOption>();
								allFields = new List<SelectOption>();
								objectIsSelected = false;
							}
						}
					}
				} catch (Exception e) {
					if (String.valueOf(e).contains('MetadataServiceExamplesException')) {
						// ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Something happened with the object addition. Try to refresh the page - maybe object is already added.'));
					} else {
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
					}
				}
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The object is not selected.'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Impossible to add the object: another object is "In Progress".'));
		}
	}

	public void deleteFields(String objectDel) {
		try {
			String activityField;
			if (objectDel.endsWith('__c')) {
				activityField = objectDel;
			} else {
				activityField = objectDel + '__c';
			}

			MetadataService.MetadataPort service = createService();
			if (! Test.isRunningTest()) {
				List<MetadataService.DeleteResult> results =
				    service.deleteMetadata(
				        'CustomField', new String[] { objectDel + '.Clone_Record_Id__c', objectDel + '.Original_Record_Id__c',
				                                      objectDel + '.Parent_Record__c', objectDel + '.Staff_User_email__c',
				                                      objectDel + '.Is_cloned__c', objectDel + '.Is_locked__c', 'Data_Change_Activity__c.' + activityField
				                                    });
				handleDeleteResults(results[0]);
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Object has already been removed.'));
		}
	}

	public void deleteFieldSet(String objectDel) {
		try {
			MetadataService.MetadataPort service = createService();
			if (! Test.isRunningTest()) {
				List<MetadataService.DeleteResult> results =
				    service.deleteMetadata('FieldSet', new String[] { objectDel + '.ApprovalFieldSet'});
				handleDeleteResults(results[0]);
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Object has already been removed.'));
		}
	}

	public void deleteObject() {
		String labelForDelete = apexPages.currentPage().getParameters().get('deleteObject');
		statusObj = apexPages.currentPage().getParameters().get('statusObject');



		List<Approval_List__c> existDataChangeAppList = new List<Approval_List__c>([
		            SELECT Id
		            FROM Approval_List__c
		            WHERE Object__c = :labelForDelete
		                              LIMIT 2]);

		if ( ! existDataChangeAppList.isEmpty()) {
			cantDeleteDCAObject = true;
			return;
		}
		// if (statusObj != 'In Progress') {
		try {
			Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
			SelectOption[] allObj = new List<SelectOption>();
			for (String objName : mapSObjects.keySet()) {
				String objLabel = mapSObjects.get(objName).getDescribe().getLabel();
				allObj.add(new SelectOption(objName, objLabel));
			}

			String objectDel;
			for (SelectOption so : allObj) {
				if (so.getLabel() == labelForDelete) {
					objectDel = so.getValue();
				}
			}
			String labelForDeleteSpaces = labelForDelete.replaceAll( '\\s+', '');
			String regex = '[^a-zA-Z0-9]';
			labelForDeleteSpaces = labelForDeleteSpaces.replaceAll(regex, '');

			List<DCA_Object__c> dcaObjDeleteList = new List<DCA_Object__c>([
			            SELECT Id
			            FROM DCA_Object__c
			            WHERE Name = :objectDel
			                         LIMIT 1
			        ]);

			if (! dcaObjDeleteList.isEmpty()) {
				dcaObjectDelete = dcaObjDeleteList.get(0);
			}
			/*String strLikeQuery = '%' + labelForDelete +'%';
			dcaFilterObjDeleteList = [
				SELECT Id,
					(SELECT Id
					FROM DCA_Filter__c)
				FROM DCA_Manager__c
				WHERE Object_Label__c LIKE labelForDelete
				LIMIT 1000
			];*/

			String apiNameDeleteObject = '';

			for (SelectOption selOpt : allObj) {
				if (selOpt.getLabel() == labelForDelete) {
					apiNameDeleteObject = selOpt.getValue();
				}
			}

			List<DCA_Manager__c> debugList;
			List<SObject> deleteObjectManAndFilter = new List<SObject>();
			List<SObject> mapMemberAndManager = new List<SObject>();
			mapMemberAndManager.addAll((List<SObject>)DCAMemberList);
			mapMemberAndManager.addAll((List<SObject>)DCAManagerList);
			List<SObject> listUpdateManagerAndMember = new List<SObject>();
			for (SObject mm : mapMemberAndManager) {
				System.debug('::::mm::::' + mm);
				String fieldObjectOfManager = String.valueOf(mm.get('Objects__c')).replaceAll('\\(', '_left_').replaceAll('\\)', '_right_');
				if (dcaObjectRecTypeMap.containsKey(apiNameDeleteObject)) {
					for (String recTypeItr : dcaObjectRecTypeMap.get(apiNameDeleteObject).split(',')) {
						String labelName = labelForDelete;
						String labelNameBrackets = labelForDelete;
						if (recTypeItr != 'None') {
							labelName += ';' + recTypeItr;
							labelNameBrackets += ' (' + recTypeItr + ')';
							labelName = labelName.replaceAll('\\(', '_left_').replaceAll('\\)', '_right_');
							labelNameBrackets = labelNameBrackets.replaceAll('\\(', '_left_').replaceAll('\\)', '_right_');
						}

						if (fieldObjectOfManager.equalsIgnoreCase(labelName) || fieldObjectOfManager.equalsIgnoreCase(labelNameBrackets)) {
							deleteObjectManAndFilter.add(mm);
							if (dcaFilterMap.containsKey(mm.Id)) {
								for (DCA_Filter__c deleteFilter : dcaFilterMap.get(mm.Id)) {
									deleteObjectManAndFilter.add(deleteFilter);
								}
							}
						} else if (fieldObjectOfManager.containsIgnoreCase(',' + labelName + ',')) {

							fieldObjectOfManager = fieldObjectOfManager.split(',' + labelName + ',').get(0) + ',' + fieldObjectOfManager.split(',' + labelName + ',').get(1);
						} else if (fieldObjectOfManager.containsIgnoreCase(',' + labelName)) {
							if (fieldObjectOfManager.toLowerCase().split(',' + labelName.toLowerCase()).size() == 1) {
								fieldObjectOfManager = fieldObjectOfManager.split(',' + labelName).get(0);
							}
						} else if (fieldObjectOfManager.containsIgnoreCase(labelName + ',')) {
							if (fieldObjectOfManager.toLowerCase().split(labelName.toLowerCase() + ',').get(0).length() == 0) {
								fieldObjectOfManager = fieldObjectOfManager.split(labelName + ',').get(1);
							}
						} else if (fieldObjectOfManager.containsIgnoreCase(',' + labelNameBrackets + ',')) {
							fieldObjectOfManager = fieldObjectOfManager.split(',' + labelNameBrackets + ',').get(0) + ',' + fieldObjectOfManager.split(',' + labelNameBrackets + ',').get(1);
						} else if (fieldObjectOfManager.containsIgnoreCase(',' + labelNameBrackets)) {
							if (fieldObjectOfManager.toLowerCase().split(',' + labelNameBrackets.toLowerCase()).size() == 1) {
								fieldObjectOfManager = fieldObjectOfManager.split(',' + labelNameBrackets).get(0);
							}
						} else if (fieldObjectOfManager.containsIgnoreCase(labelNameBrackets + ',')) {
							if (fieldObjectOfManager.toLowerCase().split(labelNameBrackets.toLowerCase() + ',').get(0).length() == 0) {
								fieldObjectOfManager = fieldObjectOfManager.split(labelNameBrackets + ',').get(1);
							}
						}
					}
					fieldObjectOfManager = fieldObjectOfManager.replaceAll('_left_', '\\(').replaceAll('_right_', '\\)');

					if (fieldObjectOfManager.length() != String.valueOf(mm.get('Objects__c')).length()) {
						mm.put('Objects__c', fieldObjectOfManager);
						listUpdateManagerAndMember.add(mm);
						if (dcaFilterMap.containsKey(mm.Id)) {
							for (DCA_Filter__c deleteFilter : dcaFilterMap.get(mm.Id)) {
								if (deleteFilter.Object_Label__c == labelForDelete) {
									deleteObjectManAndFilter.add(deleteFilter);
								}
							}
						}
					}
				}
			}

			deleteFields(objectDel);
			deleteFieldSet(objectDel);
			deleteTrigger(objectDel, labelForDeleteSpaces);

			if ( ! deleteObjectManAndFilter.isEmpty()) {
				delete deleteObjectManAndFilter;
			}

			if ( ! listUpdateManagerAndMember.isEmpty()) {
				update listUpdateManagerAndMember;
			}

			checkSelectedObjects(null);
			checkAllObjects(null);

			activeTab = 0;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Object has already been removed.'));
		}
		// } else {
		// 	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Impossible to delete. The object is "In Progress".'));
		// }

	}

	public void deleteDCAObject() {
		List<DCA_Manager__c> debug;
		try {
			if (cantDeleteDCAObject) {
				cantDeleteDCAObject = false;
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Before remove this object you should process all records, that relate to this object.'));
				return;
			}
			if (statusObj != 'In Progress') {
				if (dcaObjectDelete.Id != null) {
					delete dcaObjectDelete;
				}
				this.init();
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Impossible to delete. The object is "In Progress".'));
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Object has already been removed.'));

		}
	}

	// When we deleted object, approve all Approval list record on this object
	public void doApproveAllbyDeletedObject(String labelObjectDel) {
		if ( ! this.approvalList.isEmpty()) {
			Map<String, List<SObject>> mapTypeApproveByRecord = new Map<String, List<SObject>>();
			Set<Id> idRecords = new Set<Id>();
			for (Approval_List__c al : this.approvalList) {
				if (al.Object__c == labelObjectDel) {
					if (al.Link_to_Record__c != null) {
						String parsingString = al.Link_to_Record__c;

					}
				}
			}
		}
	}

	public void checkApprovalList() {
		if (! approvalList.isEmpty()) {
			approvalList.clear();
			alWrapperList.clear();
		}

		String f = ApexPages.currentPage().getParameters().get('sortFieldAL');
		String o = ApexPages.currentPage().getParameters().get('sortOrderAL');

		if (! String.isEmpty(f) && ! String.isEmpty(o)) {
			sortFieldAL = f;
			sortOrderAL = o;
		}

		// Author: Yarik Meshcheryakov

		String userRoleName = '';
		String userName = userInfo.getUserId();

		if (userInfo.getUserRoleId() != null) {
			userRoleName = userInfo.getUserRoleId();
		}

		String userProfileName = userInfo.getProfileId();
		Set<String> userGroupId = new Set<String>();
		List<GroupMember> userGroupMemberList = new List<GroupMember>();
		userGroupMemberList = [
		                          SELECT Group.Name, UserOrGroupId
		                          FROM GroupMember
		                          WHERE UserOrGroupId = :userInfo.getUserId()
		                      ];

		for (GroupMember gm : userGroupMemberList) {
			userGroupId.add(gm.Group.Id);
		}
		System.debug('::::DCAManagerList::::::' + DCAManagerList);
		List<DCA_Manager__c> dcaManagerApprovalList = new List<DCA_Manager__c>();

		if (! DCAManagerList.isEmpty()) {
			for (DCA_Manager__c dcaM : DCAManagerList) {
				System.debug('::::::dcaM.Profile__c:::' + dcaM.Profile__c);
				System.debug('::::userProfileName:::::' + userProfileName);
				System.debug('======username: ' + userName);

				if (dcaM.Profile__c == userProfileName || dcaM.User__c == userName ||
				        userGroupId.contains(dcaM.Public_Group__c)) {
					dcaManagerApprovalList.add(dcaM);
				} else {
					if (! String.isEmpty(userRoleName)) {
						if (dcaM.UserRole__c == userRoleName) {
							dcaManagerApprovalList.add(dcaM);
						}
					}
				}
			}
		}

		System.debug('::::dcaManagerApprovalList::::::' + dcaManagerApprovalList);

		// --------

		Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.Approval_List__c.fields.getMap();
		String queryString = 'SELECT ';
		for (Schema.SObjectField field : fieldMap.Values()) {
			queryString += field.getDescribe().getName() + ',';
		}
		queryString = queryString.removeEnd(',');
		queryString += ' FROM Approval_List__c';
		queryString += ' ORDER BY ' + sortFieldAL + ' ' + sortOrderAL;

		approvalList = Database.query(queryString);
		System.debug('::::approvalList::::::' + approvalList);


		if (! approvalList.isEmpty()) {

			Map<String, List<String>> objectRecordIdsMap = new Map<String, List<String>>();
			Map<String, Map<Id, SObject>> objectRecordsMap = new Map<String, Map<Id, SObject>>();

			for (Approval_List__c al : approvalList) {
				if (objectRecordIdsMap.containsKey(al.Object__c)) {
					objectRecordIdsMap.get(al.Object__c).add(al.Link_to_Record__c.substringAfterLast('/'));
				} else {
					List<String> recordIdsList = new List<String>();
					recordIdsList.add(al.Link_to_Record__c.substringAfterLast('/'));

					objectRecordIdsMap.put(al.Object__c, recordIdsList);
				}
			}

			for (String approveObject : objectRecordIdsMap.keySet()) {
				String objName = Id.valueOf(objectRecordIdsMap.get(approveObject)[0]).getSObjectType().getDescribe().getName();
				Map<String, Schema.SObjectField> objectFilterFields = Id.valueOf(objectRecordIdsMap.get(approveObject)[0]).getSObjectType().getDescribe().fields.getMap();

				Map<Id, SObject> recordsMap = new Map<Id, SObject>();
				Set<String> idsSet = new Set<String>();
				idsSet.addAll(objectRecordIdsMap.get(approveObject));

				queryString = 'SELECT ';

				for (Schema.SObjectField field : objectFilterFields.values()) {
					queryString += field.getDescribe().getName() + ',';
				}

				queryString = queryString.removeEnd(',');
				queryString += ' FROM ' + objName;
				queryString += ' WHERE Id IN :idsSet LIMIT 10000';

				recordsMap = new Map<Id, SObject>(Database.query(queryString));

				objectRecordsMap.put(approveObject, recordsMap);
			}

			System.debug('::::approvalList:::2:::' + approvalList);
			System.debug('::::objectRecordsMap::::::' + objectRecordsMap);

			Integer count = 1;

			for (Approval_List__c al : approvalList) {
				System.debug('::::al::::::' + al);

				Boolean isManager = false;
				Set<Id> mngerIdSet = new Set<Id>();

				System.debug('::dcaObjectRecTypeMap:::' + dcaObjectRecTypeMap);
				System.debug('::al.Link_to_Record__c.substringAfterLast(/):::' + al.Link_to_Record__c.substringAfterLast('/'));
				System.debug('::al.Link_to_Record__c.substringAfterLast(/):::' + Id.valueOf(al.Link_to_Record__c.substringAfterLast('/')).getSObjectType().getDescribe().getName());
				System.debug('======keySet: ' + dcaObjectRecTypeMap.keySet());
				System.debug('=======value: ' + dcaObjectRecTypeMap.get(Id.valueOf(al.Link_to_Record__c.substringAfterLast('/')).getSObjectType().getDescribe().getName().toLowerCase()));
				if (dcaObjectRecTypeMap.containsKey(Id.valueOf(al.Link_to_Record__c.substringAfterLast('/')).getSObjectType().getDescribe().getName().toLowerCase())) {
					System.debug(':::::hello!:::::');
					String objRecTypes = dcaObjectRecTypeMap.get(Id.valueOf(al.Link_to_Record__c.substringAfterLast('/')).getSObjectType().getDescribe().getName().toLowerCase());

					String objRecTypeName;
					String labelForFilters = al.Object__c;

					System.debug(':::::objRecTypes:::::' + objRecTypes);
					if (objRecTypes == 'All') {
						objRecTypeName = al.Object__c + ';' + al.Record_Type_Name__c;
						labelForFilters += ' (' + al.Record_Type_Name__c + ')';
					} else if (objRecTypes == 'None') {
						objRecTypeName = al.Object__c;

					} else {
						objRecTypeName = al.Object__c + ';' + al.Record_Type_Name__c;
						labelForFilters += ' (' + al.Record_Type_Name__c + ')';
					}
					System.debug('::::objRecTypeName:::' + objRecTypeName);

					for (DCA_Manager__c dcaM : dcaManagerApprovalList) {
						mngerIdSet.add(dcaM.Id);

						if (dcaM.Objects__c == 'All') {
							alWrapperList.add(new approvalListWrapper(al, count));
						} else {
							List<String> objList = new List<String>();
							objList = dcaM.Objects__c.split(',');
							System.debug('::::objList:::' + objList);

							Set<String> objSet = new Set<String>();
							objSet.addAll(objList);

							System.debug('::::objRecTypeName:::' + objRecTypeName);
							if (objSet.contains(objRecTypeName)) {
								isManager = true;
								break;
							}
						}
					}

					if (isManager) {
						for (String mngId : mngerIdSet) {
							if (dcaFilterMap.containsKey(mngId)) {
								Boolean isFilterExist = false;

								for (DCA_Filter__c dcaF : dcaFilterMap.get(mngId)) {
									if (dcaF.Object_Name__c == labelForFilters) {
										isFilterExist = true;

										SObject record = objectRecordsMap.get(al.Object__c).get(al.Link_to_Record__c.substringAfterLast('/'));
										if (record == null) {
											continue;
										}										

										Map<String, Schema.SObjectField> objectFilterFields = record.getSObjectType().getDescribe().fields.getMap();

										if (checkFilterForRecord(record, dcaF, objectFilterFields)) {
											alWrapperList.add(new approvalListWrapper(al, alWrapperList.size() + 1));
											break;
										}
									}
								}

								if (! isFilterExist) {
									alWrapperList.add(new approvalListWrapper(al, alWrapperList.size() + 1));
									break;
								}
							} else {
								alWrapperList.add(new approvalListWrapper(al, alWrapperList.size() + 1));
								break;
							}
						}

					}
				}

				count++;
			}
		}
	}

	public void checkApprovalResults() {
		if (! approvalResults.isEmpty()) {
			approvalResults.clear();
			arWrapperResult.clear();
		}

		String f = ApexPages.currentPage().getParameters().get('sortFieldAR');
		String o = ApexPages.currentPage().getParameters().get('sortOrderAR');

		if (! String.isEmpty(f) && ! String.isEmpty(o)) {
			sortFieldAR = f;
			sortOrderAR = o;
		}

		Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.Approval_Result__c.fields.getMap();
		String queryString = 'SELECT ';
		for (Schema.SObjectField field : fieldMap.Values()) {
			queryString += field.getDescribe().getName() + ',';
		}
		queryString = queryString.removeEnd(',');
		queryString += ' FROM Approval_Result__c';
		queryString += ' ORDER BY ' + sortFieldAR + ' ' + sortOrderAR;

		approvalResults = Database.query(queryString);

		if (! approvalResults.isEmpty()) {
			Integer count = 1;
			for (Approval_Result__c ar : approvalResults) {
				arWrapperResult.add(new approvalResultWrapper(ar, count));
				count++;
			}
		}
	}

	public static MetadataService.MetadataPort createService() {
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		service.timeout_x = 120000;
		return service;
	}

	private static void handleSaveResults(MetadataService.SaveResult saveResult) {
		// Nothing to see?
		if (saveResult == null || saveResult.success)
			return;
		// Construct error message and throw an exception
		List<String> messages = new List<String>();
		messages.add(
		    (saveResult.errors.size() == 1 ? 'Error ' : 'Errors ') +
		    'occured processing component ' + saveResult.fullName + '.');
		for (MetadataService.Error error : saveResult.errors)
			messages.add(
			    error.message + ' (' + error.statusCode + ').' +
			    ( error.fields != null && error.fields.size() > 0 ?
			      ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
		if (messages.size() > 0)
			throw new MetadataServiceExamplesException(String.join(messages, ' '));
	}

	private static void handleDeleteResults(MetadataService.DeleteResult deleteResult) {
		// Nothing to see?

		if (deleteResult == null || deleteResult.success)
			return;
		// Construct error message and throw an exception

		List<String> messages = new List<String>();
		messages.add(
		    (deleteResult.errors.size() == 1 ? 'Error ' : 'Errors ') +
		    'occured processing component ' + deleteResult.fullName + '.');
		for (MetadataService.Error error : deleteResult.errors)
			messages.add(
			    error.message + ' (' + error.statusCode + ').' +
			    ( error.fields != null && error.fields.size() > 0 ?
			      ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
		if (messages.size() > 0)
			throw new MetadataServiceExamplesException(String.join(messages, ' '));
	}

	public class MetadataServiceExamplesException extends Exception { }

	public void addTrigger() {
		/* 	String sessionId = UserInfo.getSessionId();
		 	addTriggerFeature(sessionId);*/

		HttpRequest req = new HttpRequest();
		req.setEndpoint('http://52.32.93.87:8080/deploy_sf/deploy');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'OAuth '  + UserInfo.getSessionId());
		req.setHeader('InstanceURL', URL.getSalesforceBaseUrl().toExternalForm());

		if (currentLabelWithoutSpaces.length() > 25) {
			currentLabelWithoutSpaces = currentLabelWithoutSpaces.substring(0, 25);
		}

		req.setBody('triggerName=DCA_' + currentLabelWithoutSpaces + 'Trigger&objectName=' + currentObject);
		req.setTimeout(120000);
		// Send the request, and return a response
		Http h = new Http();
		if (! Test.isRunningTest()) {
			HttpResponse res = h.send(req);
			if (res.getStatusCode() == 200) {
			}
		}
	}

	public void deleteTrigger(String name, String label) {
		/*	String sessionId = UserInfo.getSessionId();
			deleteTriggerFeature(sessionId);*/

		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://52.32.93.87:8080/deploy_sf/deploy');
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			req.setHeader('Authorization', 'OAuth '  + UserInfo.getSessionId());
			req.setHeader('InstanceURL', URL.getSalesforceBaseUrl().toExternalForm());

			req.setBody('triggerName=DCA_' + label + 'Trigger&objectName=' + name + '&isDelete=true');
			req.setTimeout(120000);
			// Send the request, and return a response
			Http h = new Http();
			if (! Test.isRunningTest()) {
				HttpResponse res = h.send(req);
				System.debug('Response code is ' + res.getStatusCode());
				if (res.getStatusCode() == 200) {
				}
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Object has already been removed.'));
		}
	}

	public void refreshTrigger() {
		String objLabel = ApexPages.currentPage().getParameters().get('objectName');

		currentLabelWithoutSpaces = objLabel.replaceAll( '\\s+', '');
		String regex = '[^a-zA-Z0-9]';
		currentLabelWithoutSpaces = currentLabelWithoutSpaces.replaceAll(regex, '');

		addTrigger();

		DCA_Object__c dcaObj = dcaObjectMap.get(objLabel.toLowerCase());
		dcaObj.Start_Time__c = Datetime.now();
		update dcaObj;

		checkSelectedObjects(null);
		checkAllObjects(null);
		selectedFields = new List<SelectOption>();
		allFields = new List<SelectOption>();
		currentObject = 'None';
		objectIsSelected = false;
	}

	public void selectAllRecTypes() {
		for (recordTypeWrapper rtWrapper : recordTypeSOList) {
			rtWrapper.isChecked = allRecTypeSelected;
		}
	}

	// public class userWrapper {
	//     public Boolean checkState {get; set;}
	//    	public User user {get; set;}

	//     public userWrapper(User u)
	//     {
	//         user = u;
	//         checkState = false;
	//     }
	// }

	public static Boolean checkFilterForRecord(SObject rec, DCA_Filter__c filter, Map<String, Schema.SObjectField> sobjFieldMap) {

		Boolean isFilterResult = false;
		System.debug('::::filter.Operator__c ::::' + filter.Operator__c );
		if (rec.get(filter.Field__c) != null) {
			if (filter.Operator__c == 'equals') {
				System.debug('::::String.valueOf(rec.get(filter.Field__c)::::' + String.valueOf(rec.get(filter.Field__c)) );
				System.debug('::::filter.Value__c::::' + filter.Value__c );
				if (String.valueOf(rec.get(filter.Field__c)) == filter.Value__c) {
					isFilterResult = true;
				}
			} else if (filter.Operator__c == 'not equals to') {
				if (String.valueOf(rec.get(filter.Field__c)) != filter.Value__c) {
					isFilterResult = true;
				}
			} else if (filter.Operator__c == 'starts with') {
				if (String.valueOf(rec.get(filter.Field__c)).startsWithIgnoreCase(String.valueOf(filter.Value__c))) {
					isFilterResult = true;
				}
			} else if (filter.Operator__c == 'contains') {
				if (String.valueOf(rec.get(filter.Field__c)).containsIgnoreCase(String.valueOf(filter.Value__c))) {
					isFilterResult = true;
				}
			} else if (filter.Operator__c == 'does not contain') {
				if (! String.valueOf(rec.get(filter.Field__c)).containsIgnoreCase(String.valueOf(filter.Value__c))) {
					isFilterResult = true;
				}
			} else if (filter.Operator__c == 'less than') {
				String fieldType = String.valueOf(sobjFieldMap.get(filter.Field__c).getDescribe().getType());
				if (fieldType == 'Date') {
					if (Date.valueOf(rec.get(filter.Field__c)) < Date.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'DateTime') {
					if (DateTime.valueOf(rec.get(filter.Field__c)) < DateTime.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'Currency' || fieldType == 'Double' || fieldType == 'Integer' || fieldType == 'Percent') {
					if (Double.valueOf(rec.get(filter.Field__c)) < Double.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}
			} else if (filter.Operator__c == 'greater than') {
				String fieldType = String.valueOf(sobjFieldMap.get(filter.Field__c).getDescribe().getType());
				if (fieldType == 'Date') {
					if (Date.valueOf(rec.get(filter.Field__c)) > Date.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'DateTime') {
					if (DateTime.valueOf(rec.get(filter.Field__c)) > DateTime.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'Currency' || fieldType == 'Double' || fieldType == 'Integer' || fieldType == 'Percent') {
					if (Double.valueOf(rec.get(filter.Field__c)) > Double.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}
			} else if (filter.Operator__c == 'less or equal') {
				String fieldType = String.valueOf(sobjFieldMap.get(filter.Field__c).getDescribe().getType());
				if (fieldType == 'Date') {
					if (Date.valueOf(rec.get(filter.Field__c)) <= Date.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'DateTime') {
					if (DateTime.valueOf(rec.get(filter.Field__c)) <= DateTime.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'Currency' || fieldType == 'Double' || fieldType == 'Integer' || fieldType == 'Percent') {
					if (Double.valueOf(rec.get(filter.Field__c)) <= Double.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}
			} else if (filter.Operator__c == 'greater or equal') {
				String fieldType = String.valueOf(sobjFieldMap.get(filter.Field__c).getDescribe().getType());
				if (fieldType == 'Date') {
					if (Date.valueOf(rec.get(filter.Field__c)) >= Date.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'DateTime') {
					if (DateTime.valueOf(rec.get(filter.Field__c)) >= DateTime.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}

				if (fieldType == 'Currency' || fieldType == 'Double' || fieldType == 'Integer' || fieldType == 'Percent') {
					if (Double.valueOf(rec.get(filter.Field__c)) >= Double.valueOf(filter.Value__c)) {
						isFilterResult = true;
					}
				}
			}
		}
		System.debug(':::isFilterResult::::' + isFilterResult);
		return isFilterResult;
	}

	public class objectWrapper {
		public String Name {get; set;}
		public String fields {get; set;}
		public String recTypes {get; set;}
		public String Status {get; set;}
		public Integer countOfField {get; set;}
		public Integer recTypesCount {get; set;}

		public objectWrapper(String objName, List<String> selFields, String rtStr, Map<String, DCA_Object__c> dcaObjectMap, Set<String> apexTriggersNameSet) {
			Name = objName;

			List<String> rtList = new List<String>();
			if (rtStr.contains('[All]')) {
				rtStr = 'All';
			}
			rtList = rtStr.split(',');
			rtList.sort();

			recTypes = '<html><META HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8"><body><ul>';
			Integer currentRecTypesCount = 0;
			for (String rt : rtList) {
				recTypes += currentRecTypesCount < 5 ? '<li>' : '<li style="display:none">';
				recTypes += rt;
				recTypes += '</li>';
				currentRecTypesCount++;
			}
			recTypesCount = currentRecTypesCount;
			recTypes += '</ul></html></body>';

			String TriggerName = 'DCA_';

			objName = objName.replaceAll( '\\s+', '');

			String regex = '[^a-zA-Z0-9]';
			objName = objName.replaceAll(regex, '');

			if (objName.length() > 25) {
				TriggerName += objName.substring(0, 25);
			} else {
				TriggerName += objName;
			}
			TriggerName += 'Trigger';
			fields = '<html><META HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8"><body><ul>';
			selFields.sort();
			Integer currentFieldCount = 0;
			for (String field : selFields) {
				fields += currentFieldCount < 5 ? '<li>' : '<li style="display:none">';
				fields += field;
				fields += '</li>';
				currentFieldCount++;
			}
			countOfField = currentFieldCount;
			fields += '</ul></html></body>';
			// fields = fields.removeEnd(' ');
			// fields = fields.removeEnd(',');

			// String queryString = 'SELECT a.Name';
			// 	queryString += ' FROM ApexTrigger a';
			// 	queryString += ' WHERE a.Name = \'' + TriggerName + '\'';

			// List<ApexTrigger> listTriggers = Database.query(queryString);

			// if (! listTriggers.isEmpty()) {
			// 	Status = 'Completed';
			// } else {
			// 	Status = 'In Progress';
			// }

			if (apexTriggersNameSet.contains(TriggerName)) {
				Status = 'Completed';
			} else {
				if (! dcaObjectMap.isEmpty() && dcaObjectMap.get(objName.toLowerCase()) != null) {
					DCA_Object__c dcaObj = dcaObjectMap.get(objName.toLowerCase());
					if (dcaObj.Start_Time__c != NULL) {
						decimal Hours = decimal.valueof((Datetime.now().getTime() - dcaObj.Start_Time__c.getTime()) / (60 * 60));
						decimal s = (hours / 1000);
						if (s > 1) {
							Status = 'Failed';
						} else {
							Status = 'In Progress';
						}
					} else {
						Status = 'Completed';
					}
				} else {
					Status = 'In Progress';
				}
			}
		}
	}

	public class approvalListWrapper {
		public Integer count {get; set;}
		public Approval_List__c appList {get; set;}

		public approvalListWrapper(Approval_List__c al, Integer c) {
			count = c;
			appList = al;
		}
	}

	public class approvalResultWrapper {
		public Integer count {get; set;}
		public Approval_Result__c appResult {get; set;}

		public approvalResultWrapper(Approval_Result__c ar, Integer c) {
			count = c;
			appResult = ar;
		}
	}

	public class DCAMemberWrapper {
		public String Name {get; set;}
		public String Type {get; set;}
		public String Id {get; set;}
		public String objects {get; set;}

		public DCAMemberWrapper(DCA_Member__c member) {
			Id = member.Id;

			if (! String.isEmpty(member.Profile__c)) {
				Type = 'Profile';
			} else if (! String.isEmpty(member.Public_Group__c)) {
				Type = 'Public Group';
			} else if (! String.isEmpty(member.User__c)) {
				Type = 'User';
			} else if (! String.isEmpty(member.UserRole__c)) {
				Type = 'UserRole';
			}

			Name = member.Name;


			if (member.Objects__c != null) {
				objects = member.Objects__c;
			}
		}
	}

	public class DCAManagerWrapper {
		public String Name {get; set;}
		public String Type {get; set;}
		public String Id {get; set;}
		public String objects {get; set;}
		public List<DCA_Filter__c> filters {get; set;}

		public DCAManagerWrapper(DCA_Manager__c manager, List<DCA_Filter__c> dcaFilterList) {
			Id = manager.Id;
			filters = new List<DCA_Filter__c>();
			Name = manager.Name;
			if (! String.isEmpty(manager.Profile__c)) {
				Type = 'Profile';
			} else if (! String.isEmpty(manager.Public_Group__c)) {
				Type = 'Public Group';
			} else if (! String.isEmpty(manager.User__c)) {
				Type = 'User';
			} else if (! String.isEmpty(manager.UserRole__c)) {
				Type = 'UserRole';
			}


			objects = '<html><META HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8"><body>';

			List<String> managerObjects = new List<String>();
			managerObjects = manager.Objects__c.split(',');
			managerObjects.sort();
			for (String manObj : managerObjects) {
				if (manObj.split(';').size() > 1) {
					objects += manObj.split(';').get(0) + ' (' + manObj.split(';').get(1) + ')';
				} else {
					objects += manObj;
				}
				objects += '<br>';
			}
			objects += '</html></body>';

			if (! dcaFilterList.isEmpty()) {
				for (DCA_Filter__c filter : dcaFilterList) {
					if (filter.Object_Name__c.split(';').size() > 1) {
						filter.Object_Name__c = filter.Object_Name__c.split(';').get(0) + ' (' + filter.Object_Name__c.split(';').get(1) + ')';
					}

					filters.add(filter);
				}
			}
		}
	}

	public class recordTypeWrapper {
		public RecordType recType {get; set;}
		public Boolean isChecked {get; set;}

		public recordTypeWrapper(RecordType rt, Boolean chck) {
			recType = rt;
			isChecked = chck;
		}
	}
}
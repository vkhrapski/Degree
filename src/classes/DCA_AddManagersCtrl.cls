public with sharing class DCA_AddManagersCtrl {
	public String currentType {get; set;}
	public SelectOption[] allTypes {get; set;}
	public SelectOption[] allMembersSO {get; set;}
	public SelectOption[] selectedMembersSO {get; set;}
	public SelectOption[] availableObjects {get; set;}
	public SelectOption[] selectedObjects {get; set;}
	public String searchString {get; set;}

	public Map<String, List<objectFilterWrapper>> dcaFilterMap {get; set;}
	public Boolean isFilter {get; set;}
	public List<SelectOption> operationList {get; set;}
	public Map<String, List<SelectOption>> objectFieldsMap {get; set;}
	public Map<String, String> objectNamesMap;
		
	public DCA_AddManagersCtrl() {
		allMembersSO = new List<SelectOption>();
		selectedMembersSO = new List<SelectOption>();
		availableObjects = new List<SelectOption>();
		selectedObjects = new List<SelectOption>();
		dcaFilterMap = new Map<String, List<objectFilterWrapper>>();
		objectFieldsMap = new Map<String, List<SelectOption>>();
		objectNamesMap = new Map<String, String>();
		
		allTypes = new List<SelectOption> {
            new SelectOption('Profile','Profile'), 
            new SelectOption('Public Group','Public Group'), 
            new SelectOption('UserRole','UserRole'), 
            new SelectOption('User','User') 
        };

        operationList = new List<SelectOption> {
        	new SelectOption('none','--None--'), 
            new SelectOption('equals','equals'), 
            new SelectOption('not equal to','not equal to'), 
            new SelectOption('starts with','starts with'),
            new SelectOption('contains','contains'),
            new SelectOption('does not contain','does not contain'),
            new SelectOption('less than','less than'),
            new SelectOption('greater than','greater than'),
            new SelectOption('less or equal','less or equal'),
            new SelectOption('greater or equal','greater or equal')
            // new SelectOption('includes','includes'),
            // new SelectOption('excludes','excludes'),
            // new SelectOption('within','within')
        };
        
        currentType = 'Profile';

        isFilter = false;
	}
	
	public void init() {
		displayMembers();
		displayObjects();
	}
	
	public void displayObjects() {
		availableObjects.add(new SelectOption('All','All'));
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		List<ApexTrigger> triggerList = [
			SELECT a.Name, a.TableEnumOrId
			FROM ApexTrigger a
		];
		
		Map<String, ApexTrigger> triggerMap = new Map<String, ApexTrigger>();
		for (ApexTrigger tr : triggerList) {
			triggerMap.put(tr.Name, tr);
		}

		Map<String, String> dcaObjectMap = new Map<String, String>();
		List<DCA_Object__c> dcaObjectList = new List<DCA_Object__c>();
		dcaObjectList = [
			SELECT Id, Record_Types__c, Name
			FROM DCA_Object__c
		];

		for (DCA_Object__c dcaObj : dcaObjectList) {
			dcaObjectMap.put(dcaObj.Name, dcaObj.Record_Types__c);
		}
		
		for (String objectName : mapSObjects.keySet()) {
			String objectLabel;
			if (objectName == 'Opportunity') {
				objectLabel = 'Opportunity';
			} else {
				objectLabel = mapSObjects.get(objectName).getDescribe().getLabel();	
			}

			String regex = '[^a-zA-Z0-9]';

			objectNamesMap.put(objectLabel, objectName);

			String TriggerName = 'DCA_';
			
           	String lblForTrigger = objectLabel.replaceAll( '\\s+', '').replaceAll(regex, '');
           	
			if (lblForTrigger.length() > 25) {
				TriggerName += lblForTrigger.substring(0, 25);	
			} else {
				TriggerName += lblForTrigger;	
			}
           	TriggerName += 'Trigger';

			if (triggerMap.containsKey(TriggerName)) {
				if (triggerMap.get(TriggerName).TableEnumOrId == objectName) {
					if (dcaObjectMap.containsKey(objectName)) {
						List<String> recTypes = new List<String>();
						recTypes = dcaObjectMap.get(objectName).split(',', -2);

						if (! recTypes.isEmpty()) {
							for (String recType : recTypes) {
								if(recType == '[All]') {
									continue;
								}
								if (recType == 'None') {
									availableObjects.add(new SelectOption(objectLabel,objectLabel));		
								} else {
									availableObjects.add(new SelectOption(objectLabel + ';' + recType,objectLabel + ' (' + recType + ')'));	
								}
							}
						} else {
							availableObjects.add(new SelectOption(objectLabel,objectLabel));	
						}
					} else {
						availableObjects.add(new SelectOption(objectLabel,objectLabel));	
					}
				}
			}
		}
	}
	
	public void displayMembers() {
		if (! allMembersSO.isEmpty()) {
			allMembersSO.clear();			
		}
		
		if (currentType == 'Profile') {
			List<String> selectedNames = new List<String>();
			List<DCA_Manager__c> dcaManagerList = [
				SELECT Id, Profile__c 
				FROM DCA_Manager__c 
				WHERE Profile__c != null]; 
			
			if (! dcaManagerList.isEmpty()) {
				for (DCA_Manager__c manager : dcaManagerList) {
					selectedNames.add(manager.Profile__c);
				}
			}
			List<Profile> profileList = [
				SELECT Id, Name 
				FROM Profile 
				WHERE Name NOT IN :selectedNames
				ORDER BY Name
				LIMIT 1000];
			if (! profileList.isEmpty()) {
				for (Profile pr : profileList) {
					allMembersSO.add(new SelectOption(pr.Id,'Profile: ' + pr.Name));
				}	
			}
			
			
 		} else if (currentType == 'Public Group') {
 			List<String> selectedNames = new List<String>();
 			List<DCA_Manager__c> dcaManagerList = [
 				SELECT Id, Public_Group__c 
 				FROM DCA_Manager__c 
 				WHERE Public_Group__c != null];
 			if (! dcaManagerList.isEmpty()) {
				for (DCA_Manager__c manager : dcaManagerList) {
					selectedNames.add(manager.Public_Group__c);
				}
			}
			List<Group> pgList = [
				SELECT Id, Name 
				FROM Group 
				WHERE Name NOT IN :selectedNames 
				ORDER BY Name
				LIMIT 1000];
			if (! pgList.isEmpty()) {
				for (Group pg : pgList) {
					if (pg.Name != null) {
						allMembersSO.add(new SelectOption(pg.Id,'Public Group: ' + pg.Name));
					}
				}	
			}
 		} else if (currentType == 'UserRole') {
 			List<String> selectedNames = new List<String>();
 			List<DCA_Manager__c> dcaManagerList = [
 				SELECT Id, UserRole__c 
 				FROM DCA_Manager__c 
 				WHERE UserRole__c != null];
 			if (! dcaManagerList.isEmpty()) {
				for (DCA_Manager__c manager : dcaManagerList) {
					selectedNames.add(manager.UserRole__c);
				}
			}
			List<UserRole> urList = [
				SELECT Id, Name 
				FROM UserRole 
				WHERE Name NOT IN :selectedNames
				ORDER BY Name
				LIMIT 1000];
			if (! urList.isEmpty()) {
				for (UserRole ur : urList) {
					allMembersSO.add(new SelectOption(ur.Id,'UserRole: ' + ur.Name));
				}	
			}
 		} else if (currentType == 'User') {
 			List<String> selectedNames = new List<String>();
 			List<DCA_Manager__c> dcaManagerList = [
 				SELECT Id, User__c 
 				FROM DCA_Manager__c 
 				WHERE User__c != null];
 			if (! dcaManagerList.isEmpty()) {
				for (DCA_Manager__c manager : dcaManagerList) {
					selectedNames.add(manager.User__c);
				}
			}
			List<User> userList = [
				SELECT Id, Name 
				FROM User 
				WHERE Name NOT IN :selectedNames
				ORDER BY Name
				LIMIT 1000];
			if (! userList.isEmpty()) {
				for (User user : userList) {
					allMembersSO.add(new SelectOption(user.Id,'User: ' + user.Name));
				}	
			}
 		}
	}
	
	public PageReference doAdd() {
		if (! selectedMembersSO.isEmpty()) {
			if (! selectedObjects.isEmpty()) {
				List<DCA_Manager__c> dcaList = new List<DCA_Manager__c>();
				for (SelectOption so : selectedMembersSO) {
					String memName = so.getValue();
					String[] label = so.getLabel().split(':', 2);
					String memType = label.get(0);
					
					DCA_Manager__c dcaManager = new DCA_Manager__c();
					dcaManager.Name = label.get(1).trim();

					if (memType == 'Profile') {
						dcaManager.Profile__c = memName;
						dcaManager.Type__c = 'Profile';
					} else if (memType == 'Public Group') {
						dcaManager.Public_Group__c = memName;
						dcaManager.Type__c = 'Public Group';
					} else if (memType == 'UserRole') {
						dcaManager.UserRole__c = memName;
						dcaManager.Type__c = 'UserRole';
					} else if (memType == 'User') {
						dcaManager.User__c = memName;
						dcaManager.Type__c = 'User';
					}
					String selObjects = '';
					for (SelectOption obj : selectedObjects) {
						if (obj.getLabel() == 'All') {
							dcaManager.Objects__c = 'All';
							break;
						} else {
							selObjects += obj.getValue() + ',';
						}
					}
					
					if (dcaManager.Objects__c != 'All') {
						selObjects = selObjects.removeEnd(',');
						dcaManager.Objects__c = selObjects;
					}
					
					dcaList.add(dcaManager);
				} 
				
				insert dcaList;

				List<DCA_Filter__c> dcaFilterList = new List<DCA_Filter__c>();
		
				System.debug('::::dcaList:::' + dcaList);
				System.debug('::::dcaFilterMap:::' + dcaFilterMap);

				for (DCA_Manager__c dcaMan : dcaList) {
					System.debug('::::dcaMan.Name:::' + dcaMan.Name);
					System.debug('::::dcaFilterMap.containsKey(dcaMan.Name):::' + dcaFilterMap.containsKey(dcaMan.Type__c + ': ' + dcaMan.Name));
					if (dcaFilterMap.containsKey(dcaMan.Type__c + ': ' + dcaMan.Name)) {
						System.debug('::::dcaFilterMap.get(dcaMan.Name):::' + dcaFilterMap.get(dcaMan.Type__c + ': ' + dcaMan.Name));
						for (objectFilterWrapper ofW : dcaFilterMap.get(dcaMan.Type__c + ': ' + dcaMan.Name)) {
							System.debug('::::ofW:::' + ofW);
							System.debug('::::ofW.filterList:::' + ofW.filterList);
							for (DCA_Filter__c dcaF : ofW.filterList) {
								System.debug('::::dcaF.Field__c:::' + dcaF.Field__c);
								System.debug('::::dcaF.Operator__c:::' + dcaF.Operator__c);
								System.debug('::::dcaF.Value__c:::' + dcaF.Value__c);

								if (! String.isEmpty(dcaF.Field__c) && ! String.isEmpty(dcaF.Operator__c) && dcaF.Operator__c != 'none' && ! String.isEmpty(dcaF.Value__c)) {
									dcaF.DCA_Manager__c = dcaMan.Id;
									dcaF.Object_Name__c = ofw.objectName;
									dcaF.Object_Label__c = ofw.objectRealLabel;
									dcaF.Field_Label__c = dcaF.Field__c.removeEnd('__c').replaceAll( '_', ' ');	
									dcaFilterList.add(dcaF);
								}
							}
						}
					}
				}

				if (! dcaFilterList.isEmpty()) {
					insert dcaFilterList;
				}
				
				String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
	   					'/apex/DataChangeApprovalCreationTab';
				PageReference pr = new PageReference(viewDataChangeURL);
				pr.getParameters().put('tabNumber', '3');
				
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Objects are not selected.'));
				return null;
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Managers are not selected.'));
			return null;
		}
	}
	
	public PageReference doCancel() { 
		String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/apex/DataChangeApprovalCreationTab';
		PageReference pr = new PageReference(viewDataChangeURL);
		pr.getParameters().put('tabNumber', '3');
		
		return pr;
	}
	
	public void doSearch() {
		if (! String.isEmpty(searchString)) {
			String likeSearch = '%' + searchString + '%';
			
			if (! allMembersSO.isEmpty()) {
				allMembersSO.clear();			
			}
			
			if (currentType == 'Profile') {
				List<String> selectedNames = new List<String>();
				List<DCA_Manager__c> dcaManagerList = [
					SELECT Id, Profile__c 
					FROM DCA_Manager__c 
					WHERE Profile__c != null]; 
				
				if (! dcaManagerList.isEmpty()) {
					for (DCA_Manager__c manager : dcaManagerList) {
						selectedNames.add(manager.Profile__c);
					}
				}
				List<Profile> profileList = [
					SELECT Id, Name 
					FROM Profile 
					WHERE Name NOT IN :selectedNames AND Name LIKE :likeSearch
					ORDER BY Name
					LIMIT 1000];
				if (! profileList.isEmpty()) {
					for (Profile pr : profileList) {
						allMembersSO.add(new SelectOption(pr.Id,'Profile: ' + pr.Name));
					}	
				}
			} else if (currentType == 'Public Group') {
	 			List<String> selectedNames = new List<String>();
	 			List<DCA_Manager__c> dcaManagerList = [
	 				SELECT Id, Public_Group__c 
	 				FROM DCA_Manager__c 
	 				WHERE Public_Group__c != null];
	 			if (! dcaManagerList.isEmpty()) {
					for (DCA_Manager__c manager : dcaManagerList) {
						selectedNames.add(manager.Public_Group__c);
					}
				}
				List<Group> pgList = [
					SELECT Id, Name 
					FROM Group 
					WHERE Name NOT IN :selectedNames AND Name LIKE :likeSearch
					ORDER BY Name
					LIMIT 1000];
				if (! pgList.isEmpty()) {
					for (Group pg : pgList) {
						if (pg.Name != null) {
							allMembersSO.add(new SelectOption(pg.Id,'Public Group: ' + pg.Name));
						}
					}	
				}
	 		} else if (currentType == 'UserRole') {
	 			List<String> selectedNames = new List<String>();
	 			List<DCA_Manager__c> dcaManagerList = [
	 				SELECT Id, UserRole__c 
	 				FROM DCA_Manager__c 
	 				WHERE UserRole__c != null];
	 			if (! dcaManagerList.isEmpty()) {
					for (DCA_Manager__c manager : dcaManagerList) {
						selectedNames.add(manager.UserRole__c);
					}
				}
				List<UserRole> urList = [
					SELECT Id, Name 
					FROM UserRole 
					WHERE Name NOT IN :selectedNames AND Name LIKE :likeSearch
					ORDER BY Name
					LIMIT 1000];
				if (! urList.isEmpty()) {
					for (UserRole ur : urList) {
						allMembersSO.add(new SelectOption(ur.Id,'UserRole: ' + ur.Name));
					}	
				}
	 		} else if (currentType == 'User') {
	 			List<String> selectedNames = new List<String>();
	 			List<DCA_Manager__c> dcaManagerList = [
	 				SELECT Id, User__c 
	 				FROM DCA_Manager__c 
	 				WHERE User__c != null];
	 			if (! dcaManagerList.isEmpty()) {
					for (DCA_Manager__c manager : dcaManagerList) {
						selectedNames.add(manager.User__c);
					}
				}
				List<User> userList = [
					SELECT Id, Name 
					FROM User 
					WHERE Name NOT IN :selectedNames AND Name LIKE :likeSearch
					ORDER BY Name
					LIMIT 1000];
				if (! userList.isEmpty()) {
					for (User user : userList) {
						allMembersSO.add(new SelectOption(user.Id,'User: ' + user.Name));
					}	
				}
	 		}
		}
	}

	public void addFilters() {

		if (! selectedMembersSO.isEmpty()) {
			if (selectedMembersSO.size() <= 150) {
				if (! selectedObjects.isEmpty()) {
					if (selectedObjects.size() <= 150) {
						isFilter = true;

						Boolean isAll = false;
						for (SelectOption so : selectedObjects) {
							if (so.getValue() == 'All') {
								isAll = true;
							}
						}

						if (isAll) {
							for (SelectOption so : selectedObjects) {
								if (so.getValue() != 'All') {
									if (so.getValue().split(';').size() > 1) {
										objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue().split(';').get(0)));
									} else {
										objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue()));
									}
								}
							}

							for (SelectOption so : availableObjects) {
								if (so.getValue().split(';').size() > 1) {
									objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue().split(';').get(0)));
								} else {
									objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue()));
								}
							}
						} else {
							for (SelectOption so : selectedObjects) {
								if (so.getValue().split(';').size() > 1) {
									objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue().split(';').get(0)));
								} else {
									objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue()));
								}
							}
						}
						

						for (SelectOption sm : selectedMembersSO) {
							List<objectFilterWrapper> objFilterList = new List<objectFilterWrapper>();

							if (isAll) {
								for (SelectOption so : selectedObjects) {
									if (so.getValue() != 'All') {
										objFilterList.add(new objectFilterWrapper(so.getValue()));
									}
								}

								for (SelectOption so : availableObjects) {
									objFilterList.add(new objectFilterWrapper(so.getValue()));
								}
							} else {
								for (SelectOption so : selectedObjects) {
									objFilterList.add(new objectFilterWrapper(so.getValue()));
								}
							}

							dcaFilterMap.put(sm.getLabel(), objFilterList);
						}
					} else {
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select no more than ten objects.'));
					}
				} else {
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Objects are not selected.'));
				}
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select no more than ten managers.'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Managers are not selected.'));
		}
	}

	public List<SelectOption> getObjectFields(String objLabel) {
		List<SelectOption> objectFieldsSOList = new List<SelectOption>();
		List<Schema.FieldSetMember> sFields = new List<Schema.FieldSetMember>();
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult objResult = mapSObjects.get(objectNamesMap.get(objLabel)).getDescribe();

		if (objResult.fieldSets.getMap().get('ApprovalFieldSet') != null) {
			sFields = objResult.fieldSets.getMap().get('ApprovalFieldSet').getFields();
		}
		
		for (Schema.FieldSetMember fsMem : sFields) {
			objectFieldsSOList.add(new SelectOption(fsMem.getFieldPath(), fsMem.getLabel()));
		}

		return objectFieldsSOList;
	}

	public void addNewFilter() {
		String mnger = ApexPages.currentPage().getParameters().get('mnger');
		String obj = ApexPages.currentPage().getParameters().get('obj');
		
		if (dcaFilterMap.containsKey(mnger)) {
			for (objectFilterWrapper ofWrp : dcaFilterMap.get(mnger)) {
				if (ofWrp.objectName == obj) {
					ofWrp.filterList.add(new DCA_Filter__c());
					break;
				}
			}
		} 
	}

	public class objectFilterWrapper {
		public String objectName {get; set;}
		public String objectLabel {get; set;}
		public String objectRealLabel {get; set;}
		public List<DCA_Filter__c> filterList {get; set;}

		public objectFilterWrapper(String objName) {
			objectName = objName;
			if (objName.split(';').size() > 1) {
				objectLabel = objName.split(';').get(0) + ' (' + objName.split(';').get(1) + ')';
				objectRealLabel = objName.split(';').get(0);
			} else {
				objectLabel = objName;	
				objectRealLabel = objName;	
			}

			filterList = new List<DCA_Filter__c>();
			filterList.add(new DCA_Filter__c());
		}
	}
}
public class DCA_EditManagerCtrl {
	public DCA_Manager__c dcaManager {get; set;}
	public SelectOption[] availableObjects {get; set;}
	public SelectOption[] selectedObjects {get; set;}
	public String searchString {get; set;}
	Set<String> selObjectsSet {get; set;}

	public List<objectFilterWrapper> dcaFilterWrapperList {get; set;}
	public Boolean isFilter {get; set;}
	public List<SelectOption> operationList {get; set;}
	public Map<String, List<SelectOption>> objectFieldsMap {get; set;}
	public Map<String, String> objectNamesMap;
	public List<DCA_Filter__c> dcaFilterList;
	
	public DCA_EditManagerCtrl() {
		availableObjects = new List<SelectOption>();
		selectedObjects = new List<SelectOption>();
		selObjectsSet = new Set<String>();
		dcaFilterWrapperList = new List<objectFilterWrapper>();
		objectFieldsMap = new Map<String, List<SelectOption>>();
		objectNamesMap = new Map<String, String>();
		dcaFilterList = new List<DCA_Filter__c>();

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

        isFilter = false;
	}
	
	public void init() {
		String recordId = ApexPages.currentPage().getParameters().get('mId');
		if (recordId != null) {
			List<DCA_Manager__c> dcaManagerList = [
				SELECT Id, Name, Type__c, Objects__c
				FROM DCA_Manager__c
				WHERE Id =: recordId
			];
			
			if (! dcaManagerList.isEmpty()) {
				dcaManager = dcaManagerList.get(0);
			}
			
			List<String> selObjects = dcaManager.Objects__c.split(',');
			for (String obj : selObjects) {
				if (obj.split(';').size() > 1) {
					selectedObjects.add(new SelectOption(obj,obj.split(';').get(0) + ' (' + obj.split(';').get(1) + ')'));
				} else {
					selectedObjects.add(new SelectOption(obj,obj));
				}
				selObjectsSet.add(obj);
				
			}
			displayObjects();
		}
	} 
	
	public void displayObjects() {
		Boolean isAll = false;
		for (SelectOption so : selectedObjects) {
			if (so.getLabel() == 'All') {
				isAll = true;
			}
		}
		if (isAll == false) {
			availableObjects.add(new SelectOption('All','All'));	
		}
		
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
			
			Boolean isObject = false;
			for (SelectOption so : selectedObjects) {
				if (objectLabel == so.getLabel()) {
					isObject = true;
					break;
				}
			}
			if (isObject == false) {
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
										if (! selObjectsSet.contains(objectLabel + ';' + recType)) {
											availableObjects.add(new SelectOption(objectLabel + ';' + recType,objectLabel + ' (' + recType + ')'));	
										}
									}
								}
							} else {
								if (! selObjectsSet.contains(objectLabel)) {
									availableObjects.add(new SelectOption(objectLabel,objectLabel));
								}
							}
						} else {
							if (! selObjectsSet.contains(objectLabel)) {
								availableObjects.add(new SelectOption(objectLabel,objectLabel));	
							}
						}
					}
				}
			}
		}
	}
	
	public PageReference doSave() {
		if (! selectedObjects.isEmpty()) {
			dcaManager.Objects__c = '';
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
			update dcaManager;

			if (! dcaFilterList.isEmpty()) {
				delete dcaFilterList;
			}
			
			List<DCA_Filter__c> dcaFilterUpdateList = new List<DCA_Filter__c>();
			for (objectFilterWrapper ofW : dcaFilterWrapperList) {
				for (DCA_Filter__c dcaF : ofW.filterList) {
					DCA_Filter__c newFilter = new DCA_Filter__c();
					
					if (! String.isEmpty(dcaF.Field__c) && ! String.isEmpty(dcaF.Operator__c) && dcaF.Operator__c != 'none' && ! String.isEmpty(dcaF.Value__c)) {
						newFilter.Field__c = dcaF.Field__c;
						newFilter.Operator__c = dcaF.Operator__c;
						newFilter.Value__c = dcaF.Value__c; 
						newFilter.DCA_Manager__c = dcaManager.Id;
						newFilter.Object_Name__c = ofw.objectName;
						newFilter.Object_Label__c = ofw.objectRealLabel;
						newFilter.Field_Label__c = dcaF.Field__c.removeEnd('__c').replaceAll( '_', ' ');	
						dcaFilterUpdateList.add(newFilter);
					}
				}
			}

			if (! dcaFilterUpdateList.isEmpty()) {
				insert dcaFilterUpdateList;
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
	}
	
	public PageReference doCancel() {
		String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/apex/DataChangeApprovalCreationTab';
   					
		PageReference pr = new PageReference(viewDataChangeURL);
		pr.getParameters().put('tabNumber', '3');
				
		return pr;
	}

	public void addFilters() {
		if (! selectedObjects.isEmpty()) {
			if (selectedObjects.size() <= 10) {
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
							System.debug('::::so.getValue():::::' + so.getValue());
							objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue().split(';').get(0)));
						} else {
							objectFieldsMap.put(so.getValue(), getObjectFields(so.getValue()));
						}
					}	
				}

				Map<String, List<DCA_Filter__c>> dcaFilterMap = new Map<String, List<DCA_Filter__c>>();
				dcaFilterList = new List<DCA_Filter__c>([
					SELECT Object_Name__c, Field__c, Operator__c, Value__c, Field_Label__c
	                FROM DCA_Filter__c
	                WHERE DCA_Manager__c =:dcaManager.Id AND Object_Name__c = :objectFieldsMap.keySet()
	                LIMIT 1000 
				]);

				if (! dcaFilterList.isEmpty()) {
					for (DCA_Filter__c dcaF : dcaFilterList) {
						if (! dcaFilterMap.containsKey(dcaF.Object_Name__c)) {
							List<DCA_Filter__c> newDCAFilterList = new List<DCA_Filter__c>{dcaF};
							dcaFilterMap.put(dcaF.Object_Name__c, newDCAFilterList);
						} else {
							dcaFilterMap.get(dcaF.Object_Name__c).add(dcaF);
						}
					}
				}

				if (isAll) {
					for (SelectOption so : selectedObjects) {
						if (so.getValue() != 'All') {
							if (dcaFilterMap.containsKey(so.getValue())) {
								dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), dcaFilterMap.get(so.getValue())));	
							} else {
								dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), new List<DCA_Filter__c>()));
							}
						}
					}

					for (SelectOption so : availableObjects) {
						if (dcaFilterMap.containsKey(so.getValue())) {
							dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), dcaFilterMap.get(so.getValue())));	
						} else {
							dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), new List<DCA_Filter__c>()));
						}
					}
				} else {
					for (SelectOption so : selectedObjects) {
						if (dcaFilterMap.containsKey(so.getValue())) {
							dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), dcaFilterMap.get(so.getValue())));	
						} else {
							dcaFilterWrapperList.add(new objectFilterWrapper(so.getValue(), new List<DCA_Filter__c>()));
						}
					}
				}
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select no more than ten objects.'));
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Objects are not selected.'));
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
		
		String obj = ApexPages.currentPage().getParameters().get('obj');

		for (objectFilterWrapper ofWrp : dcaFilterWrapperList) {
			if (ofWrp.objectName == obj) {
				ofWrp.filterList.add(new DCA_Filter__c());
				break;
			}
		}
	}

	public void removeFilter() {
		String obj = ApexPages.currentPage().getParameters().get('obj');
		String fltr = ApexPages.currentPage().getParameters().get('fltr');

		objectFilterWrapper updateOFWrapper;
		for (objectFilterWrapper ofWrp : dcaFilterWrapperList) {
			if (ofWrp.objectName == obj) {
				updateOFWrapper = ofWrp;
				break;
			}
		}		

		if (updateOFWrapper != null) {
			updateOFWrapper.filterList.remove(Integer.valueOf(fltr) - 1);
			// for (Integer i = 0; i < updateOFWrapper.filterList.size(); i++) {
			// 	if (updateOFWrapper.filterList.get(i).Id == fltr) {
		 //   	        updateOFWrapper.filterList.remove(i);
			// 		break;
			// 	}
			// }
		}
	}

	public class objectFilterWrapper {
		public String objectName {get; set;}
		public String objectLabel {get; set;}
		public String objectRealLabel {get; set;}
		public List<DCA_Filter__c> filterList {get; set;}

		public objectFilterWrapper(String objName, List<DCA_Filter__c> dcaFilterList) {
			objectName = objName;
			if (objName.split(';').size() > 1) {
				objectLabel = objName.split(';').get(0) + ' (' + objName.split(';').get(1) + ')';
				objectRealLabel = objName.split(';').get(0);
			} else {
				objectLabel = objName;	
				objectRealLabel = objName;
			}
			
			filterList = new List<DCA_Filter__c>();
			if (! dcaFilterList.isEmpty()) {
				filterList.addAll(dcaFilterList);
			} else {
				filterList.add(new DCA_Filter__c());
			}
		}
	}
}
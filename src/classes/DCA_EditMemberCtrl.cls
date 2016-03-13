public class DCA_EditMemberCtrl {
	public DCA_Member__c dcaMember {get; set;}
	public SelectOption[] availableObjects {get; set;}
	public SelectOption[] selectedObjects {get; set;}
	Set<String> selObjectsSet {get; set;}

	
	public DCA_EditMemberCtrl() {
		availableObjects = new List<SelectOption>();
		selectedObjects = new List<SelectOption>();
		selObjectsSet = new Set<String>();
	}
	
	public void init() {
		String recordId = ApexPages.currentPage().getParameters().get('mId');
		if (recordId != null) {
			List<DCA_Member__c> dcaMemberList = [
				SELECT Id, Name, Type__c, Objects__c
				FROM DCA_Member__c
				WHERE Id =: recordId
			];
			
			if (! dcaMemberList.isEmpty()) {
				dcaMember = dcaMemberList.get(0);
			}
			
			List<String> selObjects = dcaMember.Objects__c.split(',');
			for (String obj : selObjects) {
				selectedObjects.add(new SelectOption(obj,obj));
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
			
			// Boolean isObject = false;
			// for (SelectOption so : selectedObjects) {
			// 	if (objectLabel == so.getLabel()) {
			// 		isObject = true;
			// 		break;
			// 	}
			// }
			// if (isObject == false) {
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
							System.debug(dcaObjectMap);
							System.debug(objectName);

							recTypes = dcaObjectMap.get(objectName).split(',', -2);

							if (! recTypes.isEmpty()) {
								for (String recType : recTypes) {
									if(recType == '[All]') {
										continue;
									}
									if (recType == 'None') {
										availableObjects.add(new SelectOption(objectLabel,objectLabel));		
									} else if (! selObjectsSet.contains(objectLabel + ' (' + recType + ')')) {
										availableObjects.add(new SelectOption(objectLabel + ';' + recType, objectLabel + ' (' + recType + ')'));	
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
			// }
		}
	}
	
	public PageReference doSave() {
		if (! selectedObjects.isEmpty()) {
			if (selectedObjects.size() <= 10) {
				dcaMember.Objects__c = '';
				String selObjects = '';
				for (SelectOption obj : selectedObjects) {
					if (obj.getLabel() == 'All') {
						dcaMember.Objects__c = 'All';
						break;
					} else {
						selObjects += obj.getLabel() + ',';
					}
				}
				
				if (dcaMember.Objects__c != 'All') {
					selObjects = selObjects.removeEnd(',');
					dcaMember.Objects__c = selObjects;
				}
				update dcaMember;
				
				String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
	   					'/apex/DataChangeApprovalCreationTab';
	   					
				PageReference pr = new PageReference(viewDataChangeURL);
				pr.getParameters().put('tabNumber', '2');
						
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select no more than ten objects.'));
				return null;
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Objects are not selected.'));
			return null;
		}
	}
	
	public PageReference doCancel() {
		String viewDataChangeURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/apex/DataChangeApprovalCreationTab';
   					
		PageReference pr = new PageReference(viewDataChangeURL);
		pr.getParameters().put('tabNumber', '2');
				
		return pr;
	}
}
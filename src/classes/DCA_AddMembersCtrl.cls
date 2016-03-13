public class DCA_AddMembersCtrl {
	public String currentType {get; set;}
	public SelectOption[] allTypes {get; set;}
	public SelectOption[] allMembersSO {get; set;}
	public SelectOption[] selectedMembersSO {get; set;}
	public SelectOption[] availableObjects {get; set;}
	public SelectOption[] selectedObjects {get; set;}
	public String searchString {get; set;}

	public Boolean allRecTypeSelected {get; set;}
		
	public DCA_AddMembersCtrl() {
		allMembersSO = new List<SelectOption>();
		selectedMembersSO = new List<SelectOption>();
		availableObjects = new List<SelectOption>();
		selectedObjects = new List<SelectOption>();
		
		allTypes = new List<SelectOption> {
            new SelectOption('Profile','Profile'), 
            new SelectOption('Public Group','Public Group'), 
            new SelectOption('UserRole','UserRole'), 
            new SelectOption('User','User') 
        };
        
        currentType = 'Profile';

        allRecTypeSelected = true;
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
								availableObjects.add(new SelectOption(objectLabel + ';' + recType,objectLabel + ' (' + recType + ')'));	
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
			List<DCA_Member__c> dcaMemberList = [
				SELECT Id, Profile__c 
				FROM DCA_Member__c 
				WHERE Profile__c != null]; 
			
			if (! dcaMemberList.isEmpty()) {
				for (DCA_Member__c member : dcaMemberList) {
					selectedNames.add(member.Profile__c);
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
 			List<DCA_Member__c> dcaMemberList = [
 				SELECT Id, Public_Group__c 
 				FROM DCA_Member__c 
 				WHERE Public_Group__c != null];
 			if (! dcaMemberList.isEmpty()) {
				for (DCA_Member__c member : dcaMemberList) {
					selectedNames.add(member.Public_Group__c);
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
 			List<DCA_Member__c> dcaMemberList = [
 				SELECT Id, UserRole__c 
 				FROM DCA_Member__c 
 				WHERE UserRole__c != null];
 			if (! dcaMemberList.isEmpty()) {
				for (DCA_Member__c member : dcaMemberList) {
					selectedNames.add(member.UserRole__c);
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
 			List<DCA_Member__c> dcaMemberList = [
 				SELECT Id, User__c 
 				FROM DCA_Member__c 
 				WHERE User__c != null];
 			if (! dcaMemberList.isEmpty()) {
				for (DCA_Member__c member : dcaMemberList) {
					selectedNames.add(member.User__c);
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
		System.debug('======' + selectedMembersSO);
		System.debug(allMembersSO);
		if (! selectedMembersSO.isEmpty()) {
			if (selectedMembersSO.size() <= 150) {
				if (! selectedObjects.isEmpty()) {
					if (selectedObjects.size() <= 150) {
						List<DCA_Member__c> dcaList = new List<DCA_Member__c>();
						for (SelectOption so : selectedMembersSO) {
							String memName = so.getValue();
							String[] label = so.getLabel().split(':', 2);
							String memType = label.get(0);
							
							DCA_Member__c dcaMember = new DCA_Member__c();
							dcaMember.Name = label.get(1);
							if (memType == 'Profile') {
								dcaMember.Profile__c = memName;
								dcaMember.Type__c = 'Profile';
							} else if (memType == 'Public Group') {
								dcaMember.Public_Group__c = memName;
								dcaMember.Type__c = 'Public Group';
							} else if (memType == 'UserRole') {
								dcaMember.UserRole__c = memName;
								dcaMember.Type__c = 'UserRole';
							} else if (memType == 'User') {
								dcaMember.User__c = memName;
								dcaMember.Type__c = 'User';
							}
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
							
							dcaList.add(dcaMember);
						} 
						
						insert dcaList;
						
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
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You can select no more than ten members.'));
				return null;
			}
		} else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Members are not selected.'));
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
	
	public void doSearch() {
		if (! String.isEmpty(searchString)) {
			String likeSearch = '%' + searchString + '%';
			
			if (! allMembersSO.isEmpty()) {
				allMembersSO.clear();			
			}
			
			if (currentType == 'Profile') {
				List<String> selectedNames = new List<String>();
				List<DCA_Member__c> dcaMemberList = [
					SELECT Id, Profile__c 
					FROM DCA_Member__c 
					WHERE Profile__c != null]; 
				
				if (! dcaMemberList.isEmpty()) {
					for (DCA_Member__c member : dcaMemberList) {
						selectedNames.add(member.Profile__c);
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
	 			List<DCA_Member__c> dcaMemberList = [
	 				SELECT Id, Public_Group__c 
	 				FROM DCA_Member__c 
	 				WHERE Public_Group__c != null];
	 			if (! dcaMemberList.isEmpty()) {
					for (DCA_Member__c member : dcaMemberList) {
						selectedNames.add(member.Public_Group__c);
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
	 			List<DCA_Member__c> dcaMemberList = [
	 				SELECT Id, UserRole__c 
	 				FROM DCA_Member__c 
	 				WHERE UserRole__c != null];
	 			if (! dcaMemberList.isEmpty()) {
					for (DCA_Member__c member : dcaMemberList) {
						selectedNames.add(member.UserRole__c);
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
	 			List<DCA_Member__c> dcaMemberList = [
	 				SELECT Id, User__c 
	 				FROM DCA_Member__c 
	 				WHERE User__c != null];
	 			if (! dcaMemberList.isEmpty()) {
					for (DCA_Member__c member : dcaMemberList) {
						selectedNames.add(member.User__c);
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
}
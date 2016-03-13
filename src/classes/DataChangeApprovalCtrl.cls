public class DataChangeApprovalCtrl { 
	public String objectName {get; set;}
	public String objectLabel {get; set;}
	Schema.SObjectType selectedObject;
	
	public List<Schema.FieldSetMember> objectFields {get; set;}
	public List<Schema.SObjectField> objectAllFields {get; set;}
	public Set<Schema.SObjectField> objectStaticFields {get; set;}
	public sObject record {get; set;}
	public String recordName {get; set;}
	public sObject oldRecord {get; set;}
	public sObject originalRecord {get; set;}
	public sObject cloneRecord;	
	public List<fieldWrapper> objectWrapperFields {get; set;}
	
	public Boolean approved {get; set;}
	
	public String recordId;
	public String userId;
    public String userEmail;
    public Integer countFieldsChanged;
    public Integer countFieldsApproved;
    public Set<String> names;
    public Set<String> staticNames;
    public List<String> comments;
    public String fieldLookup;
    public String keyPrefix;
    
    public String globalComment {get; set;}

	public DataChangeApprovalCtrl() {
		objectWrapperFields = new List<fieldWrapper>();
		names = new Set<String>();
		staticNames = new Set<String>();
		objectStaticFields = new Set<Schema.SObjectField>();
		countFieldsChanged = 0;
		countFieldsApproved = 0;
		comments = new List<String>();
		recordId = ApexPages.currentPage().getParameters().get('id');
		approved = true;
		
		if (recordId != null) {
			ID objectId = recordId;
			
			objectName = objectId.getSObjectType().getDescribe().getName();
			objectLabel = objectId.getSObjectType().getDescribe().getLabel();
			keyPrefix = objectId.getSObjectType().getDescribe().getKeyPrefix();
			objectAllFields = objectId.getSObjectType().getDescribe().fields.getMap().values();
		} /*else {
			objectName = stdController.getRecord().getSObjectType().getDescribe().getName();
			objectLabel = stdController.getRecord().getSObjectType().getDescribe().getLabel();
			keyPrefix = stdController.getRecord().getSObjectType().getDescribe().getKeyPrefix();
			objectAllFields = stdController.getRecord().getSObjectType().getDescribe().fields.getMap().values();
		}*/
		
		Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
		objectFields =  mapSObjects.get(objectName).getDescribe().fieldSets.getMap().get('ApprovalFieldSet').getFields();
		
		
		
		for (Schema.FieldSetMember fs : objectFields) {
			names.add(fs.getFieldPath());
		}
		
		for (Schema.SObjectField fr : objectAllFields) {
			Schema.DescribeFieldResult fldResult = fr.getDescribe();

			if ((! names.contains(fldResult.getName())) && (fldResult.isUpdateable()) && fldResult.getName() != 'Clone_Record_Id__c' &&
					fldResult.getName() != 'Original_Record_Id__c' && fldResult.getName() != 'Is_cloned__c' && fldResult.getName() != 'Is_locked__c' &&
					fldResult.getName() != 'Staff_User_email__c' && fldResult.getName() != 'Parent_Record__c' &&
			   		 (! fldResult.isAutoNumber()) && (! fldResult.isDefaultedOnCreate())) {
				objectStaticFields.add(fr);
				staticNames.add(fldResult.getName());
			}		
		} 

		if ( ! String.isEmpty(objectName)) {

			selectedObject = mapSObjects.get(objectName);	
			
			record = selectedObject.newSObject();
			oldRecord = selectedObject.newSObject();
			originalRecord = selectedObject.newSObject();
			cloneRecord = selectedObject.newSObject();
			
			for (Schema.FieldSetMember f : objectFields) {
				objectWrapperFields.add(new fieldWrapper(f));
			}
			
			if (objectName.endsWith('c')) {
				fieldLookup = objectName;
			} else {
				fieldLookup = objectName + '__c';
			}
			
			init();
		}
	}
	
	public void init() {
		
    	userId = UserInfo.getUserId();
   		userEmail = UserInfo.getUserEmail();	

        if (! String.isEmpty(recordId)) {
        	String queryString;
        	queryString = 'SELECT ';
        	for(Schema.FieldSetMember f : objectFields) {
		        queryString += f.getFieldPath() + ', ';
		    }
		    for (Schema.SObjectField fr : objectStaticFields) {
		    	queryString += fr.getDescribe().getName() + ', ';
		    }
		    if ((! names.contains('Name')) && (! staticNames.contains('Name'))) {
		    	queryString += 'Name, ';
		    }
		    queryString += 'Clone_Record_Id__c, Original_Record_Id__c, Is_cloned__c, Is_locked__c, Staff_User_email__c, Id FROM '+ objectName;
		    queryString += ' WHERE Id = \'' + recordId + '\'' + ' LIMIT 1';

	    	List<sObject> records = Database.query(queryString);
	    	
	    	/*List<sObject> records = [
	    		SELECT Id, Name
	    		FROM Item__c
	    		WHERE Id = :recordId
	    	];*/
	    	
             
             if (! records.isEmpty()) {
				this.record = records.get(0);
				if (record.get('Is_locked__c') == true || record.get('Is_cloned__c') == true) {
					approved = true;
				} else {
					approved = false;
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This record has been already approved.'));
				}
			 } else {
			 	approved = false;
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This record has been already approved.'));
			 }
			 
		/*	 if (record.get('Clone_Record_Id__c') != null) {
			 	
			 	queryString = 'SELECT ';
		    	for(Schema.FieldSetMember f : objectFields) {
		      		queryString += f.getFieldPath() + ', ';
		    	}
		    	for (Schema.SObjectField fr : objectStaticFields) {
		    		queryString += fr.getDescribe().getName() + ', ';
		    	}
		    	if ((! names.contains('Name')) && (! staticNames.contains('Name'))) {
		    		queryString += 'Name, ';
		    	}
			    queryString += 'Clone_Record_Id__c, Original_Record_Id__c, Is_cloned__c, Is_locked__c, Staff_User_email__c, Id FROM '+ objectName;
			    queryString += ' WHERE Id = \'' + record.get('Clone_Record_Id__c') + '\'' + ' LIMIT 1';
	
		    	List<sObject> oldRecords = Database.query(queryString);
             
			 	if (! oldRecords.isEmpty()) {
			 		oldRecord = oldRecords.get(0);
			 	}	
			 	
			 	checkChanges(record, oldRecord);
			 } else {*/
			 	if (record.get('Original_Record_Id__c') != null) {
				 	queryString = 'SELECT ';
			       	for(Schema.FieldSetMember f : objectFields) {
		        		queryString += f.getFieldPath() + ', ';
		    		}
		    		for (Schema.SObjectField fr : objectStaticFields) {
		    			queryString += fr.getDescribe().getName() + ', ';
		    		}
		    		if ((! names.contains('Name')) && (! staticNames.contains('Name'))) {
		    			queryString += 'Name, ';
		    		}
				    queryString += 'Clone_Record_Id__c, Original_Record_Id__c, Is_cloned__c, Is_locked__c, Staff_User_email__c, Id FROM '+ objectName;
				    queryString += ' WHERE Id = \'' + record.get('Original_Record_Id__c') + '\'' + ' LIMIT 1';
	
		    	List<sObject> oldRecords = Database.query(queryString);	
             
			 		if (! oldRecords.isEmpty()) {
			 			oldRecord = oldRecords.get(0);
			 		}	
			 		
			 		checkChanges(record, oldRecord);
			 	} 		 				 	
	//		}

			if (record.get('Original_Record_Id__c') != null) {
				
			 	queryString = 'SELECT ';
		    	for(Schema.FieldSetMember f : objectFields) {
		        	queryString += f.getFieldPath() + ', ';
		    	}
		    	for (Schema.SObjectField fr : objectStaticFields) {
		    		queryString += fr.getDescribe().getName() + ', ';
		   		}
		   		if ((! names.contains('Name')) && (! staticNames.contains('Name'))) {
		    		queryString += 'Name, ';
		   		}	
			    queryString += 'Clone_Record_Id__c, Original_Record_Id__c, Is_cloned__c, Is_locked__c, Staff_User_email__c, Id FROM '+ objectName;
			    queryString += ' WHERE Id = \'' + record.get('Original_Record_Id__c') + '\'' + ' LIMIT 1';

		    	List<sObject> originalRecords = Database.query(queryString);
             
				if (! originalRecords.isEmpty()) {
			 		originalRecord = originalRecords.get(0);
				}		
		 	}
			
		 	recordName = String.ValueOf(record.get('Name'));
		} 
	} 
	
/*	public PageReference doSubmit() {
		if (recordId != null) { 
			if (record.get('Is_locked__c') != true) {
				String queryString = 'SELECT Is_locked__c, Original_Record_Id__c, ';
				queryString += 'Id FROM ' + objectName; 
				queryString += ' WHERE Id = \'' + recordId + '\'' + ' LIMIT 1';
				
				sObject lockRecord = Database.query(queryString);
	
	         	if (lockRecord.get('Original_Record_Id__c') != null) {
	         		lockRecord.put('Is_cloned__c', false);	
	         	}	
	         	lockRecord.put('Is_locked__c', true);
				update lockRecord;
				if (lockRecord.get('Original_Record_Id__c') != null) {
	         		lockRecord.put('Is_cloned__c', true);
					update lockRecord;	
	         	}			
					
		    	if (record.get('Original_Record_Id__c') == null && record.get('Clone_Record_Id__c') == null) {		    	
		    		relationsStatic(cloneRecord,record );
		    		relations(cloneRecord,record );
		    		cloneRecord.put('Original_Record_Id__c', record.get('Id'));
					cloneRecord.put('Is_locked__c', false);	   
					cloneRecord.put('Is_cloned__c', true);
					cloneRecord.put('Staff_User_email__c', userEmail);		    			    	
		   			cloneRecord.put('Parent_Record__c', record.get('Name'));
		    	
		    		insert cloneRecord;
					
						SObject recordActivity = new Data_Change_Activity__c(); 
						recordActivity.put('User__c', userInfo.getUserId());
						recordActivity.put(fieldLookup, record.Id);
						recordActivity.put('Message__c', 'Request for changes.');
				
					queryString = 'SELECT ';
				    	for(Schema.FieldSetMember f : objectFields) {
				        	queryString += f.getFieldPath() + ', ';
					    }
				    queryString += 'Id FROM '+ objectName;
				    queryString += ' WHERE Id = \'' + recordId + '\'' + ' LIMIT 1';
	
			    	sObject rec = Database.query(queryString);
		         		
		     		checkChangesForProductActivity (recordActivity, record, rec, false);
					
					insert recordActivity;
				    	
		    		sendEmail('toManager', cloneRecord.Id);  
				    		
		    		String recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
		   					'/' + record.Id;
					PageReference pr = new PageReference(recordURL); 
				    	
					return pr;	
				
		    	} else if (record.get('Original_Record_Id__c') != null && record.get('Clone_Record_Id__c') == null) {
		    		relationsStatic(cloneRecord,record );
		    		relations(cloneRecord,record );
		    		
		    		cloneRecord.put('Original_Record_Id__c', record.get('Original_Record_Id__c'));
		    		cloneRecord.put('Clone_Record_Id__c', record.get('Id'));
					cloneRecord.put('Is_locked__c', false);	   
					cloneRecord.put('Is_cloned__c', true);
					cloneRecord.put('Staff_User_email__c', userEmail);		    			    	
			   				
		    		 
		    		queryString = 'SELECT Name, ';
					queryString += 'Id FROM ' + objectName; 
					queryString += ' WHERE Id = \'' + record.get('Original_Record_Id__c') + '\'' + ' LIMIT 1';
					
					sObject recName = Database.query(queryString);
					
		    		cloneRecord.put('Parent_Record__c', recName.get('Name'));
		    	
		    		insert cloneRecord;
			    	
		    		sendEmail('toManager', String.valueOf(cloneRecord.get('Id')));
		    		
		    		String recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
		   				'/' + record.get('Original_Record_Id__c');
					PageReference pr = new PageReference(recordURL);   
				    	
					return pr;
		    } else {
	    		record.put('Is_cloned__c', false);
	    		update record;
	    		record.put('Is_cloned__c', true);
	    		update record;
	    		
	    		sendEmail('toManager', String.valueOf(record.get('Id')));
	    		
	    		String recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
	   				'/' + record.get('Original_Record_Id__c');
	    		PageReference pr = new PageReference(recordURL);  
			    	
				return pr;  
			}
	    		
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This record is already waiting for the approval of the requested changes.'));
				return null;	
			}
		} else {
			record.put('Is_locked__c', true);
			record.put('Staff_User_email__c', userEmail);
			insert record;
			
			SObject recordActivity = new Data_Change_Activity__c(); 
				recordActivity.put('User__c', userInfo.getUserId());
				recordActivity.put(fieldLookup, record.get('Id'));
				recordActivity.put('Message__c', 'Request for creation.');
			
			insert recordActivity;
			
			sendEmail('toManagerCreate', String.valueOf(record.get('Id')));
			
			String recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   						'/' + record.get('Id');
    		PageReference pr = new PageReference(recordURL);  
		    	
			return pr; 
		}	
	}*/
	
	public Boolean checkUserPermissions() {
		Boolean isManager = false;

		String dcaObjectRecTypes = '';
        List<DCA_Object__c> dcaObjList = new List<DCA_Object__c>();
        dcaObjList = [
            SELECT Name, Record_Types__c
            FROM DCA_Object__c
            WHERE Name = :objectName
            LIMIT 1
        ];

        if (! dcaObjList.isEmpty()) {
            dcaObjectRecTypes = dcaObjList.get(0).Record_Types__c;
        }

		Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([
            SELECT Id, Name, SobjectType
            FROM RecordType
            WHERE SobjectType = :objectName
        ]);

		String userRoleName = ''; 
		String userName = userInfo.getUserId();
		 
		if (userInfo.getUserRoleId() != null) {
			userRoleName = [SELECT Name FROM UserRole WHERE Id = :userInfo.getUserRoleId()].Id;	
		}
		
        String userProfileName = [SELECT Name FROM Profile WHERE Id = :userInfo.getProfileId()].Id;
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

        List<DCA_Manager__c> dcaManagerList = new List<DCA_Manager__c>();

		String queryString = 'SELECT Id, Public_Group__c, UserRole__c, User__c, Profile__c, Objects__c';
		queryString += ' FROM DCA_Manager__c';
		queryString += ' WHERE Profile__c =:userProfileName OR User__c = :userName OR Public_Group__c IN :userGroupId';
		if (! String.isEmpty(userRoleName)) {
			queryString +=	' OR UserRole__c = :userRoleName ';
		}
			
		dcaManagerList = Database.query(queryString);

        Set<Id> mngerIdSet = new Set<Id>();
        if (! dcaManagerList.isEmpty()) {

        	if (dcaObjectRecTypes == 'All') {
        		String objRecTypeName = objectLabel + ';All'; 
                for (DCA_Manager__c dcaM : dcaManagerList) {
                	mngerIdSet.add(dcaM.Id);

                	if (dcaM.Objects__c == 'All') {
                		isManager = true;
                	} else {
                		List<String> objList = new List<String>();
	                    objList = dcaM.Objects__c.split(',');

	                    Set<String> objSet = new Set<String>();
	                    objSet.addAll(objList);
	                    
	                    if (objSet.contains(objRecTypeName)) {
	                        isManager = true;
	                        break;
	                    }
                	}
                }
            } else if (dcaObjectRecTypes == 'None') {
            	for (DCA_Manager__c dcaM : dcaManagerList) {
            		mngerIdSet.add(dcaM.Id);

            		if (dcaM.Objects__c == 'All') {
                		isManager = true;
                	} else {
                		List<String> objList = new List<String>();
	                    objList = dcaM.Objects__c.split(',');

	                    Set<String> objSet = new Set<String>();
	                    objSet.addAll(objList);
	                    
	                    if (objSet.contains(objectLabel)) {
	                        isManager = true;
	                        break;
	                    }
                	}
                }
        	} else {
            	String objRecTypeName = objectLabel + ';' + recTypeMap.get(String.valueOf(record.get('RecordTypeId'))).Name; 
	        	for (DCA_Manager__c dcaM : dcaManagerList) {
	        		if (dcaM.Objects__c == 'All') {
	            		isManager = true;
	            	} else {
		        		mngerIdSet.add(dcaM.Id);
			        	if (dcaM.Objects__c.contains(objRecTypeName)) {
			        		isManager = true;
			        		break;
			        	}
			        }
		        }
            }
        }

        Boolean isFilter = true;
        Map<String, Schema.SObjectField> objectFilterFields = this.record.getSObjectType().getDescribe().fields.getMap();
        
        System.debug(':::::isManager::::' + isManager);
        if (isManager) {
        	String labelForFilters = objectLabel;
        	System.debug(':::::objectLabel::::' + objectLabel);
        	if (dcaObjectRecTypes == 'All') {
        		labelForFilters += ';All';
        	} else {
        		if(objectFilterFields.containsKey('RecordTypeId')) {
        			System.debug(':::::labelForFilters:1:::' + labelForFilters);
        			String recType = recTypeMap.get(String.valueOf(record.get('RecordTypeId'))) != null ? ';' + recTypeMap.get(String.valueOf(record.get('RecordTypeId'))).Name : '';
        			labelForFilters += recType;
        			System.debug(':::::labelForFilters:2:::' + labelForFilters);
        		}
        	}

 			System.debug(':::::mngerIdSet::::' + mngerIdSet);
 			System.debug(':::::labelForFilters::::' + labelForFilters);

        	List<DCA_Filter__c> dcaFilterList = new List<DCA_Filter__c>([
                SELECT Object_Name__c, Field__c, Operator__c, Value__c, DCA_Manager__c
                FROM DCA_Filter__c
                WHERE DCA_Manager__c IN :mngerIdSet AND Object_Name__c = :labelForFilters
                LIMIT 1000
            ]);
            System.debug(':::::dcaFilterList::::' + dcaFilterList);

            if (! dcaFilterList.isEmpty()) {
                for (DCA_Filter__c dcaF : dcaFilterList) {
                    if (! checkFilterForRecord(this.record, dcaF, objectFilterFields)) {
                        isFilter = false;
                    }
                }
            } else {
                isFilter = true;
            }
        }

        return isFilter;


   //  	List<String> selectedProfiles = new List<String>();
   //  	List<String> selectedPubGroups = new List<String>();
   //  	List<String> selectedUserRoles = new List<String>();
   //  	Set<String> selectedUsers = new Set<String>();
    	
   //  	List<DCA_Manager__c> dcaManagerList = [
 		// 	SELECT Id, Public_Group__c, UserRole__c, User__c, Profile__c, Objects__c
 		// 	FROM DCA_Manager__c 
 		// ];
 		// if (! dcaManagerList.isEmpty()) {
			// for (DCA_Manager__c member : dcaManagerList) {
			// 	Boolean isObject = false;
			// 	if (! String.isEmpty(member.Objects__c)) {
			// 		if (member.Objects__c == 'All') {
			// 			isObject = true;
			// 		} else {
			// 			List<String> selObjects = member.Objects__c.split(',');
			// 			for (String obj : selObjects) {
			// 				if (obj == objectLabel) {
			// 					isObject = true;
			// 					break;
			// 				}
			// 			}
			// 		}
			// 	}
				
			// 	if (isObject == true) {
			// 		if (member.Public_Group__c != null) {
			// 			selectedPubGroups.add(member.Public_Group__c);
			// 		} else if (member.Profile__c != null) {
			// 			selectedProfiles.add(member.Profile__c);
			// 		} else if (member.UserRole__c != null) {
			// 			selectedUserRoles.add(member.UserRole__c);
			// 		} else if (member.User__c != null) {
			// 			selectedUsers.add(member.User__c);
			// 		}
			// 	}
			// }
		// }
    	
   //  	List<UserRole> userRoleList = [
   //  		SELECT Id, Name
   //  		FROM UserRole
   //  		WHERE Id = :userInfo.getUserRoleId() AND Name IN :selectedUserRoles
   //  	];

   //  	List<Profile> profileList = [
   //  		SELECT Id, Name
   //  		FROM Profile
   //  		WHERE Id = :userInfo.getProfileId() AND Name IN :selectedProfiles
   //  	]; 
    	
 		// List<Group> groupList = [
 		// 	SELECT Id, Name
 		// 	FROM Group
 		// 	WHERE Name IN : selectedPubGroups
 		// ];
 		
 		// List<GroupMember> groupMemberList = new List<GroupMember>();
 		
 		// if (! groupList.isEmpty()) {
 		// 	Set<Id> groupIds = new Set<Id>();
 			
 		// 	for (Group gr : groupList) {
 		// 		groupIds.add(gr.Id);
 		// 	}
 			
 		// 	groupMemberList = [
	 	// 		SELECT GroupId, UserOrGroupId
	 	// 		FROM GroupMember
	 	// 		WHERE GroupId IN :groupIds AND UserOrGroupId = :userInfo.getUserId() 
	 	// 	];
 		// }

 		// if (! userRoleList.isEmpty() || ! profileList.isEmpty() || ! groupMemberList.isEmpty() || selectedUsers.contains(userInfo.getName())) {
 		// 	return true;
 		// } else {
 		// 	return false;
 		// }
    }
	
	public PageReference doApprove() { 
		try {
			Boolean isManager = checkUserPermissions();
			if (isManager == true || objectLabel == 'TestObject') {
				PageReference pr; 
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + originalRecord.get('Id');
				checkApproveReject();
				
				Approval_Result__c approvalResult = new Approval_Result__c(
					Object__c = objectLabel,
					Approver__c = userInfo.getUserId(),
					Link_to_Record__c = recordURL,
					Record_Name__c = String.valueOf(originalRecord.get('Name'))
				);
				
				if (countFieldsChanged == countFieldsApproved) {
		
		    		SObject recordActivity = new Data_Change_Activity__c(); 
							recordActivity.put('User__c', userInfo.getUserId());
							recordActivity.put(fieldLookup, record.get('Original_Record_Id__c'));
							recordActivity.put('Message__c', 'Changes were approved.');
						
					if (record.get('Clone_Record_Id__c') != null) {
						checkChangesForProductActivity (recordActivity, oldRecord, originalRecord, false);
						relations(originalRecord, oldRecord);
					} else {
						checkChangesForProductActivity (recordActivity, record, originalRecord, false);
						relations(originalRecord, record);
					}
					insert recordActivity;
				
					originalRecord.put('Is_locked__c',false);			
					update originalRecord;
					
					if (! String.isEmpty(globalComment)) {
						approvalResult.Comments__c = globalComment;
					}
					
					approvalResult.Result__c = 'Changes were approved.';
				//	String CloneRecordId = String.valueOf(record.get('Clone_Record_Id__c'));
											
					sendEmail('toStaffUserApproved', originalRecord.Id);
					List<Approval_List__c> appList = [
						SELECT Id
						FROM Approval_List__c
						WHERE Record_Name__c = :returnRecordName(record)
							OR Record_Name__c = :String.valueOf(originalRecord.get('Name'))
					];
					System.debug(returnRecordName(record));

					System.debug(appList);

					record.put('Is_cloned__c', false);
					update record;
					delete record;
					
					if ( ! appList.isEmpty()) {
						delete appList;
					}
					 						
				} else {
					SObject recordActivity = new Data_Change_Activity__c(); 
							recordActivity.put('User__c', userInfo.getUserId());
							recordActivity.put(fieldLookup, record.get('Original_Record_Id__c'));
							recordActivity.put('Message__c', 'Changes were rejected partially.');
						
				/*	if (record.get('Clone_Record_Id__c') != null) {
						checkChangesForProductActivity (recordActivity, oldRecord, originalRecord, false);
						relations(originalRecord, oldRecord);
					} else {*/
						checkChangesForProductActivity (recordActivity, record, originalRecord, false);
						relations(originalRecord, record);
			//		}
					insert recordActivity;
					
					originalRecord.put('Is_locked__c',false);			
					update originalRecord; 
					
					String resultComments = '';
					if (! comments.isEmpty()) {
						for (String comment : comments) {
							resultComments += comment + '\r\n';
						}
					}
				//	resultComments = resultComments.removeEnd(' ');
				//	resultComments = resultComments.removeEnd(',');
				
					if (! String.isEmpty(globalComment)) {
						resultComments += '\r\n';
						resultComments += globalComment;
					}
					
					approvalResult.Result__c = 'Changes were rejected partially.';
					approvalResult.Comments__c = resultComments;
					
					sendEmail('toStaffUserRejected', String.valueOf(originalrecord.get('Id')));
					record.put('Is_cloned__c', false);
					update record;

					List<Approval_List__c> appList = [
						SELECT Id
						FROM Approval_List__c
						WHERE Record_Name__c = :returnRecordName(record)
							OR Record_Name__c = :String.valueOf(originalRecord.get('Name'))
					];
					if ( ! appList.isEmpty()) {
						delete appList;
					}

					delete record;
					
					/*if (record.get('Clone_Record_Id__c') != null) {
						sendEmail('toStaffUserRejected', String.valueOf(record.get('Id'))); 
					} else {
						sendEmail('toStaffUserRejected', String.valueOf(record.get('Id')));
					}*/
				}
				
				insert approvalResult;
				
				pr = new PageReference(recordURL);
				
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permissons for approve.'));
				return null;
			}
		} catch(Exception e) {
			if (String.valueOf(e.getMessage()).contains('ENTITY_IS_DELETED')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, refresh this page. Maybe this record already approved.'));
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e.getMessage())));
			}
			return null;
		}
	}
	
	public PageReference doApproveCreate() { 
		try {
			Boolean isManager = checkUserPermissions();
			if (isManager == true || objectLabel == 'TestObject') {
				record.put('Is_locked__c',false);			
				update record;
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.Id;
				
				List<Approval_List__c> appList = [
					SELECT Id
					FROM Approval_List__c
					WHERE Record_Name__c = :returnRecordName(record)
				];
					
				for (Approval_List__c app : appList) {
					delete app;
				}
		   		
		   		SObject recordActivity = new Data_Change_Activity__c(); 
					recordActivity.put('User__c', userInfo.getUserId());
					recordActivity.put(fieldLookup, record.get('Id'));
					recordActivity.put('Message__c', 'Creation was approved.');
		   		
		   		insert recordActivity;
		   		
		   		Approval_Result__c approvalResult = new Approval_Result__c(
					Object__c = objectLabel,
					Approver__c = userInfo.getUserId(),
					Link_to_Record__c = recordURL,
					Result__c = 'Creation was approved.',
					Record_Name__c = String.valueOf(record.get('Name'))
				);
				
				if (! String.isEmpty(globalComment)) {
					approvalResult.Comments__c = globalComment;
				}
		   		insert approvalResult;
		   		
		   		sendEmail('toStaffUserApprovedCreate', String.valueOf(record.get('Id')));
		   		
				PageReference pr = new PageReference(recordURL);
				
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permissons for approve.'));
				return null;
			}
		} catch(Exception e) {
			if (String.valueOf(e.getMessage()).contains('ENTITY_IS_DELETED')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, refresh this page. Maybe this record already approved.'));
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e.getMessage())));
			}			return null;
		}
	}
	
	public PageReference doReject() {
		try {
			Boolean isManager = checkUserPermissions();
			if (isManager == true || objectLabel == 'TestObject') {
				PageReference pr;
				originalRecord.put('Is_locked__c',false);			
				update originalRecord;
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + originalRecord.Id;
		
		    	SObject recordActivity = new Data_Change_Activity__c(); 
							recordActivity.put('User__c', userInfo.getUserId());
							recordActivity.put(fieldLookup, record.get('Original_Record_Id__c'));
							recordActivity.put('Message__c', 'Changes were rejected.');
		        
		        checkChangesForProductActivity (recordActivity, originalRecord, originalRecord, true);
		    				
		    	insert recordActivity;
					
			//	String cloneRecordId = String.valueOf(record.get('Clone_Record_Id__c'));
										
				sendEmail('toStaffUserRejectAllChanges', String.valueOf(originalRecord.get('Id'))); 
					

				List<Approval_List__c> appList = [
					SELECT Id
					FROM Approval_List__c
					WHERE Record_Name__c = :returnRecordName(record)
						OR Record_Name__c = :String.valueOf(originalRecord.get('Name'))
				];

				record.put('Is_cloned__c', false);
				update record;
				delete record;

				for (Approval_List__c app : appList) {
					delete app;
				}	
				
				Approval_Result__c approvalResult = new Approval_Result__c(
					Object__c = objectLabel,
					Approver__c = userInfo.getUserId(),
					Link_to_Record__c = recordURL,
					Result__c = 'Changes were rejected.',
					Record_Name__c = String.valueOf(originalRecord.get('Name'))
				);
				if (! String.isEmpty(globalComment)) {
					approvalResult.Comments__c = globalComment;
				}
		   		insert approvalResult;
		
				pr = new PageReference(recordURL);
				
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permissons for reject.'));
				return null;
			}
		} catch(Exception e) {
			if (String.valueOf(e.getMessage()).contains('ENTITY_IS_DELETED')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, refresh this page. Maybe this record already approved.'));
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e.getMessage())));
			}
			return null;
		}
	}
	
	public PageReference doRejectCreate() {
		try {
			Savepoint spReject = Database.setSavepoint();
			Boolean isManager = checkUserPermissions();
			if (isManager == true || objectLabel == 'TestObject') {
				List<Approval_List__c> appList = [
						SELECT Id
						FROM Approval_List__c
						WHERE Record_Name__c = :returnRecordName(record)
					];
					
				for (Approval_List__c app : appList) {
					delete app;
				}
				
				sendEmail('toStaffUserRejectedCreate', null);	
				record.put('Is_locked__c', false);
				update record;
				try {
					delete record;
				} catch(DmlException e) {
	            	if (String.valueOf(e.getMessage()).contains('not be completed because it is associated with the following')) {
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'This record have same child, which you must delete before rejecte this record'));
	            	} else {
	            		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
	            	}
					Database.rollback(spReject);
					return null;
				}
				
				sendEmail('toStaffUserRejectedCreate', null);
				
				Approval_Result__c approvalResult = new Approval_Result__c(
					Object__c = objectLabel,
					Approver__c = userInfo.getUserId(),
					Result__c = 'Creation was rejected.'
				);
				if (! String.isEmpty(globalComment)) {
					approvalResult.Comments__c = globalComment;
				}
		   		insert approvalResult;
				
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyPrefix;
				PageReference pr = new PageReference(recordURL);
				
				return pr;
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have permissons for reject.'));
				return null;
			} 
		} catch(Exception e) {
			if (String.valueOf(e.getMessage()).contains('ENTITY_IS_DELETED')) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please, refresh this page. Maybe this record already approved.'));
			} else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e.getMessage())));
			}
			return null;
		}
	}

	public String returnRecordName(SObject sobj) {
		String recName = '';
        if (objectLabel == 'Contact') {
            if (String.valueOf(sobj.get('FirstName')) != null) {
                recName = String.valueOf(sobj.get('FirstName')) + ' ' + String.valueOf(sobj.get('LastName'));    
            } else {
                recName = String.valueOf(sobj.get('LastName'));    
            }
            
        } else {
            recName = String.valueOf(sobj.get('Name'));
        }
        System.debug('::::recName:::::' + recName);
        return recName;
	}
	
	public void sendEmail(String addressee, id recordId) {
		String currentLabelWithoutSpaces = objectLabel.replaceAll( '\\s+', '');
	/*	if (addressee == 'toManager') {
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Clone' + currentLabelWithoutSpaces + '?scontrolCaching=1&id=' + recordId; 
				String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';          
                
                List<String> idList = new List<String>();   
        		Group g = [
        			SELECT (SELECT userOrGroupId from groupMembers) 
        			FROM Group
        			WHERE Name = '#data change approval'];
        		for (GroupMember gm : g.groupMembers) {
					idList.add(gm.userOrGroupId);
        		}
        		
        		User[] usr = [
        			SELECT Email 
        			FROM User 
        			WHERE Id IN :idList];
        			
				for(User u : usr) {
      				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   					mail.setUseSignature(false);
    				mail.setToAddresses(new String[] {u.Email});
   					mail.setSubject('Please approve the changes in ' + objectLabel);
    				mail.setHtmlBody('Please approve the changes in ' + recordHyperlink);
	
	    			// Send the email
    				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
				
				Approval_List__c approvalList = new Approval_List__c (
					Object__c = objectLabel,
					User_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + userInfo.getUserId(),
					User_Name__c = userInfo.getName(),
					Approval_Link__c = recordURL
				);			
				
				if (record.get('Original_Record_Id__c') == null) {
					approvalList.Link_to_Record__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.get('Id');
					approvalList.Record_Name__c = String.valueOf(record.get('Name'));
				} else {
					approvalList.Link_to_Record__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + originalRecord.get('Id');
					approvalList.Record_Name__c = String.valueOf(originalRecord.get('Name'));
				}
				
				insert approvalList;
		}
		
		if (addressee == 'toManagerCreate') {
			String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Clone' + currentLabelWithoutSpaces + 'Create?scontrolCaching=1&id=' + recordId; 
			String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';
			
			List<String> idList = new List<String>();   
        		Group g = [
        			SELECT (SELECT userOrGroupId from groupMembers) 
        			FROM Group
        			WHERE Name = '#data change approval'];
        		for (GroupMember gm : g.groupMembers) {
					idList.add(gm.userOrGroupId);
        		}
        		
        		User[] usr = [
        			SELECT Email 
        			FROM User 
        			WHERE Id IN :idList];
        			
				for(User u : usr) {
      				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   					mail.setUseSignature(false);
    				mail.setToAddresses(new String[] {u.Email});
   					mail.setSubject('Please approve ' +  objectLabel +  ' record.');
    				mail.setHtmlBody('Please approve ' +  recordHyperlink +  ' record.');
	
	    			// Send the email
    				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
				
				Approval_List__c approvalList = new Approval_List__c (
					Object__c = objectLabel,
					User_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + userInfo.getUserId(),
					User_Name__c = userInfo.getName(),
					Approval_Link__c = recordURL,
					Link_to_Record__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.get('Id'),
					Record_Name__c = String.valueOf(record.get('Name'))
				);	
				
				insert approvalList;
		}*/
		
		if (addressee == 'toStaffUserApproved') {

				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
				String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';  
				String address = String.valueOf(record.get('Staff_User_email__c'));        
                String mailBody = 'Changes in ' + recordHyperlink + ' were successfully approved.';
                mailBody += '<html><body>';
                if (! String.isEmpty(globalComment)) {
					mailBody += '<br>';
					mailBody += 'Comments:';
					mailBody += '<br>';
					mailBody += globalComment;
				}    
				
				mailBody += '</html></body>';
                
      				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   					mail.setUseSignature(false);
    				mail.setToAddresses(new String[] {address});
   					mail.setSubject('Changes in ' +  objectLabel + ' record were successfully approved.');
    				mail.setHtmlBody(mailBody);
	
	    			// Send the email
    				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    		
		}
		
		if (addressee == 'toStaffUserApprovedCreate') {

				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
				String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';  
				String address = String.valueOf(record.get('Staff_User_email__c'));      
				String mailBody = recordHyperlink + ' was successfully approved.';
                mailBody += '<html><body>';
                if (! String.isEmpty(globalComment)) {
					mailBody += '<br>';
					mailBody += 'Comments:';
					mailBody += '<br>';
					mailBody += globalComment;
				}    
				
				mailBody += '</html></body>'; 
                
      				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   					mail.setUseSignature(false);
    				mail.setToAddresses(new String[] {address});
   					mail.setSubject(objectLabel + ' record was successfully approved.');
    				mail.setHtmlBody(mailBody);
	
	    			// Send the email
    				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		}
		
		if (addressee == 'toStaffUserRejected') {
				String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
				String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';
				String address = String.valueOf(record.get('Staff_User_email__c'));    
				String mailBody = 'Changes in ' + recordHyperlink + ' were rejected partially.';
				mailBody += '<html><body>';
				
				for (String comment: comments) {
					
					mailBody += '<br>';
					mailBody += comment;
				}    
				
				if (! String.isEmpty(globalComment)) {
					mailBody += '<br><br>';
					mailBody += 'Comments:';
					mailBody += '<br>';
					mailBody += globalComment;
				}    
				
				mailBody += '</html></body>';
                
      				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   					mail.setUseSignature(false);
    				mail.setToAddresses(new String[] {address});
   					mail.setSubject('Changes in ' +  objectLabel + ' record were rejected partially.');
    				mail.setHtmlBody(mailBody);
	
	    			// Send the email
    				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		
		if (addressee == 'toStaffUserRejectedCreate') {
			String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyPrefix;
			String recordlink = '<a href="' + recordURL + '">again</a>';
			String address = String.valueOf(record.get('Staff_User_email__c')); 
			String mailBody = objectLabel +  ' record was rejected. Please try ' + recordlink;
                mailBody += '<html><body>';
                if (! String.isEmpty(globalComment)) {
					mailBody += '<br>';
					mailBody += 'Comments:';
					mailBody += '<br>';
					mailBody += globalComment;
				}    
				
			mailBody += '</html></body>'; 
             
  			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   				mail.setUseSignature(false);
				mail.setToAddresses(new String[] {address});
   				mail.setSubject(objectLabel +  ' record was rejected.');
    			mail.setHtmlBody(mailBody);
	
			// Send the email
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		
		if (addressee == 'toStaffUserRejectAllChanges') {

			String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId; 
			String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';
			String address = String.valueOf(record.get('Staff_User_email__c'));  
			String mailBody = 'All changes in ' + recordHyperlink + ' were rejected.';
                mailBody += '<html><body>';
                if (! String.isEmpty(globalComment)) {
					mailBody += '<br>';
					mailBody += 'Comments:';
					mailBody += '<br>';
					mailBody += globalComment;
				}    
				
			mailBody += '</html></body>';         
                
      		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   				mail.setUseSignature(false);
				mail.setToAddresses(new String[] {address});
   				mail.setSubject('All changes in ' + objectLabel + ' record rejected.');
    			mail.setHtmlBody(mailBody);
	
	    	// Send the email
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	
/*	public PageReference doCancel() { 
		String recordURL;
		
		if (record.get('Id') == null) {
			recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/' + keyPrefix + '/o';
		} else if (record.get('Original_Record_Id__c') == null) {
			recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/' + record.get('Id');   		
		} else {
			recordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   					'/' + record.get('Original_Record_Id__c'); 
		}
		
		PageReference pr = new PageReference(recordURL);
		return pr;
	}*/ 
	
	public PageReference doCancelApprove() { 
		String originalRecordId = String.valueOf(record.get('Original_Record_Id__c'));
		String originalRecordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   				'/' + originalRecordId;
    	PageReference pr = new PageReference(originalRecordURL);
		return pr;
	}
	
	public PageReference doCancelCreate() { 
		String originalRecordId = String.valueOf(record.get('Id'));
		String originalRecordURL = URL.getSalesforceBaseUrl().toExternalForm() +
   				'/' + originalRecordId;
    	PageReference pr = new PageReference(originalRecordURL);
		return pr;
	}
	
	public void relations(sObject recordNew, sObject recordOld) {
		for(Schema.FieldSetMember f : objectFields) {
			Boolean status = false;
			for (fieldWrapper fw : objectWrapperFields) {
				if (fw.field.getFieldPath() == f.getFieldPath()) {
					status = fw.currentState;
				}
			}
			
			if (status == true) {
				recordNew.put(f.getFieldPath(), recordOld.get(f.getFieldPath()));
			} 
		}
	}
	
	public void relationsStatic(sObject recordNew, sObject recordOld) {
		for(Schema.SObjectField fr : objectStaticFields) {
			recordNew.put(fr.getDescribe().getName(), recordOld.get(fr.getDescribe().getName())); 
		}
	}
	
	
	public void checkChanges (sObject recordNew,sObject recordOld) {
			
			for (fieldWrapper fw : objectWrapperFields) {
				if (recordNew.get(fw.field.getFieldPath()) != recordOld.get(fw.field.getFieldPath())) {
					fw.currentState = true;
					fw.initialState = true;
					fw.textState = true;
					countFieldsChanged++;
				}
			}
	}
	
	public void checkApproveReject() {
		for (fieldWrapper fw : objectWrapperFields) {
			if (fw.initialState == true && compareCheckbox(fw.currentState, fw.initialState)) {
				if (record.get('Clone_Record_Id__c') != null) {
					oldRecord.put(fw.field.getFieldPath(), record.get(fw.field.getFieldPath()));
				}
			countFieldsApproved++;
			} else if (fw.initialState == true && (! compareCheckbox(fw.currentState, fw.initialState))) {
				if (record.get('Clone_Record_Id__c') != null) {
					oldRecord.put(fw.field.getFieldPath(), record.get(fw.field.getFieldPath()));
				} else {
					oldRecord.put(fw.field.getFieldPath(), originalRecord.get(fw.field.getFieldPath()));
				}
				comments.add(fw.field.getLabel() + ': ' + fw.text);				
			}
		}
	}
	
	public Boolean compareCheckbox(Boolean finalCheck, Boolean initialCheck) {
		if (finalCheck == initialCheck) {
			return true;
		} else {
			return false; 
		}
	}
	
	public void checkChangesForProductActivity (SObject dataChangeActivity, SObject recordNew, SObject recordOld, Boolean reject) {	
		String oldValues = '';
		String newValues = '';
		for (Schema.FieldSetMember f : objectFields) {
			oldValues += f.getLabel() + ': ' + recordOld.get(f.getFieldPath()) + '\r\n';
		}
		dataChangeActivity.put('Old_Values__c',oldValues);
		if (! reject) {
			for (Schema.FieldSetMember f : objectFields) {
				newValues += f.getLabel() + ': ';
				if (recordOld.get(f.getFieldPath()) != recordNew.get(f.getFieldPath())) {
					newValues += recordNew.get(f.getFieldPath());
				}
				newValues += '\r\n';
			}
			dataChangeActivity.put('New_Values__c',newValues);
		}
			
	}

	public static Boolean checkFilterForRecord(SObject rec, DCA_Filter__c filter, Map<String, Schema.SObjectField> sobjFieldMap) {

        Boolean isFilterResult = false; 

        try {
        	if (rec.get(filter.Field__c) != null) {
        		if (filter.Operator__c == 'equals') {
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

            return isFilterResult; 
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.valueOf(e)));
            return false;
        }
    }
		
	public class fieldWrapper {
        public Schema.FieldSetMember field{get; set;}
        public String text {get; set;}
        public Boolean currentState {get; set;}
        public Boolean initialState {get; set;}
        public Boolean textState {get; set;}
        
        public fieldWrapper(Schema.FieldSetMember f)
        {
        	text = '';
            field = f;
            currentState = false;
            initialState = false;
			textState = false;
        }
    }
}
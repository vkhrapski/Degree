public class DataChangeApprovalHandler {
    public static Boolean enablesTrigger = true;
    
    public static void isClonedStatusUpdate(Map<Id, SObject> p_oldMap, List<SObject> p_newRecords) {
        // first map: key - object type, value  - Map with key - Id current record, value - Id original record 
        Map<String, Map<Id, String>> addErrorMapUpdate = new Map<String, Map<Id, String>>(); 
        for (SObject v_newRecord : p_newRecords) {              
            SObject v_oldRecord = p_oldMap.get(String.valueOf(v_newRecord.get('Id')));
            Id recordId = String.valueOf(v_newRecord.get('Id'));
            String objectName = recordId.getSObjectType().getDescribe().getName();
            SObject nameRecord = Schema.getGlobalDescribe().get(objectName).newSObject(); 
            
            if (v_newRecord.get('Is_Cloned__c') == true && v_oldRecord.get('Is_Cloned__c') == true) {
                //  if (v_newRecord.get('Original_Record_Id__c') != null) {
                /*String queryString = 'SELECT Name, Id ';
                    queryString += 'FROM ' + objectName; 
                    queryString += ' WHERE Id = \'' + v_newRecord.get('Original_Record_Id__c') + '\'' + ' LIMIT 1';
    
                nameRecord = Database.query(queryString);  */ 
                //   }
                if( ! addErrorMapUpdate.containsKey(objectName)) {
                    addErrorMapUpdate.put(objectName, new Map<Id, String>());
                }
                addErrorMapUpdate.get(objectName).put(recordId, String.valueOf(v_newRecord.get('Original_Record_Id__c')));
          
                //v_newRecord.addError('"It is a temporary record until changes for '+ nameRecord.get('Name') +' will not be approved."');                
            }
        } 

        for(String objName: addErrorMapUpdate.keySet()) {
            List<String> queryListId = new List<String>(addErrorMapUpdate.get(objName).values());
            String queryString = 'SELECT Name, Id ';
                    queryString += 'FROM ' + objName; 
                    queryString += ' WHERE Id IN: queryListId';
    
                Map<Id, SObject> nameRecord = new Map<Id, SObject>(Database.query(queryString));

                for (SObject v_newRecord : p_newRecords) {
                    if(addErrorMapUpdate.get(objName).containsKey(v_newRecord.Id)) {
                         v_newRecord.addError('"It is a temporary record until changes for '+ nameRecord.get(addErrorMapUpdate.get(objName).get(v_newRecord.Id)).get('Name') +' will not be approved."');
                    }
                }

        }
        

    }
    
    public static void isClonedStatusDelete(Map<Id, SObject> p_oldMap) {
        // first map: key - object type, value  - Map with key - Id current record, value - Id original record 
        Map<String, Map<Id, String>> addErrorMapUpdate = new Map<String, Map<Id, String>>(); 
        for (SObject v_record : p_oldMap.values()) {
            id recordId = String.valueOf(v_record.get('Id'));
            String objectName = recordId.getSObjectType().getDescribe().getName();
            SObject nameRecord = Schema.getGlobalDescribe().get(objectName).newSObject(); 
            
            if (v_record.get('Is_Cloned__c') == true) {
                //     if (v_record.get('Original_Record_Id__c') != null) {
                /* String queryString = 'SELECT Name, Id ';
                    queryString += 'FROM ' + objectName; 
                    queryString += ' WHERE Id = \'' + v_record.get('Original_Record_Id__c') + '\'' + ' LIMIT 1';
      
                nameRecord = Database.query(queryString);*/   
                if( ! addErrorMapUpdate.containsKey(objectName)) {
                    addErrorMapUpdate.put(objectName, new Map<Id, String>());
                }
                addErrorMapUpdate.get(objectName).put(recordId, String.valueOf(v_record.get('Original_Record_Id__c')));
                //     }                 
               
                //v_record.addError('It is a temporary record until changes for '+ nameRecord.get('Name') +' will not be approved');                
            }
        
            if (v_record.get('Is_locked__c') == true) {
                v_record.addError('Impossible to delete. This record is waiting for the approval');
            }
        }   

        for(String objName: addErrorMapUpdate.keySet()) {
            List<String> queryListId = new List<String>(addErrorMapUpdate.get(objName).values());
            String queryString = 'SELECT Name, Id ';
                    queryString += 'FROM ' + objName; 
                    queryString += ' WHERE Id IN: queryListId';
    
                Map<Id, SObject> nameRecord = new Map<Id, SObject>(Database.query(queryString));

                for (SObject v_record : p_oldMap.values()) {
                    if(addErrorMapUpdate.get(objName).containsKey(v_record.Id)) {
                        v_record.addError('It is a temporary record until changes for '+ nameRecord.get(addErrorMapUpdate.get(objName).get(v_record.Id)).get('Name') +' will not be approved');
                    }
                }

        }


    }

    public static Boolean checkRecordType(String objectLabel, String recTypeId, Map<Id, RecordType> recTypeMap, String recTypes, List<DCA_Member__c> dcaMemberList) {
        if (! String.isEmpty(recTypes)) {
            if (recTypes.contains('[All]')) {
                
                Boolean isRecType = false; 

                for (DCA_Member__c dcaM : dcaMemberList) {

                    if (dcaM.Objects__c == 'All') {
                        isRecType = true;  
                        break;                       
                    } else {
                        String objRecTypeName = objectLabel + ' (All)'; 

                        if (dcaM.Objects__c.contains(objRecTypeName)) {
                            isRecType = true;
                            break;
                        } else {
                            objRecTypeName = objectLabel + ' (' + recTypeMap.get(recTypeId).Name + ')';

                            if (dcaM.Objects__c.contains(objRecTypeName)) {
                                isRecType = true;
                                break; 
                            }
                        }
                    }
                }

                return isRecType;
                
            } else {
                System.debug(':::checkRecordType::::');
                String objRecTypeName = objectLabel + ' (' + recTypeMap.get(recTypeId).Name + ')';
                System.debug(':::objRecTypeName::::' + objRecTypeName); 
                System.debug(':::recTypes::::' + recTypes); 
                if (recTypes.contains(recTypeMap.get(recTypeId).Name)) {
                    Boolean isRecType = false; 

                    for (DCA_Member__c dcaM : dcaMemberList) {
                        if (dcaM.Objects__c == 'All') {
                            isRecType = true;  
                            break;                       
                        } else if (dcaM.Objects__c.contains(objRecTypeName)) {
                            isRecType = true;
                            break;
                        }
                    }

                    return isRecType;
                } else {
                    return false;
                }
            }
        } else {
            return false;
        }
    }

    public static List<DCA_Member__c> returnDCAMembers(String objectLabel) {
        String userRoleName = '';
        // if (userInfo.getUserRoleId() != NULL)  {
        //     userRoleName = [SELECT Name FROM UserRole WHERE Id = :userInfo.getUserRoleId()].Name;
        // }
        // String userProfileName = [SELECT Name FROM Profile WHERE Id = :userInfo.getProfileId()].Name;
        Set<String> userGroupNames= new Set<String>();
        List<GroupMember> userGroupMemberList = new List<GroupMember>();
        userGroupMemberList = [
            SELECT Id, Group.Name, UserOrGroupId
            FROM GroupMember
            WHERE UserOrGroupId = :userInfo.getUserId() 
        ];

        for (GroupMember gm : userGroupMemberList) {
            userGroupNames.add(gm.Group.Id);
        }

        System.debug('::::userInfo.getProfileId()::::' + userInfo.getProfileId());
        System.debug('::::userInfo.getUserId():::::' + userInfo.getUserId());

        List<DCA_Member__c> dcaMemberAllList = [
            SELECT Id, Public_Group__c, UserRole__c, User__c, Profile__c, Objects__c
            FROM DCA_Member__c 
            WHERE (UserRole__c != NULL AND UserRole__c = :userInfo.getUserRoleId()) OR Profile__c =:userInfo.getProfileId() 
                OR User__c = :userInfo.getUserId() OR (Public_Group__c != NULL AND Public_Group__c IN :userGroupNames)
        ];

        System.debug(':::dcaMemberAllList::::::' + dcaMemberAllList);

        List<DCA_Member__c> dcaMemberList = new List<DCA_Member__c>();
        if (! dcaMemberAllList.isEmpty()) {                        
            for (DCA_Member__c dcaM : dcaMemberAllList) {
                Set<String> memberObjects = new Set<String>();
                

                for (String obj : dcaM.Objects__c.split(',')) {
                    System.debug(':::::obj:::::' + obj);
                    if(obj.contains('(None)')) {
                        memberObjects.add(String.valueOf(obj.split('\\(None\\)').get(0).removeEndIgnoreCase(' ')));
                    } else if (obj.split('\\(').size() > 2) {
                        String concatStringObj = '';
                        for(Integer i=0; i < obj.split('\\(').size()-1; i++) {
                            concatStringObj += obj.split('\\(').get(i) + '(';  
                        }
                        memberObjects.add(concatStringObj.removeEndIgnoreCase(' ').removeEndIgnoreCase('(').removeEndIgnoreCase(' '));  
                        System.debug(concatStringObj.removeEndIgnoreCase(' ').removeEndIgnoreCase('('));     
                    } if (obj.split('\\(').size() > 1) {
                        memberObjects.add(obj.split('\\(').get(0).removeEndIgnoreCase(' '));    
                    } else {
                        memberObjects.add(obj);
                    }
                }

                

                if (memberObjects.contains(objectLabel) || memberObjects.contains('All')) {
                    dcaMemberList.add(dcaM);
                }
            }
        }

        return dcaMemberList;
    }
    
    public static void checkFieldsForApprovalNew(List<SObject> p_newRecords) {
        
            String objectName = p_newRecords.get(0).getSObjectType().getDescribe().getName();
            String objectLabel;

        if (! Test.isRunningTest() || (Test.isRunningTest() && objectName == 'TestObject__c')) {
            if (objectName == 'Opportunity') {
                objectLabel = 'Opportunity';
            } else {
                objectLabel = p_newRecords.get(0).getSObjectType().getDescribe().getLabel();  
            }
    
            Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([
                SELECT Id, Name, SobjectType
                FROM RecordType
                WHERE SobjectType = :objectName
            ]);
    
            String dcaObjectRecTypes = '';
            List<DCA_Object__c> dcaObjList = new List<DCA_Object__c>();
            dcaObjList = [
                SELECT Name, Record_Types__c
                FROM DCA_Object__c
                WHERE Name = :objectName
                LIMIT 1
            ];  
            System.debug('::::objectName::::' + objectName);
            System.debug('::::dcaObjList::::' + dcaObjList);
    
            if (! dcaObjList.isEmpty()) {
                dcaObjectRecTypes = dcaObjList.get(0).Record_Types__c;
            }


    
            List<DCA_Member__c> dcaMemberList = new List<DCA_Member__c>();
            dcaMemberList = returnDCAMembers(objectLabel);
            System.debug('::::dcaMemberList::::' + dcaMemberList);    
            System.debug(dcaMemberList);


            List<DCA_Manager__c> debugList;


            if (! dcaMemberList.isEmpty()) {
                Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
                List<Schema.FieldSetMember> objectFields = mapSObjects.get(objectName).getDescribe().fieldSets.getMap().get('ApprovalFieldSet').getFields();
              
                for (SObject v_newRecord : p_newRecords) {
                    Boolean toApprove = false;
    
                    String userEmail = UserInfo.getUserEmail();
    
                    if (v_newRecord.get('Is_cloned__c') == false || v_newRecord.get('Is_cloned__c') == null) {
                        for (Schema.FieldSetMember fs : objectFields) {
                            if (v_newRecord.get(fs.getFieldPath()) != null) {
                                toApprove = true;
                            }   
                        }
                        
                        Boolean isRecType = true;
                        String recType;
                        if (v_newRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                            System.debug('::::::isRecType::hello:::');
                            isRecType = checkRecordType(objectLabel, String.valueOf(v_newRecord.get('RecordTypeId')), recTypeMap, dcaObjectRecTypes, dcaMemberList);
                            recType = String.valueOf(v_newRecord.get('RecordTypeId'));
                        } else {
                            recType = '';
                        }

                        System.debug('::::::isRecType:::::' + isRecType);
                        if (toApprove == true && isRecType) {
                            v_newRecord.put('Is_locked__c', true);
                            v_newRecord.put('Staff_User_email__c', userEmail);
                        }
                    }
                } 
            }
        }
    }

    public static void checkFieldsForApprovalNewSendEmail(List<SObject> p_newRecords) {
        
            String objectName = p_newRecords.get(0).getSObjectType().getDescribe().getName();
            String objectLabel;

        if (! Test.isRunningTest() || (Test.isRunningTest() && objectName == 'TestObject__c')) { 
            if (objectName == 'Opportunity') {
                objectLabel = 'Opportunity';
            } else {
                objectLabel = p_newRecords.get(0).getSObjectType().getDescribe().getLabel();  
            }
    
            Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([
                SELECT Id, Name, SobjectType
                FROM RecordType
                WHERE SobjectType = :objectName
            ]);
    
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
    
            String userEmail = UserInfo.getUserEmail();
            List<SObject> recordActivities = new List<SObject>();
    
            List<DCA_Manager__c> dcaManagerList = [
                SELECT Id, Public_Group__c, UserRole__c, User__c, Profile__c, Objects__c, Type__c
                FROM DCA_Manager__c
                LIMIT 10000
            ];
    
            Set<Id> dcaManagerIdSet = new Set<Id>();
            if (! dcaManagerList.isEmpty()) {
                for (DCA_Manager__c dcaManager : dcaManagerList) {
                    dcaManagerIdSet.add(dcaManager.Id);
                }
            }
    
            List<DCA_Filter__c> dcaFilterList = new List<DCA_Filter__c>([
                SELECT Object_Name__c, Field__c, Operator__c, Value__c, DCA_Manager__c
                FROM DCA_Filter__c
                WHERE DCA_Manager__c IN :dcaManagerIdSet AND Object_Label__c = :objectLabel
                LIMIT 1000
            ]);
    
            Map<String, List<DCA_Filter__c>> dcaFilterMap = new Map<String, List<DCA_Filter__c>>();
            if (! dcaFilterList.isEmpty()) {
                for (DCA_Filter__c filter : dcaFilterList) {
                    if (! dcaFilterMap.containsKey(filter.DCA_Manager__c)) {
                        List<DCA_Filter__c> dcaFilterNewList = new List<DCA_Filter__c>{filter};
                        dcaFilterMap.put(filter.DCA_Manager__c, dcaFilterNewList);
                    } else {
                        dcaFilterMap.get(filter.DCA_Manager__c).add(filter);
                    }
                }
            }
    
            List<Profile> profileList = [
                SELECT Id, Name
                FROM Profile
                LIMIT 10000
            ];
    
            List<Group> groupList = [
                SELECT Id, Name, (SELECT UserOrGroupId FROM GroupMembers)
                FROM Group
                LIMIT 10000
            ];
    
            List<UserRole> roleList = [
                SELECT Id, Name
                FROM UserRole
                LIMIT 10000
            ];
    
            Map<Id, User> userMap = new Map<Id, User>([
                SELECT Id, Name, Email, ProfileId, UserRoleId
                FROM User
                LIMIT 20000
            ]);
        
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            List<Approval_List__c> insertApprovalList = new List<Approval_List__c>();
            for (SObject v_newRecord : p_newRecords) {
                System.debug(':::::v_newRecord.get(Is_locked__c)::::::' + v_newRecord.get('Is_locked__c'));
                if (v_newRecord.get('Is_locked__c') == true) {
                    
                    String recType;
                    if (v_newRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                        recType = String.valueOf(v_newRecord.get('RecordTypeId'));
                    } else {
                        recType = '';
                    }
    
                    SObject recordActivity = new Data_Change_Activity__c(); 
                    recordActivity.put('User__c', userInfo.getUserId());
          
                    if (objectName.endsWith('c')) {
                        recordActivity.put(objectName, v_newRecord.Id);  
                    } else {
                        recordActivity.put(objectName + '__c', v_newRecord.Id);
                    }
          
                    recordActivity.put('Message__c', 'Request for creation.');
    
                    recordActivities.add(recordActivity);

    
                    sendEmailList.addAll(sendEmail('toManagerCreate', String.valueOf(v_newRecord.get('Id')), objectLabel, v_newRecord, 
                                            dcaManagerList, profileList, groupList, roleList, userMap, dcaFilterMap, 
                                                recType, recTypeMap, dcaObjectRecTypes, insertApprovalList, new Map<Id, SObject>())); 
                }
            }
            if( ! insertApprovalList.isEmpty()) {
                insert insertApprovalList;
            }
            try {
                Messaging.sendEmail(sendEmailList);
            } catch(Exception e) {
                for (SObject v_newRecord : p_newRecords) {
                    v_newRecord.addError(e.getMessage());
                }
            }
            

            if (! recordActivities.isEmpty()) {
                insert recordActivities;
            }
        } 
    }
     
    public static void checkFieldsForApprovalEdit(Map<Id, SObject> p_oldMap, List<SObject> p_newRecords) {
        
            String objectName = p_newRecords.get(0).getSObjectType().getDescribe().getName();
            String objectLabel;
        
        if (! Test.isRunningTest() || (Test.isRunningTest() && objectName == 'TestObject__c')) {  
            if (objectName == 'Opportunity') {
                objectLabel = 'Opportunity';
            } else {
                objectLabel = p_newRecords.get(0).getSObjectType().getDescribe().getLabel();  
            }
    
            Map<Id, RecordType> recTypeMap = new Map<Id, RecordType>([
                SELECT Id, Name, SobjectType
                FROM RecordType
                WHERE SobjectType = :objectName
              ]);
    
            String dcaObjectRecTypes = '';
            List<DCA_Object__c> dcaObjList = new List<DCA_Object__c>();
            dcaObjList = [
                SELECT Name, Record_Types__c
                FROM DCA_Object__c
                WHERE Name = :objectName
                LIMIT 1
            ];

            System.debug(':::::::::::::::::: ' + p_newRecords.get(0).get('Name'));

            /*List<DCA_Manager__c> debugList;
                        debugList.add(new DCA_Manager__c());*/
    
            if (! dcaObjList.isEmpty()) {
                dcaObjectRecTypes = dcaObjList.get(0).Record_Types__c;
            }
            
            List<DCA_Member__c> dcaMemberList = new List<DCA_Member__c>();
            dcaMemberList = returnDCAMembers(objectLabel);
            
            

            if (! dcaMemberList.isEmpty()) {
               /** ********  ********* ********* DEBUG ********* ********* ********* ********* ********* */
               // p_newRecords.get(0).addError(dcaMemberList.get(0).Id);
                /** ********  ********* ********* ********* ********* ********* ********* ********* */
                Map<String, Schema.SObjectType> mapSObjects = Schema.getGlobalDescribe();
                List<Schema.FieldSetMember> objectFields = mapSObjects.get(objectName).getDescribe().fieldSets.getMap().get('ApprovalFieldSet').getFields();
              
                Map <String, Schema.SObjectField> objectAllFields = p_newRecords.get(0).getSObjectType().getDescribe().fields.getMap();
              
                Set<Schema.SObjectField> objectStaticFields = new Set<Schema.SObjectField>();
                Set<String> names = new Set<String>();
                Set<String> staticNames = new Set<String>();
              
                List<SObject> cloneRecords = new List<SObject>();
                List<SObject> recordActivities = new List<SObject>();
                
                for (Schema.FieldSetMember fs : objectFields) {
                    names.add(fs.getFieldPath());
                }
              
                for (Schema.SObjectField fr : objectAllFields.values()) {    
                
                    if ((! names.contains(fr.getDescribe().getName())) && (fr.getDescribe().isAccessible()) && (fr.getDescribe().isSortable()) && (fr.getDescribe().isCreateable()) &&
                         fr.getDescribe().getName() != 'Clone_Record_Id__c' && fr.getDescribe().getName() != 'Original_Record_Id__c' && 
                            fr.getDescribe().getName() != 'Is_cloned__c' && fr.getDescribe().getName() != 'Is_locked__c' &&
                                fr.getDescribe().getName() != 'Staff_User_email__c' && fr.getDescribe().getName() != 'Parent_Record__c' &&
                            (! fr.getDescribe().isAutoNumber())) {
    
                        if (fr.getDescribe().isDefaultedOnCreate()) {
                            if (fr.getDescribe().isUpdateable()) {
                                objectStaticFields.add(fr);
                                staticNames.add(fr.getDescribe().getName());
                            }
                        } else {
                            objectStaticFields.add(fr);
                            staticNames.add(fr.getDescribe().getName());
                        }
                        
                    }    
                }
                
                // String userId = UserInfo.getUserId();
                // User activeUser = [SELECT Email FROM User WHERE Id = :userId LIMIT 1];
                String userEmail = UserInfo.getUserEmail();
        
                for (SObject v_newRecord : p_newRecords) {
                    Boolean toApprove = false;
                    SObject v_oldRecord = p_oldMap.get(String.valueOf(v_newRecord.get('Id')));
                    if (v_oldRecord.get('Original_Record_Id__c') == null && (v_oldRecord.get('Is_locked__c') == null || v_oldRecord.get('Is_locked__c') == false)) {
                        for (Schema.FieldSetMember fs : objectFields) {
                            if (v_newRecord.get(fs.getFieldPath()) != v_oldRecord.get(fs.getFieldPath())) {
                                toApprove = true;
                            }
                        }

                        if(objectAllFields.containsKey('RecordTypeId')) {
                            if(v_newRecord.get('RecordTypeId') == null) {
                                continue;
                            }
                        }                        
                        System.debug('++++++++++++++++++++');

                        Boolean isRecType = true;
                        if (v_newRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                            isRecType = checkRecordType(objectLabel, String.valueOf(v_newRecord.get('RecordTypeId')), recTypeMap, dcaObjectRecTypes, dcaMemberList);
                            isRecType = true;
                        }

    
                        if (toApprove == true && isRecType) {
                            v_newRecord.put('Is_locked__c', true);
                     
                            SObject cloneRecord = mapSObjects.get(objectName).newSObject();  
                                      
                            relationsStatic(cloneRecord,v_newRecord, objectStaticFields );
                            relations(cloneRecord,v_newRecord, objectFields );
                            cloneRecord.put('Original_Record_Id__c', v_newRecord.get('Id'));
                            cloneRecord.put('Is_locked__c', false);     
                            cloneRecord.put('Is_cloned__c', true);
                            cloneRecord.put('Staff_User_email__c', userEmail);                    
                            cloneRecord.put('Parent_Record__c', v_newRecord.get('Name'));
    
                            if (v_newRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                                cloneRecord.put('RecordTypeId', v_newRecord.get('RecordTypeId'));
                            }
                  
                            cloneRecords.add(cloneRecord);
                    
                            SObject recordActivity = new Data_Change_Activity__c(); 
                            recordActivity.put('User__c', userInfo.getUserId());
                            if (objectName.endsWith('c')) {
                                recordActivity.put(objectName, v_newRecord.Id);  
                            } else {
                                recordActivity.put(objectName + '__c', v_newRecord.Id);
                            }
                            recordActivity.put('Message__c', 'Request for changes.');
                    
                            checkChangesForProductActivity(recordActivity, v_newRecord, v_oldRecord, false, objectFields);
                  
                            recordActivities.add(recordActivity);
                      
                            for (Schema.FieldSetMember fs : objectFields) {
                                v_newRecord.put(fs.getFieldPath(), v_oldRecord.get(fs.getFieldPath()));
                            }  
                        }
                    } else if (v_oldRecord.get('Original_Record_Id__c') == null && v_oldRecord.get('Is_locked__c') == true && v_newRecord.get('Is_locked__c') == true) {
                        v_newRecord.addError('"This record is already waiting for the approval."');
                        //v_newRecord.put('Is_locked__c', false);
                    }
                }
                 
                if (! cloneRecords.isEmpty()) {
                    insert cloneRecords;
    
                    List<DCA_Manager__c> dcaManagerList = [
                        SELECT Id, Public_Group__c, UserRole__c, User__c, Profile__c, Objects__c, Type__c
                        FROM DCA_Manager__c
                        LIMIT 10000
                    ];
    
                    Set<Id> dcaManagerIdSet = new Set<Id>();
                    if (! dcaManagerList.isEmpty()) {
                        for (DCA_Manager__c dcaManager : dcaManagerList) {
                            dcaManagerIdSet.add(dcaManager.Id);
                        }
                    }
    
                    List<DCA_Filter__c> dcaFilterList = new List<DCA_Filter__c>([
                        SELECT Object_Name__c, Field__c, Operator__c, Value__c, DCA_Manager__c
                        FROM DCA_Filter__c
                        WHERE DCA_Manager__c IN :dcaManagerIdSet AND Object_Label__c = :objectLabel
                        LIMIT 1000
                    ]);
    
                    Map<String, List<DCA_Filter__c>> dcaFilterMap = new Map<String, List<DCA_Filter__c>>();
                    if (! dcaFilterList.isEmpty()) {
                        for (DCA_Filter__c filter : dcaFilterList) {
                            if (! dcaFilterMap.containsKey(filter.DCA_Manager__c)) {
                                List<DCA_Filter__c> dcaFilterNewList = new List<DCA_Filter__c>{filter};
                                dcaFilterMap.put(filter.DCA_Manager__c, dcaFilterNewList);
                            } else {
                                dcaFilterMap.get(filter.DCA_Manager__c).add(filter);
                            }
                        }
                    }
    
                    List<Profile> profileList = [
                        SELECT Id, Name
                        FROM Profile
                        LIMIT 10000
                    ];
    
                    List<Group> groupList = [
                        SELECT Id, Name, (SELECT UserOrGroupId FROM GroupMembers)
                        FROM Group
                        LIMIT 10000
                    ];
    
                    List<UserRole> roleList = [
                        SELECT Id, Name
                        FROM UserRole
                        LIMIT 10000
                    ];
    
                    Map<Id, User> userMap = new Map<Id, User>([
                        SELECT Id, Name, Email, ProfileId, UserRoleId
                        FROM User
                        LIMIT 20000
                    ]);
                    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                    List<Approval_List__c> insertApprovalList = new List<Approval_List__c>();
                    for (SObject clRecord : cloneRecords) {
                        String recType = '';
                        if (clRecord.getSobjectType().getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                            recType = String.valueOf(clRecord.get('RecordTypeId'));
                        }
                       
                        sendEmailList.addAll(sendEmail('toManager', clRecord.Id, objectLabel, clRecord, dcaManagerList, 
                                                profileList, groupList, roleList, userMap, dcaFilterMap,
                                                   recType, recTypeMap, dcaObjectRecTypes, insertApprovalList, p_oldMap));
                    }
                    if( ! insertApprovalList.isEmpty()) {
                        insert insertApprovalList;
                    }
                    try {
                        Messaging.sendEmail(sendEmailList);
                    } catch(Exception e) {
                        for (SObject v_newRecord : p_newRecords) {
                            v_newRecord.addError(e.getMessage());
                        }
                    }
                }
              
                if (! recordActivities.isEmpty()) {
                    insert recordActivities;
                }
            }
        }
    }
    
    public static void relations(sObject recordNew, sObject recordOld, List<Schema.FieldSetMember> objectFields) {
        for(Schema.FieldSetMember f : objectFields) {
            recordNew.put(f.getFieldPath(), recordOld.get(f.getFieldPath())); 
        }
    }
  
    public static void relationsStatic(sObject recordNew, sObject recordOld, Set<Schema.SObjectField> objectStaticFields) {
        for(Schema.SObjectField fr : objectStaticFields) {
            recordNew.put(fr.getDescribe().getName(), recordOld.get(fr.getDescribe().getName())); 
        }
    }
  
    public static void checkChangesForProductActivity (SObject dataChangeActivity, SObject recordNew, SObject recordOld, Boolean reject, List<Schema.FieldSetMember> objectFields) {  
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
     
    public static List<Messaging.SingleEmailMessage> sendEmail(String addressee, id recordId, String objectLabel, SObject record, List<DCA_Manager__c> dcaManagerList, List<Profile> profileList, 
            List<Group> groupList, List<UserRole> roleList, Map<Id, User> userMapVar, Map<String, List<DCA_Filter__c>> dcaFilterMap, String recType, Map<Id, RecordType> recTypeMap, 
            String dcaObjectRecTypes, List<Approval_List__c> insAPList, Map<Id, SObject> objectOriginalRecordMap ) {
        Map<String, Schema.SObjectField> objectFields = record.getSObjectType().getDescribe().fields.getMap();
        List<Messaging.SingleEmailMessage> returnListMessaging = new List<Messaging.SingleEmailMessage>();
        Set<User> usr = new Set<User>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> profileSet = new Set<Id>();
        Set<Id> groupSet = new Set<Id>();
        Set<Id> roleSet = new Set<Id>();  
        
        List<DCA_Manager__c> debugList;

        Set<String> profileSetBuf = new Set<String>();

        for (Profile p : profileList) {
            profileSetBuf.add(p.Id);
        }
        
        Map<Id,List<GroupMember>> groupMap = new Map<Id,List<GroupMember>>();

        for (Group g : groupList) {
            groupMap.put(g.Id, g.GroupMembers);
        }
        
        Set<String> roleSetBuf = new Set<String>();

        for (UserRole ur : roleList) {
            roleSetBuf.add(ur.Id);
        }

        for (DCA_Manager__c dcaMan : dcaManagerList) {
            Boolean isObject = false;
            if (! String.isEmpty(dcaMan.Objects__c)) {
                if (dcaMan.Objects__c == 'All') {
                    isObject = true;
                } else {
                    List<String> selObjects = dcaMan.Objects__c.split(',');

                    String objectLabelForManagerAll;
                    String objectLabelForManager;
                    
                    if (! String.isEmpty(recType)) {
                        objectLabelForManagerAll = objectLabel + ';All';
                        objectLabelForManager = objectLabel + ';' + recTypeMap.get(recType).Name;
                    } else {
                        objectLabelForManagerAll = objectLabel;
                        objectLabelForManager = objectLabel;
                    }

                    for (String obj : selObjects) {
                        if (obj == objectLabelForManagerAll || obj == objectLabelForManager) {
                            isObject = true;
                            break;
                        }
                    }
                }
            }

            Boolean isFilter = true;

            if (! dcaFilterMap.isEmpty()) {
                if (dcaFilterMap.containsKey(dcaMan.Id)) {
                    if (! dcaFilterMap.get(dcaMan.Id).isEmpty()) {
                        for (DCA_Filter__c dcaF : dcaFilterMap.get(dcaMan.Id)) {
                            if (dcaObjectRecTypes.length() > 0) {
                                if (dcaObjectRecTypes.contains('[All]')) {
                                    if (! checkFilterForRecord(record, dcaF, objectFields)) {
                                        isFilter = false;
                                        break;
                                    }
                                } else {
                                    System.debug(':::dcaF.Object_Name__c:::::' + dcaF.Object_Name__c);
                                    System.debug(':::objectLabel:::::' + objectLabel);
                                    System.debug(':::recTypeMap.get(recType):::::' + recTypeMap.get(recType).Name);
                                    if (dcaF.Object_Name__c == objectLabel + ';' + recTypeMap.get(recType).Name) {
                                        if (! checkFilterForRecord(record, dcaF, objectFields)) {
                                            isFilter = false;
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        isFilter = true;
                    }
                } else {
                    isFilter = true;
                }
            } else {
                isFilter = true;
            }
            
            if (isObject && isFilter) {

                if (dcaMan.Type__c == 'Profile') {
                    if (profileSetBuf.contains(dcaMan.Profile__c)) {
                        profileSet.add(dcaMan.Profile__c);
                        System.debug('++++++++Profile_c++++++++' + dcaMan.Profile__c);
                    }   
                } else if (dcaMan.Type__c == 'Public Group') {
                    if (groupMap.containsKey(dcaMan.Public_Group__c)) {
                        List<GroupMember> gmList = groupMap.get(dcaMan.Public_Group__c);
                        
                        for (GroupMember gm : gmList) {
                            groupSet.add(gm.UserOrGroupId);
                        }
                    }
                } else if (dcaMan.Type__c == 'UserRole') {
                    if (roleSetBuf.contains(dcaMan.UserRole__c)) {
                        roleSet.add(dcaMan.UserRole__c);
                    }
                } else if (dcaMan.Type__c == 'User') {
                    if (userMapVar.containsKey(dcaMan.User__c)) {
                        userIdSet.add(dcaMan.User__c);
                    }
                }
            }
        }
        System.debug('++++++++User++++++++' + userIdSet);
        System.debug('++++++++Role++++++++' + roleSet);
        System.debug('++++++++Group++++++++' + groupSet);
        System.debug('++++++++Profile++++++++' + profileSet);

        for (Id user: userIdSet) {
            if(userMapVar.containsKey(user)) {
                usr.add(userMapVar.get(user));
            }
        }

        for (Id user: groupSet) {
            if(userMapVar.containsKey(user)) {
                usr.add(userMapVar.get(user));
            }
        }
        // We need another solution, because this solution slowly 
        for (Id roleId: roleSet) {
            for (User user: userMapVar.values()) {
                if(user.UserRoleId == roleId) {
                    usr.add(user);
                }
            }   
        }
        // We need another solution, because this solution slowly 
        for (Id prId: profileSet) {
            for (User user: userMapVar.values()) {
                if(user.ProfileId == prId) {
                    usr.add(user);
                }
            }   
        }

        
        /*usr = new Set<User> ([
            SELECT Email
            FROM User
            WHERE Id IN :userIdSet 
                OR Id IN :groupSet
                    OR ProfileId IN :profileSet
                        OR UserRoleId IN :roleSet
        ]);*/


        String currentLabelWithoutSpaces = objectLabel.replaceAll( '\\s+', '');
        
        if (addressee == 'toManager') {

            String recName = '';
            if (objectLabel == 'Contact') {
                if (String.valueOf(record.get('FirstName')) != null) {
                    recName = String.valueOf(record.get('FirstName')) + ' ' + String.valueOf(record.get('LastName'));    
                } else {
                    recName = String.valueOf(record.get('LastName'));    
                }
                
            } else {
                recName = String.valueOf(record.get('Name'));
                if(recName == null) {
                    if( ! objectOriginalRecordMap.isEmpty()
                        && objectOriginalRecordMap.containsKey(String.valueOf(record.get('Original_Record_Id__c')))) {
                        String keyForMap = String.valueOf(record.get('Original_Record_Id__c'));
                        SObject sobj = objectOriginalRecordMap.get(keyForMap);
                       recName = String.valueOf(sobj.get('Name'));
                    }
                }
            }

            String urlPrefix = URL.getSalesforceBaseUrl().getHost().split('\\.')[1];
            if (urlPrefix.contains('salesforce')) {
                urlPrefix = URL.getSalesforceBaseUrl().getHost().split('\\.')[0];
            }

            String recordURL = 'https://' + urlPrefix + '.salesforce.com/apex/DCA_Edit?scontrolCaching=1&id=' + recordId + ''; 
            String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';          

            Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage>();
            System.debug('====' + usr);
            for (User u : usr) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setToAddresses(new String[] {u.Email});
                    mail.setSubject('Please approve the changes in ' + objectLabel);
                    mail.setHtmlBody('Please approve the changes in ' + recordHyperlink);
                // Add the email
                emailList.add(mail);
            }
            returnListMessaging.addAll(emailList);
            
            String linkToRecord = 'https://' + urlPrefix + '.salesforce.com/' + recordId;
            String linkToUser = 'https://' + urlPrefix + '.salesforce.com/' + userInfo.getUserId();

            System.debug('+++++++++++++++++++++++++' + recName);
            Approval_List__c approvalList = new Approval_List__c (
                Object__c = objectLabel,
                User_Link__c = linkToUser,
                User_Name__c = userInfo.getName(),
                Approval_Link__c = recordURL,
                Link_to_Record__c = linkToRecord,
                Record_Name__c = recName
            );      

            if (! String.isEmpty(recType)) {
                approvalList.Record_Type_Name__c = recTypeMap.get(recType).Name;
            }
              
            insAPList.add(approvalList);
            //insert approvalList;
        }
    
        if (addressee == 'toManagerCreate') {
            
            String recName = '';
            if (objectLabel == 'Contact') {
                if (String.valueOf(record.get('FirstName')) != null) {
                    recName = String.valueOf(record.get('FirstName')) + ' ' + String.valueOf(record.get('LastName'));    
                } else {
                    recName = String.valueOf(record.get('LastName'));    
                }
                
            } else {
                recName = String.valueOf(record.get('Name'));
            }

            String urlPrefix = URL.getSalesforceBaseUrl().getHost().split('\\.')[1];
            if (urlPrefix.contains('salesforce')) {
                urlPrefix = URL.getSalesforceBaseUrl().getHost().split('\\.')[0];
            }
            
            String recordURL = 'https://' + urlPrefix + '.salesforce.com/apex/DCA_Create?scontrolCaching=1&id=' + recordId + '&'; 
            String recordHyperlink = '<a href="' + recordURL + '">' + objectLabel + '</a>';  
              
            Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage>();
                    
            for (User u : usr) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setToAddresses(new String[] {u.Email});
                    mail.setSubject('Please approve ' +  objectLabel +  ' record.');
                    mail.setHtmlBody('Please approve ' +  recordHyperlink +  ' record.');
        
                // Add the email
                emailList.add(mail);
            }
          
            List<Messaging.SendEmailResult> sendEmailResultList = new List< Messaging.SendEmailResult>();
            returnListMessaging.addAll(emailList);

            String linkToRecord = 'https://' + urlPrefix + '.salesforce.com/' + recordId;
            String linkToUser = 'https://' + urlPrefix + '.salesforce.com/' + userInfo.getUserId();
            
            System.debug('+++++++++++++++++++++++++' + recName);

            Approval_List__c approvalList = new Approval_List__c (
                Object__c = objectLabel,
                User_Link__c = linkToUser,
                User_Name__c = userInfo.getName(),
                Approval_Link__c = recordURL,
                Link_to_Record__c = linkToRecord,
                Record_Name__c = recName
            );  

            if (! String.isEmpty(recType)) {
                approvalList.Record_Type_Name__c = recTypeMap.get(recType).Name;
            }

            insAPList.add(approvalList);
            //insert approvalList;
        }

        return returnListMessaging;
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
                    System.debug('::::filter.Operator__c::::' + filter.Operator__c);
                    String fieldType = String.valueOf(sobjFieldMap.get(filter.Field__c).getDescribe().getType());
                    System.debug('::::fieldType::::' + fieldType);
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
                        System.debug('::::fieldType::2::' + fieldType);
                        System.debug('::::Double.valueOf(rec.get(filter.Field__c)::::' + Double.valueOf(rec.get(filter.Field__c)));
                            System.debug('::::Double.valueOf(filter.Value__c)::::' + Double.valueOf(filter.Value__c));
                        if (Double.valueOf(rec.get(filter.Field__c)) > Double.valueOf(filter.Value__c)) {
                            isFilterResult = true;    
                        }
                    }
                    System.debug('::::isFilterResult::::' + isFilterResult);
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
}
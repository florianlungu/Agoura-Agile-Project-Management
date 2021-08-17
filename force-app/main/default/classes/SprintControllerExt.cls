public with sharing class SprintControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public List<AgouraFree__ProjectTask__c> items { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String typeKey { get;set; }       
    }
    
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }   
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AgouraFree__Sprint__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c FROM AgouraFree__Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getEndDate(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__End_Date__c FROM AgouraFree__Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__Sprint__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__Sprint__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree__Project__c> getProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, AgouraFree__Title__c
                FROM AgouraFree__Project__c
                WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__Project__c> getDefaultProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, AgouraFree__Title__c
                FROM AgouraFree__Project__c
                WHERE Id = :recId
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getDefaultFields(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Sprint_Length__c, AgouraFree__Work_Days_Report__c, AgouraFree__Target_Points__c, AgouraFree__Version__c, AgouraFree__End_Date__c
                FROM AgouraFree__Sprint__c
                WHERE AgouraFree__Project__c = :recId
                ORDER BY CreatedDate DESC
                LIMIT 1]; 
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> projectSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AgouraFree__Project__c (Id, Name, AgouraFree__Title__c WHERE Id NOT IN :selectedIds ORDER BY AgouraFree__Title__c)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__Project__c [] projects = ((List<AgouraFree__Project__c>) searchResults[0]);
        for (AgouraFree__Project__c project : projects) {
            results.add(new AgouraFree.LookupSearchResult(project.Id, 'AgouraFree__Project__c', 'standard:drafts', project.AgouraFree__Title__c, 'Project • ' + project.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<String> getStatuses() {
        Schema.DescribeFieldResult result = AgouraFree__ProjectTask__c.AgouraFree__Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getTypeKeys() {
        Schema.DescribeFieldResult result = AgouraFree__ProjectTask__c.AgouraFree__Type__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }    
    
    @AuraEnabled
    public static PagedResult getProjectTasks(String filters, Decimal pageSize, Decimal pageNumber, Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, SprintControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String key = '%' + filter.searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        r.total = [SELECT count() FROM AgouraFree__ProjectTask__c
                   WHERE AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :sprintId)
                   AND AgouraFree__Sprint__c = ''
                   AND AgouraFree__Status__c NOT IN ('Canceled','Resolved','Done')
                   AND AgouraFree__Title__c LIKE :key
                   AND AgouraFree__Type__c like : (filter.typeKey  == '' ? '%' : filter.typeKey )];
        r.items = [SELECT Id, AgouraFree__Swim_Lane__r.Name, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c, 
                   AgouraFree__Status__c, AgouraFree__Points__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, AgouraFree__Project__c, AgouraFree__Formatted_Status__c 
                   FROM AgouraFree__ProjectTask__c
                   WHERE AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :sprintId)
                   AND AgouraFree__Sprint__c = ''
                   AND AgouraFree__Status__c NOT IN ('Canceled','Resolved','Done')
                   AND AgouraFree__Title__c LIKE :key
                   AND AgouraFree__Type__c like : (filter.typeKey  == '' ? '%' : filter.typeKey )
                   ORDER BY AgouraFree__Order__c, AgouraFree__Task_Number_Int__c, AgouraFree__Title__c
                   LIMIT :pSize OFFSET :offset];
        RETURN r;
    }  
    
    @AuraEnabled
    public static List<AgouraFree__ProjectTask__c> getSprintTaskItems(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, AgouraFree__Swim_Lane__c, AgouraFree__Swim_Lane__r.AgouraFree__Title__c, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, 
                AgouraFree__Formatted_Type__c, AgouraFree__Status__c, AgouraFree__Points__c, AgouraFree__Assigned_To__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, 
                AgouraFree__Project__c, AgouraFree__Formatted_Status__c
                FROM AgouraFree__ProjectTask__c
                WHERE AgouraFree__Sprint__c = :sprintId
                AND AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :sprintId)
                ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Task_Number_Int__c, AgouraFree__Title__c];        
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTask__c updateSprintTaskItem(Id sprintTaskId, Id sprintId, String doAction) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Formatted_Status__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Assigned_To__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Start_Date__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Resolution__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Resolved_Date__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Blocked__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__End_Date__c.isUpdateable() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Remaining__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isUpdateable() ||             
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AgouraFree__ProjectTask__c projectTask = [SELECT Id, AgouraFree__Type__c, AgouraFree__Status__c, AgouraFree__Project__c, AgouraFree__Sprint__c 
                                              FROM AgouraFree__ProjectTask__c WHERE Id = :sprintTaskId];
        Date thisDay = Date.today();
        List<String> sprintIds = new List<String>();  
        if (projectTask.Sprint__c != null) {
            sprintIds.add(String.valueOf(projectTask.AgouraFree__Sprint__c));
        }
        if (sprintId != null) {
            if (sprintIds.indexOf(String.valueOf(sprintId)) < 0) {
                sprintIds.add(String.valueOf(sprintId));
            }
        }
        
        if (doAction == 'Start') {
            if (projectTask.AgouraFree__Status__c == 'Open') {
                projectTask.AgouraFree__Status__c = 'In Progress';
                projectTask.AgouraFree__Formatted_Status__c = 'inprogress';
                projectTask.AgouraFree__Assigned_To__c = UserInfo.getUserId();
                projectTask.AgouraFree__Start_Date__c = thisDay;      
                update projectTask;
            }
        } else if (doAction == 'Complete') {
            if (projectTask.AgouraFree__Type__c == 'Bug') {
                projectTask.AgouraFree__Status__c = 'Resolved';
                projectTask.AgouraFree__Formatted_Status__c = 'resolved'; 
                projectTask.AgouraFree__Resolution__c = 'Fixed';
                projectTask.AgouraFree__Resolved_Date__c = thisDay;   
            } else {
                projectTask.AgouraFree__Status__c = 'Done';  
                projectTask.AgouraFree__Formatted_Status__c = 'done';   
                projectTask.AgouraFree__Resolution__c = null;
                projectTask.AgouraFree__Resolved_Date__c = null; 
            }            
            projectTask.AgouraFree__Blocked__c = false;
            projectTask.AgouraFree__End_Date__c = thisDay;
            projectTask.AgouraFree__Order__c = Null;
            projectTask.AgouraFree__Time_Remaining__c = Null;
            update projectTask;            
        } else if (doAction == 'Remove') {
            projectTask.AgouraFree__Sprint__c = null;      
            update projectTask;
        } else if (doAction == 'AddItem') {
            projectTask.AgouraFree__Sprint__c = sprintId;        
            update projectTask;
        }
        
        if (doAction == 'Complete') {
            // update sort order of all project tasks in batches of 1000
            Id projectId = projectTask.AgouraFree__Project__c;
            Integer taskTotal = [SELECT Count()  
                                 FROM AgouraFree__ProjectTask__c
                                 WHERE AgouraFree__Project__c = :projectId 
                                 AND AgouraFree__Order__c != NULL];
            Integer loopTimes = (Integer)Math.ceil(taskTotal/1000.0);
            List<AgouraFree__ProjectTask__c> newList = new List<AgouraFree__ProjectTask__c>();
            decimal goodIndex = 1;
            for (Integer i = 0; i < loopTimes; i++) {
                Integer loopStart = i * 1000;
                Integer loopEnd = loopStart + 999;
                if (loopTimes == (i + 1) ) {
                    loopEnd = 999999;
                }
                list<AgouraFree__ProjectTask__c> origList = [SELECT Id, AgouraFree__Order__c 
                                                         FROM AgouraFree__ProjectTask__c
                                                         WHERE AgouraFree__Project__c = :projectId
                                                         AND AgouraFree__Order__c >= :loopStart
                                                         AND AgouraFree__Order__c <= :loopEnd
                                                         ORDER BY AgouraFree__Order__c
                                                         LIMIT 2000];
                Integer arrayLength = origList.size();            
                for (Integer j = 0; j < arrayLength; j++) {
                    decimal thisOrder = origList[j].AgouraFree__Order__c;
                    if (thisOrder != goodIndex) {
                        AgouraFree__ProjectTask__c resultItem = new AgouraFree__ProjectTask__c(Id=origList[j].Id);   
                        resultItem.AgouraFree__Order__c = goodIndex;
                        newList.add(resultItem);    
                    } 
                    goodIndex += 1;
                }    
                update newList; 
                newList.clear();    
            }
        }
        
        // update sprint completed field
        if (doAction == 'Complete' || doAction == 'Remove') {
            for (Integer i = 0; i < sprintIds.size(); i++) {
                if (sprintIds[i] != '') {
                    // sum the points of completed tasks
                    AgouraFree__Sprint__c Sprnt = [SELECT id, AgouraFree__Completed_Points__c 
                                               FROM AgouraFree__Sprint__c 
                                               WHERE Id = :sprintIds[i]]; 
                    AggregateResult taskTotal = [SELECT Sum(AgouraFree__Points__c) completedPoints 
                                                 FROM AgouraFree__ProjectTask__c
                                                 WHERE AgouraFree__Sprint__c = :sprintIds[i]
                                                 AND AgouraFree__Status__c IN ('Resolved','Done')];
                    Integer completedPointsValue = Integer.valueOf((taskTotal.get('completedPoints')));
                    if (Sprnt.AgouraFree__Completed_Points__c != completedPointsValue) {
                        Sprnt.AgouraFree__Completed_Points__c = completedPointsValue;
                        update Sprnt;
                    }
                }
            }     
        }
        RETURN projectTask;
    } 
    
    @AuraEnabled
    public static AgouraFree__ProjectTask__c updateTaskSwimLane(Id sprintTaskId, Id swimLaneId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Swim_Lane__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        } 
        
        AgouraFree__ProjectTask__c projectTask = [SELECT Id, AgouraFree__Swim_Lane__c from AgouraFree__ProjectTask__c WHERE Id = :sprintTaskId];
        projectTask.AgouraFree__Swim_Lane__c = swimLaneId;        
        update projectTask;
        RETURN projectTask;
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getTargetPoints(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Target_Points__c FROM AgouraFree__Sprint__c WHERE Id = :sprintId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getStartDate(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }        
        
        RETURN [SELECT AgouraFree__Start_Date__c, AgouraFree__End_Date__c, AgouraFree__Sprint_Length__c, AgouraFree__Target_Points__c, AgouraFree__Work_Days_Report__c 
                FROM AgouraFree__Sprint__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AggregateResult> getCompletedPoints(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT SUM(AgouraFree__Points__c) points, AgouraFree__End_Date__c 
                FROM AgouraFree__ProjectTask__c 
                WHERE AgouraFree__Status__c IN ('Resolved','Done')
                AND AgouraFree__Sprint__c = :sprintId
                GROUP BY AgouraFree__End_Date__c
                ORDER BY AgouraFree__End_Date__c]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectSwimLanes(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, AgouraFree__Title__c
                FROM AgouraFree__ProjectItem__c
                WHERE AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :recId)
                AND AgouraFree__Type__c = 'Project Swim Lane'
                ORDER BY AgouraFree__Title__c]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getAssignedToList(Id recId) {
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__Assigned_To__c FROM AgouraFree__ProjectTask__c WHERE AgouraFree__Sprint__c = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Assigned To'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static Boolean removeAccess(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Id userId = UserInfo.getUserId();
        Boolean hasRemoveAccess = false;
        List<AgouraFree__Project__c> projects = [SELECT Id
                                             FROM AgouraFree__Project__c
                                             WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__Sprint__c WHERE Id = :recId)
                                             AND (AgouraFree__Product_Owner__c = :userId OR AgouraFree__Scrum_Master__c = :userId)
                                             LIMIT 1]; 
        if (projects.size() == 1) {
            hasRemoveAccess = true;
        }
        RETURN hasRemoveAccess;
    }
    
    @AuraEnabled
    public static void doCloseSprint(Id recId, FeedItem newPost, Boolean postChatter) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'Id'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        }
        
        list<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Sprint__c 
                                                 FROM AgouraFree__ProjectTask__c
                                                 WHERE AgouraFree__Sprint__c = :recId
                                                 AND AgouraFree__Status__c IN ('Open','In Progress','Ready to Test','Testing','Ready to Deploy')];
        for (AgouraFree__ProjectTask__c task : taskList) {
            task.AgouraFree__Sprint__c = null;
        }        
        update taskList; 
        if (postChatter == true) {
            insert newPost;
        }
    }
    
    @AuraEnabled
    public static AgouraFree__Sprint__c updateSprintNumberCompletedPoints(Id projectId, Id sprintId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Sprint_Number__c', 'AgouraFree__Completed_Points__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__Sprint__c .fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable() || !m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        }
        
        AgouraFree__Sprint__c tmpSprint = new AgouraFree__Sprint__c();
        
        if (String.valueOf(projectId) != null) {
         
            // assign the next sprint number 
            if (String.valueOf(sprintId) == null) {
                list<AgouraFree__Sprint__c> Sprnt = [SELECT AgouraFree__Sprint_Number__c 
                                                 FROM AgouraFree__Sprint__c 
                                                 WHERE AgouraFree__Project__c = :projectId
                                                 ORDER BY AgouraFree__Sprint_Number__c DESC LIMIT 1];                
                if(Sprnt.size() > 0) {
                    Integer nextSprintNumber = Integer.valueOf(Sprnt[0].AgouraFree__Sprint_Number__c)+1;
                    tmpSprint.AgouraFree__Sprint_Number__c = nextSprintNumber;
                } else {
                    tmpSprint.AgouraFree__Sprint_Number__c = 1;
                } 
            }
            
            // sum the points of completed tasks
            if (String.valueOf(sprintId) != null) {
                AgouraFree__Sprint__c Sprnt = [SELECT Id, AgouraFree__Sprint_Number__c, AgouraFree__Completed_Points__c 
                                           FROM AgouraFree__Sprint__c 
                                           WHERE AgouraFree__Project__c = :projectId
                                           AND Id = :sprintId]; 
                if (Sprnt != null) {
                    AggregateResult sprintTotal = [SELECT Sum(AgouraFree__Points__c) completedPoints 
                                                   FROM AgouraFree__ProjectTask__c
                                                   WHERE AgouraFree__Project__c = :projectId 
                                                   AND AgouraFree__Sprint__c = :sprintId
                                                   AND AgouraFree__Status__c IN ('Resolved','Done')];
                    Integer completedPointsValue = Integer.valueOf((sprintTotal.get('completedPoints')));
                    tmpSprint.AgouraFree__Completed_Points__c = completedPointsValue;
                    tmpSprint.AgouraFree__Sprint_Number__c = Sprnt.AgouraFree__Sprint_Number__c;
                }
            }
        }
        
        RETURN tmpSprint;
    }
    
    @AuraEnabled        
    public static Map<String, String> getFieldLabelMap(String objectName, List<String> fieldList){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        for(String  fieldName : fieldList) {                 
            fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());                
        }
        return fieldLabelMap;
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getCurrentSprint(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Project__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Number__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Length__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Target_Points__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Start_Date__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__End_Date__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Version__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Goal__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Name__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_went_well__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_did_not_go_well__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_can_we_do_different_next_time__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Title__c.isAccessible() ||
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        Date thisDay = Date.today();
        List<AgouraFree__Sprint__c> currentSprint =  [SELECT Id, Name, AgouraFree__Project__c, AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c, 
                                                  AgouraFree__Sprint_Length__c, AgouraFree__Target_Points__c, AgouraFree__Completed_Points__c, AgouraFree__Start_Date__c, 
                                                  AgouraFree__End_Date__c, AgouraFree__Version__c, AgouraFree__Sprint_Goal__c, AgouraFree__Sprint_Name__c, 
                                                  AgouraFree__What_went_well__c, AgouraFree__What_did_not_go_well__c, AgouraFree__What_can_we_do_different_next_time__c
                                                  FROM AgouraFree__Sprint__c 
                                                  WHERE AgouraFree__Project__c = :projectId
                                                  AND AgouraFree__Start_Date__c <= :thisDay AND (AgouraFree__End_Date__c = null OR AgouraFree__End_Date__c >= :thisDay)
                                                  ORDER BY AgouraFree__Sprint_Number__c DESC LIMIT 1];
        if (currentSprint.size() == 0) {
            currentSprint =  [SELECT Id, Name, AgouraFree__Project__c, AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c, 
                              AgouraFree__Sprint_Length__c, AgouraFree__Target_Points__c, AgouraFree__Completed_Points__c, AgouraFree__Start_Date__c, 
                              AgouraFree__End_Date__c, AgouraFree__Version__c, AgouraFree__Sprint_Goal__c, AgouraFree__Sprint_Name__c, 
                              AgouraFree__What_went_well__c, AgouraFree__What_did_not_go_well__c, AgouraFree__What_can_we_do_different_next_time__c
                              FROM AgouraFree__Sprint__c 
                              WHERE AgouraFree__Project__c = :projectId
                              ORDER BY AgouraFree__Sprint_Number__c DESC LIMIT 1];            
        }
        return currentSprint;
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getSprint(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Project__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Number__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Length__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Target_Points__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Start_Date__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__End_Date__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Version__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Goal__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Sprint_Name__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_went_well__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_did_not_go_well__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__What_can_we_do_different_next_time__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.Id.isAccessible() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Title__c.isAccessible() ||
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        List<AgouraFree__Sprint__c> sprint = new List<AgouraFree__Sprint__c>();
        sprint =  [SELECT Id, Name, AgouraFree__Project__c, AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c, 
                   AgouraFree__Sprint_Length__c, AgouraFree__Target_Points__c, AgouraFree__Completed_Points__c, AgouraFree__Start_Date__c, 
                   AgouraFree__End_Date__c, AgouraFree__Version__c, AgouraFree__Sprint_Goal__c, AgouraFree__Sprint_Name__c, 
                   AgouraFree__What_went_well__c, AgouraFree__What_did_not_go_well__c, AgouraFree__What_can_we_do_different_next_time__c
                   FROM AgouraFree__Sprint__c 
                   WHERE Id = :sprintId];
        return sprint;
    }
    
    @AuraEnabled
    public static AgouraFree__Sprint__c removeProjectSprint(Id sprintId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__Sprint__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__Sprint__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }       
        
        List<AgouraFree__Sprint__c> deleteMe = [SELECT Id FROM AgouraFree__Sprint__c WHERE Id = :sprintId];
        delete deleteMe;
        RETURN null;
    }
}
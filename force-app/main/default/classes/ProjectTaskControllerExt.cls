public with sharing class ProjectTaskControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    // User record access
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }  
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AgouraFree__ProjectTask__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectTask__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Status__c, AgouraFree__Blocked__c, AgouraFree__Type__c,
                AgouraFree__Time_Estimate__c, AgouraFree__Time_Logged__c, AgouraFree__Time_Remaining__c
                FROM AgouraFree__ProjectTask__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__Assigned_To__c FROM AgouraFree__ProjectTask__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Assigned To'));
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
                WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectTask__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__Sprint__c> getSprint(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Sprint_Name__c
                FROM AgouraFree__Sprint__c
                WHERE Id IN (SELECT AgouraFree__Sprint__c FROM AgouraFree__ProjectTask__c WHERE Id = :recId)
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectTask__c> getMasterTask(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Master_Task__c, AgouraFree__Master_Task__r.Name, AgouraFree__Master_Task__r.AgouraFree__Task_Number__c
                FROM AgouraFree__ProjectTask__c
                WHERE Id = :recId
                LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectTask__c> getSubTasks(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, AgouraFree__Task_Number__c
                FROM AgouraFree__ProjectTask__c
                WHERE AgouraFree__Master_Task__c = :recId]; 
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
    public static void doStartWork(Id taskId){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Status__c', 'AgouraFree__Formatted_Status__c', 'AgouraFree__Assigned_To__c', 'AgouraFree__Start_Date__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }        
        
        AgouraFree__ProjectTask__c projectTask = New AgouraFree__ProjectTask__c(Id=taskId);
        projectTask.AgouraFree__Status__c = 'In Progress';
        projectTask.AgouraFree__Formatted_Status__c = 'inprogress';
        projectTask.AgouraFree__Assigned_To__c = UserInfo.getUserId();
        Date thisDay = Date.today();
        projectTask.AgouraFree__Start_Date__c = thisDay;
        update projectTask;
    }
    
    @AuraEnabled
    public static void doAssignToMe(Id taskId){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Assigned_To__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }        
        
        AgouraFree__ProjectTask__c projectTask = New AgouraFree__ProjectTask__c(Id=taskId);
        projectTask.AgouraFree__Assigned_To__c = UserInfo.getUserId();
        update projectTask;
    }
    
    @AuraEnabled
    public static void doCompleteWork(Id taskId, Id sprintId, Id projectId){
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Blocked__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Remaining__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Formatted_Status__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Resolution__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Resolved_Date__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__End_Date__c.isUpdateable() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isUpdateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AgouraFree__ProjectTask__c projectTask = [SELECT Id, AgouraFree__Type__c FROM AgouraFree__ProjectTask__c WHERE Id = :taskId];
        projectTask.AgouraFree__Blocked__c = false;
        projectTask.AgouraFree__Order__c = Null;
        projectTask.AgouraFree__Time_Remaining__c = Null;
        Date thisDay = Date.today();
        projectTask.AgouraFree__End_Date__c = thisDay;
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
        update projectTask;

        updateOrderCompletedPoints(projectId, sprintId);
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> userOnlySearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name)                                          
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectSwimLanes(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Title__c
                FROM AgouraFree__ProjectItem__c 
                WHERE AgouraFree__Project__c = :projectId
                AND AgouraFree__Type__c = 'Project Swim Lane'
                ORDER BY AgouraFree__Title__c]; 
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> sprintSearch(String searchTerm, List<String> selectedIds, String recStr) {   
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm = '%' + searchTerm + '%';
        Id recId = Id.valueOf(recStr);
        List<AgouraFree__Sprint__c> sprints = [SELECT Id, Name, AgouraFree__Sprint_Name__c
                                           FROM AgouraFree__Sprint__c
                                           WHERE AgouraFree__Sprint_Name__c LIKE :searchTerm
                                           AND AgouraFree__Project__c = :recId
                                           AND Id NOT IN :selectedIds 
                                           ORDER BY AgouraFree__Sprint_Name__c
                                           LIMIT 12];    
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        for (AgouraFree__Sprint__c sprint : sprints) {
            results.add(new AgouraFree.LookupSearchResult(sprint.Id, 'AgouraFree__Sprint__c', 'standard:work_order', sprint.AgouraFree__Sprint_Name__c, 'Sprint • ' + sprint.Name));
        }
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> projectTaskSearch(String searchTerm, List<String> selectedIds, String recStr) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';
        Id recId = Id.valueOf(recStr);        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AgouraFree__ProjectTask__c (Id, Name, AgouraFree__Task_Number__c, AgouraFree__Title__c 
                                                                     WHERE AgouraFree__Project__c = :recId                                      
                                                                     AND Id NOT IN :selectedIds 
                                                                     ORDER BY AgouraFree__Task_Number__c)
                                             LIMIT 12];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__ProjectTask__c [] tasks = ((List<AgouraFree__ProjectTask__c>) searchResults[0]);
        for (AgouraFree__ProjectTask__c task : tasks) {
            results.add(new AgouraFree.LookupSearchResult(task.Id, 'AgouraFree__ProjectTask__c', 'standard:task', task.AgouraFree__Task_Number__c, task.Title__c));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<Account> getRelatedAccount(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name
                FROM Account
                WHERE Id IN (SELECT AgouraFree__Account__c FROM AgouraFree__ProjectTask__c WHERE Id = :recId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> accountSearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             Account (Id, Name WHERE Id NOT IN :selectedIds ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            results.add(new AgouraFree.LookupSearchResult(account.Id, 'Account', 'standard:account', account.Name, 'Account • ' + account.Id));
        }
        
        RETURN results;
    }
    
    // Project Task Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> tagSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Tag__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AgouraFree__Tag__c (Id, Name WHERE Id NOT IN :selectedIds AND AgouraFree__For_ProjectTasks__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__Tag__c [] tags = ((List<AgouraFree__Tag__c>) searchResults[0]);
        for (AgouraFree__Tag__c tag : tags) {
            results.add(new AgouraFree.LookupSearchResult(tag.Id, 'AgouraFree__Tag__c', 'standard:topic', tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }    
    
    @AuraEnabled
    public static List<AgouraFree__Tag__c> getProjectTaskTags(Id projectTaskId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Tag__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTaskTagAssoc__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM AgouraFree__Tag__c
                WHERE Id IN (SELECT AgouraFree__Tag__c FROM AgouraFree__ProjectTaskTagAssoc__c WHERE AgouraFree__Project_Task__c = :projectTaskId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTaskTagAssoc__c addProjectTaskTag(Id tagId, Id projectTaskId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Tag__c', 'AgouraFree__Project_Task__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTaskTagAssoc__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectTaskTagAssoc__c item = new AgouraFree__ProjectTaskTagAssoc__c();
        item.AgouraFree__Tag__c = tagId;
        item.AgouraFree__Project_Task__c = projectTaskId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTaskTagAssoc__c removeProjectTaskTag(Id tagId, Id projectTaskId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__ProjectTaskTagAssoc__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__ProjectTaskTagAssoc__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<AgouraFree__ProjectTaskTagAssoc__c> deleteMe = [SELECT Id FROM AgouraFree__ProjectTaskTagAssoc__c 
                                                         WHERE AgouraFree__Tag__c = :tagId AND AgouraFree__Project_Task__c = :projectTaskId];
        delete deleteMe;
        RETURN null;
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
    public static Id createCloneTask(Id recId, Id projectId) {   
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Accept__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Account__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Affected_Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Bug_Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Components__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Dependencies__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Description__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Due_Date__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Fix_Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Points__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Priority__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Reported_By__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Reported_Date__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__URL__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Value__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTaskTagAssoc__c.fields.AgouraFree__Tag__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTaskTagAssoc__c.fields.AgouraFree__Project_Task__c.isCreateable() ||            
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AgouraFree__ProjectTask__c projectTask = [SELECT AgouraFree__Title__c, AgouraFree__Description__c, AgouraFree__Type__c, AgouraFree__Points__c, AgouraFree__Reported_By__c, 
                                              AgouraFree__Reported_Date__c, AgouraFree__Swim_Lane__c, AgouraFree__Value__c, AgouraFree__Due_Date__c, AgouraFree__Priority__c, 
                                              AgouraFree__Bug_Type__c, AgouraFree__Accept__c, AgouraFree__Affected_Version__c, AgouraFree__Time_Estimate__c, AgouraFree__Version__c, 
                                              AgouraFree__Fix_Version__c, AgouraFree__Components__c, AgouraFree__Dependencies__c, AgouraFree__Comments__c, AgouraFree__Project__c, 
                                              AgouraFree__Master_Task__c, AgouraFree__Account__c, AgouraFree__URL__c
                                              FROM AgouraFree__ProjectTask__c
                                              WHERE Id = :recId
                                              LIMIT 1]; 
        AggregateResult[] taskOrderTotal = [SELECT MAX(AgouraFree__Order__c)lastNumber
                                            FROM AgouraFree__ProjectTask__c 
                                            WHERE AgouraFree__Project__c = :projectId];                 
        decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
        decimal nextOrderNumber = lastOrderNumber + 1;
        list<AgouraFree__Project__c> Project = [SELECT AgouraFree__Project_Abbreviation__c 
                                            FROM AgouraFree__Project__c 
                                            WHERE Id = :projectId 
                                            ORDER BY AgouraFree__Project_Abbreviation__c DESC LIMIT 1];
        string projectAbbreviation = Project[0].AgouraFree__Project_Abbreviation__c;
        AggregateResult[] taskTotal = [SELECT MAX(AgouraFree__Task_Number_Int__c)lastNumber
                                       FROM AgouraFree__ProjectTask__c 
                                       WHERE AgouraFree__Project__c = :projectId];                 
        decimal lastNumber = taskTotal[0].get('lastNumber') == null ? 0 : (decimal)taskTotal[0].get('lastNumber');                
        Integer nextTaskNumber = Integer.valueOf(lastNumber) + 1; 
        String titleStr = projectTask.AgouraFree__Title__c;
        
        AgouraFree__ProjectTask__c newProjectTask = new AgouraFree__ProjectTask__c (
            AgouraFree__Accept__c = projectTask.AgouraFree__Accept__c,
            AgouraFree__Account__c = projectTask.AgouraFree__Account__c,
            AgouraFree__Affected_Version__c = projectTask.AgouraFree__Affected_Version__c,
            AgouraFree__Bug_Type__c = projectTask.AgouraFree__Bug_Type__c,
            AgouraFree__Comments__c = projectTask.AgouraFree__Comments__c,
            AgouraFree__Components__c = projectTask.AgouraFree__Components__c,
            AgouraFree__Dependencies__c = projectTask.AgouraFree__Dependencies__c,
            AgouraFree__Description__c = projectTask.AgouraFree__Description__c,
            AgouraFree__Due_Date__c = projectTask.AgouraFree__Due_Date__c,
            AgouraFree__Fix_Version__c = projectTask.AgouraFree__Fix_Version__c,
            AgouraFree__Formatted_Status__c = 'open',
            AgouraFree__Master_Task__c = projectTask.AgouraFree__Master_Task__c,
            AgouraFree__Order__c = nextOrderNumber,
            AgouraFree__Points__c = projectTask.AgouraFree__Points__c,
            AgouraFree__Priority__c = projectTask.AgouraFree__Priority__c,
            AgouraFree__Project__c = projectId,
            AgouraFree__Reported_By__c = projectTask.AgouraFree__Reported_By__c,
            AgouraFree__Reported_Date__c = projectTask.AgouraFree__Reported_Date__c,
            AgouraFree__Status__c = 'Open',
            AgouraFree__Swim_Lane__c = projectTask.AgouraFree__Swim_Lane__c,
            AgouraFree__Task_Number__c = projectAbbreviation + '-' + nextTaskNumber,
            AgouraFree__Task_Number_Int__c = nextTaskNumber,
            AgouraFree__Time_Estimate__c = projectTask.AgouraFree__Time_Estimate__c,
            AgouraFree__Title__c = titleStr.left(248) + ' (Copy)',
            AgouraFree__Type__c = projectTask.AgouraFree__Type__c,
            AgouraFree__URL__c = projectTask.AgouraFree__URL__c,
            AgouraFree__Value__c = projectTask.AgouraFree__Value__c,
            AgouraFree__Version__c = projectTask.AgouraFree__Version__c);  
        insert newProjectTask;    
        
        // create tag association
        List<AgouraFree__ProjectTaskTagAssoc__c> projectTaskTagAssocList = [SELECT AgouraFree__Tag__c, AgouraFree__Project_Task__c                
                                                                        FROM AgouraFree__ProjectTaskTagAssoc__c
                                                                        WHERE AgouraFree__Project_Task__c = :recId];
        for (AgouraFree__ProjectTaskTagAssoc__c projectTaskTagAssoc : projectTaskTagAssocList) {
            AgouraFree__ProjectTaskTagAssoc__c newProjectTaskTagAssoc = new AgouraFree__ProjectTaskTagAssoc__c (
                AgouraFree__Tag__c = projectTaskTagAssoc.AgouraFree__Tag__c,
                AgouraFree__Project_Task__c = newProjectTask.Id);
            insert newProjectTaskTagAssoc;
        }
        RETURN newProjectTask.Id;
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTask__c saveProjectTaskData(Id recId, Id oldSprintId) { 
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Remaining__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Remaining__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Remaining__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Blocked__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Blocked__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Blocked__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AgouraFree__ProjectTask__c projectTaskData = [Select Id, AgouraFree__Task_Number__c, AgouraFree__Task_Number_Int__c, AgouraFree__Project__c, AgouraFree__Sprint__c,
                                                  AgouraFree__Status__c, AgouraFree__Order__c, AgouraFree__Time_Remaining__c
                                                  From AgouraFree__ProjectTask__c WHERE Id = :recId];
        Id projectId = projectTaskData.AgouraFree__Project__c;
        Id sprintId = projectTaskData.AgouraFree__Sprint__c;
                                                                
        // set task number if needed        
        if (projectTaskData.AgouraFree__Task_Number_Int__c == null) {
            list<AgouraFree__Project__c> Project = [SELECT AgouraFree__Project_Abbreviation__c 
                                                FROM AgouraFree__Project__c 
                                                WHERE Id = :projectId
                                                ORDER BY AgouraFree__Project_Abbreviation__c DESC LIMIT 1];
            string projectAbbreviation = Project[0].AgouraFree__Project_Abbreviation__c;
            AggregateResult[] taskTotal = [SELECT MAX(AgouraFree__Task_Number_Int__c)lastNumber
                                           FROM AgouraFree__ProjectTask__c 
                                           WHERE AgouraFree__Project__c = :projectId];                 
            decimal lastNumber = taskTotal[0].get('lastNumber') == null ? 0 : (decimal)taskTotal[0].get('lastNumber');                
            Integer nextTaskNumber = Integer.valueOf(lastNumber) + 1; 
            projectTaskData.AgouraFree__Task_Number__c = projectAbbreviation + '-' + nextTaskNumber;
            projectTaskData.AgouraFree__Task_Number_Int__c = nextTaskNumber;
        }
        
        // update sort order   
        if (projectTaskData.AgouraFree__Status__c == 'Canceled' || projectTaskData.AgouraFree__Status__c == 'Done' || projectTaskData.AgouraFree__Status__c == 'Resolved') {
            projectTaskData.AgouraFree__Blocked__c = false;
            projectTaskData.AgouraFree__Order__c = null;
            projectTaskData.AgouraFree__Time_Remaining__c = null;       
        } else {
            if (projectTaskData.AgouraFree__Order__c == null) {                
                AggregateResult[] taskOrderTotal = [SELECT MAX(AgouraFree__Order__c)lastNumber
                                                    FROM AgouraFree__ProjectTask__c 
                                                    WHERE AgouraFree__Project__c = :projectId];                 
                decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
                decimal nextOrderNumber = lastOrderNumber + 1; 
                projectTaskData.AgouraFree__Order__c = nextOrderNumber;
            }
        }        
        upsert projectTaskData;
        
        updateOrderCompletedPoints(projectId, sprintId);
                
        // sum the points of completed tasks in oldSprintId
        if (String.valueOf(sprintId) != String.valueOf(oldSprintId) && String.valueOf(oldSprintId) != null) {
            AgouraFree__Sprint__c Sprnt2 = [SELECT Id, AgouraFree__Completed_Points__c 
                                        FROM AgouraFree__Sprint__c 
                                        WHERE AgouraFree__Project__c = :projectId
                                        AND Id = :oldSprintId]; 
            if (Sprnt2 != null) {
                AggregateResult sprintTotal2 = [SELECT Sum(AgouraFree__Points__c) completedPoints 
                                                FROM AgouraFree__ProjectTask__c
                                                WHERE AgouraFree__Project__c = :projectId 
                                                AND AgouraFree__Sprint__c = :oldSprintId
                                                AND AgouraFree__Status__c IN ('Resolved','Done')];
                Integer completedPointsValue2 = Integer.valueOf((sprintTotal2.get('completedPoints')));
                if (Sprnt2.AgouraFree__Completed_Points__c != completedPointsValue2) {
                    Sprnt2.AgouraFree__Completed_Points__c = completedPointsValue2;
                    update Sprnt2;
                }
            }
        }
       
        RETURN projectTaskData;
    }
    
    @AuraEnabled
    public static void updateOrderCompletedPoints(Id projectId, Id sprintId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isUpdateable()) 
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        if (String.valueOf(projectId) != null) {
            // update sort order of all project tasks in batches of 1000
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
            
            // sum the points of completed tasks
            if (String.valueOf(sprintId) != null) {
                AgouraFree__Sprint__c Sprnt = [SELECT Id, AgouraFree__Completed_Points__c 
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
                    if (Sprnt.AgouraFree__Completed_Points__c != completedPointsValue) {
                        Sprnt.AgouraFree__Completed_Points__c = completedPointsValue;
                        update Sprnt;
                    }
                }
            }
        }
    }
        
    @AuraEnabled
    public static void updateOrder(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable()) 
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        if (String.valueOf(projectId) != null) {
            // update sort order of all project tasks in batches of 1000
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
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.Id.isAccessible() || 
            !Schema.sObjectType.FeedItem.isCreateable() || 
            !Schema.sObjectType.FeedItem.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        } 
        
        insert newPost;
    }
    
    @AuraEnabled
    public static void doMoveProjectTask(Id recId, Id projectId) { 
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isUpdateable() ||            
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isUpdateable() ||            
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Sprint__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Points__c.isAccessible() ||  
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Project_Abbreviation__c.isAccessible() ||  
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Sprint__c.fields.AgouraFree__Completed_Points__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        } 
        
        AgouraFree__ProjectTask__c projectTaskData = [Select Id, AgouraFree__Status__c, AgouraFree__Sprint__c, AgouraFree__Order__c
                                                  From AgouraFree__ProjectTask__c WHERE Id = :recId];
        Id oldSprintId = projectTaskData.AgouraFree__Sprint__c;
        list<AgouraFree__Project__c> Project = [SELECT AgouraFree__Project_Abbreviation__c 
                                            FROM AgouraFree__Project__c 
                                            WHERE Id = :projectId 
                                            ORDER BY AgouraFree__Project_Abbreviation__c DESC LIMIT 1];
        string projectAbbreviation = Project[0].AgouraFree__Project_Abbreviation__c;
        AggregateResult[] taskTotal = [SELECT MAX(AgouraFree__Task_Number_Int__c)lastNumber
                                       FROM AgouraFree__ProjectTask__c 
                                       WHERE AgouraFree__Project__c = :projectId];                 
        decimal lastNumber = taskTotal[0].get('lastNumber') == null ? 0 : (decimal)taskTotal[0].get('lastNumber');                
        Integer nextTaskNumber = Integer.valueOf(lastNumber) + 1; 
                
        AgouraFree__ProjectTask__c projectTask = New AgouraFree__ProjectTask__c(Id=recId);
        projectTask.AgouraFree__Master_Task__c = null;
        projectTask.AgouraFree__Project__c = projectId;
        projectTask.AgouraFree__Sprint__c = null;
        projectTask.AgouraFree__Swim_Lane__c = null;
        projectTask.AgouraFree__Task_Number__c = projectAbbreviation + '-' + nextTaskNumber;
        projectTask.AgouraFree__Task_Number_Int__c = nextTaskNumber;           
        
        // update sort order   
        if (projectTaskData.AgouraFree__Status__c == 'Canceled' || projectTaskData.AgouraFree__Status__c == 'Done' || projectTaskData.AgouraFree__Status__c == 'Resolved') {
            projectTask.AgouraFree__Order__c = null;      
        } else {              
            AggregateResult[] taskOrderTotal = [SELECT MAX(AgouraFree__Order__c)lastNumber
                                                FROM AgouraFree__ProjectTask__c 
                                                WHERE AgouraFree__Project__c = :projectId];                 
            decimal lastOrderNumber = taskOrderTotal[0].get('lastNumber') == null ? 0 : (decimal)taskOrderTotal[0].get('lastNumber'); 
            decimal nextOrderNumber = lastOrderNumber + 1; 
            projectTask.AgouraFree__Order__c = nextOrderNumber;
        } 
        update projectTask;
        
        // sum the points of completed tasks in oldSprintId
        if (String.valueOf(oldSprintId) != null) {
            AgouraFree__Sprint__c Sprnt2 = [SELECT Id, AgouraFree__Completed_Points__c 
                                        FROM AgouraFree__Sprint__c 
                                        WHERE Id = :oldSprintId]; 
            if (Sprnt2 != null) {
                AggregateResult sprintTotal2 = [SELECT Sum(AgouraFree__Points__c) completedPoints 
                                                FROM AgouraFree__ProjectTask__c
                                                WHERE AgouraFree__Sprint__c = :oldSprintId
                                                AND AgouraFree__Status__c IN ('Resolved','Done')];
                Integer completedPointsValue2 = Integer.valueOf((sprintTotal2.get('completedPoints')));
                if (Sprnt2.AgouraFree__Completed_Points__c != completedPointsValue2) {
                    Sprnt2.AgouraFree__Completed_Points__c = completedPointsValue2;
                    update Sprnt2;
                }
            }
        }
    }
    
    @AuraEnabled
    public static Boolean checkChatterEnabled() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('FeedItem');
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
}
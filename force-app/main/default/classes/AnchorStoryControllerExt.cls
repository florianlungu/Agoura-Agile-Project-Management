public with sharing class AnchorStoryControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AgouraFree__AnchorStory__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static List<AgouraFree__AnchorStory__c> getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Title__c, AgouraFree__Time_Estimate__c
                FROM AgouraFree__AnchorStory__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM AgouraFree__AnchorStory__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> anchorStorySearch(String searchTerm, List<String> selectedIds, String recStr) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AgouraFree__AnchorStory__c (Id, Name, AgouraFree__Title__c
                                                                     WHERE Id NOT IN :selectedIds AND Id != :recStr
                                                                     ORDER BY AgouraFree__Title__c) LIMIT 12];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__AnchorStory__c [] stories = ((List<AgouraFree__AnchorStory__c>) searchResults[0]);
        for (AgouraFree__AnchorStory__c story : stories) {
            results.add(new AgouraFree.LookupSearchResult(story.Id, 'AgouraFree__AnchorStory__c', 'standard:task', story.AgouraFree__Title__c, 'Anchor Story • ' + story.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree__AnchorStory__c> getMasterTask(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Master_Task__c, AgouraFree__Master_Task__r.Name, AgouraFree__Master_Task__r.AgouraFree__Title__c
                FROM AgouraFree__AnchorStory__c
                WHERE Id = :recId LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__AnchorStory__c> getSubTasks(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, AgouraFree__Title__c
                FROM AgouraFree__AnchorStory__c
                WHERE AgouraFree__Master_Task__c = :recId]; 
    }
    
    @AuraEnabled
    public static Id createCloneAnchorStory(Id recId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Acceptance_Criteria__c', 'AgouraFree__Comments__c', 'AgouraFree__Components__c', 'AgouraFree__Dependencies__c', 
            'AgouraFree__Description__c', 'AgouraFree__Master_Task__c', 'AgouraFree__Points__c', 'AgouraFree__Priority__c', 
            'AgouraFree__Search_Terms__c', 'AgouraFree__Time_Estimate__c', 'AgouraFree__Value__c', 'AgouraFree__Title__c', 'AgouraFree__Type__c', 'AgouraFree__URL__c' };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__AnchorStory__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable() || !m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__AnchorStory__c anchorStory = [SELECT AgouraFree__Acceptance_Criteria__c, AgouraFree__Comments__c, AgouraFree__Components__c, AgouraFree__Dependencies__c, 
                                              AgouraFree__Description__c, AgouraFree__Master_Task__c, AgouraFree__Points__c, AgouraFree__Priority__c, AgouraFree__Search_Terms__c, 
                                              AgouraFree__Time_Estimate__c, AgouraFree__Value__c, AgouraFree__Title__c, AgouraFree__Type__c, AgouraFree__URL__c                
                                              FROM AgouraFree__AnchorStory__c
                                              WHERE Id = :recId
                                              LIMIT 1];  
        String titleStr = anchorStory.AgouraFree__Title__c;
        
        AgouraFree__AnchorStory__c newAnchorStory = new AgouraFree__AnchorStory__c (
            AgouraFree__Title__c = titleStr.left(248) + ' (Copy)',
            AgouraFree__Acceptance_Criteria__c = anchorStory.AgouraFree__Acceptance_Criteria__c,
            AgouraFree__Comments__c = anchorStory.AgouraFree__Comments__c,
            AgouraFree__Components__c = anchorStory.AgouraFree__Components__c,
            AgouraFree__Dependencies__c = anchorStory.AgouraFree__Dependencies__c,
            AgouraFree__Description__c = anchorStory.AgouraFree__Description__c,
            AgouraFree__Master_Task__c = anchorStory.AgouraFree__Master_Task__c,
            AgouraFree__Points__c = anchorStory.AgouraFree__Points__c,
            AgouraFree__Priority__c = anchorStory.AgouraFree__Priority__c,
            AgouraFree__Search_Terms__c = anchorStory.AgouraFree__Search_Terms__c,
            AgouraFree__Time_Estimate__c = anchorStory.AgouraFree__Time_Estimate__c,
            AgouraFree__Type__c = anchorStory.AgouraFree__Type__c,
            AgouraFree__URL__c = anchorStory.AgouraFree__URL__c,
            AgouraFree__Value__c  = anchorStory.AgouraFree__Value__c );
        insert newAnchorStory;
        RETURN newAnchorStory.Id;
    }
    
    @AuraEnabled
    public static AgouraFree__AnchorStory__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
            Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__AnchorStory__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__AnchorStory__c item = [SELECT Id, OwnerId FROM AgouraFree__AnchorStory__c WHERE Id = :recId];
        item.OwnerId = userId;
        update item;
        RETURN item;
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
    public static Id doCreateProjectTask(Id recId, Id projectId) {  
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Accept__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Components__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Dependencies__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Description__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Points__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Priority__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__URL__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Value__c.isCreateable() ||            
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Acceptance_Criteria__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Comments__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Components__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Dependencies__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Description__c.isAccessible() ||           
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Priority__c.isAccessible() ||            
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Time_Estimate__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Title__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Type__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__URL__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__AnchorStory__c.fields.AgouraFree__Value__c.isAccessible() ||                    
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        AgouraFree__AnchorStory__c anchorStory = [SELECT AgouraFree__Acceptance_Criteria__c, AgouraFree__Comments__c, AgouraFree__Components__c, AgouraFree__Dependencies__c, 
                                              AgouraFree__Description__c, AgouraFree__Points__c, AgouraFree__Priority__c, AgouraFree__Time_Estimate__c, AgouraFree__Value__c, 
                                              AgouraFree__Title__c, AgouraFree__Type__c, AgouraFree__URL__c                
                                              FROM AgouraFree__AnchorStory__c
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
 
        AgouraFree__ProjectTask__c newProjectTask = new AgouraFree__ProjectTask__c (
            AgouraFree__Accept__c = anchorStory.AgouraFree__Acceptance_Criteria__c,
            AgouraFree__Comments__c = anchorStory.AgouraFree__Comments__c,
            AgouraFree__Components__c = anchorStory.AgouraFree__Components__c,
            AgouraFree__Dependencies__c = anchorStory.AgouraFree__Dependencies__c,
            AgouraFree__Description__c = anchorStory.AgouraFree__Description__c,
            AgouraFree__Formatted_Status__c = 'open',
            AgouraFree__Order__c = nextOrderNumber,
            AgouraFree__Points__c = anchorStory.AgouraFree__Points__c,
            AgouraFree__Priority__c = anchorStory.AgouraFree__Priority__c,
            AgouraFree__Project__c = projectId,
            AgouraFree__Status__c = 'Open',
            AgouraFree__Task_Number__c = projectAbbreviation + '-' + nextTaskNumber,
            AgouraFree__Task_Number_Int__c = nextTaskNumber,
            AgouraFree__Time_Estimate__c = anchorStory.AgouraFree__Time_Estimate__c,
            AgouraFree__Title__c = anchorStory.AgouraFree__Title__c,
            AgouraFree__Type__c = anchorStory.AgouraFree__Type__c,
            AgouraFree__URL__c = anchorStory.AgouraFree__URL__c,
            AgouraFree__Value__c = anchorStory.AgouraFree__Value__c);

        insert newProjectTask;   
        RETURN newProjectTask.Id;
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
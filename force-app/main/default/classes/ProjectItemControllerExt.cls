public with sharing class ProjectItemControllerExt {
    
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
        if (Schema.sObjectType.AgouraFree__ProjectItem__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c getWebPageTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Type__c, AgouraFree__Title__c FROM AgouraFree__ProjectItem__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__User__c FROM AgouraFree__ProjectItem__c WHERE Id = :recId)
                                     ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'AgouraFree__User__c'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static AgouraFree__Project__c getProject(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, Name, AgouraFree__Title__c
                FROM AgouraFree__Project__c
                WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE Id = :recId)
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
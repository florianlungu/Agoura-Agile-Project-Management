public with sharing class IdeaBoardControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
        
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AgouraFree__IdeaBoard__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    // Search methods
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
                                             AgouraFree__Tag__c (Id, Name WHERE id NOT IN :selectedIds AND AgouraFree__For_IdeaBoards__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__Tag__c [] tags = ((List<AgouraFree__Tag__c>) searchResults[0]);
        for (AgouraFree__Tag__c tag : tags) {
            results.add(new AgouraFree.LookupSearchResult(tag.Id, 'AgouraFree__Tag__c', 'standard:topic', 
                                                      tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> userSearch(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             User (Id, Name, Title, SmallPhotoUrl WHERE Id NOT IN :selectedIds ORDER BY Name),
                                             Group (Id, Name WHERE Type = 'Regular' AND Id NOT IN :selectedIds ORDER BY Name)                                             
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        User [] users = ((List<User>) searchResults[0]);
        for (User user : users) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'User • ' + user.Title));
        }
        
        Group [] groups = ((List<Group>) searchResults[1]);
        for (Group groupItem : groups) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Group • ' + groupItem.Name));
        }
        
        RETURN results;
    }
    
    // Idea Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<AgouraFree__Tag__c> getIdeaTags(Id ideaId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Tag__c.isAccessible() ||
            !Schema.sObjectType.AgouraFree__IdeaTagAssociation__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        
        RETURN [SELECT Id, Name
                FROM AgouraFree__Tag__c
                WHERE Id IN (SELECT AgouraFree__Tag__c FROM AgouraFree__IdeaTagAssociation__c WHERE AgouraFree__Idea_Board__c = :ideaId)
                AND AgouraFree__For_IdeaBoards__c = True
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static AgouraFree__IdeaTagAssociation__c addIdeaTag(Id tagId, Id ideaId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Tag__c', 'AgouraFree__Idea_Board__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__IdeaTagAssociation__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__IdeaTagAssociation__c item = new AgouraFree__IdeaTagAssociation__c();
        item.AgouraFree__Tag__c = tagId;
        item.AgouraFree__Idea_Board__c = ideaId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__IdeaTagAssociation__c removeIdeaTag(Id tagId, Id ideaId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__IdeaTagAssociation__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__IdeaTagAssociation__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<AgouraFree__IdeaTagAssociation__c> deleteMe = [SELECT Id FROM AgouraFree__IdeaTagAssociation__c WHERE AgouraFree__Tag__c = :tagId AND AgouraFree__Idea_Board__c = :ideaId];
        delete deleteMe;
        RETURN null;
    } 
    
    // Idea Project Association 
    @AuraEnabled
    public static List<sObject> getIdeaProjects(Id ideaId) {
        Boolean hasProjects = hasProjectObject();
        List<sObject> results = new List<sObject>();
        
        if (hasProjects) {
            // CRUD and FLS Enforcement
            if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
            
            results= [SELECT Id, Name, AgouraFree__Title__c
                      FROM AgouraFree__Project__c
                      WHERE AgouraFree__Idea_Board__c = :ideaId 
                      ORDER BY AgouraFree__Title__c];  
        } 
        return results;        
    }
    
    // Idea Board Sharing - Get, Add, & Remove
    @AuraEnabled
    public static AgouraFree__IdeaBoard__Share addIdeaSharingAccess(Id ideaId, Id userId, String accessLevel) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'ParentId', 'UserOrGroupId', 'AccessLevel' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__IdeaBoard__Share.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__IdeaBoard__Share item = new AgouraFree__IdeaBoard__Share();
        item.ParentId = ideaId;
        item.UserOrGroupId = userId;
        item.AccessLevel = accessLevel;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__IdeaBoard__Share removeIdeaSharingAccess(Id ideaId, Id userId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__IdeaBoard__Share.sObjectType.getDescribe().isAccessible() || !AgouraFree__IdeaBoard__Share.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        List<AgouraFree__IdeaBoard__Share> deleteMe = [SELECT Id FROM AgouraFree__IdeaBoard__Share WHERE ParentId = :ideaId AND UserOrGroupId = :userId];
        delete deleteMe;
        RETURN null;
    } 
    
    // User record access
    @AuraEnabled
    public static List<UserRecordAccess> recordAccess(Id recId) {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess 
                FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                LIMIT 1];
    }
    
    // Idea Board Users
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id ideaId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__IdeaBoard__Share.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM AgouraFree__IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__IdeaBoard__c WHERE Id = :ideaId)
                                     ORDER BY Name];
        List<User> searchResults4 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__IdeaBoard__Share 
                                                  WHERE ParentId = :ideaId AND AccessLevel = 'Read')
                                     ORDER BY Name];
        List<User> searchResults5 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__IdeaBoard__Share 
                                                  WHERE ParentId = :ideaId AND AccessLevel = 'Edit')
                                     ORDER BY Name];
        List<Group> searchResults6 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__IdeaBoard__Share 
                                                   WHERE ParentId = :ideaId AND AccessLevel = 'Read')
                                      ORDER BY Name];
        List<Group> searchResults7 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__IdeaBoard__Share 
                                                   WHERE ParentId = :ideaId AND AccessLevel = 'Edit')
                                      ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults4) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Read Access'));
        }
        for (User user : searchResults5) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Edit Access'));
        }
        for (Group groupItem : searchResults6) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Read Access'));
        }
        for (Group groupItem : searchResults7) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Edit Access'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static List<AgouraFree__IdeaBoard__c> getIdeaBoardTitle(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Title__c FROM AgouraFree__IdeaBoard__c WHERE Id = :recId LIMIT 1];  
    }
    
    @AuraEnabled
    public static Id createCloneIdeaBoard(Id recId) {                      
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Problem__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Existing_Alternatives__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Solution__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Key_Metrics__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Unique_Value_Proposition__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__High_Level_Concept__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Unfair_Advantage__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Channels__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Customer_Segment__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Early_Adopters__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Cost_Structure__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Revenue_Streams__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaTagAssociation__c.fields.AgouraFree__Tag__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__IdeaTagAssociation__c.fields.AgouraFree__Idea_Board__c.isCreateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }   
        
        AgouraFree__IdeaBoard__c ideaBoard = [SELECT AgouraFree__Title__c, AgouraFree__Problem__c, AgouraFree__Existing_Alternatives__c, AgouraFree__Solution__c, AgouraFree__Key_Metrics__c, 
                                          AgouraFree__Unique_Value_Proposition__c, AgouraFree__High_Level_Concept__c, AgouraFree__Unfair_Advantage__c, AgouraFree__Channels__c,
                                          AgouraFree__Customer_Segment__c, AgouraFree__Early_Adopters__c, AgouraFree__Cost_Structure__c, AgouraFree__Revenue_Streams__c, 
                                          AgouraFree__Comments__c
                                          FROM AgouraFree__IdeaBoard__c
                                          WHERE Id = :recId
                                          LIMIT 1];
        String titleStr = ideaBoard.AgouraFree__Title__c;
        
        AgouraFree__IdeaBoard__c newIdeaBoard = new AgouraFree__IdeaBoard__c (
            AgouraFree__Title__c = titleStr.left(248) + ' (Copy)',
            AgouraFree__Problem__c = ideaBoard.AgouraFree__Problem__c,
            AgouraFree__Existing_Alternatives__c = ideaBoard.AgouraFree__Existing_Alternatives__c,
            AgouraFree__Solution__c = ideaBoard.AgouraFree__Solution__c,
            AgouraFree__Key_Metrics__c = ideaBoard.AgouraFree__Key_Metrics__c,
            AgouraFree__Unique_Value_Proposition__c = ideaBoard.AgouraFree__Unique_Value_Proposition__c,
            AgouraFree__High_Level_Concept__c = ideaBoard.AgouraFree__High_Level_Concept__c,
            AgouraFree__Unfair_Advantage__c = ideaBoard.AgouraFree__Unfair_Advantage__c,
            AgouraFree__Channels__c = ideaBoard.AgouraFree__Channels__c,
            AgouraFree__Customer_Segment__c = ideaBoard.AgouraFree__Customer_Segment__c,
            AgouraFree__Early_Adopters__c = ideaBoard.AgouraFree__Early_Adopters__c,
            AgouraFree__Cost_Structure__c = ideaBoard.AgouraFree__Cost_Structure__c,
            AgouraFree__Revenue_Streams__c = ideaBoard.AgouraFree__Revenue_Streams__c,
            AgouraFree__Comments__c = ideaBoard.AgouraFree__Comments__c,
            AgouraFree__Status__c = 'Draft'
        );  
        insert newIdeaBoard;    
        
        // create tag association
        List<AgouraFree__IdeaTagAssociation__c> tagAssocList = [SELECT AgouraFree__Tag__c                
                                                            FROM AgouraFree__IdeaTagAssociation__c
                                                            WHERE AgouraFree__Idea_Board__c = :recId];
        
        for (AgouraFree__IdeaTagAssociation__c tagAssoc : tagAssocList) {
            AgouraFree__IdeaTagAssociation__c newTagAssoc = new AgouraFree__IdeaTagAssociation__c (
                AgouraFree__Tag__c = tagAssoc.AgouraFree__Tag__c,
                AgouraFree__Idea_Board__c = newIdeaBoard.Id);
            insert newTagAssoc;
        }
        RETURN newIdeaBoard.Id;
    }
    
    @AuraEnabled
    public static AgouraFree__IdeaBoard__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__IdeaBoard__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__IdeaBoard__c item = [SELECT Id, OwnerId FROM AgouraFree__IdeaBoard__c WHERE Id = :recId];
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
    public static Boolean hasProjectObject() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('AgouraFree__Project__c');
    }
    
    @AuraEnabled
    public static Boolean checkChatterEnabled() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('FeedItem');
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.fields.Id.isAccessible() || 
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
}
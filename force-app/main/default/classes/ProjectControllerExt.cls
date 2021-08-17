public with sharing class ProjectControllerExt {
    
    private final static Integer MAX_RESULTS = 5; 
         
    public class ProjectAccess {        
        @AuraEnabled
        public Boolean hasReadAccess { get;set; }
        @AuraEnabled
        public Boolean hasEditAccess { get;set; }
        @AuraEnabled
        public Boolean hasDeleteAccess { get;set; }
        @AuraEnabled
        public Boolean hasTransferAccess { get;set; }
        @AuraEnabled
        public Boolean hasDeleteSprintTaskAccess { get;set; }      
    }
    
    // User record access
    @AuraEnabled
    public static ProjectAccess recordAccess(Id recId) {
        ProjectAccess result = new ProjectAccess();
        Id userId = UserInfo.getUserId();
        UserRecordAccess recordAccess = [SELECT RecordID, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess 
                                         FROM UserRecordAccess WHERE UserId = :userId AND RecordID = :recId
                                         LIMIT 1];               
        Integer permissionSetAssignment = [SELECT Count()
                                           FROM PermissionSetAssignment
                                           WHERE AssigneeId = :userId
                                           AND (PermissionSet.Name = 'Agoura_AddStandardUserDelete' OR PermissionSet.Name = 'Agoura_Admin')];        
        
        result.hasReadAccess = recordAccess.HasReadAccess;
        result.hasEditAccess = recordAccess.HasEditAccess;
        result.hasDeleteAccess = recordAccess.HasDeleteAccess;
        result.hasTransferAccess = recordAccess.HasTransferAccess;
        result.hasDeleteSprintTaskAccess = false;
        if (permissionSetAssignment > 0 && recordAccess.HasEditAccess) {
           result.hasDeleteSprintTaskAccess = true; 
        }    
        return result;
    }
    
    @AuraEnabled
    public static Boolean createAccess() {
        if (Schema.sObjectType.AgouraFree__Project__c.isCreateable()) {
            return true;
        } else {
            return false;
        }
    }
    
    // Project Sharing - Get, Add, & Remove
    @AuraEnabled
    public static AgouraFree__Project__Share addProjectSharingAccess(Id projectId, Id userId, String accessLevel) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'ParentId', 'UserOrGroupId', 'AccessLevel' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__Project__Share.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__Project__Share item = new AgouraFree__Project__Share();
        item.ParentId = projectId;
        item.UserOrGroupId = userId;
        item.AccessLevel = accessLevel;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__Project__Share removeProjectSharingAccess(Id projectId, Id userId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__Project__Share.sObjectType.getDescribe().isAccessible() || !AgouraFree__Project__Share.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<AgouraFree__Project__Share> deleteMe = [SELECT Id FROM AgouraFree__Project__Share WHERE ParentId = :projectId AND UserOrGroupId = :userId];
        delete deleteMe;
        RETURN null;
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
                                             AgouraFree__Tag__c (Id, Name WHERE Id NOT IN :selectedIds AND AgouraFree__For_Projects__c = True ORDER BY Name)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__Tag__c [] tags = ((List<AgouraFree__Tag__c>) searchResults[0]);
        for (AgouraFree__Tag__c tag : tags) {
            results.add(new AgouraFree.LookupSearchResult(tag.Id, 'AgouraFree__Tag__c', 'standard:topic', tag.Name, 'Tag • ' + tag.Name));
        }
        
        RETURN results;
    }
    
    @AuraEnabled    
    public static List<AgouraFree.LookupSearchResult> ideaBoardSearch(String searchTerm, List<String> selectedIds) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        searchTerm += '*';        
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                                             AgouraFree__IdeaBoard__c (Id, Name, AgouraFree__Title__c WHERE Id NOT IN :selectedIds ORDER BY AgouraFree__Title__c)
                                             LIMIT :MAX_RESULTS];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        AgouraFree__IdeaBoard__c [] ideas = ((List<AgouraFree__IdeaBoard__c>) searchResults[0]);
        for (AgouraFree__IdeaBoard__c idea : ideas) {
            results.add(new AgouraFree.LookupSearchResult(idea.Id, 'AgouraFree__IdeaBoard__c', 'standard:drafts', idea.AgouraFree__Title__c, 'Idea Board • ' + idea.Name));
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
    
    @AuraEnabled
    public static List<Account> getRelatedAccount(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM Account
                WHERE Id IN (SELECT AgouraFree__Account__c FROM AgouraFree__Project__c WHERE Id = :projectId) 
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
    
    // Project Tag Association - Get, Add, & Remove
    @AuraEnabled
    public static List<AgouraFree__Tag__c> getProjectTags(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Tag__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTagAssociation__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name
                FROM AgouraFree__Tag__c
                WHERE Id IN (SELECT AgouraFree__Tag__c FROM AgouraFree__ProjectTagAssociation__c WHERE AgouraFree__Project__c = :projectId) 
                ORDER BY Name]; 
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTagAssociation__c addProjectTag(Id tagId, Id projectId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Tag__c', 'AgouraFree__Project__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTagAssociation__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectTagAssociation__c item = new AgouraFree__ProjectTagAssociation__c();
        item.AgouraFree__Tag__c = tagId;
        item.AgouraFree__Project__c = projectId;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTagAssociation__c removeProjectTag(Id tagId, Id projectId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__ProjectTagAssociation__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__ProjectTagAssociation__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<AgouraFree__ProjectTagAssociation__c> deleteMe = [SELECT Id FROM AgouraFree__ProjectTagAssociation__c 
                                                           WHERE AgouraFree__Tag__c = :tagId AND AgouraFree__Project__c = :projectId];
        delete deleteMe;
        RETURN null;
    } 
    
    // Idea Project Association - Get, Add, & Remove
    @AuraEnabled
    public static List<AgouraFree__IdeaBoard__c> getIdeaProjects(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        RETURN [SELECT Id, Name, AgouraFree__Title__c
                FROM AgouraFree__IdeaBoard__c
                WHERE Id IN (SELECT AgouraFree__Idea_Board__c FROM AgouraFree__Project__c WHERE Id = :projectId)]; 
    } 
    
    // Project Users
    @AuraEnabled
    public static List<AgouraFree.LookupSearchResult> getUsers(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Project__Share.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        List<User> searchResults1 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__Executive_Sponsor__c FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults2 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__Product_Owner__c FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults3 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT AgouraFree__Scrum_Master__c FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults4 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT OwnerId FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults5 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT CreatedById FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults6 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT LastModifiedById FROM AgouraFree__Project__c WHERE Id = :projectId)
                                     ORDER BY Name];
        List<User> searchResults7 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__Project__Share 
                                                  WHERE ParentId = :projectId AND AccessLevel = 'Read')
                                     ORDER BY Name];
        List<User> searchResults8 = [SELECT Id, Name, SmallPhotoUrl FROM User
                                     WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__Project__Share 
                                                  WHERE ParentId = :projectId AND AccessLevel = 'Edit')
                                     ORDER BY Name];
        List<Group> searchResults9 = [SELECT Id, Name FROM Group
                                      WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__Project__Share 
                                                   WHERE ParentId = :projectId AND AccessLevel = 'Read')
                                      ORDER BY Name];
        List<Group> searchResults10 = [SELECT Id, Name FROM Group
                                       WHERE Id IN (SELECT UserOrGroupId FROM AgouraFree__Project__Share 
                                                    WHERE ParentId = :projectId AND AccessLevel = 'Edit')
                                       ORDER BY Name];
        
        List<AgouraFree.LookupSearchResult> results = new List<AgouraFree.LookupSearchResult>();
        
        for (User user : searchResults1) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Executive Sponsor'));
        }
        for (User user : searchResults2) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Product Owner'));
        }
        for (User user : searchResults3) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Scrum Master'));
        }
        for (User user : searchResults4) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Owner'));
        }
        for (User user : searchResults5) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Created By'));
        }
        for (User user : searchResults6) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Last Modified By'));
        }
        for (User user : searchResults7) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Read Access'));
        }
        for (User user : searchResults8) {
            results.add(new AgouraFree.LookupSearchResult(user.Id, 'User', user.SmallPhotoUrl, user.Name, 'Edit Access'));
        }
        for (Group groupItem : searchResults9) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Read Access'));
        }
        for (Group groupItem : searchResults10) {
            results.add(new AgouraFree.LookupSearchResult(groupItem.Id, 'Group', 'standard:groups', groupItem.Name, 'Edit Access'));
        }
        
        RETURN results;
    }
    
    @AuraEnabled
    public static AgouraFree__Project__c updateDocumentOwner(Id recId, Id userId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'OwnerId'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__Project__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__Project__c item = [SELECT Id, OwnerId FROM AgouraFree__Project__c WHERE Id = :recId];
        item.OwnerId = userId;
        update item;
        RETURN item;
    }
    
    @AuraEnabled
    public static AggregateResult getUnassignedPoints(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Sum(AgouraFree__Points__c) unassignedPoints 
                FROM AgouraFree__ProjectTask__c
                WHERE AgouraFree__Project__c = :projectId 
                AND AgouraFree__Status__c NOT IN ('Done','Resolved','Canceled')
                AND AgouraFree__Sprint__c = null]; 
    }
    
    @AuraEnabled
    public static List<AgouraFree__Project__c> getProjectTitle(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT AgouraFree__Title__c, AgouraFree__Project_Abbreviation__c, AgouraFree__IsTemplate__c FROM AgouraFree__Project__c WHERE Id = :projectId LIMIT 1];  
    }
    
    // related objects
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectGoals(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Title__c, AgouraFree__Type__c, AgouraFree__Start_Date__c, AgouraFree__Target_Date__c, AgouraFree__Progress__c, AgouraFree__Comments__c
                FROM AgouraFree__ProjectItem__c
                WHERE AgouraFree__Project__c = :projectId 
                AND (AgouraFree__Type__c = 'Project Goal' OR AgouraFree__Type__c = 'Project Milestone')
                ORDER BY AgouraFree__Target_Date__c ASC NULLS LAST, AgouraFree__Start_Date__c ASC NULLS LAST, AgouraFree__Title__c]; 
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c addGoal(Id projectId, String typeStr, String title, String startDate, String targetDate, String progress, String comments) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Project__c', 'AgouraFree__Type__c', 'AgouraFree__Title__c', 'AgouraFree__Start_Date__c', 'AgouraFree__Target_Date__c', 
            'AgouraFree__Progress__c', 'AgouraFree__Comments__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectItem__c item = new AgouraFree__ProjectItem__c();
        item.AgouraFree__Project__c = projectId;
        item.AgouraFree__Type__c = typeStr;
        item.AgouraFree__Title__c = title;
        if (typeStr == 'Project Goal' && String.isNotBlank(startDate)) {
            item.AgouraFree__Start_Date__c = Date.valueOf(startDate);  
        }
        if (String.isNotBlank(targetDate)) {
            item.AgouraFree__Target_Date__c = Date.valueOf(targetDate);  
        }
        if (String.isNotBlank(progress)) {
            Decimal progressDec = Decimal.valueOf(progress);
            item.AgouraFree__Progress__c = progressDec;
        }  
        item.AgouraFree__Comments__c = comments;
        insert item;
        return item;
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c removeProjectItem(Id recId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__ProjectItem__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }        
        
        List<AgouraFree__ProjectItem__c> deleteMe = [SELECT Id FROM AgouraFree__ProjectItem__c WHERE id = :recId];
        delete deleteMe;
        RETURN null;
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectRisks(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Title__c, AgouraFree__Probability__c, AgouraFree__Impact__c, AgouraFree__Status__c, AgouraFree__Response__c
                FROM AgouraFree__ProjectItem__c
                WHERE AgouraFree__Project__c = :projectId 
                AND AgouraFree__Type__c = 'Project Risk'
                ORDER BY AgouraFree__Title__c]; 
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c addRisk(Id projectId, String title, String probability, String impact, String status, String response) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Type__c', 'AgouraFree__Project__c', 'AgouraFree__Title__c', 'AgouraFree__Probability__c', 'AgouraFree__Impact__c', 
            'AgouraFree__Status__c', 'AgouraFree__Response__c' };
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectItem__c item = new AgouraFree__ProjectItem__c();
        item.AgouraFree__Type__c = 'Project Risk';
        item.AgouraFree__Project__c = projectId;
        item.AgouraFree__Title__c = title;
        item.AgouraFree__Probability__c = probability;
        item.AgouraFree__Impact__c = impact;
        item.AgouraFree__Status__c = status;
        item.AgouraFree__Response__c = response;
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectStakeholders(Id projectId) {        
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Type__c, AgouraFree__Swim_Lane__r.AgouraFree__Title__c, AgouraFree__RACI__c, AgouraFree__User__r.Name, AgouraFree__User__r.Title
                FROM AgouraFree__ProjectItem__c
                WHERE AgouraFree__Project__c = :projectId 
                AND (AgouraFree__Type__c = 'Project Team Member' OR AgouraFree__Type__c = 'Project Stakeholder')
                ORDER BY AgouraFree__User__r.Name]; 
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c addStakeholder(Id projectId, String stakeholderType, Id userId, String raci, String swimLane, String grantAccess) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__User__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__RACI__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__Share.fields.ParentId.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__Share.fields.UserOrGroupId.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__Share.fields.AccessLevel.isCreateable() ||
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isAccessible() || 
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }  
        
        list<AgouraFree__ProjectItem__c> itemList = [SELECT Id FROM AgouraFree__ProjectItem__c
                                                 WHERE AgouraFree__Project__c = :projectId
                                                 AND (AgouraFree__Type__c = 'Project Stakeholder' OR AgouraFree__Type__c = 'Project Team Member')
                                                 AND AgouraFree__User__c = :userId];
        delete itemList;
        
        AgouraFree__ProjectItem__c item = new AgouraFree__ProjectItem__c();
        item.AgouraFree__Title__c = userId;
        item.AgouraFree__Project__c = projectId;
        item.AgouraFree__Type__c = stakeholderType;
        item.AgouraFree__User__c = userId;
        item.AgouraFree__RACI__c = raci;
        if (swimLane == '') {
            item.AgouraFree__Swim_Lane__c = null;
        } else {
            item.AgouraFree__Swim_Lane__c = swimLane;
        }
        insert item;
        
        if (grantAccess == 'Read Access') {
            AgouraFree__Project__Share shareItem = new AgouraFree__Project__Share();
            shareItem.ParentId = projectId;
            shareItem.UserOrGroupId = userId;
            shareItem.AccessLevel = 'Read';
            insert shareItem;
        } else if (grantAccess == 'Edit Access') {
            AgouraFree__Project__Share shareItem = new AgouraFree__Project__Share();
            shareItem.ParentId = projectId;
            shareItem.UserOrGroupId = userId;
            shareItem.AccessLevel = 'Edit';
            insert shareItem;
        }
        RETURN item;
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c addSwimLane(Id projectId, String title) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Type__c', 'AgouraFree__Project__c', 'AgouraFree__Title__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectItem__c item = new AgouraFree__ProjectItem__c();
        item.AgouraFree__Type__c = 'Project Swim Lane';
        item.AgouraFree__Project__c = projectId;
        item.AgouraFree__Title__c = title;
        insert item;
        RETURN item;
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
    public static List<AgouraFree__Sprint__c> getProjectSprints(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Sprint_Number__c, AgouraFree__Target_Points__c, AgouraFree__Completed_Points__c, AgouraFree__Start_Date__c, AgouraFree__End_Date__c,
                AgouraFree__What_went_well__c, AgouraFree__What_did_not_go_well__c, AgouraFree__What_can_we_do_different_next_time__c
                FROM AgouraFree__Sprint__c
                WHERE AgouraFree__Project__c = :projectId
                ORDER BY AgouraFree__Start_Date__c NULLS LAST, AgouraFree__Sprint_Number__c];         
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
    
    @AuraEnabled
    public static AgouraFree__ProjectItem__c addLink(Id projectId, String title, String url, String ownerId) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Type__c', 'AgouraFree__Project__c', 'AgouraFree__Title__c', 'AgouraFree__URL__c', 'AgouraFree__User__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectItem__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        }
        
        AgouraFree__ProjectItem__c item = new AgouraFree__ProjectItem__c();
        item.AgouraFree__Type__c = 'Project Link';
        item.AgouraFree__Project__c = projectId;
        item.AgouraFree__Title__c = title;
        item.AgouraFree__URL__c = url; 
        if (ownerId == '') {
            item.AgouraFree__User__c = null;  
        } else {
            item.AgouraFree__User__c = ownerId;  
        }
        insert item;
        RETURN item;
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectItem__c> getProjectLinks(Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        RETURN [SELECT Id, AgouraFree__Title__c, AgouraFree__URL__c, AgouraFree__User__r.Name 
                FROM AgouraFree__ProjectItem__c
                WHERE AgouraFree__Project__c = :projectId 
                AND AgouraFree__Type__c = 'Project Link'
                ORDER BY AgouraFree__Title__c]; 
    }
    
    @AuraEnabled
    public static Id createCloneProject(Id recId, List<String> cloneWhat) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Idea_Board__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Mission_Statement__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Project_Abbreviation__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Executive_Sponsor__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Product_Owner__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Scrum_Master__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Product__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Deliverables__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__KPIs__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Value_Trackers__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Assumptions__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Constraints__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Account__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__Project__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Target_Date__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Progress__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Probability__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Impact__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Response__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Description__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__URL__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__User__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__RACI__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTagAssociation__c.fields.AgouraFree__Tag__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTagAssociation__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Title__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Description__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Points__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Reported_By__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Reported_Date__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Value__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Due_Date__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Priority__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Bug_Type__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Accept__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Affected_Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Time_Estimate__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Fix_Version__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Components__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Dependencies__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Comments__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Formatted_Status__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number_Int__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Task_Number__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Order__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Account__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Project__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Swim_Lane__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__URL__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__URL__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTaskTagAssoc__c.fields.AgouraFree__Tag__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTaskTagAssoc__c.fields.AgouraFree__Project_Task__c.isCreateable() ||
            !Schema.sObjectType.AgouraFree__ProjectTask__c.fields.AgouraFree__Master_Task__c.isUpdateable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        System.debug('Start Project Cloning'); 
        List<AgouraFree__ProjectTask__c> newTaskList = new List<AgouraFree__ProjectTask__c>();
        List<AgouraFree__ProjectTask__c> newTaskList2 = new List<AgouraFree__ProjectTask__c>();
        List<AgouraFree__ProjectTagAssociation__c> newTagList = new List<AgouraFree__ProjectTagAssociation__c>();
        List<AgouraFree__ProjectItem__c> newItemList = new List<AgouraFree__ProjectItem__c>();
        List<AgouraFree__ProjectTaskTagAssoc__c> newProjectTaskTagAssocList = new List<AgouraFree__ProjectTaskTagAssoc__c>();
        Map<Id, String> taskOldIdMap = new Map<Id, String>(); 
        Map<Id, String> taskNewIdMap = new Map<Id, String>(); 
        Map<Id, Id> taskIdMap = new Map<Id, Id>();   
        Map<Id, Id> swimLaneIdMap = new Map<Id, Id>();   
        
        AgouraFree__Project__c project = [SELECT AgouraFree__Title__c, AgouraFree__Mission_Statement__c, AgouraFree__Project_Abbreviation__c, AgouraFree__Executive_Sponsor__c, 
                                      AgouraFree__Product_Owner__c, AgouraFree__Scrum_Master__c, AgouraFree__Product__c, AgouraFree__Deliverables__c, 
                                      AgouraFree__KPIs__c, AgouraFree__Value_Trackers__c, AgouraFree__Assumptions__c, AgouraFree__Constraints__c,
                                      AgouraFree__Comments__c, AgouraFree__Idea_Board__c, AgouraFree__Account__c              
                                      FROM AgouraFree__Project__c
                                      WHERE Id = :recId
                                      LIMIT 1];      
        String titleStr = project.AgouraFree__Title__c;
        String abbreviationStr = project.AgouraFree__Project_Abbreviation__c;  
        
        AgouraFree__Project__c newProject = new AgouraFree__Project__c (
            AgouraFree__Title__c = titleStr.left(248) + ' (Copy)',
            AgouraFree__Idea_Board__c = project.AgouraFree__Idea_Board__c,
            AgouraFree__Mission_Statement__c = project.AgouraFree__Mission_Statement__c,
            AgouraFree__Project_Abbreviation__c = abbreviationStr.left(16) + 'COPY',
            AgouraFree__Executive_Sponsor__c = project.AgouraFree__Executive_Sponsor__c,
            AgouraFree__Product_Owner__c = project.AgouraFree__Product_Owner__c,
            AgouraFree__Scrum_Master__c = project.AgouraFree__Scrum_Master__c,
            AgouraFree__Product__c = project.AgouraFree__Product__c,
            AgouraFree__Deliverables__c = project.AgouraFree__Deliverables__c,
            AgouraFree__KPIs__c = project.AgouraFree__KPIs__c,
            AgouraFree__Value_Trackers__c = project.AgouraFree__Value_Trackers__c,
            AgouraFree__Assumptions__c = project.AgouraFree__Assumptions__c,
            AgouraFree__Constraints__c = project.AgouraFree__Constraints__c,
            AgouraFree__Comments__c = project.AgouraFree__Comments__c,
            AgouraFree__Account__c = project.AgouraFree__Account__c,
            AgouraFree__Status__c = 'Draft');  
        insert newProject;    
         
        // clone related objects
        for (String cloneWhatItem : cloneWhat) {
            List<AgouraFree__ProjectItem__c> projectItemList = [SELECT AgouraFree__Title__c, AgouraFree__Type__c, AgouraFree__Target_Date__c, AgouraFree__Progress__c, AgouraFree__Comments__c, 
                                                            AgouraFree__User__c, AgouraFree__Probability__c, AgouraFree__Impact__c, AgouraFree__Status__c, AgouraFree__Response__c, 
                                                            AgouraFree__Description__c, AgouraFree__URL__c, AgouraFree__Swim_Lane__c, AgouraFree__RACI__c           
                                                            FROM AgouraFree__ProjectItem__c
                                                            WHERE AgouraFree__Project__c = :recId AND AgouraFree__Type__c = :cloneWhatItem LIMIT 1000];   
            
            for (AgouraFree__ProjectItem__c projectItem : projectItemList) {
                AgouraFree__ProjectItem__c newProjectItem = new AgouraFree__ProjectItem__c (
                    AgouraFree__Title__c = projectItem.AgouraFree__Title__c,
                    AgouraFree__Type__c = projectItem.AgouraFree__Type__c,
                    AgouraFree__Target_Date__c = projectItem.AgouraFree__Target_Date__c,
                    AgouraFree__Progress__c = projectItem.AgouraFree__Progress__c,
                    AgouraFree__Comments__c = projectItem.AgouraFree__Comments__c,
                    AgouraFree__Probability__c = projectItem.AgouraFree__Probability__c,
                    AgouraFree__Impact__c = projectItem.AgouraFree__Impact__c,
                    AgouraFree__Status__c = projectItem.AgouraFree__Status__c,
                    AgouraFree__Response__c = projectItem.AgouraFree__Response__c,
                    AgouraFree__Description__c = projectItem.AgouraFree__Description__c,
                    AgouraFree__URL__c = projectItem.AgouraFree__URL__c,
                    AgouraFree__User__c = projectItem.AgouraFree__User__c,
                    AgouraFree__Swim_Lane__c = projectItem.AgouraFree__Swim_Lane__c,
                    AgouraFree__RACI__c = projectItem.AgouraFree__RACI__c,
                    AgouraFree__Project__c = newProject.Id);
                newItemList.add(newProjectItem); 
            }
            insert newItemList;
            for (Integer i = 0; i < projectItemList.size(); i++) {
                AgouraFree__ProjectItem__c projectItem = projectItemList[i];
                AgouraFree__ProjectItem__c newProjectItem = newItemList[i];
                if (projectItem.AgouraFree__Type__c == 'Project Swim Lane') {
                    swimLaneIdMap.put(projectItem.Id,newProjectItem.Id); 
                }                
            }
            newItemList.clear();
        }
        
        if (cloneWhat.indexOf('Tags') >= 0) {
            List<AgouraFree__ProjectTagAssociation__c> tagList = [SELECT AgouraFree__Tag__c               
                                                              FROM AgouraFree__ProjectTagAssociation__c
                                                              WHERE AgouraFree__Project__c = :recId];
            for (AgouraFree__ProjectTagAssociation__c tag : tagList) {
                AgouraFree__ProjectTagAssociation__c newTag = new AgouraFree__ProjectTagAssociation__c (
                    AgouraFree__Tag__c = tag.AgouraFree__Tag__c,
                    AgouraFree__Project__c = newProject.Id);                    
                newTagList.add(newTag); 
            }
        }
        insert newTagList;
        
        if (cloneWhat.indexOf('Tasks') >= 0) {
            List<AgouraFree__ProjectTaskTagAssoc__c> projectTaskTagAssocList = [SELECT AgouraFree__Tag__c, AgouraFree__Project_Task__c              
                                                                            FROM AgouraFree__ProjectTaskTagAssoc__c
                                                                            WHERE AgouraFree__Project_Task__c IN (SELECT Id FROM AgouraFree__ProjectTask__c
                                                                                                              WHERE AgouraFree__Project__c = :recId)];
            
            List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Title__c, AgouraFree__Description__c, AgouraFree__Type__c, AgouraFree__Points__c, AgouraFree__Reported_By__c, 
                                                     AgouraFree__Reported_Date__c, AgouraFree__Value__c, AgouraFree__Due_Date__c, AgouraFree__Priority__c, AgouraFree__Bug_Type__c, 
                                                     AgouraFree__Accept__c, AgouraFree__Affected_Version__c, AgouraFree__Time_Estimate__c, AgouraFree__Version__c, 
                                                     AgouraFree__Fix_Version__c, AgouraFree__Components__c, AgouraFree__Dependencies__c, AgouraFree__Comments__c, 
                                                     AgouraFree__Task_Number_Int__c, AgouraFree__Swim_Lane__c, AgouraFree__Master_Task__c, AgouraFree__Account__c, AgouraFree__URL__c
                                                     FROM AgouraFree__ProjectTask__c
                                                     WHERE AgouraFree__Project__c = :recId
                                                     ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Task_Number_Int__c
                                                     LIMIT 1000];
            decimal goodIndex = 1;
            for (AgouraFree__ProjectTask__c task : taskList) {
                AgouraFree__ProjectTask__c newTask = new AgouraFree__ProjectTask__c (
                    AgouraFree__Title__c = task.AgouraFree__Title__c,
                    AgouraFree__Description__c = task.AgouraFree__Description__c,
                    AgouraFree__Type__c = task.AgouraFree__Type__c,
                    AgouraFree__Points__c = task.AgouraFree__Points__c,
                    AgouraFree__Reported_By__c = task.AgouraFree__Reported_By__c,
                    AgouraFree__Reported_Date__c = task.AgouraFree__Reported_Date__c,
                    AgouraFree__Value__c = task.AgouraFree__Value__c,
                    AgouraFree__Due_Date__c = task.AgouraFree__Due_Date__c,
                    AgouraFree__Priority__c = task.AgouraFree__Priority__c,
                    AgouraFree__Bug_Type__c = task.AgouraFree__Bug_Type__c,
                    AgouraFree__Accept__c = task.AgouraFree__Accept__c,
                    AgouraFree__Affected_Version__c = task.AgouraFree__Affected_Version__c,
                    AgouraFree__Time_Estimate__c = task.AgouraFree__Time_Estimate__c,
                    AgouraFree__Version__c = task.AgouraFree__Version__c,
                    AgouraFree__Fix_Version__c = task.AgouraFree__Fix_Version__c,
                    AgouraFree__Components__c = task.AgouraFree__Components__c,
                    AgouraFree__Dependencies__c = task.AgouraFree__Dependencies__c,
                    AgouraFree__Comments__c = task.AgouraFree__Comments__c,
                    AgouraFree__Status__c = 'Open',
                    AgouraFree__Formatted_Status__c = 'open',
                    AgouraFree__Task_Number_Int__c = goodIndex,                        
                    AgouraFree__Task_Number__c = newProject.AgouraFree__Project_Abbreviation__c + '-' + goodIndex,
                    AgouraFree__Order__c = goodIndex,
                    AgouraFree__Master_Task__c = task.AgouraFree__Master_Task__c, // update later
                    AgouraFree__Account__c = task.AgouraFree__Account__c,
                    AgouraFree__URL__c = task.AgouraFree__URL__c,
                    AgouraFree__Project__c = newProject.Id);
                
                if (task.AgouraFree__Swim_Lane__c != null) {
                    for (Id key : swimLaneIdMap.keySet()) { 
                        if (task.AgouraFree__Swim_Lane__c == key) {
                            newTask.AgouraFree__Swim_Lane__c = swimLaneIdMap.get(key);
                        }
                    }
                } 
                newTaskList.add(newTask);               
                goodIndex += 1;
            } 
            insert newTaskList;
            for (Integer i = 0; i < taskList.size(); i++) {
                AgouraFree__ProjectTask__c task = taskList[i];
                AgouraFree__ProjectTask__c newTask = newTaskList[i];
                taskIdMap.put(task.Id,newTask.Id); 
                
                // create tag association
                for (AgouraFree__ProjectTaskTagAssoc__c projectTaskTagAssoc : projectTaskTagAssocList) {
                    if (task.Id == projectTaskTagAssoc.AgouraFree__Project_Task__c) {
                        AgouraFree__ProjectTaskTagAssoc__c newProjectTaskTagAssoc = new AgouraFree__ProjectTaskTagAssoc__c (
                            AgouraFree__Tag__c = projectTaskTagAssoc.AgouraFree__Tag__c,
                            AgouraFree__Project_Task__c = newTask.Id);
                        newProjectTaskTagAssocList.add(newProjectTaskTagAssoc);
                    }                    
                }
            }            
            insert newProjectTaskTagAssocList; 
            
            // update Master Task ids
            for (AgouraFree__ProjectTask__c task : newTaskList) {                 
                for (Id key : taskIdMap.keySet()) { 
                    if (task.AgouraFree__Master_Task__c == key) {
                        task.AgouraFree__Master_Task__c = taskIdMap.get(key);
                        newTaskList2.add(task);
                    }
                }
            } 
            update newTaskList2;              
        }
        
        RETURN newProject.Id;
    }
    
    @AuraEnabled
    public static void doChatterFeedPost(FeedItem newPost) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.fields.Id.isAccessible() || 
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
    public static void updateProjectTaskAbbreviation(Id projectId, String projectAbbrev) {
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Task_Number__c'};
        Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;  
            }
        } 
        
        Integer taskTotal = [SELECT Count()  
                             FROM AgouraFree__ProjectTask__c
                             WHERE AgouraFree__Project__c = :projectId];
        Integer loopTimes = (Integer)Math.ceil(taskTotal/1000.0);
        List<AgouraFree__ProjectTask__c> newList = new List<AgouraFree__ProjectTask__c>();
        for (Integer i = 0; i < loopTimes; i++) {
            Integer loopStart = i * 1000;
            Integer loopEnd = loopStart + 999;
            if (loopTimes == (i + 1) ) {
                loopEnd = 999999;
            }
            list<AgouraFree__ProjectTask__c> origList = [SELECT Id, AgouraFree__Task_Number_Int__c 
                                                     FROM AgouraFree__ProjectTask__c
                                                     WHERE AgouraFree__Project__c = :projectId
                                                     AND AgouraFree__Task_Number_Int__c >= :loopStart
                                                     AND AgouraFree__Task_Number_Int__c <= :loopEnd
                                                     ORDER BY AgouraFree__Task_Number_Int__c
                                                     LIMIT 2000];
            Integer arrayLength = origList.size();            
            for (Integer j = 0; j < arrayLength; j++) {
                AgouraFree__ProjectTask__c resultItem = new AgouraFree__ProjectTask__c(Id=origList[j].Id);                
                resultItem.AgouraFree__Task_Number__c = projectAbbrev + '-' + origList[j].AgouraFree__Task_Number_Int__c;
                newList.add(resultItem); 
            }
            update newList; 
            newList.clear(); 
        }       
    } 
    
    @AuraEnabled
    public static void updateProjectStakeholders(Id projectId, Id execSponsorId, Id productOwnerId, Id docOwnerId, Id scrumMasterId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Project__c.isCreateable() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Project__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Type__c.isCreateable() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Type__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Title__c.isCreateable() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__Title__c.isUpdateable() ||
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__User__c.isCreateable() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.fields.AgouraFree__User__c.isUpdateable() ||    
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isAccessible() || 
            !AgouraFree__ProjectItem__c.sObjectType.getDescribe().isDeletable())
        {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        // update project stakeholders as needed
        list<AgouraFree__ProjectItem__c> existList = [SELECT Id, AgouraFree__Type__c, AgouraFree__User__c
                                                  FROM AgouraFree__ProjectItem__c
                                                  WHERE AgouraFree__Project__c = :projectId
                                                  AND AgouraFree__Type__c IN ('Executive Sponsor', 'Project Document Owner', 'Product Owner', 'Scrum Master')
                                                  ORDER BY AgouraFree__Type__C];
        list<Id> deleteList = new list<Id>();
        list<AgouraFree__ProjectItem__c> upsertList = new list<AgouraFree__ProjectItem__c>(); 
        boolean foundIt;        
        
        if (execSponsorId != null) {
            upsertList.add(new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId, AgouraFree__Type__c='Executive Sponsor',
                                                      AgouraFree__Title__c='Executive Sponsor', AgouraFree__User__c=execSponsorId));
        }
        if (docOwnerId != null) {
            upsertList.add(new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId ,AgouraFree__Type__c='Project Document Owner',
                                                      AgouraFree__Title__c='Project Document Owner', AgouraFree__User__c=docOwnerId));
        }
        if (productOwnerId != null) {
            upsertList.add(new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId, AgouraFree__Type__c='Product Owner',
                                                      AgouraFree__Title__c='Product Owner', AgouraFree__User__c=productOwnerId));
        }
        if (scrumMasterId != null) {
            upsertList.add(new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId, AgouraFree__Type__c='Scrum Master',
                                                      AgouraFree__Title__c='Scrum Master', AgouraFree__User__c=scrumMasterId));
        }
     
        // update as needed
        for (AgouraFree__ProjectItem__c item1 : upsertList) {
            for (AgouraFree__ProjectItem__c item2 : existList) {
                if (item2.AgouraFree__Type__c == item1.AgouraFree__Type__c) {  
                    item1.Id = item2.Id;               
                }
            }
        }        
        
        // delete as needed
        for (AgouraFree__ProjectItem__c item2 : existList) {
            foundIt = false;
            for (AgouraFree__ProjectItem__c item1 : upsertList) {
                if (item2.AgouraFree__Type__c == item1.AgouraFree__Type__c) {  
                    foundIt = true;              
                }
            }
            if (foundIt == false) {
                deleteList.add(item2.Id);
            }
        }
        
        upsert upsertList;
        List<AgouraFree__ProjectItem__c> deleteMe = [SELECT Id FROM AgouraFree__ProjectItem__c WHERE Id IN :deleteList];
        delete deleteMe;      
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
    
    @AuraEnabled        
    public static Map<String, String> getFieldHelpMap(String objectName, List<String> fieldList){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        
        for(String  fieldName : fieldList) {                 
            fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getInlineHelpText());                
        }
        return fieldLabelMap;
    }
  
    @AuraEnabled
    public static Map<String, Integer> getNumRecords(Id recId) {
        return specialClass.getAllNumRecords(recId);
    }
}
public with sharing class ViewControllerExt {
    
    private final static Integer MAX_RESULTS = 5;
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public Integer ideaBoardTotal { get;set; }        
        @AuraEnabled
        public Integer projectTotal { get;set; }        
        @AuraEnabled
        public Integer sprintTotal { get;set; }        
        @AuraEnabled
        public Integer taskTotal { get;set; }        
        @AuraEnabled
        public List<ViewRecord> viewItems { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String statusKey { get;set; }        
        @AuraEnabled
        public String assignedKey { get;set; }        
        @AuraEnabled
        public String rowKey { get;set; }         
    }  
    
    public class ObjectAccess {        
        @AuraEnabled
        public Boolean canCreateAnchorStory { get;set; }        
        @AuraEnabled
        public Boolean canCreateTag { get;set; }          
    } 
    
    @AuraEnabled
    public static List<String> getStatusKeys(String viewName) {
        List<String> values = new list <String>();
        List<String> uniqueValues = new list <String>();
        List<String> tempList = new list <String>();
        List<String> ignoreValues = new List<String>();
        Integer index = 0;
        
        if (viewName == 'Home') {
            Schema.DescribeFieldResult result1 = AgouraFree__IdeaBoard__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            Schema.DescribeFieldResult result2 = AgouraFree__Project__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries2 = result2.getPicklistValues();
            Schema.DescribeFieldResult result3 = AgouraFree__ProjectTask__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries3 = result3.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                values.add(entry.getValue());
            } 
            
            for (Schema.PicklistEntry entry: entries2) {
                values.add(entry.getValue());
            } 
            
            for (Schema.PicklistEntry entry: entries3) {
                values.add(entry.getValue());
            }    
            ignoreValues.add('Approved');
            ignoreValues.add('Canceled');
            ignoreValues.add('Closed');
            ignoreValues.add('Done');
            ignoreValues.add('Resolved');
            
            // sort and remove duplicates
            values.sort();            
            for (String val: values) {               
                if (index > 0) {
                    if (val != values[index-1]) {
                        tempList.add(val);
                    }
                } else {
                    tempList.add(val);
                }
                index += 1;
            }            
            for (String val: tempList) {
                if(ignoreValues.indexOf(val) < 0) {                   
                    uniqueValues.add(val);              
                }
            }
        } else if (viewName == 'Idea Boards') {
            Schema.DescribeFieldResult result1 = AgouraFree__IdeaBoard__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Project Tasks') {
            Schema.DescribeFieldResult result1 = AgouraFree__ProjectTask__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Projects' || viewName == 'Project Templates') {
            Schema.DescribeFieldResult result1 = AgouraFree__Project__c.AgouraFree__Status__c.getDescribe();
            List<Schema.PicklistEntry> entries1 = result1.getPicklistValues();
            
            for (Schema.PicklistEntry entry: entries1) {
                uniqueValues.add(entry.getValue());
            }
        } else if (viewName == 'Sprints') {            
            uniqueValues.add('Closed');          
            uniqueValues.add('Open');
        }
        
        RETURN uniqueValues;
    }  
    
    @AuraEnabled
    public static PagedResult getHomeRecordList(String filters, Decimal pageSize, Decimal pageNumber) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ViewControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchKey = '%' + filter.searchKey + '%';
        String statusKey = filter.statusKey;
        String assignedKey = filter.assignedKey;
        List<String> ignoreStatus = new List<String>();
        ignoreStatus.add('Approved');
        ignoreStatus.add('Canceled');
        ignoreStatus.add('Closed');
        ignoreStatus.add('Done');
        ignoreStatus.add('Resolved');
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        Id userId = UserInfo.getUserId();
        List<ViewRecord> homeResults = new List<ViewRecord>();
        Integer skipRecords = offset;   
        
        // set SOQL query strings
        String ideaBoardTotalQuery = 'SELECT count() FROM AgouraFree__IdeaBoard__c WHERE AgouraFree__Title__c LIKE :searchKey';
        String ideaBoardRecordQuery = 'SELECT Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate, UserRecordAccess.HasEditAccess ' +
            'FROM AgouraFree__IdeaBoard__c  WHERE AgouraFree__Title__c LIKE :searchKey';
        String projectTotalQuery = 'SELECT count() FROM AgouraFree__Project__c ' +
            'WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId ' +
            'AND AgouraFree__Type__c != \'Project Link\') ' +
            'AND AgouraFree__Title__c LIKE :searchKey';
        String projectRecordQuery = 'SELECT Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate, UserRecordAccess.HasEditAccess ' +
            'FROM AgouraFree__Project__c ' +
            'WHERE Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId AND AgouraFree__Type__c != \'Project Link\') ' +
            'AND AgouraFree__Title__c LIKE :searchKey';
        String sprintTotalQuery = 'SELECT count() FROM AgouraFree__Sprint__c ' +
            'WHERE AgouraFree__Start_Date__c <= today ' +
            'AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today) ' +
            'AND AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c ' + 
            'WHERE AgouraFree__User__c = :userId ' +    
            'AND AgouraFree__Project__r.AgouraFree__Title__c LIKE :searchKey ' +
            'AND AgouraFree__Project__r.AgouraFree__Status__c NOT IN :ignoreStatus ' +
            'AND AgouraFree__Type__c != \'Project Link\')';
        String sprintRecordQuery = 'SELECT Id, Name, AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Name__c, CreatedDate, LastModifiedDate, ' +
            'UserRecordAccess.HasEditAccess FROM AgouraFree__Sprint__c ' +
            'WHERE AgouraFree__Start_Date__c <= today ' +
            'AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today) ' +
            'AND AgouraFree__Project__c IN ( ' +
            'SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c ' +
            'WHERE AgouraFree__User__c = :userId ' +                    
            'AND AgouraFree__Project__r.AgouraFree__Title__c LIKE :searchKey ' +
            'AND AgouraFree__Project__r.AgouraFree__Status__c NOT IN :ignoreStatus ' +
            'AND AgouraFree__Type__c != \'Project Link\')';
        String taskTotalQuery = 'SELECT count() FROM AgouraFree__ProjectTask__c ' +
            'WHERE AgouraFree__Title__c LIKE :searchKey ';
        String taskRecordQuery = 'SELECT Id, Name, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Status__c, ' +
            'CreatedDate, LastModifiedDate, AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c, UserRecordAccess.HasEditAccess ' +
            'FROM AgouraFree__ProjectTask__c WHERE AgouraFree__Title__c LIKE :searchKey';
        
        if (assignedKey != '') {
            ideaBoardTotalQuery += ' AND OwnerId = :userId';
            ideaBoardRecordQuery += ' AND OwnerId = :userId';
            taskTotalQuery += ' AND AgouraFree__Assigned_To__c = :userId';
            taskRecordQuery += ' AND AgouraFree__Assigned_To__c = :userId';
        } else {
            taskTotalQuery += ' AND (AgouraFree__Assigned_To__c = :userId OR CreatedById = :userId)';
            taskRecordQuery += ' AND (AgouraFree__Assigned_To__c = :userId OR CreatedById = :userId)';
        }
        if (statusKey  == '') {
            ideaBoardTotalQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
            ideaBoardRecordQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
            projectTotalQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
            projectRecordQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
            taskTotalQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
            taskRecordQuery += ' AND AgouraFree__Status__c NOT IN :ignoreStatus';
        } else {
            ideaBoardTotalQuery += ' AND AgouraFree__Status__c = :statusKey';  
            ideaBoardRecordQuery += ' AND AgouraFree__Status__c = :statusKey';  
            projectTotalQuery += ' AND AgouraFree__Status__c = :statusKey';  
            projectRecordQuery += ' AND AgouraFree__Status__c = :statusKey';   
            taskTotalQuery += ' AND AgouraFree__Status__c = :statusKey';     
            taskRecordQuery += ' AND AgouraFree__Status__c = :statusKey';            
        }
        
        // perform SOQL queries
        r.ideaBoardTotal = Database.countQuery(ideaBoardTotalQuery);
        r.projectTotal = Database.countQuery(projectTotalQuery);
        if (statusKey == '' || statusKey == 'Open') {
            r.sprintTotal = Database.countQuery(sprintTotalQuery);
        } else {
            r.sprintTotal = 0;
        }
        r.taskTotal = Database.countQuery(taskTotalQuery);
        r.total = r.ideaBoardTotal + r.projectTotal + r.sprintTotal + r.taskTotal;
        
        skipRecords = skipRecords - r.ideaBoardTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            ideaBoardRecordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset';
            List<AgouraFree__IdeaBoard__c> ideaBoardList = Database.query(ideaBoardRecordQuery);   
            for (AgouraFree__IdeaBoard__c ideaBoard : ideaBoardList) {
                homeResults.add(new ViewRecord(ideaBoard.Id, ideaBoard.Name, 'AgouraFree__IdeaBoard__c', 'standard:drafts', 
                                               ideaBoard.AgouraFree__Title__c, ideaBoard.AgouraFree__Status__c, null, null, null,
                                               ideaBoard.CreatedDate, ideaBoard.LastModifiedDate, ideaBoard.UserRecordAccess.HasEditAccess));
            }
            pSize = pSize - ideaBoardList.size();
            offset = 0;
        } else {
            offset = offset - r.ideaBoardTotal;
        }
        
        skipRecords = skipRecords - r.projectTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            projectRecordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset';
            List<AgouraFree__Project__c> projectList = Database.query(projectRecordQuery);    
            for (AgouraFree__Project__c project : projectList) {
                homeResults.add(new ViewRecord(project.Id, project.Name, 'AgouraFree__Project__c', 'standard:drafts', 
                                               project.AgouraFree__Title__c, project.AgouraFree__Status__c, null, null, null, 
                                               project.CreatedDate, project.LastModifiedDate, project.UserRecordAccess.HasEditAccess));
            }
            pSize = pSize - projectList.size();
            offset = 0;
        } else {
            offset = offset - r.projectTotal;
        }
        
        skipRecords = skipRecords - r.sprintTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            if (statusKey == '' || statusKey == 'Open') {
                sprintRecordQuery += ' ORDER BY AgouraFree__Sprint_Name__c LIMIT :pSize OFFSET :offset';
                List<AgouraFree__Sprint__c> sprintList = Database.query(sprintRecordQuery);      
                for (AgouraFree__Sprint__c sprint : sprintList) {
                    homeResults.add(new ViewRecord(sprint.Id, sprint.Name, 'AgouraFree__Sprint__c', 'standard:work_order', 
                                                   sprint.AgouraFree__Project__r.AgouraFree__Title__c + ' ' + sprint.AgouraFree__Sprint_Name__c, 'Open', null, null, null,
                                                   sprint.CreatedDate, sprint.LastModifiedDate, sprint.UserRecordAccess.HasEditAccess));
                }
                pSize = pSize - sprintList.size();
                offset = 0;
            } 
        } else {
            offset = offset - r.sprintTotal;
        }
        
        skipRecords = skipRecords - r.taskTotal;
        if (pSize > 0 && skipRecords <= 0 && offset >= 0) {
            taskRecordQuery += ' ORDER BY AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c, AgouraFree__Task_Number_Int__c LIMIT :pSize OFFSET :offset';
            List<AgouraFree__ProjectTask__c> taskList = Database.query(taskRecordQuery);    
            for (AgouraFree__ProjectTask__c task : taskList) {
                homeResults.add(new ViewRecord(task.Id, task.Name, 'AgouraFree__ProjectTask__c', 'standard:task', 
                                               task.AgouraFree__Task_Number__c + ' ' + task.AgouraFree__Title__c, task.AgouraFree__Status__c, 
                                               null, null, null, task.CreatedDate, task.LastModifiedDate, task.UserRecordAccess.HasEditAccess));
            }
        }  
                
        r.viewItems = homeResults;
        RETURN r;
    }
    
    @AuraEnabled
    public static User getUserInfo() {
        Id userId = UserInfo.getUserId();
        RETURN [SELECT Name, Title, CompanyName, Phone, Email, MobilePhone FROM User WHERE Id = :userId LIMIT 1];
    }
    
    @AuraEnabled
    public static Organization getOrgInfo() {
        RETURN [SELECT Id FROM Organization LIMIT 1];
    }
    
    @AuraEnabled
    public static void sendFeedback(String mbody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'feedback@agourasoftware.com'}; 
            mail.setToAddresses(toAddresses);
        mail.setSubject('Agoura Feedback');
        mail.setPlainTextBody(mbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @AuraEnabled
    public static PagedResult getViewRecordList(String filters, Decimal pageSize, Decimal pageNumber, String viewName) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__IdeaBoard__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectItem__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Tag__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__AnchorStory__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ViewControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchTerm = filter.searchKey + '*';
        String statusKey = filter.statusKey + '%';
        String assignedKey = filter.assignedKey;
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        List<ViewRecord> queryResults = new List<ViewRecord>();
        Id userId = UserInfo.getUserId();
        String otherString = '';
        String totalQuery = '';
        String recordQuery = '';
        
        if (viewName == 'Anchor Stories') {
            // Anchor Story Query   
            List<AgouraFree__AnchorStory__c> results = new List<AgouraFree__AnchorStory__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__AnchorStory__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, AgouraFree__Points__c, AgouraFree__Search_Terms__c, AgouraFree__Title__c' +
                    ' FROM AgouraFree__AnchorStory__c ORDER BY AgouraFree__Points__c, Name LIMIT :pSize OFFSET :offset';
                r.total = Database.countQuery(totalQuery);
                List<AgouraFree__AnchorStory__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__AnchorStory__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' AgouraFree__AnchorStory__c (Id, Name, AgouraFree__Points__c, AgouraFree__Search_Terms__c, AgouraFree__Title__c' +
                    ' ORDER BY AgouraFree__Points__c, Name LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__AnchorStory__c> searchResultsCount = (List<AgouraFree__AnchorStory__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__AnchorStory__c>) searchResults[0]);   
            }            
            for (AgouraFree__AnchorStory__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__AnchorStory__c', 'standard:task', item.AgouraFree__Title__c, 
                                                null, null, item.AgouraFree__Points__c, item.AgouraFree__Search_Terms__c, null, null, false));
            }
            
        } else if (viewName == 'Idea Boards') {
            // Idea Board Query
            List<AgouraFree__IdeaBoard__c> results = new List<AgouraFree__IdeaBoard__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__IdeaBoard__c WHERE AgouraFree__Status__c LIKE :statusKey';
                recordQuery = 'SELECT Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate' +
                    ' FROM AgouraFree__IdeaBoard__c WHERE AgouraFree__Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery += ' AND OwnerId = :userId';
                    recordQuery += ' AND OwnerId = :userId';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset';
                List<AgouraFree__IdeaBoard__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__IdeaBoard__c (Id WHERE AgouraFree__Status__c LIKE :statusKey)';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                    ' AgouraFree__IdeaBoard__c (Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate WHERE AgouraFree__Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__IdeaBoard__c (Id WHERE AgouraFree__Status__c LIKE :statusKey AND OwnerId = :userId)';
                    recordQuery += ' AND OwnerId = :userId';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__IdeaBoard__c> searchResultsCount = (List<AgouraFree__IdeaBoard__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__IdeaBoard__c>) searchResults[0]);   
            }           
            for (AgouraFree__IdeaBoard__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__IdeaBoard__c', 'standard:drafts', 
                                                item.AgouraFree__Title__c, item.AgouraFree__Status__c, null, null, null,
                                                item.CreatedDate, item.LastModifiedDate, false));
            } 
            
        } else if (viewName == 'Project Tasks') {
            // Project Task Query
            List<AgouraFree__ProjectTask__c> results = new List<AgouraFree__ProjectTask__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__ProjectTask__c WHERE AgouraFree__Status__c LIKE :statusKey';
                recordQuery = 'SELECT Id, Name, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c,' + 
                    ' AgouraFree__Status__c, CreatedDate, LastModifiedDate, AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c' +
                    ' FROM AgouraFree__ProjectTask__c WHERE AgouraFree__Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery += ' AND AgouraFree__Assigned_To__c = :userId';
                    recordQuery += ' AND AgouraFree__Assigned_To__c = :userId';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c, AgouraFree__Task_Number_Int__c LIMIT :pSize OFFSET :offset';
                List<AgouraFree__ProjectTask__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__ProjectTask__c (Id WHERE AgouraFree__Status__c LIKE :statusKey)';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' +
                    ' AgouraFree__ProjectTask__c (Id, Name, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c,' +
                    ' AgouraFree__Status__c, CreatedDate, LastModifiedDate, AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c' +
                    ' WHERE AgouraFree__Status__c LIKE :statusKey';
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__ProjectTask__c (Id WHERE AgouraFree__Status__c LIKE :statusKey' +
                        ' AND AgouraFree__Assigned_To__c = :userId)';
                    recordQuery += ' AND AgouraFree__Assigned_To__c = :userId';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__ProjectTask__c> searchResultsCount = (List<AgouraFree__ProjectTask__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY AgouraFree__Project__r.AgouraFree__Project_Abbreviation__c, AgouraFree__Task_Number_Int__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__ProjectTask__c>) searchResults[0]);   
            }            
            for (AgouraFree__ProjectTask__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__ProjectTask__c', 'standard:task', 
                                                item.AgouraFree__Task_Number__c + ' ' + item.AgouraFree__Title__c, item.AgouraFree__Status__c, 
                                                null, null, null, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        } else if (viewName == 'Projects' || viewName == 'Project Templates') {
            // Project Query
            List<AgouraFree__Project__c> results = new List<AgouraFree__Project__c>();
            String isProjectTemplate = '';
            if (viewName == 'Project Templates') {
                isProjectTemplate = ' AND AgouraFree__IsTemplate__c = TRUE';                 
            }
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__Project__c WHERE AgouraFree__Status__c LIKE :statusKey' + isProjectTemplate;
                recordQuery = 'SELECT Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate ' +
                    ' FROM AgouraFree__Project__c WHERE AgouraFree__Status__c LIKE :statusKey' + isProjectTemplate;
                if (assignedKey != '') {
                    totalQuery += ' AND Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId' +
                        ' AND AgouraFree__Type__c != \'Project Link\')';
                    recordQuery += ' AND Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId' +
                        ' AND AgouraFree__Type__c != \'Project Link\')';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset';
                List<AgouraFree__Project__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__Project__c (Id WHERE AgouraFree__Status__c LIKE :statusKey' +
                     isProjectTemplate + ')';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' AgouraFree__Project__c (Id, Name, AgouraFree__Title__c, AgouraFree__Status__c, CreatedDate, LastModifiedDate WHERE AgouraFree__Status__c LIKE :statusKey' +
                     isProjectTemplate;
                if (assignedKey != '') {
                    totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__Project__c (Id WHERE AgouraFree__Status__c LIKE :statusKey' + isProjectTemplate +
                        ' AND Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c  WHERE AgouraFree__User__c = :userId AND AgouraFree__Type__c != \'Project Link\'))';
                    recordQuery += ' AND Id IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c' +
                        ' WHERE AgouraFree__User__c = :userId AND AgouraFree__Type__c != \'Project Link\')';
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__Project__c> searchResultsCount = (List<AgouraFree__Project__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY AgouraFree__Title__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__Project__c>) searchResults[0]);   
            }            
            for (AgouraFree__Project__c item : results) {
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__Project__c', 'standard:drafts', item.AgouraFree__Title__c, item.AgouraFree__Status__c, 
                                                null, null, null, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        } else if (viewName == 'Sprints') {
            // Sprint Query
            List<AgouraFree__Sprint__c> results = new List<AgouraFree__Sprint__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__Sprint__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c, AgouraFree__Start_Date__c, AgouraFree__End_Date__c,' + 
                    ' CreatedDate, LastModifiedDate FROM AgouraFree__Sprint__c WHERE Id != null';
                if (statusKey == 'Open%') {
                    totalQuery += ' AND AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today)';
                    recordQuery += ' AND AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today)';
                } else if (statusKey == 'Closed%') {
                    totalQuery += ' AND (AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today)';
                    recordQuery += ' AND (AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today)';
                }
                if (assignedKey != '') {
                    totalQuery += ' AND AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId' + 
                        ' AND AgouraFree__Type__c != \'Project Link\')';
                    recordQuery += ' AND AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__User__c = :userId' + 
                        ' AND AgouraFree__Type__c != \'Project Link\')';
                }
                r.total = Database.countQuery(totalQuery);
                recordQuery += ' ORDER BY AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c LIMIT :pSize OFFSET :offset';
                List<AgouraFree__Sprint__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__Sprint__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__Sprint__c (Id, Name, AgouraFree__Project__r.AgouraFree__Title__c,' +
                    ' AgouraFree__Sprint_Number__c, AgouraFree__Start_Date__c, AgouraFree__End_Date__c, CreatedDate, LastModifiedDate';
                if (assignedKey != '') {
                    totalQuery += ' (Id WHERE AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c ' +
                        ' WHERE AgouraFree__User__c = :userId AND AgouraFree__Type__c != \'Project Link\')';
                    recordQuery += ' WHERE AgouraFree__Project__c IN (SELECT AgouraFree__Project__c FROM AgouraFree__ProjectItem__c ' +
                        ' WHERE AgouraFree__User__c = :userId  AND AgouraFree__Type__c != \'Project Link\')';
                    if (statusKey == 'Open%') {
                        totalQuery += ' AND AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today)';
                        recordQuery += ' AND AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today)';
                    } else if (statusKey == 'Closed%') {
                        totalQuery += ' AND (AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today)';  
                        recordQuery += ' AND (AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today)';
                    }
                    totalQuery += ')';
                } else {
                    if (statusKey == 'Open%') {
                        totalQuery += ' (Id WHERE AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today))';
                        recordQuery += ' WHERE AgouraFree__Start_Date__c <= today AND (AgouraFree__End_Date__c = null or AgouraFree__End_Date__c >= today)';
                    } else if (statusKey == 'Closed%') {
                        totalQuery += ' (Id WHERE AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today)';
                        recordQuery += ' WHERE AgouraFree__Start_Date__c > today OR AgouraFree__End_Date__c < today';
                    }                   
                }    
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__Sprint__c> searchResultsCount = (List<AgouraFree__Sprint__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                recordQuery += ' ORDER BY AgouraFree__Project__r.AgouraFree__Title__c, AgouraFree__Sprint_Number__c LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__Sprint__c>) searchResults[0]);   
            }            
            Date thisDay = Date.today();
            String sprintStatus;
            for (AgouraFree__Sprint__c item : results) {
                sprintStatus = 'Closed';
                if (item.AgouraFree__Start_Date__c <= thisDay && (item.AgouraFree__End_Date__c == null || item.AgouraFree__End_Date__c >= thisDay)) {
                    sprintStatus = 'Open';
                }
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__Sprint__c', 'standard:work_order', 
                                                item.AgouraFree__Project__r.AgouraFree__Title__c + ' Sprint ' + item.AgouraFree__Sprint_Number__c, 
                                                sprintStatus, null, null, null, item.CreatedDate, item.LastModifiedDate, false));                
            } 
            
        } else if (viewName == 'Tags') {
            // Tag Query
            List<AgouraFree__Tag__c> results = new List<AgouraFree__Tag__c>();
            if (filter.searchKey == '') {
                totalQuery = 'SELECT count() FROM AgouraFree__Tag__c WHERE Id != null';
                recordQuery = 'SELECT Id, Name, AgouraFree__For_IdeaBoards__c, AgouraFree__For_ProjectTasks__c, AgouraFree__For_Projects__c, CreatedDate, LastModifiedDate' +
                    ' FROM AgouraFree__Tag__c ORDER BY Name LIMIT :pSize OFFSET :offset';
                r.total = Database.countQuery(totalQuery);
                List<AgouraFree__Tag__c> itemList = Database.query(recordQuery);
                results = itemList;
            } else {
                totalQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING AgouraFree__Tag__c';
                recordQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING' +
                    ' AgouraFree__Tag__c (Id, Name, AgouraFree__For_IdeaBoards__c, AgouraFree__For_ProjectTasks__c, AgouraFree__For_Projects__c, CreatedDate, LastModifiedDate' +
                    ' ORDER BY Name LIMIT :pSize OFFSET :offset)';
                List<List<SObject>> searchQueryCount = Search.query(totalQuery); 
                List<AgouraFree__Tag__c> searchResultsCount = (List<AgouraFree__Tag__c>) searchQueryCount[0];
                r.total = searchResultsCount.size();
                List<List<SObject>> searchResults = Search.query(recordQuery); 
                results = ((List<AgouraFree__Tag__c>) searchResults[0]);   
            }            
            for (AgouraFree__Tag__c item : results) {
                otherString = '';
                if (item.AgouraFree__For_IdeaBoards__c) {otherString += 'Idea Boards, ';}
                if (item.AgouraFree__For_ProjectTasks__c) {otherString += 'Project Tasks, ';}
                if (item.AgouraFree__For_Projects__c) {otherString += 'Projects, ';}
                if (otherString.length() > 3) {
                    otherString = otherString.substring(0, otherString.length() - 2);
                }
                queryResults.add(new ViewRecord(item.Id, item.Name, 'AgouraFree__Tag__c', 'standard:topic', item.Name, 
                                                null, null, null, otherString, item.CreatedDate, item.LastModifiedDate, false));
            }
            
        }
        
        r.viewItems = queryResults; 
        RETURN r;
    }
    
    @AuraEnabled
    public static ObjectAccess objectAccess() {   
        Boolean hasProjects = hasProjectObject();
        ObjectAccess result = new ObjectAccess();
        result.canCreateAnchorStory = false;
        result.canCreateTag = false;
        
        if (hasProjects) {
            if (AgouraFree__AnchorStory__c.sObjectType.getDescribe().isCreateable()) {
                result.canCreateAnchorStory = true;
            }
        }
        if (AgouraFree__Tag__c.sObjectType.getDescribe().isCreateable()) {
            result.canCreateTag = true;
        }
        return result;
    }
    
    @AuraEnabled
    public static Boolean hasProjectObject() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        return gd.containsKey('AgouraFree__Project__c');
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
public with sharing class ProjectSortControllerExt {
    
    public class PagedResult {        
        @AuraEnabled
        public Integer pageSize { get;set; }        
        @AuraEnabled
        public Integer page { get;set; }        
        @AuraEnabled
        public Integer total { get;set; }        
        @AuraEnabled
        public List<AgouraFree__ProjectTask__c> sortlist { get;set; }        
        @AuraEnabled
        public List<AgouraFree__ProjectTask__c> items { get;set; }        
    }
    
    public class Filter {        
        @AuraEnabled
        public String searchKey { get;set; }        
        @AuraEnabled
        public String typeKey { get;set; }        
        @AuraEnabled
        public String rowKey { get;set; }        
        @AuraEnabled
        public String sprintKey { get;set; }        
    }
    
    @AuraEnabled
    public static AgouraFree__ProjectTask__c removeProjectTask(Id taskId) {
        // CRUD and FLS Enforcement
        if (!AgouraFree__ProjectTask__c.sObjectType.getDescribe().isAccessible() || !AgouraFree__ProjectTask__c.sObjectType.getDescribe().isDeletable()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e; 
        }
        
        List<AgouraFree__ProjectTask__c> deleteMe = [SELECT Id FROM AgouraFree__ProjectTask__c WHERE id = :taskId];
        delete deleteMe;
        RETURN null;
    }
    
    @AuraEnabled
    public static List<AgouraFree__ProjectTask__c> sortProjectTasks(Id projectId, List<AgouraFree__ProjectTask__c> projectTasksData){
        // CRUD and FLS Enforcement
        String [] checkFields = new String [] {'AgouraFree__Order__c' };
            Map<String,Schema.SObjectField> m = Schema.SObjectType.AgouraFree__ProjectTask__c.fields.getMap();
        for (String fieldToCheck : checkFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e; 
            }
        }
        update projectTasksData;
        
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
        }
        update newList;        
        RETURN null;
    }
    
    @AuraEnabled
    public static PagedResult getProjectTasks(String filters, Decimal pageSize, Decimal pageNumber, Id projectId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__ProjectTask__c.isAccessible() || 
            !Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
                System.debug('Insufficient access');
                AuraHandledException e = new AuraHandledException('Insufficient access');
                e.setMessage('Insufficient access');
                throw e;
            }
        
        Filter filter = (Filter) JSON.deserializeStrict(filters, ProjectSortControllerExt.Filter.class);
        Integer pSize = (Integer)pageSize;
        String searchKey = '%' + filter.searchKey + '%';
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;
        Integer sprintNumber = 0;
        
        if (filter.sprintKey == 'All') {
            r.sortlist = [SELECT Id, AgouraFree__Order__c
                          FROM AgouraFree__ProjectTask__c
                          WHERE AgouraFree__Project__c = :projectId
                          AND AgouraFree__Order__c != NULL
                          AND AgouraFree__Title__c LIKE :searchKey
                          AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, 
                          AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, AgouraFree__Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )];
            r.items = [SELECT Id, AgouraFree__Order__c, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c, AgouraFree__Status__c, 
                       AgouraFree__Points__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, AgouraFree__Sprint__r.AgouraFree__Start_Date__c, 
                       AgouraFree__Sprint__r.AgouraFree__Sprint_Name__c, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c, AgouraFree__Formatted_Status__c, AgouraFree__Priority__c, 
                       AgouraFree__Due_Date__c, CreatedDate 
                       FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, 
                       AgouraFree__Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];  
        } else if (filter.sprintKey == 'BacklogLatest') {              
            List<AgouraFree__Sprint__c> Sprnts = [SELECT Id
                                              FROM AgouraFree__Sprint__c
                                              WHERE AgouraFree__Project__c = :projectId
                                              ORDER BY AgouraFree__Start_Date__c DESC, AgouraFree__Sprint_Number__c DESC LIMIT 1]; 
            Id sprintId;
            if (Sprnts.size() > 0) {
                sprintId = Sprnts[0].Id;
            }             
            r.sortlist = [SELECT Id, AgouraFree__Order__c
                          FROM AgouraFree__ProjectTask__c
                          WHERE AgouraFree__Project__c = :projectId
                          AND ((AgouraFree__Order__c != NULL AND AgouraFree__Sprint__c = '') OR AgouraFree__Sprint__c = :sprintId)
                          AND AgouraFree__Title__c LIKE :searchKey
                          AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, 
                          AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, AgouraFree__Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND ((AgouraFree__Order__c != NULL AND AgouraFree__Sprint__c = '') OR AgouraFree__Sprint__c = :sprintId)
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )];
            r.items = [SELECT Id, AgouraFree__Order__c, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c, AgouraFree__Status__c, 
                       AgouraFree__Points__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, AgouraFree__Sprint__r.AgouraFree__Start_Date__c, 
                       AgouraFree__Sprint__r.AgouraFree__Sprint_Name__c, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c, AgouraFree__Formatted_Status__c, AgouraFree__Priority__c, 
                       AgouraFree__Due_Date__c, CreatedDate 
                       FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND ((AgouraFree__Order__c != NULL AND AgouraFree__Sprint__c = '') OR AgouraFree__Sprint__c = :sprintId)
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )           
                       ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, 
                       AgouraFree__Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];    
        } else if (filter.sprintKey == 'Backlog') {
            r.sortlist = [SELECT Id, AgouraFree__Order__c
                          FROM AgouraFree__ProjectTask__c
                          WHERE AgouraFree__Project__c = :projectId
                          AND AgouraFree__Order__c != NULL
                          AND AgouraFree__Title__c LIKE :searchKey
                          AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          AND AgouraFree__Sprint__c = ''
                          ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, 
                          AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, AgouraFree__Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Order__c != NULL
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND AgouraFree__Sprint__c = ''];
            r.items = [SELECT Id, AgouraFree__Order__c, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c, AgouraFree__Status__c, 
                       AgouraFree__Points__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, AgouraFree__Sprint__r.AgouraFree__Start_Date__c, 
                       AgouraFree__Sprint__r.AgouraFree__Sprint_Name__c, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c, AgouraFree__Formatted_Status__c, AgouraFree__Priority__c, 
                       AgouraFree__Due_Date__c, CreatedDate  
                       FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Order__c != NULL
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND AgouraFree__Sprint__c = ''
                       ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, 
                       AgouraFree__Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];   
        } else {
            sprintNumber = Integer.valueOf(filter.sprintKey);
            r.sortlist = [SELECT Id, AgouraFree__Order__c
                          FROM AgouraFree__ProjectTask__c
                          WHERE AgouraFree__Project__c = :projectId
                          AND AgouraFree__Order__c != NULL
                          AND AgouraFree__Title__c LIKE :searchKey
                          AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                          AND AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c = :sprintNumber
                          ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, 
                          AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, AgouraFree__Task_Number_Int__c
                          LIMIT :pSize OFFSET :offset];
            r.total = [SELECT count() FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c = :sprintNumber];
            r.items = [SELECT Id, AgouraFree__Order__c, AgouraFree__Task_Number_Int__c, AgouraFree__Task_Number__c, AgouraFree__Title__c, AgouraFree__Formatted_Type__c, 
                       AgouraFree__Status__c, AgouraFree__Points__c, AgouraFree__Assigned_To__r.Name, AgouraFree__Blocked__c, AgouraFree__Sprint__r.AgouraFree__Start_Date__c, 
                       AgouraFree__Sprint__r.AgouraFree__Sprint_Name__c, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c, AgouraFree__Formatted_Status__c, AgouraFree__Priority__c, 
                       AgouraFree__Due_Date__c, CreatedDate  
                       FROM AgouraFree__ProjectTask__c
                       WHERE AgouraFree__Project__c = :projectId
                       AND AgouraFree__Title__c LIKE :searchKey
                       AND AgouraFree__Type__c LIKE : (filter.typeKey  == '' ? '%' : filter.typeKey )
                       AND AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c = :sprintNumber
                       ORDER BY AgouraFree__Order__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Start_Date__c NULLS LAST, AgouraFree__Sprint__r.AgouraFree__Sprint_Number__c NULLS LAST, 
                       AgouraFree__Task_Number_Int__c
                       LIMIT :pSize OFFSET :offset];            
        }
        
        RETURN r;
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
    public static List<String> getSprintKeys(Id projectId) {        
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Sprint__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        List<AgouraFree__Sprint__c> Sprnts = [SELECT AgouraFree__Sprint_Number__c
                                          FROM AgouraFree__Sprint__c
                                          WHERE AgouraFree__Project__c = :projectId
                                          ORDER BY AgouraFree__Start_Date__c DESC, AgouraFree__Sprint_Number__c
                                          LIMIT 10];         
        List<String> values = new list <String>();
        Integer arrayLength = Sprnts.size();     
        String sprintNumber = '';
        for(Integer i = Sprnts.size() - 1; i >= 0; i--){
            sprintNumber = String.valueOf(Sprnts[i].AgouraFree__Sprint_Number__c);
            values.add(sprintNumber);
        }  
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getIdeaBoardStatusKeys() {
        Schema.DescribeFieldResult result = AgouraFree__IdeaBoard__c.AgouraFree__Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getProjectStatusKeys() {
        Schema.DescribeFieldResult result = AgouraFree__Project__c.AgouraFree__Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
    
    @AuraEnabled
    public static List<String> getProjectTaskStatusKeys() {
        Schema.DescribeFieldResult result = AgouraFree__ProjectTask__c.AgouraFree__Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = result.getPicklistValues();
        List<String> values = new list <String>();
        for (Schema.PicklistEntry entry: entries) {
            values.add(entry.getValue());
        }
        RETURN values;
    }
}
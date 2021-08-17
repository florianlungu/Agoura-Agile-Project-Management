public without sharing class specialClass {
    public static Map<String, Integer> getAllNumRecords(Id recId) {
        // CRUD and FLS Enforcement
        if (!Schema.sObjectType.AgouraFree__Project__c.isAccessible()) {
            System.debug('Insufficient access');
            AuraHandledException e = new AuraHandledException('Insufficient access');
            e.setMessage('Insufficient access');
            throw e;
        }
        
        Integer projects = [SELECT Count()
                            FROM AgouraFree__Project__c
                            WHERE Id != :recId
                            AND AgouraFree__IsTemplate__c = false]; 
        Integer templates = [SELECT Count()
                             FROM AgouraFree__Project__c
                             WHERE Id != :recId
                             AND AgouraFree__IsTemplate__c = true]; 
        Map<String, Integer> resultMap = new Map<String, Integer>();
        resultMap.put('projects', projects);  
        resultMap.put('templates', templates);          
        return resultMap;
    }
}
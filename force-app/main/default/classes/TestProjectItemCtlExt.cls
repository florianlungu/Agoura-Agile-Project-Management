@isTest 
public class TestProjectItemCtlExt {
    
    static testMethod void test_recordAccess() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');       
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.ProjectItemControllerExt.recordAccess(testProjectItem.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPI1','standarduserPI1@agourasoftware.com','Testing PI1','standarduserPI1@agourasoftware.com');      
        
        Test.startTest();
        AgouraFree__ProjectItem__c results = AgouraFree.ProjectItemControllerExt.getWebPageTitle(testProjectItem.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectItemControllerExt.getWebPageTitle(testProjectItem.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Swim Lane', results.get('AgouraFree__Title__c'));
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectStakeholder(userId, testProject.Id, 'Executive Sponsor', 'Informed');
        User testUser = createTestUser('userPI2','standarduserPI2@agourasoftware.com','Testing PI2','standarduserPI2@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectItemControllerExt.getUsers(testProjectItem.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectItemControllerExt.getUsers(testProjectItem.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(3, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
        System.assertEquals(userId, results.get(2).getId());
    }
    
    static testMethod void test_getProject() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane'); 
        User testUser = createTestUser('userPI3','standarduserPI3@agourasoftware.com','Testing PI3','standarduserPI3@agourasoftware.com');       
        
        Test.startTest();
        AgouraFree__Project__c results = AgouraFree.ProjectItemControllerExt.getProject(testProjectItem.Id);
        System.runas(testUser) {
            try {
                AgouraFree__Project__c accessResult = AgouraFree.ProjectItemControllerExt.getProject(testProjectItem.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Project', results.get('AgouraFree__Title__c'));
    } 
    
    static testMethod void test_projectSearch() {
        Id [] fixedResults = new Id[1]; 
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPI4','standarduserPI4@agourasoftware.com','Testing PI4','standarduserPI4@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectItemControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectItemControllerExt.projectSearch('Test', selectedIds);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userPI5','standarduserPI5@agourasoftware.com','Testing PI5','standarduserPI5@agourasoftware.com'); 
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectItemControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void test_getProjectSwimLanes() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPI6','standarduserPI6@agourasoftware.com','Testing PI6','standarduserPI6@agourasoftware.com');       
        
        Test.startTest();
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectItemControllerExt.getProjectSwimLanes(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectItem__c> accessResult = AgouraFree.ProjectItemControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults.size());
        System.assertEquals(testProjectItem.Id, getResults.get(0).Id);       
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userPI7','standarduserPI7@agourasoftware.com','Testing PI7','standarduserPI7@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.ProjectItemControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.ProjectItemControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Comments__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.ProjectItemControllerExt.getFieldLabelMap('AgouraFree__ProjectItem__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Comments__c'));     
		Test.stopTest();
    }
    
    //
    // create test data
    // 
    private static AgouraFree__Project__c createTestProject(String title, String abbrev) {
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c=title,
                                                                AgouraFree__Project_Abbreviation__c=abbrev,
                                                                AgouraFree__Status__c='Draft');
        insert testProject;
        return testProject;
    }
    
    private static AgouraFree__ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        AgouraFree__ProjectItem__c testProjectItem = new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId,
                                                                            AgouraFree__Type__c=typeStr,
                                                                            AgouraFree__Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static AgouraFree__ProjectItem__c createTestProjectStakeholder(Id userId, Id projectId, String typeStr, String raci) {
        AgouraFree__ProjectItem__c testProjectItem = new AgouraFree__ProjectItem__c(AgouraFree__Title__c = userId,
                                                                            AgouraFree__Project__c = projectId,
                                                                            AgouraFree__Type__c = typeStr,
                                                                            AgouraFree__User__c = userId,
                                                                            AgouraFree__RACI__c = raci);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static User createTestUser(String alias, String email, String lastName, String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(Alias=alias, Email=email, 
                                 EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName=userName);        
        insert testUser;
        return testUser;
    }
}
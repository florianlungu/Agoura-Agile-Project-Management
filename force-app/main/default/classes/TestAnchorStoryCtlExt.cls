@isTest 
public class TestAnchorStoryCtlExt {

    static testMethod void test_recordAccess() {
        Id userId = UserInfo.getUserId();
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');      
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.AnchorStoryControllerExt.recordAccess(testAnchorStory.Id);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userAS12','standarduserAS12@agourasoftware.com','Testing AS12','standarduserAS12@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.AnchorStoryControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.AnchorStoryControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void test_getRecordTitle() {
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createTestUser('userAS2','standarduserAS2@agourasoftware.com','Testing AS2','standarduserAS2@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree__AnchorStory__c> results = AgouraFree.AnchorStoryControllerExt.getWebPageTitle(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__AnchorStory__c> accessResult = AgouraFree.AnchorStoryControllerExt.getWebPageTitle(testAnchorStory.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Record', results.get(0).AgouraFree__Title__c);
    } 
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createTestUser('userAS3','standarduserAS3@agourasoftware.com','Testing AS3','standarduserAS3@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.AnchorStoryControllerExt.getUsers(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.AnchorStoryControllerExt.getUsers(testAnchorStory.Id);
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
    
    static testMethod void test_anchorStorySearch() {
        Id [] fixedResults = new Id[1]; 
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        fixedResults.add(testAnchorStory.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userAS4','standarduserAS4@agourasoftware.com','Testing AS4','standarduserAS4@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.AnchorStoryControllerExt.anchorStorySearch('Test Record', selectedIds, '');
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.AnchorStoryControllerExt.anchorStorySearch('Test Record', selectedIds, ''); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAnchorStory.Id, results.get(0).getId());
    }
    
    static testMethod void test_cloneAndMasterTask() {
        Id [] fixedResults = new Id[1];
        AgouraFree__AnchorStory__c testAnchorStoryMaster = createTestAnchorStory('Test Record'); 
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, testAnchorStoryMaster.Id);
        fixedResults.add(testAnchorStoryMaster.Id);
        Test.setFixedSearchResults(fixedResults);
        User testUser = createTestUser('userAS5','standarduserAS5@agourasoftware.com','Testing AS5','standarduserAS5@agourasoftware.com'); 
        
        Test.startTest();
        Id result = AgouraFree.AnchorStoryControllerExt.createCloneAnchorStory(testAnchorStory.Id);        
        List<AgouraFree__AnchorStory__c> resultMasterTask = AgouraFree.AnchorStoryControllerExt.getMasterTask(testAnchorStory.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AgouraFree.AnchorStoryControllerExt.createCloneAnchorStory(testAnchorStory.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__AnchorStory__c> accessResult2 = AgouraFree.AnchorStoryControllerExt.getMasterTask(testAnchorStory.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assert(result != null);
        System.assertEquals(testAnchorStoryMaster.Id, resultMasterTask.get(0).AgouraFree__Master_Task__c);        
    }
    
    static testMethod void test_subTask() {
        Id [] fixedResults = new Id[1];
        AgouraFree__AnchorStory__c testAnchorStoryMaster = createTestAnchorStory('Test Record'); 
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, testAnchorStoryMaster.Id);
        fixedResults.add(testAnchorStory.Id);
        Test.setFixedSearchResults(fixedResults);
        User testUser = createTestUser('userAS6','standarduserAS6@agourasoftware.com','Testing AS6','standarduserAS6@agourasoftware.com'); 
        
        Test.startTest();        
        List<AgouraFree__AnchorStory__c> resultSubTask = AgouraFree.AnchorStoryControllerExt.getSubTasks(testAnchorStoryMaster.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__AnchorStory__c> accessResult = AgouraFree.AnchorStoryControllerExt.getSubTasks(testAnchorStoryMaster.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
  		Test.stopTest();

        System.assertEquals(1, resultSubTask.size());
        System.assertEquals(testAnchorStory.Id, resultSubTask.get(0).Id);
    }
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStory('Test Record');
        User testUser = createAdminUser('userAS7','standarduserAS7@agourasoftware.com','Testing AS7','standarduserAS7@agourasoftware.com'); 
        User testUser2 = createTestUser('userAS8','standarduserAS8@agourasoftware.com','Testing AS8','standarduserAS8@agourasoftware.com'); 
        
        Test.startTest();
        AgouraFree__AnchorStory__c updateTest = AgouraFree.AnchorStoryControllerExt.updateDocumentOwner(testAnchorStory.Id, testUser.id);
        System.runas(testUser2) {
            try {
                AgouraFree__AnchorStory__c accessResult = AgouraFree.AnchorStoryControllerExt.updateDocumentOwner(testAnchorStory.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userAS9','standarduserAS9@agourasoftware.com','Testing AS9','standarduserAS9@agourasoftware.com'); 
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.AnchorStoryControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userAS10','standarduserAS10@agourasoftware.com','Testing AS10','standarduserAS10@agourasoftware.com'); 
        User testUser2 = createTestUser('userAS11','standarduserAS11@agourasoftware.com','Testing AS11','standarduserAS11@agourasoftware.com'); 
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.AnchorStoryControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }
    
    static testMethod void test_projectSearch() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Id [] fixedResults = new Id[1]; 
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userAS13','standarduserAS13@agourasoftware.com','Testing AS13','standarduserAS13@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.AnchorStoryControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.AnchorStoryControllerExt.projectSearch('Test', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_doCreateProjectTask() {
        AgouraFree__AnchorStory__c testAnchorStory = createTestAnchorStoryBig('Test Record', 'Test String', 10, null);
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createAdminUser('userAS14','standarduserAS14@agourasoftware.com','Testing AS14','standarduserAS14@agourasoftware.com'); 
        
        Test.startTest();
        Id results2 = AgouraFree.AnchorStoryControllerExt.doCreateProjectTask(testAnchorStory.Id, testProject.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AgouraFree.AnchorStoryControllerExt.doCreateProjectTask(testAnchorStory.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertNotEquals(Null, results2);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Acceptance_Criteria__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.AnchorStoryControllerExt.getFieldLabelMap('AgouraFree__AnchorStory__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Acceptance_Criteria__c'));     
		Test.stopTest();
    }
    
    //
    // create test data
    //
    private static AgouraFree__AnchorStory__c createTestAnchorStory(String anchorStoryName) {
        AgouraFree__AnchorStory__c testAnchorStory = new AgouraFree__AnchorStory__c(AgouraFree__Title__c=anchorStoryName,
                                                                            AgouraFree__Type__c='User Story');        
        insert testAnchorStory;
        return testAnchorStory;
    }
    
    private static AgouraFree__AnchorStory__c createTestAnchorStoryBig(String anchorStoryName, String testString, Decimal testDecimal, Id recId) {
        AgouraFree__AnchorStory__c testAnchorStory = new AgouraFree__AnchorStory__c(AgouraFree__Title__c=anchorStoryName,
                                                                            AgouraFree__Acceptance_Criteria__c=testString, 
                                                                            AgouraFree__Comments__c=testString, 
                                                                            AgouraFree__Components__c=testString, 
                                                                            AgouraFree__Dependencies__c=testString, 
                                                                            AgouraFree__Description__c=testString, 
                                                                            AgouraFree__Master_Task__c=recId, 
                                                                            AgouraFree__Points__c=testDecimal, 
                                                                            AgouraFree__Priority__c='High', 
                                                                            AgouraFree__Search_Terms__c=testString, 
                                                                            AgouraFree__Time_Estimate__c=testDecimal, 
                                                                            AgouraFree__Value__c=testString,
                                                                            AgouraFree__Type__c='User Story');        
        insert testAnchorStory;
        return testAnchorStory;
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
    
    private static User createAdminUser(String alias, String email, String lastName, String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User testUser = new User(Alias=alias, Email=email, 
                                 EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName=userName);        
        insert testUser;
        return testUser;
    }  
    private static AgouraFree__Project__c createTestProject(String title, String abbrev) {
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c=title,
                                                                AgouraFree__Project_Abbreviation__c=abbrev,
                                                                AgouraFree__Status__c='Draft');
        insert testProject;
        return testProject;
    }
    
    private static AgouraFree__ProjectTask__c createTestProjectTask(Id projectId, String title, Decimal points, Id swimLane, Id masterTask, Decimal order,
                                                                Id userId, Id sprintId, String typeStr) {
		AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=projectId,
                                                                            AgouraFree__Title__c=title,
                                                                            AgouraFree__Points__c=points,
                                                                            AgouraFree__Swim_Lane__c=swimLane,
                                                                            AgouraFree__Master_Task__c=masterTask,
                                                                            AgouraFree__Order__c=order,
                                                                            AgouraFree__Assigned_To__c=userId,
                                                                            AgouraFree__Sprint__c=sprintId,
                                                                            AgouraFree__Type__c=typeStr);
        insert testProjectTask;
		return testProjectTask;
    }
}
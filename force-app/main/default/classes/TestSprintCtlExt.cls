@isTest 
public class TestSprintCtlExt {
    
    static testMethod void test_recordAccess() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.SprintControllerExt.recordAccess(testSprint.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS1','standarduserS1@agourasoftware.com','Testing S1','standarduserS1@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getWebPageTitle(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getWebPageTitle(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).AgouraFree__Project__r.AgouraFree__Title__c);
    }
    
    static testMethod void test_getEndDate() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Date thisDay = Date.today();
        testSprint.AgouraFree__End_Date__c = thisDay;
        update testSprint;
        User testUser = createTestUser('userS2','standarduserS2@agourasoftware.com','Testing S2','standarduserS2@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getEndDate(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getEndDate(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(thisDay, results.get(0).AgouraFree__End_Date__c);
    }
    
    static testMethod void test_getUsers() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userS3','standarduserS3@agourasoftware.com','Testing S3','standarduserS3@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.SprintControllerExt.getUsers(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.SprintControllerExt.getUsers(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(2, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
    }
    
    static testMethod void test_getProject() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS4','standarduserS4@agourasoftware.com','Testing S4','standarduserS4@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Project__c> results = AgouraFree.SprintControllerExt.getProject(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Project__c> accessResult = AgouraFree.SprintControllerExt.getProject(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);
    }
    
    static testMethod void test_getDefaultProject() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS5','standarduserS5@agourasoftware.com','Testing S5','standarduserS5@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Project__c> results = AgouraFree.SprintControllerExt.getDefaultProject(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Project__c> accessResult = AgouraFree.SprintControllerExt.getDefaultProject(testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).AgouraFree__Title__c);
    }
    
    static testMethod void test_getDefaultFields() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userS6','standarduserS6@agourasoftware.com','Testing S6','standarduserS6@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getDefaultFields(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getDefaultFields(testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('2 weeks', results.get(0).AgouraFree__Sprint_Length__c);
    }
    
    static testMethod void test_projectSearch() {
        Id [] fixedResults = new Id[1]; 
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userS7','standarduserS7@agourasoftware.com','Testing S7','standarduserS7@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.SprintControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.SprintControllerExt.projectSearch('Test', selectedIds);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_getStatuses() {
        Test.startTest();
        List<String> getResults = AgouraFree.SprintControllerExt.getStatuses();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Open', getResults.get(0));
    }
    
    static testMethod void test_getTypeKeys() {
        Test.startTest();
        List<String> getResults = AgouraFree.SprintControllerExt.getTypeKeys();
        Test.stopTest();
        
        System.assertEquals(8, getResults.size());
        System.assertEquals('Bug', getResults.get(0));
    }
    
    static testMethod void test_getProjectTasks() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', null);
        List<AgouraFree__ProjectTask__c> taskList = new List<AgouraFree__ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS8','standarduserS8@agourasoftware.com','Testing S8','standarduserS8@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.SprintControllerExt.PagedResult results = AgouraFree.SprintControllerExt.getProjectTasks(searchFilter, 10.0, 1.0, testSprint.Id);
        System.runas(testUser) {
            try {
                AgouraFree.SprintControllerExt.PagedResult accessResult = AgouraFree.SprintControllerExt.getProjectTasks(searchFilter, 10.0, 1.0, testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        taskList = results.items;
        System.assertEquals(1, results.total);  
        System.assertEquals(testProjectTask.Id, taskList.get(0).Id);  
        
    }
    
    static testMethod void test_getSprintTaskItems() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        List<AgouraFree__ProjectTask__c> taskList = new List<AgouraFree__ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS9','standarduserS9@agourasoftware.com','Testing S9','standarduserS9@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__ProjectTask__c> results = AgouraFree.SprintControllerExt.getSprintTaskItems(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectTask__c> accessResult = AgouraFree.SprintControllerExt.getSprintTaskItems(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).Id);         
    }
    
    static testMethod void test_updateSprintTaskItem() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        AgouraFree__ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask2.AgouraFree__Type__c='Bug';
        testProjectTask2.AgouraFree__Order__c=2;
        update testProjectTask2;
        List<AgouraFree__ProjectTask__c> taskList = new List<AgouraFree__ProjectTask__c>{};
            String searchFilter = createTestFilter('','');
        User testUser = createTestUser('userS10','standarduserS10@agourasoftware.com','Testing S10','standarduserS10@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectTask__c result1 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Start');
        AgouraFree__ProjectTask__c result2 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Complete');
        AgouraFree__ProjectTask__c result3 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'Complete');
        AgouraFree__ProjectTask__c result4 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'Remove');
        AgouraFree__ProjectTask__c result5 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask2.Id, testSprint.Id, 'AddItem');
        System.runas(testUser) {
            try {
                AgouraFree__ProjectTask__c accessResult = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Start');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals('In Progress', result1.AgouraFree__Status__c);  
        System.assertEquals('Done', result2.AgouraFree__Status__c);   
        System.assertEquals('Resolved', result3.AgouraFree__Status__c); 
        System.assertEquals(null, result4.AgouraFree__Sprint__c);       
        System.assertEquals(testSprint.Id, result5.AgouraFree__Sprint__c);         
    }
    
    static testMethod void test_updateTaskSwimLane() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', null);
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');
        User testUser = createTestUser('userS11','standarduserS11@agourasoftware.com','Testing S11','standarduserS11@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectTask__c results = AgouraFree.SprintControllerExt.updateTaskSwimLane(testProjectTask.Id, testProjectItem.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectTask__c accessResult = AgouraFree.SprintControllerExt.updateTaskSwimLane(testProjectTask.Id, testProjectItem.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(testProjectItem.Id, results.AgouraFree__Swim_Lane__c);   
    }
    
    static testMethod void test_getTargetPoints() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        testSprint.AgouraFree__Target_Points__c = 10;
        update testSprint;
        User testUser = createTestUser('userS12','standarduserS12@agourasoftware.com','Testing S12','standarduserS12@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getTargetPoints(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getTargetPoints(testSprint.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(10, results.get(0).AgouraFree__Target_Points__c);
    }
    
    static testMethod void test_getStartDate() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Date thisDay = Date.today();
        testSprint.AgouraFree__Start_Date__c = thisDay;
        update testSprint;
        User testUser = createTestUser('userS13','standarduserS13@agourasoftware.com','Testing S13','standarduserS13@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getStartDate(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getStartDate(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(thisDay, results.get(0).AgouraFree__Start_Date__c);
    }
    
    static testMethod void test_getCompletedPoints() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask.AgouraFree__Points__c = 10;
        update testProjectTask;
        AgouraFree__ProjectTask__c result1 = AgouraFree.SprintControllerExt.updateSprintTaskItem(testProjectTask.Id, testSprint.Id, 'Complete');
        User testUser = createTestUser('userS14','standarduserS14@agourasoftware.com','Testing S14','standarduserS14@agourasoftware.com');
        
        Test.startTest();
        List<AggregateResult> results2 = AgouraFree.SprintControllerExt.getCompletedPoints(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AggregateResult> accessResult = AgouraFree.SprintControllerExt.getCompletedPoints(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results2.size());
        System.assertEquals(10, results2.get(0).get('points'));
    }
    
    static testMethod void test_getProjectSwimLanes() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');
        User testUser = createTestUser('userS15','standarduserS15@agourasoftware.com','Testing S15','standarduserS15@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__ProjectItem__c> results = AgouraFree.SprintControllerExt.getProjectSwimLanes(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectItem__c> accessResult = AgouraFree.SprintControllerExt.getProjectSwimLanes(testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectItem.Id, results.get(0).Id);   
    }
    
    static testMethod void test_getAssignedToList() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');        
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);
        testProjectTask.AgouraFree__Assigned_To__c = userId;
        update testProjectTask;
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.SprintControllerExt.getAssignedToList(testSprint.Id);
        Test.stopTest();        
        
        System.assertEquals(1, results.size());
        System.assertEquals(userId, results.get(0).getId()); 
    }
    
    static testMethod void test_removeAccess() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        testProject.AgouraFree__Product_Owner__c = userId;
        update testProject;
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');    
        User testUser = createTestUser('userS16','standarduserS16@agourasoftware.com','Testing S16','standarduserS16@agourasoftware.com'); 
        
        Test.startTest();
        Boolean result = AgouraFree.SprintControllerExt.removeAccess(testSprint.Id);
        System.runas(testUser) {
            try {
                Boolean accessResult = AgouraFree.SprintControllerExt.removeAccess(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        System.assertEquals(true, result); 
    }
    
    static testMethod void test_doCloseSprint() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');  
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint.Id);   
        FeedItem testFeedItem = createFeedPost(testProject.Id);
        User testUser = createTestUser('userS17','standarduserS17@agourasoftware.com','Testing S17','standarduserS17@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.SprintControllerExt.doCloseSprint(testSprint.Id, testFeedItem, true);
        System.runas(testUser) {
            try {
                AgouraFree.SprintControllerExt.doCloseSprint(testSprint.Id, testFeedItem, true);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();        
        
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProject.Id];        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    } 
    
    static testMethod void test_updateSprintNumberCompletedPoints() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST'); 
        User testUser = createTestUser('userS18','standarduserS18@agourasoftware.com','Testing S18','standarduserS18@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__Sprint__c result = AgouraFree.SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks'); 
        AgouraFree__Sprint__c result2 = AgouraFree.SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
        AgouraFree__Sprint__c testSprint2 = new AgouraFree__Sprint__c(AgouraFree__Project__c=testProject.Id,
                                                                      AgouraFree__Sprint_Length__c='2 weeks',
                                                                      AgouraFree__Sprint_Number__c=2);
        insert testSprint2;
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', testSprint2.Id); 
        testProjectTask.AgouraFree__Status__c = 'Done';
        testProjectTask.AgouraFree__Points__c = 5;
        update testProjectTask;
        AgouraFree__Sprint__c result3 = AgouraFree.SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, testSprint2.Id);
        System.runas(testUser) {
            try {
                AgouraFree__Sprint__c accessResult = AgouraFree.SprintControllerExt.updateSprintNumberCompletedPoints(testProject.Id, null);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, result.AgouraFree__Sprint_Number__c); 
        System.assertEquals(2, result2.AgouraFree__Sprint_Number__c);   
        System.assertEquals(2, result3.AgouraFree__Sprint_Number__c); 
        System.assertEquals(5, result3.AgouraFree__Completed_Points__c);
    }     
    
    static testMethod void test_createAccess() {
        User testUser = createTestUser('userS19','standarduserS19@agourasoftware.com','Testing S19','standarduserS19@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.SprintControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.SprintControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
        Test.stopTest();
        
        System.assertEquals(True, results);
    }  
    
    static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Completed_Points__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.SprintControllerExt.getFieldLabelMap('AgouraFree__Sprint__c', fieldList);
        
        System.assertEquals(true,results.containsKey('AgouraFree__Completed_Points__c'));     
        Test.stopTest();
    }
    
    static testMethod void test_getCurrentSprint() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 20;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getCurrentSprint(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getCurrentSprint(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void test_getSprint() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 21;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.SprintControllerExt.getSprint(testSprint.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.SprintControllerExt.getSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
    }
    
    static testMethod void test_removeProjectSprint() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Integer userNum = 22;
        User testUser = createTestUser('userS'+userNum,'standarduserS'+userNum+'@agourasoftware.com','Testing S'+userNum,'standarduserS'+userNum+'@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__Sprint__c result = AgouraFree.SprintControllerExt.removeProjectSprint(testSprint.Id);
        System.runas(testUser) {
            try {
                AgouraFree__Sprint__c accessResult = AgouraFree.SprintControllerExt.removeProjectSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(null, result);
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
    
    private static AgouraFree__Sprint__c createTestSprint(Id projectId, String sprintLength) {
        AgouraFree__Sprint__c testSprint = new AgouraFree__Sprint__c(AgouraFree__Project__c=projectId,
                                                                     AgouraFree__Sprint_Length__c=sprintLength,
                                                                     AgouraFree__Sprint_Number__c=1,
                                                                     AgouraFree__Sprint_Name__c='Sprint 1');
        insert testSprint;
        return testSprint;
    }
    
    private static AgouraFree__ProjectTask__c createTestProjectTask(Id projectId, String title, Id SprintId) {
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=projectId,
                                                                                    AgouraFree__Title__c=title,
                                                                                    AgouraFree__Sprint__c=sprintId,
                                                                                    AgouraFree__Status__c='Open',
                                                                                    AgouraFree__Type__c='User Story');
        insert testProjectTask;
        return testProjectTask;
    }
    
    private static String createTestFilter(String searchKeyStr, String typeKeyStr) {
        AgouraFree.SprintControllerExt.Filter testFilter = new AgouraFree.SprintControllerExt.Filter();
        testFilter.searchKey = searchKeyStr;
        testFilter.typeKey = typeKeyStr;
        String myJSON = JSON.serialize(testFilter);
        return myJSON;
    }
    
    private static AgouraFree__ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        AgouraFree__ProjectItem__c testProjectItem = new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId,
                                                                                    AgouraFree__Type__c=typeStr,
                                                                                    AgouraFree__Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static FeedItem createFeedPost(Id projectId) {
        FeedItem testFeedPost = new FeedItem(ParentId=projectId,
                                             Type='TextPost',
                                             IsRichText=false,
                                             Body='Some text');                  
        return testFeedPost;
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
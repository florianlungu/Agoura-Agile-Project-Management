@isTest 
public class TestProjectTaskCtlExt {
    
    static testMethod void test_recordAccess() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.ProjectTaskControllerExt.recordAccess(testProjectTask.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT2','standarduserPT2@agourasoftware.com','Testing PT2','standarduserPT2@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__ProjectTask__c> results = AgouraFree.ProjectTaskControllerExt.getWebPageTitle(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectTask__c> accessResult = AgouraFree.ProjectTaskControllerExt.getWebPageTitle(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project Task', results.get(0).AgouraFree__Title__c);
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, userId, null, 'User Story');
        User testUser = createTestUser('userPT3','standarduserPT3@agourasoftware.com','Testing PT3','standarduserPT3@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.getUsers(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectTaskControllerExt.getUsers(testProjectTask.Id); 
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
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT4','standarduserPT4@agourasoftware.com','Testing PT4','standarduserPT4@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Project__c> results = AgouraFree.ProjectTaskControllerExt.getProject(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Project__c> accessResult = AgouraFree.ProjectTaskControllerExt.getProject(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);      
    }
    
    static testMethod void test_getSprint() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, testSprint.Id, 'User Story');
        User testUser = createTestUser('userPT5','standarduserPT5@agourasoftware.com','Testing PT5','standarduserPT5@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Sprint__c> results = AgouraFree.ProjectTaskControllerExt.getSprint(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Sprint__c> accessResult = AgouraFree.ProjectTaskControllerExt.getSprint(testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testSprint.Id, results.get(0).Id);        
    }
    
    static testMethod void test_getMasterTask() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        AgouraFree__ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, testProjectTask.Id, 1.0, null, 
                                                                        null, 'User Story');
        User testUser = createTestUser('userPT6','standarduserPT6@agourasoftware.com','Testing PT6','standarduserPT6@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__ProjectTask__c> results = AgouraFree.ProjectTaskControllerExt.getMasterTask(testProjectTask2.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectTask__c> accessResult = AgouraFree.ProjectTaskControllerExt.getMasterTask(testProjectTask2.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).AgouraFree__Master_Task__c);      
    }
    
    static testMethod void test_getSubTasks() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        AgouraFree__ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, testProjectTask.Id, 1.0, null, 
                                                                        null, 'User Story');
        User testUser = createTestUser('userPT7','standarduserPT7@agourasoftware.com','Testing PT7','standarduserPT7@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__ProjectTask__c> results = AgouraFree.ProjectTaskControllerExt.getSubTasks(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectTask__c> accessResult = AgouraFree.ProjectTaskControllerExt.getSubTasks(testProjectTask.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask2.Id, results.get(0).Id);       
    }
    
    static testMethod void test_projectSearch() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Id [] fixedResults = new Id[1]; 
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT8','standarduserPT8@agourasoftware.com','Testing PT8','standarduserPT8@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.projectSearch('Test', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectTaskControllerExt.projectSearch('Test', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).getId());
    }
    
    static testMethod void test_doStartWork() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT9','standarduserPT9@agourasoftware.com','Testing PT9','standarduserPT9@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.doStartWork(testProjectTask.Id);
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.doStartWork(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Status__c FROM AgouraFree__ProjectTask__c];        
        System.assertEquals(1, taskList.size());
        System.assertEquals('In Progress', taskList.get(0).AgouraFree__Status__c);         
    }
    
    static testMethod void test_doCompleteWork() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, null, null, 1.0, null, testSprint.Id, 'User Story');
        AgouraFree__ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task 2', 5.0, null, null, 2.0, null, testSprint.Id, 'Bug');
        User testUser = createTestUser('userPT10','standarduserPT10@agourasoftware.com','Testing PT10','standarduserPT10@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.doCompleteWork(testProjectTask.Id, testSprint.Id, testProject.Id);
        AgouraFree.ProjectTaskControllerExt.doCompleteWork(testProjectTask2.Id, testSprint.Id, testProject.Id);  
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.doCompleteWork(testProjectTask.Id, testSprint.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }      
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Status__c FROM AgouraFree__ProjectTask__c ORDER BY AgouraFree__Title__c];  
        System.assertEquals(2, taskList.size());
        System.assertEquals('Done', taskList.get(0).AgouraFree__Status__c); 
        List<AgouraFree__ProjectTask__c> taskList2 = [SELECT Id, AgouraFree__Status__c FROM AgouraFree__ProjectTask__c ORDER BY AgouraFree__Title__c]; 
        System.assertEquals(2, taskList2.size());
        System.assertEquals('Resolved', taskList2.get(1).AgouraFree__Status__c);        
        List<AgouraFree__Sprint__c> sprintList = [SELECT Id, AgouraFree__Completed_Points__c FROM AgouraFree__Sprint__c];
        System.assertEquals(1, sprintList.size());
        System.assertEquals(10.0, sprintList.get(0).AgouraFree__Completed_Points__c);       
    }
    
    static testMethod void test_userOnlySearch() {
        User testUser = createTestUser('userPT11','standarduserPT11@agourasoftware.com','Testing PT11','standarduserPT11@agourasoftware.com'); 
        Id [] fixedResults = new Id[1];
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());      
    }
    
    static testMethod void test_getProjectSwimLanes() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testProjectItem = createTestProjectItem(testProject.Id, 'Project Swim Lane', 'Test Swim Lane');  
        User testUser = createTestUser('userPT12','standarduserPT12@agourasoftware.com','Testing PT12','standarduserPT12@agourasoftware.com');     
        
        Test.startTest();
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectTaskControllerExt.getProjectSwimLanes(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__ProjectItem__c> accessResult = AgouraFree.ProjectTaskControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults.size());
        System.assertEquals(testProjectItem.Id, getResults.get(0).Id);        
    }
    
    static testMethod void test_sprintSearch() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testSprint.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT13','standarduserPT13@agourasoftware.com','Testing PT13','standarduserPT13@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.sprintSearch('Sprint 1', selectedIds, testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectTaskControllerExt.sprintSearch('Sprint 1', selectedIds, testProject.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testSprint.Id, results.get(0).getId());      
    }
    
    static testMethod void test_projectTaskSearch() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task');
        insert testProjectTask;
        Id [] fixedResults = new Id[1];
        fixedResults.add(testProjectTask.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT14','standarduserPT14@agourasoftware.com','Testing PT14','standarduserPT14@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.projectTaskSearch('Task', selectedIds, testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectTaskControllerExt.projectTaskSearch('Task', selectedIds, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProjectTask.Id, results.get(0).getId());     
    }
    
    static testMethod void test_getRelatedAccount() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Account testAccount = createTestAccount('Test Account');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Account__c=testAccount.Id);
        insert testProjectTask;
        User testUser = createTestUser('userPT15','standarduserPT15@agourasoftware.com','Testing PT15','standarduserPT15@agourasoftware.com'); 
        
        Test.startTest();
        List<Account> results = AgouraFree.ProjectTaskControllerExt.getRelatedAccount(testProjectTask.Id);
        System.runas(testUser) {
            try {
                List<Account> accessResult = AgouraFree.ProjectTaskControllerExt.getRelatedAccount(testProjectTask.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).Id);           
    }
    
    static testMethod void test_accountSearch() {
        Account testAccount1 = createTestAccount('Test Account 1');
        Account testAccount2 = createTestAccount('Test Account 2');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testAccount1.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.accountSearch('Account 1', selectedIds);
        Test.stopTest();
                
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount1.Id, results.get(0).getId());         
    }
    
    static testMethod void test_tagSearch() {
        AgouraFree__Tag__c testTag1 = createTestTag('Test Tag 1');
        AgouraFree__Tag__c testTag2 = createTestTag('Test Tag 2');
        Id [] fixedResults = new Id[1];
        fixedResults.add(testTag1.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userPT16','standarduserPT16@agourasoftware.com','Testing PT16','standarduserPT16@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectTaskControllerExt.tagSearch('Tag 1', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectTaskControllerExt.tagSearch('Tag 1', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());          
    }
    
    static testMethod void test_Project_Task_Tags() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');        
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag 1');
        insert testProjectTask;
        User testUser = createTestUser('userPT17','standarduserPT17@agourasoftware.com','Testing PT17','standarduserPT17@agourasoftware.com'); 
        User testUser2 = createTestUser('userPT18','standarduserPT18@agourasoftware.com','Testing PT18','standarduserPT18@agourasoftware.com'); 
        
        Test.startTest();
        AgouraFree__ProjectTaskTagAssoc__c results = AgouraFree.ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        List<AgouraFree__Tag__c> results2 = AgouraFree.ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
        AgouraFree__ProjectTaskTagAssoc__c results3 = AgouraFree.ProjectTaskControllerExt.removeProjectTaskTag(testTag.Id, testProjectTask.Id);
        List<AgouraFree__Tag__c> results4 = AgouraFree.ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectTaskTagAssoc__c accessResult = AgouraFree.ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__ProjectTaskTagAssoc__c accessResult2 = AgouraFree.ProjectTaskControllerExt.removeProjectTaskTag(testTag.Id, testProjectTask.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__Tag__c> accessResult3 = AgouraFree.ProjectTaskControllerExt.getProjectTaskTags(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results2.size());
        System.assertEquals(testTag.Id, results2.get(0).Id);
        System.assertEquals(0, results4.size());
    }
    
    static testMethod void test_getDefaultProject() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userPT19','standarduserPT19@agourasoftware.com','Testing PT19','standarduserPT19@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree__Project__c> results = AgouraFree.ProjectTaskControllerExt.getDefaultProject(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Project__c> accessResult = AgouraFree.ProjectTaskControllerExt.getDefaultProject(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testProject.Id, results.get(0).Id);
    }
    
    static testMethod void test_createCloneTask() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectItem__c testSwimLane = AgouraFree.ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        Account testAccount = createTestAccount('Test Account');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        AgouraFree__ProjectTask__c testProjectTaskMaster = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                                  AgouraFree__Title__c='Test Project Task');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Accept__c='Test String', 
                                                                            AgouraFree__Account__c=testAccount.Id, 
                                                                            AgouraFree__Affected_Version__c='Test String',
                                                                            AgouraFree__Bug_Type__c='Blocker',   
                                                                            AgouraFree__Comments__c='Test String', 
                                                                            AgouraFree__Components__c='Test String',       
                                                                            AgouraFree__Dependencies__c='Test String',                                                                    
                                                                            AgouraFree__Description__c='Test String', 
                                                                            AgouraFree__Due_Date__c=Date.today(), 
                                                                            AgouraFree__Fix_Version__c='Test String',
                                                                            AgouraFree__Master_Task__c=testProjectTaskMaster.Id,
                                                                            AgouraFree__Priority__c='High',
                                                                            AgouraFree__Project__c=testProject.Id, 
                                                                            AgouraFree__Points__c=5.0, 
                                                                            AgouraFree__Reported_By__c='Test String', 
                                                                            AgouraFree__Reported_Date__c=Date.today(), 
                                                                            AgouraFree__Swim_Lane__c=testSwimLane.Id, 
                                                                            AgouraFree__Time_Estimate__c=1.0, 
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Type__c='Bug',
                                                                            AgouraFree__Value__c='Test String',  
                                                                            AgouraFree__Version__c='Unreleased');
        insert testProjectTask;
        AgouraFree__ProjectTaskTagAssoc__c results = AgouraFree.ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        User testUser = createTestUser('userPT20','standarduserPT20@agourasoftware.com','Testing PT20','standarduserPT20@agourasoftware.com'); 
        
        Test.startTest();
        Id results2 = AgouraFree.ProjectTaskControllerExt.createCloneTask(testProjectTask.Id, testProject.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AgouraFree.ProjectTaskControllerExt.createCloneTask(testProjectTask.Id, testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertNotEquals(Null, results2);
    }
    
    static testMethod void test_saveProjectTaskData() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__Sprint__c testSprint2 = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Sprint__c=testSprint2.Id,
                                                                            AgouraFree__Status__c='Canceled');
        insert testProjectTask;
        AgouraFree__ProjectTask__c testProjectTask2 = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                             AgouraFree__Title__c='Test Project Task 2',
                                                                             AgouraFree__Order__c=2.0);
        insert testProjectTask2;
        AgouraFree__ProjectTask__c testProjectTask3 = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task 3',
                                                                            AgouraFree__Status__c='Open');
        insert testProjectTask3;
        User testUser = createTestUser('userPT21','standarduserPT21@agourasoftware.com','Testing PT21','standarduserPT21@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectTask__c results = AgouraFree.ProjectTaskControllerExt.saveProjectTaskData(testProjectTask.Id, testSprint.Id);
        AgouraFree__ProjectTask__c results3 = AgouraFree.ProjectTaskControllerExt.saveProjectTaskData(testProjectTask3.Id, null);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectTask__c accessResult = AgouraFree.ProjectTaskControllerExt.saveProjectTaskData(testProjectTask.Id, testSprint.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testProjectTask.Id, results.Id);
        System.assertEquals(testProjectTask3.Id, results3.Id);
    }
    
    static testMethod void test_updateOrderCompletedPoints() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__Sprint__c testSprint2 = createTestSprint(testProject.Id, '2 weeks');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Sprint__c=testSprint2.Id,
                                                                            AgouraFree__Status__c='Canceled');
        insert testProjectTask;
        AgouraFree__ProjectTask__c testProjectTask2 = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                             AgouraFree__Title__c='Test Project Task 2',
                                                                             AgouraFree__Order__c=2.0);
        insert testProjectTask2;
        User testUser = createTestUser('userPT22','standarduserPT22@agourasoftware.com','Testing PT22','standarduserPT22@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.updateOrderCompletedPoints(testProject.Id, testSprint.Id);
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.updateOrderCompletedPoints(testProject.Id, testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Order__c FROM AgouraFree__ProjectTask__c ORDER BY AgouraFree__Order__c NULLS LAST];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(1, taskList.get(0).AgouraFree__Order__c); 
    }
    
    static testMethod void test_updateOrder() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Status__c='Canceled');
        insert testProjectTask;
        AgouraFree__ProjectTask__c testProjectTask2 = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                             AgouraFree__Title__c='Test Project Task 2',
                                                                             AgouraFree__Order__c=2.0);
        insert testProjectTask2;
        User testUser = createTestUser('userPT23','standarduserPT23@agourasoftware.com','Testing PT23','standarduserPT23@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.updateOrder(testProject.Id);
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.updateOrder(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Order__c FROM AgouraFree__ProjectTask__c ORDER BY AgouraFree__Order__c NULLS LAST];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(1, taskList.get(0).AgouraFree__Order__c); 
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userPT24','standarduserPT24@agourasoftware.com','Testing PT24','standarduserPT24@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.ProjectTaskControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.ProjectTaskControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void test_feedPost() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, null, null, 1.0, null, null, 'User Story');
        FeedItem testFeedItem = createFeedPost(testProjectTask.Id);
        User testUser = createTestUser('userPT25','standarduserPT25@agourasoftware.com','Testing PT25','standarduserPT25@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProjectTask.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testProjectTask.Id);
                AgouraFree.ProjectTaskControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    static testMethod void test_doAssignToMe() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null, 1.0, null, null, 'User Story');
        User testUser = createTestUser('userPT26','standarduserPT26@agourasoftware.com','Testing PT26','standarduserPT26@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.doAssignToMe(testProjectTask.Id);
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.doAssignToMe(testProjectTask.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Assigned_To__c FROM AgouraFree__ProjectTask__c];        
        System.assertEquals(1, taskList.size());
        System.assertEquals(userId, taskList.get(0).AgouraFree__Assigned_To__c);         
    }
    
    static testMethod void test_moveProjectTask() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Project__c testProject2 = createTestProject('Test Project 2', 'TESTTESTTEST2');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        Account testAccount = createTestAccount('Test Account');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        AgouraFree__ProjectTask__c testProjectTaskMaster = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                                  AgouraFree__Title__c='Test Project Task');
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Accept__c='Test String', 
                                                                            AgouraFree__Account__c=testAccount.Id, 
                                                                            AgouraFree__Affected_Version__c='Test String',
                                                                            AgouraFree__Bug_Type__c='Blocker',   
                                                                            AgouraFree__Comments__c='Test String', 
                                                                            AgouraFree__Components__c='Test String',       
                                                                            AgouraFree__Dependencies__c='Test String',                                                                    
                                                                            AgouraFree__Description__c='Test String', 
                                                                            AgouraFree__Due_Date__c=Date.today(), 
                                                                            AgouraFree__Fix_Version__c='Test String',
                                                                            AgouraFree__Priority__c='High',
                                                                            AgouraFree__Project__c=testProject.Id, 
                                                                            AgouraFree__Points__c=5.0, 
                                                                            AgouraFree__Reported_By__c='Test String', 
                                                                            AgouraFree__Reported_Date__c=Date.today(), 
                                                                            AgouraFree__Sprint__c=testSprint.Id,
                                                                            AgouraFree__Time_Estimate__c=1.0, 
                                                                            AgouraFree__Title__c='Test Project Task',
                                                                            AgouraFree__Type__c='Bug',
                                                                            AgouraFree__Value__c='Test String',  
                                                                            AgouraFree__Version__c='Unreleased');
        insert testProjectTask;
        AgouraFree__ProjectTaskTagAssoc__c results = AgouraFree.ProjectTaskControllerExt.addProjectTaskTag(testTag.Id, testProjectTask.Id);
        AgouraFree__ProjectTask__c testProjectTask2 = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=testProject.Id,
                                                                             AgouraFree__Title__c='Test Project Task 2',
                                                                             AgouraFree__Status__c='Canceled');
        insert testProjectTask2;
        User testUser = createTestUser('userPT27','standarduserPT27@agourasoftware.com','Testing PT27','standarduserPT27@agourasoftware.com'); 
        
        Test.startTest();
        AgouraFree.ProjectTaskControllerExt.doMoveProjectTask(testProjectTask.Id, testProject2.Id);
        AgouraFree.ProjectTaskControllerExt.doMoveProjectTask(testProjectTask2.Id, testProject2.Id);
        System.runas(testUser) {
            try {
                AgouraFree.ProjectTaskControllerExt.doMoveProjectTask(testProjectTask.Id, testProject2.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        List<AgouraFree__ProjectTask__c> taskList = [SELECT Id, AgouraFree__Project__c, AgouraFree__Title__c FROM AgouraFree__ProjectTask__c ORDER BY AgouraFree__Title__c];        
        System.assertEquals(2, taskList.size());
        System.assertEquals(testProject2.Id, taskList.get(0).AgouraFree__Project__c); 
        System.assertEquals(testProject2.Id, taskList.get(1).AgouraFree__Project__c);  
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = AgouraFree.ProjectTaskControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Accept__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.ProjectTaskControllerExt.getFieldLabelMap('AgouraFree__ProjectTask__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Accept__c'));     
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
    
    private static AgouraFree__ProjectTask__c createTestProjectTaskBase(Id projectId, String title) {
		AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=projectId,
                                                                            AgouraFree__Title__c=title);
		return testProjectTask;
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
    
    private static AgouraFree__Sprint__c createTestSprint(Id projectId, String sprintLength) {
        AgouraFree__Sprint__c testSprint = new AgouraFree__Sprint__c(AgouraFree__Project__c=projectId,
                                                             AgouraFree__Sprint_Length__c=sprintLength,
                                                             AgouraFree__Sprint_Name__c='Sprint 1',
                                                             AgouraFree__Sprint_Number__c=1);
        insert testSprint;
        return testSprint;
    }
    
    private static AgouraFree__ProjectItem__c createTestProjectItem(Id projectId, String typeStr, String title) {
        AgouraFree__ProjectItem__c testProjectItem = new AgouraFree__ProjectItem__c(AgouraFree__Project__c=projectId,
                                                                            AgouraFree__Type__c=typeStr,
                                                                            AgouraFree__Title__c=title);
        insert testProjectItem;
        return testProjectItem;
    }
    
    private static Account createTestAccount(String name) {
        Account testAccount = new Account(Name=name);
        insert testAccount;
        return testAccount;
    }
    
    private static AgouraFree__Tag__c createTestTag(String name) {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name=name, 
                                                    AgouraFree__For_IdeaBoards__c=True,
                                                    AgouraFree__For_ProjectTasks__c=True,
                                                    AgouraFree__For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    }
}
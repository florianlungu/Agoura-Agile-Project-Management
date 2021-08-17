@isTest 
public class TestProjectCtlExt {
    
    static testMethod void test_add_get_remove_ProjectSharingAccess() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser1 = createTestUser('userP1','standarduserP1@agourasoftware.com','Testing P1','standarduserP1@agourasoftware.com'); 
        User testUser2 = createTestUser('userP2','standarduserP2@agourasoftware.com','Testing P2','standarduserP2@agourasoftware.com');
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        
        Test.startTest();
        AgouraFree__Project__Share addResult1 = AgouraFree.ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser1.id, 'Read');
        AgouraFree__Project__Share addResult2 = AgouraFree.ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser2.id, 'Edit');
        AgouraFree__Project__Share addResult3 = AgouraFree.ProjectControllerExt.addProjectSharingAccess(testProject.Id, testGroup1.id, 'Read');
        AgouraFree__Project__Share addResult4 = AgouraFree.ProjectControllerExt.addProjectSharingAccess(testProject.Id, testGroup2.id, 'Edit');
        List<AgouraFree.LookupSearchResult> getResults = AgouraFree.ProjectControllerExt.getUsers(testProject.Id);
        AgouraFree__Project__Share removeResult1 = AgouraFree.ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser1.Id);
        AgouraFree__Project__Share removeResult2 = AgouraFree.ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser2.Id);
        AgouraFree__Project__Share removeResult3 = AgouraFree.ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testGroup1.Id);
        AgouraFree__Project__Share removeResult4 = AgouraFree.ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testGroup2.Id);
        System.runas(testUser1) {
            try {
                AgouraFree__Project__Share accessResult = AgouraFree.ProjectControllerExt.addProjectSharingAccess(testProject.Id, testUser1.id, 'Read');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__Project__Share accessResult2 = AgouraFree.ProjectControllerExt.removeProjectSharingAccess(testProject.Id, testUser1.id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testProject.Id, addResult1.ParentId);
        System.assertEquals(testProject.Id, addResult2.ParentId);
        System.assertEquals(testProject.Id, addResult3.ParentId);
        System.assertEquals(testProject.Id, addResult4.ParentId);
        System.assertEquals(7, getResults.size());
        System.assertEquals(userId, getResults.get(0).getId());
        System.assertEquals(userId, getResults.get(1).getId());
        System.assertEquals(userId, getResults.get(2).getId());
        System.assertEquals(testUser1.Id, getResults.get(3).getId());
        System.assertEquals(testUser2.Id, getResults.get(4).getId());
        System.assertEquals(testGroup1.Id, getResults.get(5).getId());
        System.assertEquals(testGroup2.Id, getResults.get(6).getId());        
        List<AgouraFree.LookupSearchResult> getResults2 = AgouraFree.ProjectControllerExt.getUsers(testProject.Id);
        System.assertEquals(3, getResults2.size());        
    }
     
    static testMethod void test_recordAccess() {        
        User testUser = createTestUser('userP3','standarduserP3@agourasoftware.com','Testing P3','standarduserP3@agourasoftware.com');
        PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'Agoura_StandardUserAccess'];
        PermissionSet ps2 = [SELECT ID From PermissionSet WHERE Name = 'Agoura_AddStandardUserDelete'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id ); 
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps2.Id ); 
        
        Test.startTest();
        System.runas(testUser) {
            AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
            AgouraFree.ProjectControllerExt.ProjectAccess results = AgouraFree.ProjectControllerExt.recordAccess(testProject.Id);
            System.assertEquals(True, results.hasEditAccess);
            System.assertEquals(True, results.hasDeleteAccess);
            System.assertEquals(True, results.hasDeleteSprintTaskAccess);
        }
        Test.stopTest();        
    }
    
    // test search
    static testMethod void tag_search_should_return_tag() {
        Id [] fixedResults = new Id[1];
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP4','standarduserP4@agourasoftware.com','Testing P4','standarduserP4@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.tagSearch('Test Tag', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectControllerExt.tagSearch('Test Tag', selectedIds); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag.Id, results.get(0).getId());
    }
    
    static testMethod void tag_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        AgouraFree__Tag__c testTag1 = createTestTag('Test Tag 1');
        fixedResults.add(testTag1.Id);
        AgouraFree__Tag__c testTag2 = createTestTag('Test Tag 2');
        fixedResults.add(testTag2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testTag2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.tagSearch('Test Tag', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());
    }
    
    static testMethod void ideaboard_search_should_return_ideaboard() {
        Id [] fixedResults = new Id[1];
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        fixedResults.add(testIdeaBoard.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP5','standarduserP5@agourasoftware.com','Testing P5','standarduserP5@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testIdeaBoard.Id, results.get(0).getId());
    }
    
    static testMethod void ideaboard_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        AgouraFree__IdeaBoard__c testIdeaBoard1 = createTestIdeaBoard('Test Idea Board 1');
        fixedResults.add(testIdeaBoard1.Id);
        AgouraFree__IdeaBoard__c testIdeaBoard2 = createTestIdeaBoard('Test Idea Board 2');
        fixedResults.add(testIdeaBoard2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testIdeaBoard2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.ideaBoardSearch('Test Idea Board', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testIdeaBoard1.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userP6','standarduserP6@agourasoftware.com','Testing P6','standarduserP6@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.userSearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        fixedResults.add(testGroup1.Id);
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        fixedResults.add(testGroup2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testGroup2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.userSearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testGroup1.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userP7','standarduserP7@agourasoftware.com','Testing P7','standarduserP7@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userP8','standarduserP8@agourasoftware.com','Testing P8','standarduserP8@agourasoftware.com');
        User testUser2 = createTestUser('userP9','standarduserP9@agourasoftware.com','Testing P9','standarduserP9@agourasoftware.com');
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }
    
    static testMethod void related_account_search_should_return_account() {
        Id [] fixedResults = new Id[1];
        Account testAccount = createTestAccount('Test Account');
        AgouraFree__Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', testAccount.Id, null, null, 'Test String');        
        fixedResults.add(testProject.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userP10','standarduserP10@agourasoftware.com','Testing P10','standarduserP10@agourasoftware.com');
        
        Test.startTest();
        List<Account> results = AgouraFree.ProjectControllerExt.getRelatedAccount(testProject.Id);
        System.runas(testUser) {
            try {
                List<Account> accessResult = AgouraFree.ProjectControllerExt.getRelatedAccount(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).Id);
    }
    
    static testMethod void account_search_should_return_account() {
        Id [] fixedResults = new Id[1];
        Account testAccount = createTestAccount('Test Account');
        fixedResults.add(testAccount.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.accountSearch('Test Account', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount.Id, results.get(0).getId());
    }
    
    static testMethod void account_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Account testAccount1 = createTestAccount('Test Account 1');
        fixedResults.add(testAccount1.Id);
        Account testAccount2 = createTestAccount('Test Account 2');
        fixedResults.add(testAccount2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testAccount2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.accountSearch('Test Account', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testAccount1.Id, results.get(0).getId());
    }
    
    static testMethod void test_tags() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        User testUser = createTestUser('userP11','standarduserP11@agourasoftware.com','Testing P11','standarduserP11@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectTagAssociation__c addResult = AgouraFree.ProjectControllerExt.addProjectTag(testTag.id, testProject.Id);
        List<AgouraFree__Tag__c> getResults = AgouraFree.ProjectControllerExt.getProjectTags(testProject.Id);
        AgouraFree__ProjectTagAssociation__c removeResult = AgouraFree.ProjectControllerExt.removeProjectTag(testTag.Id, testProject.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectTagAssociation__c accessResult = AgouraFree.ProjectControllerExt.addProjectTag(testTag.id, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__ProjectTagAssociation__c accessResult2 = AgouraFree.ProjectControllerExt.removeProjectTag(testTag.id, testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__Tag__c> accessResult3 = AgouraFree.ProjectControllerExt.getProjectTags(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
               
        System.assertEquals(testTag.Id, addResult.AgouraFree__Tag__c);
        System.assertEquals(testProject.Id, addResult.AgouraFree__Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals(testTag.Name, getResults.get(0).Name);
        List<AgouraFree__Tag__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectTags(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_ideaProjects() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        AgouraFree__Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, testIdeaBoard.Id, null, 'Test String');
        User testUser = createTestUser('userP12','standarduserP12@agourasoftware.com','Testing P12','standarduserP12@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__IdeaBoard__c> getResults = AgouraFree.ProjectControllerExt.getIdeaProjects(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__IdeaBoard__c> accessResult = AgouraFree.ProjectControllerExt.getIdeaProjects(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
                
        System.assertEquals(1, getResults.size());
        System.assertEquals(testIdeaBoard.Id, getResults.get(0).Id);       
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, null, userId, 'Test String');
        User testUser = createTestUser('userP28','standarduserP28@agourasoftware.com','Testing P28','standarduserP28@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.ProjectControllerExt.getUsers(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.ProjectControllerExt.getUsers(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(6, results.size());
        System.assertEquals(userId, results.get(0).getId());
        System.assertEquals(userId, results.get(1).getId());
        System.assertEquals(userId, results.get(2).getId());
        System.assertEquals(userId, results.get(3).getId());
        System.assertEquals(userId, results.get(4).getId());
        System.assertEquals(userId, results.get(5).getId());
    }
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createAdminUser('userP13','standarduserP13@agourasoftware.com','Testing P13','standarduserP13@agourasoftware.com');
        User testUser2 = createTestUser('userP14','standarduserP14@agourasoftware.com','Testing P14','standarduserP14@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__Project__c updateTest = AgouraFree.ProjectControllerExt.updateDocumentOwner(testProject.Id, testUser.id);
        System.runas(testUser2) {
            try {
                AgouraFree__Project__c accessResult = AgouraFree.ProjectControllerExt.updateDocumentOwner(testProject.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void test_unassigned_points() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null); 
        User testUser = createTestUser('userP15','standarduserP15@agourasoftware.com','Testing P15','standarduserP15@agourasoftware.com');
        
        Test.startTest();
        AggregateResult getResults = AgouraFree.ProjectControllerExt.getUnassignedPoints(testProject.Id);
        System.runas(testUser) {
            try {
                AggregateResult accessResult = AgouraFree.ProjectControllerExt.getUnassignedPoints(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(5.0, getResults.get('unassignedPoints'));  
    }
    
    static testMethod void test_getRecordTitle() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP16','standarduserP16@agourasoftware.com','Testing P16','standarduserP16@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__Project__c> results = AgouraFree.ProjectControllerExt.getProjectTitle(testProject.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Project__c> accessResult = AgouraFree.ProjectControllerExt.getProjectTitle(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Project', results.get(0).AgouraFree__Title__c);
    }     

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userP29','standarduserP29@agourasoftware.com','Testing P29','standarduserP29@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.ProjectControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.ProjectControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = AgouraFree.ProjectControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
    
    // 
    // related objects
    // 
    static testMethod void test_goals() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        Date thisDay = Date.today();
        User testUser = createTestUser('userP17','standarduserP17@agourasoftware.com','Testing P17','standarduserP17@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectItem__c addResult = AgouraFree.ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal', string.valueofGmt(thisDay), 
                                                                               string.valueofGmt(thisDay), '10', '');
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectControllerExt.getProjectGoals(testProject.Id);
        AgouraFree__ProjectItem__c removeResult = AgouraFree.ProjectControllerExt.removeProjectItem(addResult.Id);
        
        AgouraFree__ProjectItem__c addResult2 = AgouraFree.ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal 2', '', 
                                                                                string.valueofGmt(thisDay), '10', '');
        System.runas(testUser) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectControllerExt.addGoal(testProject.Id, 'Project Goal','Test Goal', string.valueofGmt(thisDay),
                                                                                          string.valueofGmt(thisDay), '10', ''); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__ProjectItem__c accessResult2 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult2.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__ProjectItem__c> accessResult3 = AgouraFree.ProjectControllerExt.getProjectGoals(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        AgouraFree__ProjectItem__c removeResult2 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult2.Id);
		Test.stopTest();
        
        System.assertEquals('Test Goal', addResult.AgouraFree__Title__c);
        System.assertEquals(testProject.Id, addResult.AgouraFree__Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals('Test Goal', addResult.AgouraFree__Title__c);        
        List<AgouraFree__ProjectItem__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectGoals(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }  
    
    static testMethod void test_risks() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP18','standarduserP18@agourasoftware.com','Testing P18','standarduserP18@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectItem__c addResult = AgouraFree.ProjectControllerExt.addRisk(testProject.Id, 'Test Risk', 'High', 'High', 'Open', 'Test String');
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectControllerExt.getProjectRisks(testProject.Id);
        AgouraFree__ProjectItem__c removeResult = AgouraFree.ProjectControllerExt.removeProjectItem(addResult.Id); 
        System.runas(testUser) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectControllerExt.addRisk(testProject.Id, 'Test Risk', 'High', 'High', 'Open', 'Test String'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__ProjectItem__c> accessResult2 = AgouraFree.ProjectControllerExt.getProjectRisks(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }       
        Test.stopTest();
        
        System.assertEquals('Test Risk', addResult.AgouraFree__Title__c);
        System.assertEquals(testProject.Id, addResult.AgouraFree__Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals('Test Risk', addResult.AgouraFree__Title__c);
        List<AgouraFree__ProjectItem__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectRisks(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    } 
    
    static testMethod void test_stakeholders() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser1 = createTestUser('userP19','standarduserP19@agourasoftware.com','Testing P19','standarduserP19@agourasoftware.com');
        User testUser2 = createTestUser('userP20','standarduserP20@agourasoftware.com','Testing P20','standarduserP20@agourasoftware.com');
        AgouraFree__ProjectItem__c testSwimLane = AgouraFree.ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        
        Test.startTest();
        AgouraFree__ProjectItem__c addResult1 = AgouraFree.ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser1.Id, 'Responsible', 
                                                                                       testSwimLane.Id, 'Edit Access');
        AgouraFree__ProjectItem__c addResult2 = AgouraFree.ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser2.Id, 'Informed', 
                                                                                       '', 'Read Access');
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectControllerExt.getProjectStakeholders(testProject.Id);
        AgouraFree__ProjectItem__c removeResult1 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult1.Id);
        AgouraFree__ProjectItem__c removeResult2 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult2.Id);
        System.runas(testUser1) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectControllerExt.addStakeholder(testProject.Id, 'Project Stakeholder', testUser1.Id, 'Responsible', 
                                                                                       testSwimLane.Id, 'Edit Access'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__ProjectItem__c> accessResult2 = AgouraFree.ProjectControllerExt.getProjectStakeholders(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser1.Id, addResult1.AgouraFree__User__c);
        System.assertEquals(testProject.Id, addResult1.AgouraFree__Project__c);
        System.assertEquals(testUser2.Id, addResult2.AgouraFree__User__c);
        System.assertEquals(testProject.Id, addResult2.AgouraFree__Project__c);
        System.assertEquals(2, getResults.size());
        System.assertEquals(testUser1.Id, getResults.get(0).AgouraFree__User__c);
        System.assertEquals(testUser2.Id, getResults.get(1).AgouraFree__User__c);      
        List<AgouraFree__ProjectItem__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectStakeholders(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_swimlanes() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP21','standarduserP21@agourasoftware.com','Testing P21','standarduserP21@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectItem__c testSwimLane = AgouraFree.ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectControllerExt.getProjectSwimLanes(testProject.Id);
        AgouraFree__ProjectItem__c removeResult = AgouraFree.ProjectControllerExt.removeProjectItem(testSwimLane.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__ProjectItem__c> accessResult2 = AgouraFree.ProjectControllerExt.getProjectSwimLanes(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals('Test Swim Lane', testSwimLane.AgouraFree__Title__c);
        System.assertEquals(testProject.Id, testSwimLane.AgouraFree__Project__c);
        System.assertEquals(1, getResults.size());
        System.assertEquals(testSwimLane.Id, getResults.get(0).Id);
        List<AgouraFree__ProjectItem__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectSwimLanes(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_sprints() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        AgouraFree__Sprint__c testSprint = createTestSprint(testProject.Id, '2 weeks');
        User testUser = createTestUser('userP22','standarduserP22@agourasoftware.com','Testing P22','standarduserP22@agourasoftware.com');
                        
        Test.startTest();
        List<AgouraFree__Sprint__c> getResults1 = AgouraFree.ProjectControllerExt.getProjectSprints(testProject.Id);
        AgouraFree__Sprint__c removeResult = AgouraFree.ProjectControllerExt.removeProjectSprint(testSprint.Id);
        List<AgouraFree__Sprint__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectSprints(testProject.Id);
        System.runas(testUser) {
            try {
                AgouraFree__Sprint__c accessResult = AgouraFree.ProjectControllerExt.removeProjectSprint(testSprint.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__Sprint__c> accessResult2 = AgouraFree.ProjectControllerExt.getProjectSprints(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getResults1.size());
        System.assertEquals(testSprint.Id, getResults1.get(0).Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_links() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        User testUser = createTestUser('userP23','standarduserP23@agourasoftware.com','Testing P23','standarduserP23@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__ProjectItem__c addResult1 = AgouraFree.ProjectControllerExt.addLink(testProject.Id, 'Test Link 1', 'http://www.salesforce.com', testUser.Id);
        AgouraFree__ProjectItem__c addResult2 = AgouraFree.ProjectControllerExt.addLink(testProject.Id, 'Test Link 2', 'http://www.salesforce.com', '');
        List<AgouraFree__ProjectItem__c> getResults = AgouraFree.ProjectControllerExt.getProjectLinks(testProject.Id);
        AgouraFree__ProjectItem__c removeResult1 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult1.Id);
        AgouraFree__ProjectItem__c removeResult2 = AgouraFree.ProjectControllerExt.removeProjectItem(addResult2.Id);
        System.runas(testUser) {
            try {
                AgouraFree__ProjectItem__c accessResult = AgouraFree.ProjectControllerExt.addLink(testProject.Id, 'Test Link 1', 'http://www.salesforce.com', testUser.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__ProjectItem__c> accessResult2 = AgouraFree.ProjectControllerExt.getProjectLinks(testProject.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(2, getResults.size());
        System.assertEquals('Test Link 1', getResults.get(0).AgouraFree__Title__c);
        System.assertEquals('Test Link 2', getResults.get(1).AgouraFree__Title__c);
        System.assertEquals(testUser.Id, addResult1.AgouraFree__User__c);
        System.assertEquals(testProject.Id, addResult1.AgouraFree__Project__c);
        System.assertEquals(null, addResult2.AgouraFree__User__c);
        System.assertEquals(testProject.Id, addResult2.AgouraFree__Project__c);

        List<AgouraFree__ProjectItem__c> getResults2 = AgouraFree.ProjectControllerExt.getProjectLinks(testProject.Id);
        System.assertEquals(0, getResults2.size());        
    }
    
    static testMethod void test_createCloneProject() {
        AgouraFree__Project__c testProject = createTestProjectBig('Test Project', 'TESTTESTTEST', null, null, null, 'Test String');
        List<String> cloneWhat = new List<String>{ 'Tags', 'Tasks', 'Project Swim Lane' };
        User testUser = createTestUser('userP24','standarduserP24@agourasoftware.com','Testing P24','standarduserP24@agourasoftware.com');
            
        AgouraFree__ProjectItem__c testSwimLane = AgouraFree.ProjectControllerExt.addSwimLane(testProject.Id, 'Test Swim Lane');        
        System.assertEquals('Test Swim Lane', testSwimLane.AgouraFree__Title__c);
        System.assertEquals(testProject.Id, testSwimLane.AgouraFree__Project__c);
        
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        AgouraFree__ProjectTagAssociation__c addResult2 = AgouraFree.ProjectControllerExt.addProjectTag(testTag.id, testProject.Id);
        System.assertEquals(testTag.Id, addResult2.AgouraFree__Tag__c);
        System.assertEquals(testProject.Id, addResult2.AgouraFree__Project__c);

        AgouraFree__ProjectTask__c testProjectTask1 = createTestProjectTask(testProject.Id, 'Test Project Task 1', 5.0, testSwimLane.Id, null); 
        AgouraFree__ProjectTaskTagAssoc__c testProjectTaskTagAssoc = createTestProjectTaskTagAssoc(testTag.Id, testProjectTask1.Id);
        AgouraFree__ProjectTask__c testProjectTask2 = createTestProjectTask(testProject.Id, 'Test Project Task 2', 5.0, testSwimLane.Id, testProjectTask1.Id);         
        
        Test.startTest();
        Id result = AgouraFree.ProjectControllerExt.createCloneProject(testProject.Id, cloneWhat);
        System.runas(testUser) {
            try {
                Id accessResult = AgouraFree.ProjectControllerExt.createCloneProject(testProject.Id, cloneWhat); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assert(result != null);
    }
    
    static testMethod void test_feedPost() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');
        FeedItem testFeedItem = createFeedPost(testProject.Id);
        User testUser = createTestUser('userP25','standarduserP25@agourasoftware.com','Testing P25','standarduserP25@agourasoftware.com');
        
        Test.startTest();
        AgouraFree.ProjectControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testProject.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testProject.Id); 
                AgouraFree.ProjectControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    static testMethod void test_updateProjectTaskAbbreviation() {
        AgouraFree__Project__c testProject = createTestProject('Test Project', 'TESTTESTTEST');        
        AgouraFree__ProjectTask__c testProjectTask = createTestProjectTask(testProject.Id, 'Test Project Task', 5.0, null, null); 
        User testUser = createTestUser('userP26','standarduserP26@agourasoftware.com','Testing P26','standarduserP26@agourasoftware.com');      
        testProject.AgouraFree__Project_Abbreviation__c = 'TESTTESTTEST2';
        update testProject;
        
        Test.startTest();
        AgouraFree.ProjectControllerExt.updateProjectTaskAbbreviation(testProject.Id, 'TESTTESTTEST2'); 
        System.runas(testUser) {
            try {
                AgouraFree.ProjectControllerExt.updateProjectTaskAbbreviation(testProject.Id, 'TESTTESTTEST'); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();

        List<AgouraFree__ProjectTask__c> results = [SELECT Id, AgouraFree__Task_Number__c FROM AgouraFree__ProjectTask__c WHERE AgouraFree__Project__c = :testProject.Id];        
        System.assertEquals(1, results.size());
        System.assertEquals('TESTTESTTEST2-1', results.get(0).AgouraFree__Task_Number__c);   
    }
    
    static testMethod void test_updateProjectStakeholders() {
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userP27','standarduserP27@agourasoftware.com','Testing P27','standarduserP27@agourasoftware.com');
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c='Test Project',
                                                                AgouraFree__Project_Abbreviation__c='TESTTESTTEST',
                                                                AgouraFree__Status__c='Draft',
                                                                AgouraFree__Executive_Sponsor__c = userId,
                                                                AgouraFree__Product_Owner__c = testUser.Id,
                                                                AgouraFree__Scrum_Master__c = userId);
        
        Test.startTest();
        insert testProject;
        AgouraFree__ProjectItem__c testProjectItem = new AgouraFree__ProjectItem__c(AgouraFree__Title__c = 'Executive Sponsor',
                                                                            AgouraFree__Project__c = testProject.Id,
                                                                            AgouraFree__Type__c = 'Executive Sponsor',
                                                                            AgouraFree__User__c = testUser.Id,
                                                                            AgouraFree__RACI__c = 'Informed');
        insert testProjectItem;
        AgouraFree.ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, userId);
        AgouraFree.ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, null);          
        System.runas(testUser) {
            try {
                AgouraFree.ProjectControllerExt.updateProjectStakeholders(testProject.Id, userId, userId, userId, userId); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();

        List<AgouraFree__ProjectItem__c> results = [SELECT Id, AgouraFree__User__c FROM AgouraFree__ProjectItem__c WHERE AgouraFree__Project__c = :testProject.Id
                                               ORDER BY AgouraFree__Type__c];        
        System.assertEquals(3, results.size());
        System.assertEquals(userId, results.get(0).AgouraFree__User__c);   
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Account__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.ProjectControllerExt.getFieldLabelMap('AgouraFree__Project__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Account__c'));     
		Test.stopTest();
    }
            
	static testMethod void test_getFieldHelpMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Project_Abbreviation__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.ProjectControllerExt.getFieldHelpMap('AgouraFree__Project__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Project_Abbreviation__c'));     
		Test.stopTest();
    }
    
    static testMethod void test_getNumRecords() {
        Id userId = UserInfo.getUserId();
        User testUser = createTestUser('userP30','standarduserP30@agourasoftware.com','Testing P30','standarduserP30@agourasoftware.com');
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c='Test Project',
                                                                AgouraFree__Project_Abbreviation__c='TESTTESTTEST',
                                                                AgouraFree__Status__c='Draft',
                                                                AgouraFree__Executive_Sponsor__c = userId,
                                                                AgouraFree__Product_Owner__c = testUser.Id,
                                                                AgouraFree__Scrum_Master__c = userId);
        AgouraFree__Project__c testProject2 = new AgouraFree__Project__c(AgouraFree__Title__c='Test Project 2',
                                                                AgouraFree__Project_Abbreviation__c='TESTTESTTEST2',
                                                                AgouraFree__Status__c='Draft',
                                                                AgouraFree__Executive_Sponsor__c = userId,
                                                                AgouraFree__Product_Owner__c = testUser.Id,
                                                                AgouraFree__Scrum_Master__c = userId);
        
        Test.startTest();
        insert testProject;
        insert testProject2;        
        Map<String, Integer> results = AgouraFree.ProjectControllerExt.getNumRecords(testProject.Id);        
        System.runas(testUser) {
            try {
                Map<String, Integer> results2 = AgouraFree.ProjectControllerExt.getNumRecords(testProject.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
       
        System.assertEquals(1, results.get('projects'));           
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
    
    private static AgouraFree__Project__c createTestProjectBig(String title, String abbrev, Id accountId, Id ideaBoardId, Id userId, String testString) {
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c=title,
                                                                AgouraFree__Project_Abbreviation__c=abbrev,
                                                                AgouraFree__Status__c='Draft',
                                                                AgouraFree__Account__c = accountId,
                                                                AgouraFree__Idea_Board__c = ideaBoardId,
                                                                AgouraFree__Executive_Sponsor__c = userId,
                                                                AgouraFree__Product_Owner__c = userId,
                                                                AgouraFree__Scrum_Master__c = userId,
                                                                AgouraFree__Mission_Statement__c=testString, 
                                                                AgouraFree__Product__c=testString, 
                                                                AgouraFree__Deliverables__c=testString, 
                                                                AgouraFree__KPIs__c=testString, 
                                                                AgouraFree__Value_Trackers__c=testString, 
                                                                AgouraFree__Assumptions__c=testString, 
                                                                AgouraFree__Constraints__c=testString, 
                                                                AgouraFree__Comments__c=testString);
        insert testProject;
        return testProject;
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
    
    private static Group createTestGroup(String name, String developerName) {
        Group testGroup = new Group(Name=name, 
                                    DeveloperName=developerName);        
        insert testGroup;
        return testGroup;
    }
    
    private static AgouraFree__Tag__c createTestTag(String name) {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name=name, 
                                                    AgouraFree__For_IdeaBoards__c=True,
                                                    AgouraFree__For_ProjectTasks__c=True,
                                                    AgouraFree__For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static AgouraFree__IdeaBoard__c createTestIdeaBoard(String ideaBoardName) {
        AgouraFree__IdeaBoard__c testIdeaBoard = new AgouraFree__IdeaBoard__c(AgouraFree__Title__c=ideaBoardName, 
                                                                      AgouraFree__Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static Account createTestAccount(String name) {
        Account testAccount = new Account(Name=name);
        insert testAccount;
        return testAccount;
    }
    
    private static AgouraFree__ProjectTask__c createTestProjectTask(Id projectId, String title, Decimal points, Id swimLane, Id masterTask) {
        AgouraFree__ProjectTask__c testProjectTask = new AgouraFree__ProjectTask__c(AgouraFree__Project__c=projectId,
                                                                            AgouraFree__Title__c=title,
                                                                            AgouraFree__Points__c=points,
                                                                            AgouraFree__Swim_Lane__c=swimLane,
                                                                            AgouraFree__Master_Task__c=masterTask,
                                                                            AgouraFree__Task_Number_Int__c=1);
        insert testProjectTask;
        return testProjectTask;
    }
    
    private static AgouraFree__Sprint__c createTestSprint(Id projectId, String sprintLength) {
        AgouraFree__Sprint__c testSprint = new AgouraFree__Sprint__c(AgouraFree__Project__c=projectId,
                                                             AgouraFree__Sprint_Length__c=sprintLength,
                                                             AgouraFree__Sprint_Number__c=1,
                                                             AgouraFree__Sprint_Name__c='Sprint 1');
        insert testSprint;
        return testSprint;
    }
    
    private static AgouraFree__ProjectTaskTagAssoc__c createTestProjectTaskTagAssoc(Id tagId, Id taskId) {
        AgouraFree__ProjectTaskTagAssoc__c testProjectTaskTagAssoc = new AgouraFree__ProjectTaskTagAssoc__c(AgouraFree__Tag__c=tagId, 
                                                                                                    AgouraFree__Project_Task__c=taskId);        
        insert testProjectTaskTagAssoc;
        return testProjectTaskTagAssoc;
    }
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    } 
}
@isTest 
private class TestIdeaBoardCtlExt {
    
    static testMethod void tag_search_should_return_tag() {
        Id [] fixedResults = new Id[1];
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        User testUser = createTestUser('userIB1','standarduserIB1@agourasoftware.com','Testing IB1','standarduserIB1@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
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
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag1.Id, results.get(0).getId());
    }
    
    static testMethod void user_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userIB2','standarduserIB2@agourasoftware.com','Testing IB2','standarduserIB2@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.userSearch('Test', selectedIds);
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
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.userSearch('Test', selectedIds);
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testGroup1.Id, results.get(0).getId());
    }
    
    static testMethod void test_add_get_remove_IdeaTags() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        AgouraFree__IdeaTagAssociation__c testIdeaTagAssoc = createTestIdeaTagAssoc(testTag.Id, testIdeaBoard.Id);
        User testUser = createTestUser('userIB3','standarduserIB3@agourasoftware.com','Testing IB3','standarduserIB3@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__IdeaTagAssociation__c addResult = AgouraFree.IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);
        List<AgouraFree__Tag__c> getResults1 = AgouraFree.IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
        AgouraFree__IdeaTagAssociation__c removeResult = AgouraFree.IdeaBoardControllerExt.removeIdeaTag(testTag.Id, testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                AgouraFree__IdeaTagAssociation__c accessResult = AgouraFree.IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__IdeaTagAssociation__c accessResult2 = AgouraFree.IdeaBoardControllerExt.removeIdeaTag(testTag.Id, testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree__Tag__c> accessResult3 = AgouraFree.IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assertEquals(testIdeaBoard.Id, addResult.AgouraFree__Idea_Board__c);
        System.assertEquals(1, getResults1.size());
        System.assertEquals(testTag.Name, getResults1.get(0).Name);
        List<AgouraFree__Tag__c> getResults2 = AgouraFree.IdeaBoardControllerExt.getIdeaTags(testIdeaBoard.Id);
        System.assertEquals(0, getResults2.size());
    }
    
    static testMethod void test_getIdeaProjects() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Boolean hasProjects = gd.containsKey('AgouraFree__Project__c');
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');        
        User testUser = createTestUser('userIB4','standarduserIB4@agourasoftware.com','Testing IB4','standarduserIB4@agourasoftware.com');
        
        if (hasProjects) {
            AgouraFree__Project__c testProject = createTestProject('TEST TEST TEST', 'TESTTESTTEST', testIdeaBoard.Id);    
            Test.startTest();
            List<sObject> results = AgouraFree.IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
            System.runas(testUser) {
                try {
                    List<sObject> accessResult = AgouraFree.IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
                } catch (AuraHandledException e) {
                    System.assertEquals('Insufficient access', e.getMessage());
                }
            }
            Test.stopTest();
            
            System.assertEquals(1, results.size());
            System.assertEquals(testProject.Id, results.get(0).Id);
        } else {
            Test.startTest();
            List<sObject> results = AgouraFree.IdeaBoardControllerExt.getIdeaProjects(testIdeaBoard.Id);
            Test.stopTest();
            
            System.assertEquals(0, results.size());
        }   
    }
    
    static testMethod void test_add_get_remove_IdeaSharingAccess() {
        Id userId = UserInfo.getUserId();
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        User testUser1 = createTestUser('userIB5','standarduserIB5@agourasoftware.com','Testing IB5','standarduserIB5@agourasoftware.com');
        User testUser2 = createTestUser('userIB6','standarduserIB6@agourasoftware.com','Testing IB6','standarduserIB6@agourasoftware.com');
        Group testGroup1 = createTestGroup('Test Group 1', 'Dev1');
        Group testGroup2 = createTestGroup('Test Group 2', 'Dev2');
        User testUser3 = createTestUser('userIB15','standarduserIB15@agourasoftware.com','Testing IB15','standarduserIB15@agourasoftware.com');
              
        Test.startTest();
        AgouraFree__IdeaBoard__Share addResult1 = AgouraFree.IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser1.id, 'Read');
        AgouraFree__IdeaBoard__Share addResult2 = AgouraFree.IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser2.id, 'Edit');
        AgouraFree__IdeaBoard__Share addResult3 = AgouraFree.IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testGroup1.id, 'Read');
        AgouraFree__IdeaBoard__Share addResult4 = AgouraFree.IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testGroup2.id, 'Edit');
        List<AgouraFree.LookupSearchResult> getResults1 = AgouraFree.IdeaBoardControllerExt.getUsers(testIdeaBoard.Id);
        AgouraFree__IdeaBoard__Share removeResult1 = AgouraFree.IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser1.Id);
        AgouraFree__IdeaBoard__Share removeResult2 = AgouraFree.IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser2.Id);
        AgouraFree__IdeaBoard__Share removeResult3 = AgouraFree.IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testGroup1.Id);
        AgouraFree__IdeaBoard__Share removeResult4 = AgouraFree.IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testGroup2.Id);
        System.runas(testUser3) {
            try {
                AgouraFree__IdeaBoard__Share accessResult = AgouraFree.IdeaBoardControllerExt.addIdeaSharingAccess(testIdeaBoard.Id, testUser1.id, 'Read');  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                AgouraFree__IdeaBoard__Share accessResult2 = AgouraFree.IdeaBoardControllerExt.removeIdeaSharingAccess(testIdeaBoard.Id, testUser1.id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
            try {
                List<AgouraFree.LookupSearchResult> accessResult3 = AgouraFree.IdeaBoardControllerExt.getUsers(testIdeaBoard.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();

        System.assertEquals(testIdeaBoard.Id, addResult1.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult2.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult3.ParentId);
        System.assertEquals(testIdeaBoard.Id, addResult4.ParentId);
        System.assertEquals(7, getResults1.size());
        System.assertEquals(userId, getResults1.get(0).getId());
        System.assertEquals(userId, getResults1.get(1).getId());
        System.assertEquals(userId, getResults1.get(2).getId());
        System.assertEquals(testUser1.Id, getResults1.get(3).getId());
        System.assertEquals(testUser2.Id, getResults1.get(4).getId());
        System.assertEquals(testGroup1.Id, getResults1.get(5).getId());
        System.assertEquals(testGroup2.Id, getResults1.get(6).getId());
        List<AgouraFree.LookupSearchResult> getResults2 = AgouraFree.IdeaBoardControllerExt.getUsers(testIdeaBoard.Id);
        System.assertEquals(3, getResults2.size());        
    }
    
    static testMethod void test_recordAccess() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.IdeaBoardControllerExt.recordAccess(testIdeaBoard.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getRecordTitle() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        User testUser = createTestUser('userIB8','standarduserIB8@agourasoftware.com','Testing IB8','standarduserIB8@agourasoftware.com');
        
        Test.startTest();
        List<AgouraFree__IdeaBoard__c> results = AgouraFree.IdeaBoardControllerExt.getIdeaBoardTitle(testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__IdeaBoard__c> accessResult = AgouraFree.IdeaBoardControllerExt.getIdeaBoardTitle(testIdeaBoard.Id);  
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Idea Board', results.get(0).AgouraFree__Title__c);
    } 
    
    static testMethod void test_createCloneIdeaBoard() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoardBig('Test Idea Board','Test String');
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        AgouraFree__IdeaTagAssociation__c testIdeaTagAssoc = createTestIdeaTagAssoc(testTag.Id, testIdeaBoard.Id);
        AgouraFree__IdeaTagAssociation__c addResult = AgouraFree.IdeaBoardControllerExt.addIdeaTag(testTag.Id, testIdeaBoard.Id);
        User testUser = createTestUser('userIB9','standarduserIB9@agourasoftware.com','Testing IB9','standarduserIB9@agourasoftware.com');
        
        Test.startTest();
        Id result = AgouraFree.IdeaBoardControllerExt.createCloneIdeaBoard(testIdeaBoard.Id);
        System.runas(testUser) {
            try {
                Id accessResult = AgouraFree.IdeaBoardControllerExt.createCloneIdeaBoard(testIdeaBoard.Id); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
		Test.stopTest();
        
        System.assertEquals(testIdeaBoard.Id, addResult.AgouraFree__Idea_Board__c);
        System.assert(result != null);
    }   
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoardBig('Test Idea Board','Test String');
        User testUser = createAdminUser('userIB10','standarduserIB10@agourasoftware.com','Testing IB10','standarduserIB10@agourasoftware.com');
        User testUser2 = createTestUser('userIB11','standarduserIB11@agourasoftware.com','Testing IB11','standarduserIB11@agourasoftware.com');
        
        Test.startTest();
        AgouraFree__IdeaBoard__c updateTest = AgouraFree.IdeaBoardControllerExt.updateDocumentOwner(testIdeaBoard.Id, testUser.id);
        System.runas(testUser2) {
            try {
                AgouraFree__IdeaBoard__c accessResult = AgouraFree.IdeaBoardControllerExt.updateDocumentOwner(testIdeaBoard.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userIB12','standarduserIB12@agourasoftware.com','Testing IB12','standarduserIB12@agourasoftware.com');
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        User testUser1 = createTestUser('userIB13','standarduserIB13@agourasoftware.com','Testing IB13','standarduserIB13@agourasoftware.com');
        User testUser2 = createTestUser('userIB14','standarduserIB14@agourasoftware.com','Testing IB14','standarduserIB14@agourasoftware.com');
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userIB16','standarduserIB16@agourasoftware.com','Testing IB16','standarduserIB16@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.IdeaBoardControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.IdeaBoardControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
            
	static testMethod void test_getFieldLabelMap() {
        List<String> fieldList = new List<String>();
        fieldList.add('AgouraFree__Problem__c');
        Test.startTest();
        
        Map<String, String> results = AgouraFree.IdeaBoardControllerExt.getFieldLabelMap('AgouraFree__IdeaBoard__c', fieldList);
           
        System.assertEquals(true,results.containsKey('AgouraFree__Problem__c'));     
		Test.stopTest();
    }
    
    static testMethod void isChatterEnabled() {      
        Test.startTest();
        Boolean result = AgouraFree.IdeaBoardControllerExt.checkChatterEnabled();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
    
    static testMethod void test_feedPost() {
        AgouraFree__IdeaBoard__c testIdeaBoard = createTestIdeaBoard('Test Idea Board');
        FeedItem testFeedItem = createFeedPost(testIdeaBoard.Id);
        User testUser = createTestUser('userIB17','standarduserIB17@agourasoftware.com','Testing IB17','standarduserIB17@agourasoftware.com'); 
        
        Test.startTest();
        AgouraFree.IdeaBoardControllerExt.doChatterFeedPost(testFeedItem);
        List<FeedItem> getFeedItemResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testIdeaBoard.Id];
        System.runas(testUser) {
            try {
                FeedItem testFeedItem2 = createFeedPost(testIdeaBoard.Id); 
                AgouraFree.IdeaBoardControllerExt.doChatterFeedPost(testFeedItem2); 
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, getFeedItemResult.size());
        System.assertEquals('Some text', getFeedItemResult.get(0).Body);
    }
    
    //
    // create test data
    //
    private static AgouraFree__Tag__c createTestTag(String name) {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name=name, 
                                                    AgouraFree__For_IdeaBoards__c=True,
                                                    AgouraFree__For_ProjectTasks__c=True,
                                                    AgouraFree__For_Projects__c=True);
        insert testTag;
        return testTag;
    }
    
    private static AgouraFree__Project__c createTestProject(String title, String abbrev, Id ideaId) {
        AgouraFree__Project__c testProject = new AgouraFree__Project__c(AgouraFree__Title__c=title,
                                                                AgouraFree__Project_Abbreviation__c=abbrev,
                                                                AgouraFree__Status__c='Draft',
                                                                AgouraFree__Idea_Board__c=ideaId);
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
    
    private static AgouraFree__IdeaBoard__c createTestIdeaBoard(String ideaBoardName) {
        AgouraFree__IdeaBoard__c testIdeaBoard = new AgouraFree__IdeaBoard__c(AgouraFree__Title__c=ideaBoardName, 
                                                                      AgouraFree__Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static AgouraFree__IdeaBoard__c createTestIdeaBoardBig(String ideaBoardName, String testString) {
        AgouraFree__IdeaBoard__c testIdeaBoard = new AgouraFree__IdeaBoard__c(AgouraFree__Title__c=ideaBoardName,
                                                                      AgouraFree__Problem__c=testString, 
                                                                      AgouraFree__Existing_Alternatives__c=testString, 
                                                                      AgouraFree__Solution__c=testString, 
                                                                      AgouraFree__Key_Metrics__c=testString, 
                                                                      AgouraFree__Unique_Value_Proposition__c=testString, 
                                                                      AgouraFree__High_Level_Concept__c=testString, 
                                                                      AgouraFree__Unfair_Advantage__c=testString, 
                                                                      AgouraFree__Channels__c=testString,
                                                                      AgouraFree__Customer_Segment__c=testString, 
                                                                      AgouraFree__Early_Adopters__c=testString, 
                                                                      AgouraFree__Cost_Structure__c=testString, 
                                                                      AgouraFree__Revenue_Streams__c=testString, 
                                                                      AgouraFree__Comments__c=testString,
                                                                      AgouraFree__Status__c='Draft');        
        insert testIdeaBoard;
        return testIdeaBoard;
    }
    
    private static AgouraFree__IdeaTagAssociation__c createTestIdeaTagAssoc(Id tagId, Id ideaId) {
        AgouraFree__IdeaTagAssociation__c testIdeaTagAssoc = new AgouraFree__IdeaTagAssociation__c(AgouraFree__Tag__c=tagId, 
                                                                                           AgouraFree__Idea_Board__c=ideaId);        
        insert testIdeaTagAssoc;
        return testIdeaTagAssoc;
    }   
    
    private static FeedItem createFeedPost(Id recId) {
        FeedItem testFeedPost = new FeedItem(ParentId=recId,
                                             Type='TextPost',
                                             IsRichText=true,
                                             Body='Some text');                  
        return testFeedPost;
    } 
}
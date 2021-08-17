@isTest
public class TestTagCtlExt {
   
    static testMethod void test_recordAccess() {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name='Test Tag');
        insert testTag;
        Id userId = UserInfo.getUserId();
        
        Test.startTest();
        List<UserRecordAccess> results = AgouraFree.TagControllerExt.recordAccess(testTag.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(True, results.get(0).HasReadAccess);
    }
    
    static testMethod void test_getWebPageTitle() {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name='Test Tag');
        insert testTag;    
        User testUser = createTestUser('userT1','standarduserT1@agourasoftware.com','Testing T1','standarduserT1@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree__Tag__c> results = AgouraFree.TagControllerExt.getWebPageTitle(testTag.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree__Tag__c> accessResult = AgouraFree.TagControllerExt.getWebPageTitle(testTag.Id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals('Test Tag', results.get(0).Name);
    }
    
    static testMethod void test_getUsers() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name='Test Tag');
        insert testTag; 
        User testUser = createTestUser('userT2','standarduserT2@agourasoftware.com','Testing T2','standarduserT2@agourasoftware.com'); 
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.TagControllerExt.getUsers(testTag.Id);
        System.runas(testUser) {
            try {
                List<AgouraFree.LookupSearchResult> accessResult = AgouraFree.TagControllerExt.getUsers(testTag.Id); 
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
    
    static testMethod void test_update_document_owner() {
        Id userId = UserInfo.getUserId();
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name='Test Tag');
        insert testTag;
        User testUser = createAdminUser('userT3','standarduserT3@agourasoftware.com','Testing T3','standarduserT3@agourasoftware.com'); 
        User testUser2 = createTestUser('userT4','standarduserT4@agourasoftware.com','Testing T4','standarduserT4@agourasoftware.com'); 
        
        Test.startTest();
        AgouraFree__Tag__c updateTest = AgouraFree.TagControllerExt.updateDocumentOwner(testTag.Id, testUser.id);
        System.runas(testUser2) {
            try {
                AgouraFree__Tag__c accessResult = AgouraFree.TagControllerExt.updateDocumentOwner(testTag.Id, testUser2.id);
            } catch (AuraHandledException e) {
                System.assertEquals('Insufficient access', e.getMessage());
            }
        }
        Test.stopTest();
        
        System.assertEquals(testUser.id, updateTest.OwnerId);
    }
    
    static testMethod void userOnly_search_should_return_user() {
        Id [] fixedResults = new Id[1];
        User testUser = createTestUser('userT5','standarduserT5@agourasoftware.com','Testing T5','standarduserT5@agourasoftware.com'); 
        fixedResults.add(testUser.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.TagControllerExt.userOnlySearch('Test', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser.Id, results.get(0).getId());
    }
    
    static testMethod void userOnly_search_should_not_return_selected_item() {
        User testUser1 = createTestUser('userT6','standarduserT6@agourasoftware.com','Testing T6','standarduserT6@agourasoftware.com'); 
        User testUser2 = createTestUser('userT7','standarduserT7@agourasoftware.com','Testing T7','standarduserT7@agourasoftware.com'); 
        Id [] fixedResults = new Id[1];
        fixedResults.add(testUser1.Id);
        fixedResults.add(testUser2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(testUser2.Id);
        
        Test.startTest();
        List<AgouraFree.LookupSearchResult> results = AgouraFree.TagControllerExt.userOnlySearch('Testing', selectedIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(testUser1.Id, results.get(0).getId());
    }    

    static testMethod void test_createAccess() {
        User testUser = createTestUser('userT8','standarduserT8@agourasoftware.com','Testing T8','standarduserT8@agourasoftware.com');  
        
        Test.startTest();
        Boolean results = AgouraFree.TagControllerExt.createAccess();
        System.runas(testUser) {            
            Boolean accessResult = AgouraFree.TagControllerExt.createAccess(); 
            System.assertEquals(False, accessResult);      
        }
		Test.stopTest();
        
        System.assertEquals(True, results);
    }
    
    static testMethod void test_hasProjectObject() {      
        Test.startTest();
        Boolean result = AgouraFree.TagControllerExt.hasProjectObject();
        Test.stopTest();
        
        System.assert(result==true || result==false);
    }
    
    //
    // create test data
    //
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
}
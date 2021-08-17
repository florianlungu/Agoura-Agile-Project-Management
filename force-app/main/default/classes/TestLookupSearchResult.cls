@isTest 
public class TestLookupSearchResult {
    
    static testMethod void test_LookupSearchResult() {
        Id [] fixedResults = new Id[1];
        AgouraFree__Tag__c testTag = createTestTag('Test Tag');
        fixedResults.add(testTag.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        
        List<AgouraFree.LookupSearchResult> results = AgouraFree.IdeaBoardControllerExt.tagSearch('Test Tag', selectedIds);
        
        System.assertEquals(1, results.size());
        System.assertEquals(testTag.Id, results.get(0).getId());
        System.assertEquals('AgouraFree__Tag__c', results.get(0).getSObjectType());
        System.assertEquals('standard:topic', results.get(0).getIcon());
        System.assertEquals(testTag.Name, results.get(0).getTitle());   
        System.assertEquals('Tag • ' + testTag.Name, results.get(0).getSubtitle());       
    }
    
    private static AgouraFree__Tag__c createTestTag(String name) {
        AgouraFree__Tag__c testTag = new AgouraFree__Tag__c(Name=name,
                                                    AgouraFree__For_IdeaBoards__c=true);
        insert testTag;
        return testTag;
    }
}
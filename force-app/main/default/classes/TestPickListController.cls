@isTest 
public class TestPickListController {
    
	static testMethod void test_PickListController() {
        // Arrange - Set up test data
        Test.startTest();
        
        // Act - start test code
        List<String> results = AgouraFree.PickListController.getPickListValuesIntoList('AgouraFree__IdeaBoard__c', 'AgouraFree__Status__c');
        
        // Assert - expected results   
        System.assertEquals(4,results.size());  
        System.assertEquals('Draft',results.get(0));     
		Test.stopTest();
    }
}
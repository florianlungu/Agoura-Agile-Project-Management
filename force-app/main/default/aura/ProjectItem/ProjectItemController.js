({
   doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.checkAccess(component, recId);
            helper.setWebPageTitle(component, recId);
            helper.loadProject(component, recId); 
            helper.loadUsers(component, recId);  
        }
        helper.loadFieldLabelMap(component);
        if (!recId) {
            component.set("v.hasEditAccess", true);
            component.find("forceRecord").getNewRecord(
                "AgouraFree__ProjectItem__c",
                null,
                false,
                $A.getCallback(function() {
                    var rec = component.get("v.targetFields");
                    var error = component.get("v.recordError");
                    if (error || (rec === null)) {
                        console.log("Error initializing record template: " + error);
                        return;
                    }
                })
            );	
        }		
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    }
})
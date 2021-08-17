({
    doInitCS : function(component, event, helper) {
        var projectId = component.get("v.pageReference").state.AgouraFree__project;
        var currentVal = component.get("v.gSprint");
        if (projectId && currentVal == null) {
            var action = component.get("c.getCurrentSprint");
            action.setParams({
                "projectId": projectId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({ "message": errors[0].message, "type": "error"});
                        resultsToast.fire();
                    } else {
                        console.log("Unknown error");
                    }  
                    return;
                }
                var result = response.getReturnValue();
                if (result[0] != null) {
                    component.set("v.gSprint", result[0]);
                }  else {
                    var homeEvt = $A.get("e.force:navigateToObjectHome");
                    homeEvt.setParams({"scope": "AgouraFree__Sprint__c"});
                    homeEvt.fire();                    
                }
            });
            $A.enqueueAction(action);
        }
        
        if (!projectId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__Sprint__c"});
            homeEvt.fire();
        }
    }
})
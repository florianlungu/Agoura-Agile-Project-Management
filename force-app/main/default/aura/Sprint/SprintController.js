({
    doInitCS : function(component, event, helper) {
        // load
        var thisUrl = window.location;
        var splitUrl = thisUrl.toString().split("/");
        splitUrl.reverse();        
        var sprintId = splitUrl[1];
        var currentVal = component.get("v.gSprint");
        if (sprintId && currentVal == null) {
            var action = component.get("c.getSprint");
            action.setParams({
                "sprintId": sprintId
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
        
        if (!sprintId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__Sprint__c"});
            homeEvt.fire();
        }
    }
})
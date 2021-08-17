({
    loadSprintKeys: function (component) {
        var action = component.get("c.getSprintKeys");
        action.setParams({
            "projectId": component.get("v.recStr")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var sprintKeys = response.getReturnValue();
            if (sprintKeys) {
                window.DataCache.setData("sprintKeys", sprintKeys);
                component.set("v.sprintKeys", sprintKeys);
            }
        });
        $A.enqueueAction(action);
    },
    handleError: function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({ "message": errors[0].message, "type": "error"});
            resultsToast.fire();
        } else {
            console.log("Unknown error");
        }  
    }
})
({
    loadStatusKeys: function (component) {
        var viewName = component.get("v.view");
        var action = component.get("c.getStatusKeys");
        action.setParams({
            "viewName": viewName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var statusKeys = response.getReturnValue();
            if (statusKeys) {
                statusKeys.unshift("");
                window.DataCache.setData("statusKeys", statusKeys);
                component.set("v.statusKeys", statusKeys);
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
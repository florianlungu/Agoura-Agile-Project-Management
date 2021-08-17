({
    loadTypeKeys: function (component) {
        var action = component.get("c.getTypeKeys");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var typeKeys = response.getReturnValue();
            if (typeKeys) {
                typeKeys.unshift("");
                window.DataCache.setData("typeKeys", typeKeys);
                component.set("v.typeKeys", typeKeys);
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
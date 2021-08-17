({
    setWebPageTitle: function (component) {
        var viewName = component.get("v.viewName");
        if (viewName == "Home") {
            viewName = "My Projects";
        }
        document.title = viewName + " | Agoura";
        component.set("v.windowTitle", document.title); 
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },    
	checkAccess: function (component) {
        var action = component.get("c.objectAccess");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            if (result.canCreateAnchorStory == true) {
                component.set("v.canCreateAnchorStory", true);
            }
            if (result.canCreateTag == true) {
                component.set("v.canCreateTag", true);
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
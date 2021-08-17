({
    hasProjects: function (component) {
        var action = component.get("c.hasProjectObject");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.hasProjects", result);
        });
        $A.enqueueAction(action);
    }
})
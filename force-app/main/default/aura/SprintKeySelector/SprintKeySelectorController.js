({
	afterScriptsLoaded : function(component, event, helper) {
        var assetClasses = window.DataCache.getData("assetClasses");
        if (assetClasses) {
            component.set("v.sprintKeys", assetClasses);
        } else {
	    	helper.loadSprintKeys(component);    
        }
	},    
    changeHandler : function(component, event, helper) {
        var changeEvent = component.getEvent("onchange");
        changeEvent.setParams({
            "value": component.get("v.selectedValue")
        });
        changeEvent.fire();
    }    
})
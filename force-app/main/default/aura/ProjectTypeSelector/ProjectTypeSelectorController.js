({
	afterScriptsLoaded : function(component, event, helper) {
        var assetClasses = window.DataCache.getData("assetClasses");
        if (assetClasses) {
            component.set("v.typeKeys", assetClasses);
        } else {
	    	helper.loadTypeKeys(component);    
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
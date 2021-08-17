({    
    changeHandler : function(component, event, helper) {
        var changeEvent = component.getEvent("onchange");
        changeEvent.setParams({
            "value": component.get("v.selectedValue")
        });
        changeEvent.fire();
    }    
})
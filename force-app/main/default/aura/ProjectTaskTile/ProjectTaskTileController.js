({
    doInit: function(component, event, helper) {
        var formattedPoints = component.get("v.projectTask").AgouraFree__Points__c;
        if (formattedPoints === undefined) {
            formattedPoints = "??";
        }        
        component.set("v.formattedPoints", formattedPoints);
    },
    titleClickHandler: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.projectTask").Id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },    
    dragStart : function(component, event) {
        var projectTask = component.get("v.projectTask");
        event.dataTransfer.setData("projectTask", JSON.stringify(projectTask));
    }
})
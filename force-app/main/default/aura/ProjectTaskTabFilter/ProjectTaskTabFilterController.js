({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recStr");        
        helper.loadUnassignedPoints(component, recId); 
        helper.loadSprintCadence(component, recId); 
    },
	searchKeyChangeHandler : function(component, event) {
        var projectTaskTabFilterChangeEvent = $A.get("e.c:ProjectTaskTabFilterChange");
        projectTaskTabFilterChangeEvent.setParams({
            "searchKey": event.getParam("value")
        });
        projectTaskTabFilterChangeEvent.fire();
	},
    typeKeyChangeHandler : function(component, event) {
        var projectTaskTabFilterChangeEvent = $A.get("e.c:ProjectTaskTabFilterChange");
        projectTaskTabFilterChangeEvent.setParams({
            "typeKey": event.getParam("value")
        });
        projectTaskTabFilterChangeEvent.fire();
    },
    rowKeyChangeHandler : function(component, event) {
        var projectTaskTabFilterChangeEvent = $A.get("e.c:ProjectTaskTabFilterChange");
        projectTaskTabFilterChangeEvent.setParams({
            "rowKey": event.getParam("value")
        });
        projectTaskTabFilterChangeEvent.fire();
    },
    sprintKeyChangeHandler : function(component, event) {
        var projectTaskTabFilterChangeEvent = $A.get("e.c:ProjectTaskTabFilterChange");
        projectTaskTabFilterChangeEvent.setParams({
            "sprintKey": event.getParam("value")
        });
        projectTaskTabFilterChangeEvent.fire();
    },
    refreshProjectTasksList : function(component, event, helper) {
        var projectTaskTabFilterChangeEvent = $A.get("e.c:ProjectTaskTabFilterChange");
        projectTaskTabFilterChangeEvent.fire();
        var recId = component.get("v.recStr");
        helper.loadUnassignedPoints(component, recId);  
        helper.loadSprintCadence(component, recId); 
	}
})
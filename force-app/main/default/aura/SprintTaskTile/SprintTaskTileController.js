({
    doInit: function(component, event, helper) {
        if (component.get("v.sprintTaskItem")) {
            var check = component.get("v.sprintTaskItem");
            if (check !== null) {
                var formattedPoints = component.get("v.sprintTaskItem").points;
                if (formattedPoints === undefined) {
                    formattedPoints = "??";
                }
                component.set("v.formattedPoints", formattedPoints);        
                var formattedStatus = component.get("v.sprintTaskItem").formattedStatus; 
                if (formattedStatus == 'inprogress' || formattedStatus == 'readytotest' || formattedStatus == 'testing' || formattedStatus == 'readytodeploy') {
                    component.set("v.showCompleteButton", true);   
                }        
                var assignedToList = component.get("v.assignedToList");
                var assignedToId = component.get("v.sprintTaskItem").assignedTo;
                for (var x = 0; x < assignedToList.length; x++) {
                    if (assignedToList[x].id == assignedToId) {
                        component.set("v.assignedTo", assignedToList[x]);
                        break;
                    }
                }
            }
        }
    },
    titleClickHandler: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.sprintTaskItem").projectTaskId
        });
        navEvt.fire();
    },
    startHandler : function(component) {
        var startEvent = component.getEvent("onStart");
        startEvent.setParam("sprintTaskItem", component.get("v.sprintTaskItem"));
        startEvent.fire();
    },
    completeHandler : function(component) {
        var completeEvent = component.getEvent("onComplete");
        completeEvent.setParam("sprintTaskItem", component.get("v.sprintTaskItem"));
        completeEvent.fire();
    },
    editHandler : function(component) {
        var editEvent = component.getEvent("onEdit");
        editEvent.setParam("sprintTaskItem", component.get("v.sprintTaskItem"));
        editEvent.fire();
    },
    changeSwimLaneHandler : function(component, event) {
        var swimLaneId = event.getParam("value");          
        var changeEvent = component.getEvent("onChangeSwimLane");
        changeEvent.setParams({
            "sprintTaskItem": component.get("v.sprintTaskItem"),
            "swimLaneId": swimLaneId
        });
        changeEvent.fire();
    },
    removeHandler : function(component) {
        var removeEvent = component.getEvent("onRemove");
        removeEvent.setParam("sprintTaskItem", component.get("v.sprintTaskItem"));
        removeEvent.fire();
    }
})
({    
    loadUnassignedPoints: function (component, projectId) {
        var action = component.get("c.getUnassignedPoints");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue(); 
            var unassignedPoints = result.unassignedPoints;
            if (unassignedPoints != '' && unassignedPoints != null) {
                component.set("v.unassignedPoints", unassignedPoints);
            }
        });
        $A.enqueueAction(action);
    },
    loadSprintCadence: function (component, projectId) {
        var action = component.get("c.getProjectSprints");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue(); 
            var projectSprints = [];
            for (var s = 0, len = result.length; s < len; s++) {
                var status = "Closed";
                var today = new Date();
                today.setHours(0,0,0,0);
                var endDateStr = result[s].AgouraFree__End_Date__c;
                if (endDateStr != null) {
                    var endDate = new Date(endDateStr.substr(0,4), (endDateStr.substr(5,2)-1), endDateStr.substr(8,2));
                    if (endDate >= today || !result[s].AgouraFree__End_Date__c) {
                        status = "Open";
                    }        
                }
                var resultItem = {
                    completedPoints: result[s].AgouraFree__Completed_Points__c,
                    status: status,
                    startDate: result[s].AgouraFree__Start_Date__c,
                    endDate: result[s].AgouraFree__End_Date__c
                };                
                projectSprints.push(resultItem);   
            }
            var i = 0;
            var sprintCadence = 0;
            var count = 0;
            var lastSprint = 0;
            for (i = projectSprints.length; i > 0; i--){
                if (projectSprints[i-1].status == 'Closed') {
                    sprintCadence += projectSprints[i-1].completedPoints;
                    if (count == 0) {
                        lastSprint = projectSprints[i-1].completedPoints;
                    }
                    count += 1
                    if (count >= 3) {                        
                        break;
                    }
                }
            }
            if (sprintCadence > 0) {
                sprintCadence = Math.round(sprintCadence/3);
                component.set("v.sprintCadence", sprintCadence);
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
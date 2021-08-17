({
    doInit : function(component, event, helper) {
        helper.isDesktop(component);
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.hasEditAccess(component, recId); 
        } else {
            helper.hasCreateAccess(component);
        }	 
        helper.loadFieldLabelMap(component);		
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var fieldList = ["propSprintLength","propStartDate"];
        var allGood = helper.validateFields(component, fieldList);  
        if (allGood == false) {return false;}
        
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        if(projectId == null || projectId == '') {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"message": "Please select a project before saving", "type": "error"});
            resultsToast.fire();  
            return null;
        }
        
        var workDaysField = document.getElementsByName('workDays');
        var workDaysValue = [];
        for(var i = 0; i < workDaysField.length; ++i) {
            if(workDaysField[i].checked) {
                workDaysValue.push(workDaysField[i].value);
            }
        }
        workDaysValue.sort(function(a,b){return a - b});
        var workDaysValueStr = workDaysValue.join(';');        
        if (workDaysValueStr == null || workDaysValueStr == '') {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"title": "Error", "message": "Please select at least 1 working day for this sprint", "type": "error"});
            resultsToast.fire();
            return null;
        } 
        
        // save record  
        component.set("v.targetFields.AgouraFree__Project__c", projectId);
        component.set("v.targetFields.AgouraFree__Sprint_Length__c", component.find('propSprintLength').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Target_Points__c", component.find('propTargetPoints').get("v.value"));   
        component.set("v.targetFields.AgouraFree__Start_Date__c", component.find('propStartDate').get("v.value"));  
        component.set("v.targetFields.AgouraFree__End_Date__c", component.find('propEndDate').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Work_Days_Report__c", workDaysValueStr);   
        component.set("v.targetFields.AgouraFree__Version__c", component.find('propVersion').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Sprint_Goal__c", component.find('propSprintGoal').get("v.value"));  
        component.set("v.targetFields.AgouraFree__What_went_well__c", component.find('propDidWell').get("v.value"));  
        component.set("v.targetFields.AgouraFree__What_did_not_go_well__c", component.find('propDidNotWell').get("v.value"));   
        component.set("v.targetFields.AgouraFree__What_can_we_do_different_next_time__c", component.find('propDoDifferent').get("v.value"));  
        
        // close Sprint
        var today = new Date();
        today.setHours(0,0,0,0);
        var endDateStr = component.find('propEndDate').get("v.value");
        if (endDateStr != null) {
            var endDate = new Date(endDateStr.substr(0,4), (endDateStr.substr(5,2)-1), endDateStr.substr(8,2));
            if (endDate <= today) {
                // close sprint confirm
                component.set("v.showConfirmTitle", "Close Sprint?");
                component.set("v.showConfirmModal", true); 
                return null;
            }
        }
        
        // set sprint number and completed points
        helper.setSprintNumberCompletedPoints(component, projectId);
    },  
    closeConfirm: function(component, event, helper) {
        component.set("v.showConfirmModal", false);
    },
    closeSprint: function(component, event, helper) {
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        var closeSprintChoice = component.find('closeSprintRadioValue').get("v.value");
        if (closeSprintChoice == 'No') {
            helper.setSprintNumberCompletedPoints(component, projectId);
        } else {
            var recId = component.get("v.recordId"); 
            var sGoal = component.get("v.targetFields.AgouraFree__Sprint_Goal__c") || " ";
            var goWell = component.get("v.targetFields.AgouraFree__What_went_well__c") || " ";
            var goNotWell = component.get("v.targetFields.AgouraFree__What_did_not_go_well__c") || " ";
            var doDiff = component.get("v.targetFields.AgouraFree__What_can_we_do_different_next_time__c") || " ";
            var body = component.get("v.targetFields.AgouraFree__Project__r.AgouraFree__Title__c") + " " +
                component.get("v.targetFields.AgouraFree__Sprint_Name__c") + " Completed\n\n"
            + "Sprint Goal\n" + sGoal + "\n\n"
            + "What went well?\n" + goWell + "\n\n"
            + "What did not go well?\n" + goNotWell + "\n\n"
            + "What can we do different next time?\n" + doDiff + "\n\n";
            var newPost = {
                sObjectType: 'FeedItem',
                ParentId: projectId,
                Type: 'TextPost',
                IsRichText: false,
                Body: body
            };   
            var postChatter = false;
            if (closeSprintChoice == 'Yes2') {
                postChatter = true;
            }
            var action = component.get("c.doCloseSprint");
            action.setParams({
                "recId": recId,
                "newPost": newPost,
                "postChatter" : postChatter
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "ERROR") {
                    helper.handleError(response);
                    return;
                }
                helper.setSprintNumberCompletedPoints(component, projectId);
            });
            $A.enqueueAction(action);  
        }          
    },
    cancelDialog: function(component, event, helper) {
        helper.doCancel(component);
    },
    lookupProjectSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propProject').search(serverSearchAction);
    },
    updateRetrospectiveFields: function (component, event, helper) {
        var fieldValue = component.find('propEndDate').get("v.value");
        helper.updateRetrospectiveFields(component,fieldValue);
        helper.setWorkDayChoices(component, "Refresh");
    },
    changeDate: function (component, event, helper) { 
        helper.setWorkDayChoices(component, "Refresh");
    }
})
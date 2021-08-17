({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.checkAccess(component, recId);
            helper.setWebPageTitle(component, recId);
            helper.loadProject(component, recId); 
            helper.loadSprint(component, recId);
            helper.loadMasterTask(component, recId); 
            helper.loadSubTasks(component, recId); 
            helper.loadUsers(component, recId); 
            helper.loadAccountList(component, recId);
            helper.loadTagList(component, recId);
            helper.loadChatterFeed(component);
            helper.loadFieldLabelMap(component);
        }
        if (!recId) {
            component.set("v.hasEditAccess", true);
            component.find("record").getNewRecord(
                "AgouraFree__ProjectTask__c",
                null,
                false,
                $A.getCallback(function() {
                    var rec = component.get("v.targetFields");
                    var error = component.get("v.recordError");
                    if (error || (rec === null)) {
                        console.log("Error initializing record template: " + error);
                        return;
                    }
                })
            );	
        }
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    editRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__ProjectTask__c/'+recId+'/edit';
    },
    deleteRecord : function(component, event, helper) {
        component.set("v.showConfirmDeleteToast", true);
        component.find("record").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                console.log("Record is deleted."); 
            } else if (deleteResult.state === "ERROR") {
                helper.handleError(deleteResult);
                return;
            } else {
                var errors = "";
                for (var i = 0; deleteResult.error.length > i; i++){
                    errors = errors + deleteResult.error[i].message;
                }
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + errors);
            }
        }));
    },
    handleRecordUpdated: function(component, event, helper) {
        var showConfirmDeleteToast = component.get("v.showConfirmDeleteToast");
        var eventParams = event.getParams();
        if(eventParams.changeType === "REMOVED") {
            var sprint = component.get("v.sprintSelection");
            var sprintId = (sprint.length > 0) ? sprint[0].id : '';
            var project = component.get("v.projectSelection");
            var projectId = (project.length > 0) ? project[0].id : '';
            
            if (sprintId.length > 0 && projectId.length > 0) {
                helper.updateTasksPlusSprint(component, projectId, sprintId);
            } else if (projectId.length > 0) {
                helper.updateTasks(component, projectId);
            }
            
            // record is deleted, show a toast UI message
            if (showConfirmDeleteToast) {
                var toastMsg = "Project Task \"" + component.get("v.targetFields.AgouraFree__Task_Number__c") + "\" was deleted.";
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to sprint or project or object home                
                if (sprintId.length > 0) {
                    helper.navigateTo(component, sprintId);
                } else if (projectId.length > 0) {
                    helper.navigateTo(component, projectId);
                } else {
                    var homeEvt = $A.get("e.force:navigateToObjectHome");
                    homeEvt.setParams({"scope": "AgouraFree__ProjectTask__c"});
                    homeEvt.fire();
                }
            }
        }
    }, 
    closeConfirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", false);
    },
    startWork: function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.doStartWork");
        action.setParams({"taskId": taskId});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var recName = component.get("v.targetFields.AgouraFree__Task_Number__c");
            var toastMsg = "Project Task " + recName + " updated";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                window.location.reload();
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action); 
    },
    completeWork: function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var sprintId = component.get("v.targetFields.AgouraFree__Sprint__c");
        var projectId = component.get("v.targetFields.AgouraFree__Project__c");
        var taskType = component.get("v.targetFields.AgouraFree__Type__c");
        var action = component.get("c.doCompleteWork");
        action.setParams({
            "taskId": taskId,
            "sprintId": sprintId,
            "projectId": projectId,
            "taskType": taskType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var recName = component.get("v.targetFields.AgouraFree__Task_Number__c");
            var toastMsg = "Project Task " + recName + " updated";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                window.location.reload();
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action); 
    },
    handleMenuSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");        
        if (selectedMenuItemValue == "Assign to Me") {
            helper.assignToMe(component, event, helper);
        } else if (selectedMenuItemValue == "Delete") {
            helper.confirmDelete(component, event, helper);
        } else if (selectedMenuItemValue == "Clone") {
            helper.confirmClone(component, event, helper);
        } else if (selectedMenuItemValue == "Move") {
            helper.confirmMove(component, event, helper);
        }
    },  
    closeConfirm: function(component, event, helper) {
        component.set("v.showConfirmModal", false);
    },
    lookupProjectSearchMove : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propMoveProject').search(serverSearchAction);
    },
    lookupProjectSearchClone : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propCloneProject').search(serverSearchAction);
    },
    cloneRecord: function(component, event, helper) {
        var project = component.get("v.cloneProjectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        var resultsToast = $A.get("e.force:showToast");
        
        if (projectId.length == 0) {
            resultsToast.setParams({"message":  "Please select a project", "type": "error"});
            resultsToast.fire();
            return null;
        }       
        
        var action = component.get("c.createCloneTask");
        var recId = component.get("v.recordId");        
        action.setParams({
            "recId": recId,
            "projectId": projectId
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  "Project Task cloned", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var cloneRecordEvent = $A.get("e.force:editRecord");
                cloneRecordEvent.setParams({
                    "recordId": result
                });
                cloneRecordEvent.fire();
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);    
    },
    moveRecord: function(component, event, helper) {
        var project = component.get("v.moveProjectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        var resultsToast = $A.get("e.force:showToast");
        
        if (projectId.length == 0) {
            resultsToast.setParams({"message":  "Please select a project", "type": "error"});
            resultsToast.fire();
            return null;
        }       
        
        var action = component.get("c.doMoveProjectTask");
        var recId = component.get("v.recordId");        
        action.setParams({
            "recId": recId,
            "projectId": projectId
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  "Project Task moved", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var moveRecordEvent = $A.get("e.force:editRecord");
                moveRecordEvent.setParams({"recordId": result});
                moveRecordEvent.fire();
                window.location.reload();
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);
    },
    refreshChatterFeed: function(component, event, helper) {
        helper.doRefreshChatterFeed(component);
    },
    chatterFeedPost: function(component, event, helper) {
        var content = component.find('chatterTextPostField').get("v.value");
        var resultsToast = $A.get("e.force:showToast");
        if (typeof content === "undefined") {
            resultsToast.setParams({"message": "Nothing to share", "type": "error"});
            resultsToast.fire();
            return;
        }
        var newPost = {
            sObjectType: 'FeedItem',
            ParentId: component.get("v.recordId"),
            Type: 'TextPost',
            IsRichText: true,
            Body: content
        };        
        var action = component.get("c.doChatterFeedPost");
        action.setParams({"newPost": newPost});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var updatedRecord = response.getReturnValue();
                resultsToast.setParams({"message": "Chatter Update Posted", "type": "success"});
                resultsToast.fire();
                component.find('chatterTextPostField').set("v.value", "");
                helper.doRefreshChatterFeed(component);
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            } else {
                console.log("Unknown error");
            }
        });        
        $A.enqueueAction(action);   
    }
})
({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.checkAccess(component, recId);
            helper.setWebPageTitle(component, recId);
            helper.loadMasterTask(component, recId); 
            helper.loadSubTasks(component, recId); 
            helper.loadUsers(component, recId); 
        }
        helper.loadFieldLabelMap(component);
        if (!recId) {
            component.set("v.hasEditAccess", true);
            component.find("record").getNewRecord(
                "AgouraFree__AnchorStory__c",
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
    deleteRecord : function(component, event, helper) {
        var resultsToast = $A.get("e.force:showToast");
        component.set("v.showConfirmDeleteToast", true);
        component.find("record").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                console.log("Record is deleted.");                
            } else if (deleteResult.state === "ERROR") {  
                helper.handleError(deleteResult);
            } else {
                console.log("Unknown error");
            }
        }));
    },
    handleRecordUpdated: function(component, event, helper) {
        var showConfirmDeleteToast = component.get("v.showConfirmDeleteToast");
        var eventParams = event.getParams();
        if(eventParams.changeType === "REMOVED") {
            if (showConfirmDeleteToast) {
                var toastMsg = "Anchor Story \"" + component.get("v.targetFields.AgouraFree__Title__c") + "\" was deleted.";
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to Anchor Story Page
                window.location = '/lightning/o/AgouraFree__AnchorStory__c/home';
            }
        }
    },
    handleMenuSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");        
        if (selectedMenuItemValue == "Delete") {
            helper.confirmDelete(component, event, helper);
        } else if (selectedMenuItemValue == "Change Owner") {
            helper.confirmChangeOwner(component, event, helper);
        } else if (selectedMenuItemValue == "Clone") {
            helper.cloneRecord(component, event, helper);
        } else if (selectedMenuItemValue == "Edit") {
            helper.editRecord(component, event, helper);
        }
    }, 
    closeConfirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", false);
    },  
    closeConfirm: function(component, event, helper) {
        component.set("v.showConfirmModal", false);
    },
    lookupNewOwnerSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propNewOwner').search(serverSearchAction);
    },
    changeOwner : function(component, event, helper) {
        // field validation
        var userField = component.get("v.recordNewOwnerSelection");
        var resultsToast = $A.get("e.force:showToast");
        if(userField == null || userField == '') {            
            resultsToast.setParams({"message": "Please select a user to continue", "type": "error"});
            resultsToast.fire();  
            return null;
        }        
        
        var action = component.get("c.updateDocumentOwner");
        var recId = component.get("v.targetFields.Id");        
        action.setParams({
            "recId": recId,
            "userId": userField[0].id
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = "Record Owner has been updated";
            var resultsToast = $A.get("e.force:showToast");
            
            if (state === "SUCCESS") {
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
                location.reload(); 
            } else if (state === "ERROR") {
                helper.handleError(response);                
            }
        });        
        $A.enqueueAction(action);        
    },  
    confirmCreateProjectTask: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Create Project Task");
        component.set("v.showConfirmAsk", "Select the project to create the project task in:");
        component.set("v.showConfirmModal", true);
    },
    lookupProjectSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propProject').search(serverSearchAction);
    },
    createProjectTask: function(component, event, helper) {
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        var resultsToast = $A.get("e.force:showToast");
        
        if (projectId.length == 0) {
            resultsToast.setParams({"message":  "Please select a project", "type": "error"});
            resultsToast.fire();
            return null;
        }       
        
        var action = component.get("c.doCreateProjectTask");
        var recId = component.get("v.recordId");        
        action.setParams({
            "recId": recId,
            "projectId": projectId
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  "Project Task created", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var createRecordEvent = $A.get("e.force:editRecord");
                createRecordEvent.setParams({"recordId": result});
                createRecordEvent.fire();
            } else {
                helper.handleError(response);
                return null;
            }
        });        
        $A.enqueueAction(action);    
    }
})
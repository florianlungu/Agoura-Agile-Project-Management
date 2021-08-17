({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.checkAccess(component, recId);
            helper.setWebPageTitle(component, recId);
            helper.loadUsers(component, recId);     
            helper.hasProjects(component);        
        }
        if (!recId) {
            component.set("v.hasEditAccess", true);
            component.find("forceRecord").getNewRecord(
                "AgouraFree__Tag__c",
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
                var errors = deleteResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({ "message": errors[0].message, "type": "error"});
                    resultsToast.fire();
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error");
            }
        }));
    },
    handleRecordUpdated: function(component, event, helper) {
        var showConfirmDeleteToast = component.get("v.showConfirmDeleteToast");
        var eventParams = event.getParams();
        if(eventParams.changeType === "REMOVED") {
            // record is deleted, show a toast UI message
            if (showConfirmDeleteToast) {
                var toastMsg = "Tag \"" + component.get("v.targetFields.Name") + "\" was deleted.";
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to object home
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "AgouraFree__Tag__c"
                });
                homeEvent.fire();
            }
        }
    },
    handleMenuSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");        
        if (selectedMenuItemValue == "Change Owner") {
            helper.confirmChangeOwner(component, event, helper);
        } else if (selectedMenuItemValue == "Clone") {
            helper.cloneRecord(component, event, helper);
        } else if (selectedMenuItemValue == "Delete") {
            helper.confirmDelete(component, event, helper);
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
            if (state === "SUCCESS") {
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
                location.reload(); 
            }
            else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    }
})
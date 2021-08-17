({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.checkAccess(component, recId); 
            helper.setWebPageTitle(component, recId);
            helper.loadUsers(component, recId);
            helper.loadIdeaTagList(component, recId);
            helper.hasProjects(component);
            helper.loadIdeaProjectList(component, recId);  
            helper.loadFieldLabelMap(component);
            helper.isChatterEnabled(component);
        }
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    showMoreInfo : function (component, event, helper) {
        var cmpDetails = component.find('Details');
        $A.util.removeClass(cmpDetails, 'slds-show');
        $A.util.addClass(cmpDetails, 'slds-hide');
        var cmpMoreInfo = component.find('MoreInfo');
        $A.util.removeClass(cmpMoreInfo, 'slds-hide');
        $A.util.addClass(cmpMoreInfo, 'slds-show');
        var cmpMoreInfoButton = component.find('MoreInfoButton');
        $A.util.removeClass(cmpMoreInfoButton, 'slds-show');
        $A.util.addClass(cmpMoreInfoButton, 'slds-hide');
        var cmpDetailsButton = component.find('DetailsButton');
        $A.util.removeClass(cmpDetailsButton, 'slds-hide');
        $A.util.addClass(cmpDetailsButton, 'slds-show');
    },
    showDetails : function (component, event, helper) {
        var cmpDetails = component.find('Details');
        $A.util.removeClass(cmpDetails, 'slds-hide');
        $A.util.addClass(cmpDetails, 'slds-show');
        var cmpMoreInfo = component.find('MoreInfo');
        $A.util.removeClass(cmpMoreInfo, 'slds-show');
        $A.util.addClass(cmpMoreInfo, 'slds-hide');
        var cmpMoreInfoButton = component.find('MoreInfoButton');
        $A.util.removeClass(cmpMoreInfoButton, 'slds-hide');
        $A.util.addClass(cmpMoreInfoButton, 'slds-show');
        var cmpDetailsButton = component.find('DetailsButton');
        $A.util.removeClass(cmpDetailsButton, 'slds-show');
        $A.util.addClass(cmpDetailsButton, 'slds-hide');
    },
    deleteRecord : function(component, event, helper) {
        component.set("v.showConfirmDeleteToast", true);
        component.find("record").deleteRecord($A.getCallback(function(deleteResult) {
            var resultsToast = $A.get("e.force:showToast");
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
            if (showConfirmDeleteToast) {
                var toastMsg = "Idea Board \"" + component.get("v.targetFields.Name") + "\" was deleted.";
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "message":  toastMsg,
                    "type": "success"
                });
                resultsToast.fire();
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({"scope": "AgouraFree__IdeaBoard__c"});
                homeEvent.fire();
            }
        }
    }, 
    closeConfirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", false);
    },  
    closeConfirm: function(component, event, helper) {
        component.set("v.showConfirmModal", false);
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
            }
            else if (state === "ERROR") {
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
                    resultsToast.setParams({ "message": errors[0].message, "type": "error"});
                    resultsToast.fire();
                } else {
                    console.log("Unknown error");
                }
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
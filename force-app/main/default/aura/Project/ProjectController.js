({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");     
        if (recId) {
            helper.checkAccess(component, recId);  
        }	
        helper.isChatterEnabled(component);
        helper.loadFieldLabelMap(component);
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    editProjectRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__Project__c/'+recId+'/edit';
    },
    cloneRecord : function(component, event, helper) {
        component.set("v.showPleaseWait", true);
        var selectedValues = component.find("cloneWhat").get("v.value");
        var action = component.get("c.createCloneProject");
        var recId = component.get("v.recordId");
        action.setParams({
            "recId": recId,
            "cloneWhat": selectedValues
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message": "Project cloned", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({ "recordId": result });
                navigateEvent.fire();
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });
        $A.enqueueAction(action);
    },
    deleteRecord : function(component, event, helper) {
        var deleteWhat = component.get("v.showConfirmDeleteWhat");
        var projectItems = ["Project Goal", "Project Link", "Project Milestone", "Project Risk", "Project Stakeholder",
                            "Project Swim Lane", "Project Team Member"];
        if (deleteWhat == "Project") {
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
        } else if (projectItems.indexOf(deleteWhat) > -1) { 
            component.set("v.showConfirmDeleteModal", false);
            helper.removeProjectItem(component);        
        } else if (deleteWhat == "Project Sprint") { 
            component.set("v.showConfirmDeleteModal", false);            
            helper.removeProjectSprint(component);
        }             
    },
    handleRecordUpdated: function(component, event, helper) {
        var showConfirmDeleteToast = component.get("v.showConfirmDeleteToast");
        var eventParams = event.getParams();
        if(eventParams.changeType === "REMOVED") {
            if (showConfirmDeleteToast) {
                var toastMsg = "Project \"" + component.get("v.targetFields.Name") + "\" was deleted.";
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to object home
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({"scope": "AgouraFree__Project__c"});
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
        } else if (selectedMenuItemValue == "Clone") {
            helper.confirmClone(component, event, helper);
        } else if (selectedMenuItemValue == "Change Owner") {
            helper.confirmChangeOwner(component, event, helper);
        }
    },
    lookupNewOwnerSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propNewOwner').search(serverSearchAction);
    },
    changeOwner : function(component, event, helper) {
        // field validation
        var userField = component.get("v.projectNewOwnerSelection");
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
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
                location.reload(); 
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    
    // Roadmap Tab
    updateRoadmapFields: function (component, event, helper) {
        var fieldValue = component.find('propGoalType').get("v.value");
        if (fieldValue == "Project Goal") {
            var cmpDetails = component.find("readOnlyStartDate");
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide');
            var cmpDetails = component.find("editStartDate");
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show'); 
        } else {
            var cmpDetails = component.find("editStartDate");
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide'); 
            var cmpDetails = component.find("readOnlyStartDate");
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show');        
        }
    },
    addNewGoal : function(component, event, helper) {
        // field validation
        var titleField = component.find('propGoalTitle');
        var titleValue = titleField.get('v.value');
        if(titleValue == null || titleValue == '') {
            titleField.set('v.validity', {valid:false, badInput :true});
            titleField.showHelpMessageIfInvalid();
            return null;
        }
        var startDate = component.find('propGoalStartDate');
        var targetDate = component.find('propGoalTargetDate');
        var progress = component.find('propGoalProgress');
        if (startDate.checkValidity() == false || targetDate.checkValidity() == false || progress.checkValidity() == false) {
            return null;
        }
        
        var action = component.get("c.addGoal");
        var projectId = component.get("v.targetFields.Id"); 
        action.setParams({
            "projectId": projectId,
            "typeStr": component.find('propGoalType').get("v.value"),
            "title": component.find('propGoalTitle').get("v.value"),
            "startDate": startDate.get("v.value"),
            "targetDate": targetDate.get("v.value"),
            "progress": progress.get("v.value"),
            "comments": component.find('propGoalComments').get("v.value")        
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            var recType = component.find('propGoalType').get("v.value");
            var recName = component.find('propGoalTitle').get("v.value");
            if (state === "SUCCESS") {
                var toastMsg = recType + " \"" + recName + "\" was saved.";
                helper.loadProjectGoals(component, projectId); 
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    refreshGoalsList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadProjectGoals(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Roadmap Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    updateProjectGoalsColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectGoalsSortedBy", fieldName);
        component.set("v.projectGoalsSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectGoalsList");
    },
    updateProjectMilestonesColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectMilestonesSortedBy", fieldName);
        component.set("v.projectMilestonesSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectMilestonesList");
    },
    handleProjectItemRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view':
                helper.viewRecord(row); 
                break;
            case 'edit':
                helper.editRecord(row); 
                break;
            case 'delete':
                component.set("v.showConfirmDeleteWhat", row.type);
                component.set("v.showConfirmDeleteWhatId", row.id);
                component.set("v.showConfirmDeleteModal", true);
                break;
            default:
                helper.editRecord(row);
                break;
        }
    },
    
    // Risks Tab
    addNewRisk : function(component, event, helper) {
        // field validation
        var titleField = component.find('propRiskTitle');
        var titleValue = titleField.get('v.value');
        if(titleValue == null || titleValue == '') {
            titleField.set('v.validity', {valid:false, badInput :true});
            titleField.showHelpMessageIfInvalid();
            return null;
        }        
        
        var action = component.get("c.addRisk");
        var projectId = component.get("v.targetFields.Id"); 
        action.setParams({
            "projectId": projectId,
            "title": component.find('propRiskTitle').get("v.value"),
            "probability": component.find('propRiskProbability').get("v.value"),
            "impact": component.find('propRiskImpact').get("v.value"),
            "status": component.find('propRiskStatus').get("v.value"),
            "response": component.find('propRiskResponse').get("v.value")      
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var recName = component.find('propRiskTitle').get("v.value");
            var toastMsg = "Project Risk \"" + recName + "\" was saved.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                helper.loadProjectRisks(component, projectId); 
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    refreshRisksList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadProjectRisks(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Risks Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    updateProjectRisksColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectRisksSortedBy", fieldName);
        component.set("v.projectRisksSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectRisksList");
    },
    
    // Stakeholder Tab
    lookupStakeholderSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propStakeholder').search(serverSearchAction);
    },
    addNewStakeholder : function(component, event, helper) {
        // field validation
        var userField = component.get("v.projectStakeholderSelection");
        var resultsToast = $A.get("e.force:showToast");
        if (userField == null || userField == '') {            
            resultsToast.setParams({"message": "Please select a user to add a Project Team Member", "type": "error"});
            resultsToast.fire();  
            return null;
        }
        
        var action = component.get("c.addStakeholder");
        var projectId = component.get("v.targetFields.Id"); 
        var stakeholderType = component.find('propStakeholderType').get("v.value");
        var raci = new String;
        var swimLane = new String;
        var swimLaneList = component.get("v.projectSwimLanesList");
        var grantAccess = component.find('propGrantAcesss').get("v.value");
        if (component.get("v.targetFields.OwnerId") == userField[0].id) {
            grantAccess = "";
        }
        if (stakeholderType == "Project Team Member") {
            if (swimLaneList.length > 0) {
                swimLane = component.find('propStakeholderSwimLane').get("v.value");
            }           
        } else {
            raci = component.find('propStakeholderRACI').get("v.value");
        }
        action.setParams({
            "projectId": projectId,
            "stakeholderType": stakeholderType,  
            "userId": userField[0].id,  
            "raci": raci,  
            "swimLane": swimLane,
            "grantAccess": grantAccess
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = stakeholderType + " was added.";            
            if (state === "SUCCESS") {
                helper.loadProjectStakeholders(component, projectId); 
                helper.loadUsers(component, projectId);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    refreshStakeholdersList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadSwimLaneList(component, recId);
        helper.loadProjectStakeholders(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Team Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    updateProjectStakeholdersColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectStakeholdersSortedBy", fieldName);
        component.set("v.projectStakeholdersSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectStakeholdersList");
    },
    updateProjectTeamColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectTeamSortedBy", fieldName);
        component.set("v.projectTeamSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectTeamList");
    },
    updateProjectTeamFields: function (component, event, helper) {
        var fieldValue = component.find('propStakeholderType').get("v.value");
        if (fieldValue == "Project Team Member") {
            var cmpDetails = component.find("teamRACI");
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide');
            var cmpDetails = component.find("teamSwimLane");
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show');
        } else {
            var cmpDetails = component.find("teamSwimLane");
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide'); 
            var cmpDetails = component.find("teamRACI");
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show');           
        }
    },
    
    // Sprint Tab
    addNewSwimLane : function(component, event, helper) {
        component.set("v.showConfirmTitle", "New Project Swim Lane");
        component.set("v.showConfirmAsk", "Enter a title for the new Project Swim Lane");
        component.set("v.showConfirmModal", true);     
    },   
    createSwimLane : function(component, event, helper) {
        // field validation
        var titleField = component.find('propNewSwimLaneTitle');
        var titleValue = titleField.get('v.value');
        if(titleValue == null || titleValue == '') {
            titleField.set('v.validity', {valid:false, badInput :true});
            titleField.showHelpMessageIfInvalid();
            return null;
        }        
        
        var action = component.get("c.addSwimLane");
        var projectId = component.get("v.targetFields.Id"); 
        action.setParams({
            "projectId": projectId,
            "title": titleValue    
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = "Project Swim Lane \"" + titleValue + "\" was saved.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                component.set("v.showConfirmModal", false);
                helper.loadSwimLaneList(component, projectId); 
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    refreshSprintsList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadSwimLaneList(component, recId);
        helper.loadProjectSprints(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Sprints Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    refreshRetrospectivesList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadProjectSprints(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Retrospectives Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    updateProjectSprintsColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectSprintsSortedBy", fieldName);
        component.set("v.projectSprintsSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectSprintsList");
    },
    updateProjectSwimLanesColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectSwimLanesSortedBy", fieldName);
        component.set("v.projectSwimLanesSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectSwimLanesList");
    },
    
    // Links Tab
    lookupLinkOwnerSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propLinkOwner').search(serverSearchAction);
    },
    addNewLink : function(component, event, helper) {
        // field validation
        var fieldList = ["propLinkTitle","propLinkURL"];
        var allGood = helper.validateFields(component, fieldList);  
        if (allGood == false) {return false;}       
        
        var action = component.get("c.addLink");
        var projectId = component.get("v.targetFields.Id"); 
        var ownerField = component.get("v.projectLinkOwnerSelection");
        var ownerId = '';
        
        if (ownerField.length > 0) {              
            ownerId = ownerField[0].id;
        }       
        action.setParams({
            "projectId": projectId,
            "title": component.find('propLinkTitle').get("v.value"),
            "url": component.find('propLinkURL').get("v.value"),
            "ownerId": ownerId
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var recName = component.find('propLinkTitle').get("v.value");
            var toastMsg = "Project Link \"" + recName + "\" was saved.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                helper.loadProjectLinks(component, projectId); 
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },
    refreshLinksList : function(component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.loadProjectLinks(component, recId); 
        var resultsToast = $A.get("e.force:showToast");          
        resultsToast.setParams({"message": "Project Links Tab refreshed", "type": "success"});
        resultsToast.fire()
    },
    updateProjectLinksColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectLinksSortedBy", fieldName);
        component.set("v.projectLinksSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.projectLinksList");
    },
    refreshChatterFeed: function(component, event, helper) {
        helper.doRefreshChatterFeed(component);
    },
    changeChatterTab: function(component, event, helper) {        
        var thisTab = event.target.id;
        for (var i = 1; i <= 3; i++) {
            var tabId = "chatterTab" + i;
            var subTabId = "chatterTabPanel" + i;
            var cmpDetails = component.find(tabId);
            var cmpDetails2 = component.find(subTabId);
            if ( thisTab == tabId) {
                $A.util.addClass(cmpDetails, 'slds-is-active');
                $A.util.removeClass(cmpDetails2, 'slds-hide');
                $A.util.addClass(cmpDetails2, 'slds-show');
            } else {
                $A.util.removeClass(cmpDetails, 'slds-is-active');
                $A.util.removeClass(cmpDetails2, 'slds-show');
                $A.util.addClass(cmpDetails2, 'slds-hide');
            }
        }
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
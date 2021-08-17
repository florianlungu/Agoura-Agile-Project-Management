({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        if (recId) {
            helper.checkAccess(component, recId);
            helper.setWebPageTitle(component, recId);
            helper.loadProject(component, recId); 
            helper.loadFieldLabelMap(component);
            helper.loadFieldLabelMapTasks(component, recId);
            
            // refresh every 5 minutes            
            var lastReload = new Date(); // If the user just loaded the page you don't want to reload either
            var interval = window.setInterval(
                $A.getCallback(function() {
                    var now = new Date();
                    if (now.getHours() == 2 && new Date() - lastReload > 1000 * 60 * 60 * 2) { 
                        // If it is between 2 and 3 AND the last reload was longer ago than 2 hours reload the page.
                        location.reload(true);
                    } else {
                        helper.refreshSprint(component, recId, "auto"); 
                    }                    
                }), 300000
            );
        }
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__Sprint__c"});
            homeEvt.fire();
        }		
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    showRetrospective : function (component, event, helper) {
        var cmpDetails = component.find('contentRetrospective');
        $A.util.removeClass(cmpDetails, 'slds-hide');
        $A.util.addClass(cmpDetails, 'slds-show');            
        var cmpDetailsButton = component.find('DetailsButton');
        $A.util.removeClass(cmpDetailsButton, 'slds-hide');
        $A.util.addClass(cmpDetailsButton, 'slds-show');
        var cmpRetrospectiveButton = component.find('RetrospectiveButton2');
        $A.util.removeClass(cmpRetrospectiveButton, 'slds-show');
        $A.util.addClass(cmpRetrospectiveButton, 'slds-hide');
        var cmpDetailsButton = component.find('DetailsButton2');
        $A.util.removeClass(cmpDetailsButton, 'slds-hide');
        $A.util.addClass(cmpDetailsButton, 'slds-show');
    },
    showDetails : function (component, event, helper) {
        var cmpcontentRetrospective = component.find('contentRetrospective');
        $A.util.removeClass(cmpcontentRetrospective, 'slds-show');
        $A.util.addClass(cmpcontentRetrospective, 'slds-hide');        
        var cmpDetailsButton = component.find('DetailsButton');
        $A.util.removeClass(cmpDetailsButton, 'slds-show');
        $A.util.addClass(cmpDetailsButton, 'slds-hide');
        var cmpRetrospectiveButton = component.find('RetrospectiveButton2');
        $A.util.removeClass(cmpRetrospectiveButton, 'slds-hide');
        $A.util.addClass(cmpRetrospectiveButton, 'slds-show');
        var cmpDetailsButton = component.find('DetailsButton2');
        $A.util.removeClass(cmpDetailsButton, 'slds-show');
        $A.util.addClass(cmpDetailsButton, 'slds-hide');
    },
    editRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__Sprint__c/'+recId+'/edit';
    }, 
    closeConfirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", false);
    },
    deleteRecord : function(component, event, helper) {
        var sprintId = component.get("v.recordId");
        var action = component.get("c.removeProjectSprint");
        action.setParams({
            "sprintId": sprintId                    
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = "Project Sprint was deleted.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                var projName = component.get("v.targetFields.AgouraFree__Project__r.AgouraFree__Title__c");
                var recName = component.get("v.targetFields.AgouraFree__Sprint_Number__c");
                var toastMsg = projName + " Sprint " + recName + " was deleted.";                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to project or object home
                var project = component.get("v.projectSelection");
                var projectId = (project.length > 0) ? project[0].id : '';
                if(projectId == null || projectId == '') {
                    var homeEvt = $A.get("e.force:navigateToObjectHome");
                    homeEvt.setParams({
                        "scope": "AgouraFree__Sprint__c"
                    });
                    homeEvt.fire();           
                } else {
                    helper.navigateTo(component, projectId);
                }
            } else if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action); 
    },
    handleRecordUpdated: function(component, event, helper) {
        var showConfirmDeleteToast = component.get("v.showConfirmDeleteToast");
        var eventParams = event.getParams();
        if(eventParams.changeType === "REMOVED") {
            // record is deleted, show a toast UI message
            if (showConfirmDeleteToast) {
                var projName = component.get("v.targetFields.AgouraFree__Project__r.AgouraFree__Title__c");
                var recName = component.get("v.targetFields.AgouraFree__Sprint_Number__c");
                var toastMsg = projName + " Sprint " + recName + " was deleted.";                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();
                // navigate to project or object home
                var project = component.get("v.projectSelection");
                var projectId = (project.length > 0) ? project[0].id : '';
                if(projectId == null || projectId == '') {
                    var homeEvt = $A.get("e.force:navigateToObjectHome");
                    homeEvt.setParams({
                        "scope": "AgouraFree__Sprint__c"
                    });
                    homeEvt.fire();           
                } else {
                    helper.navigateTo(component, projectId);
                }
            }
        }
    },
    handleMenuSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");        
        if (selectedMenuItemValue == "Delete") {
            helper.confirmDelete(component, event, helper);
        }
    },
    dropHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintId = component.get("v.recordId");
        event.preventDefault();
        var cmpTarget= component.find("dropZone");
        $A.util.removeClass(cmpTarget, 'active');
        var sprintTaskItems = component.get("v.sprintTaskItems");
        var theData = event.dataTransfer.getData("projectTask");
        if (theData !== null && theData !== "") {
            var projectTask = JSON.parse(theData);            
            var tableStatus = projectTask.AgouraFree__Status__c + (projectTask.AgouraFree__Blocked__c ? ' (Blocked)' : '');
            var assignedTo = '';
            if (projectTask.AgouraFree__Assigned_To__r != null) {
                assignedTo = projectTask.AgouraFree__Assigned_To__r.Name;
            }
            var sprintTaskItem = {
                projectId: projectTask.AgouraFree__Project__c,
                sprintId: component.get("v.recordId"),
                projectTaskId: projectTask.Id,
                taskName: projectTask.AgouraFree__Task_Number__c,
                title: projectTask.AgouraFree__Title__c,
                type: projectTask.AgouraFree__Formatted_Type__c,
                status: projectTask.AgouraFree__Status__c,
                formattedStatus: projectTask.AgouraFree__Formatted_Status__c,
                tag: "",
                points: projectTask.AgouraFree__Points__c,
                assignedTo: assignedTo,
                blocked: projectTask.AgouraFree__Blocked__c,
                tableStatus: tableStatus
            };
            sprintTaskItems.push(sprintTaskItem);
            helper.updateItem(component, sprintTaskItem,"AddItem");
            component.set("v.sprintTaskItems", sprintTaskItems);
            var projectTaskFilterChangeEvent = $A.get("e.c:ProjectTaskFilterChange");
            projectTaskFilterChangeEvent.fire();
            helper.loadAssignedToList(component, sprintId);
        }
    },
    dragOverHandler : function(component, event) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        event.preventDefault();
        var cmpTarget= component.find("dropZone");
        $A.util.addClass(cmpTarget, 'active');
    },
    dragLeaveHandler : function(component, event){  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        event.preventDefault();
        var cmpTarget= component.find("dropZone");
        $A.util.removeClass(cmpTarget, 'active');
    },
    sprintTaskItemStartHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintTaskItem = event.getParam("sprintTaskItem");
        helper.updateItem(component, sprintTaskItem, "Start");
    },
    sprintTaskItemCompleteHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintTaskItem = event.getParam("sprintTaskItem");
        helper.updateItem(component, sprintTaskItem, "Complete");
    },
    sprintTaskItemEditHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintTaskItem = event.getParam("sprintTaskItem");
        helper.editRecord(sprintTaskItem);
    },
    sprintTaskItemChangeSLHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintTaskItem = event.getParam("sprintTaskItem");
        var swimLaneId = event.getParam("swimLaneId");
        helper.updateSwimLane(component, sprintTaskItem, swimLaneId);
    },
    sprintTaskItemRemoveHandler : function(component, event, helper) {  
        var hasEditAccess = component.get('v.hasEditAccess');
        if (!hasEditAccess) {
            return null;
        }
        var sprintTaskItem = event.getParam("sprintTaskItem");
        helper.removeItem(component, sprintTaskItem, "Remove");
        var projectTaskFilterChangeEvent = $A.get("e.c:ProjectTaskFilterChange");
        projectTaskFilterChangeEvent.fire();
    },
    toggleListMode: function (component, event, helper) {       
        var iconName = event.getSource().get("v.iconName");
        component.set('v.isTileView', iconName === 'utility:apps');
    },
    refreshSprint : function (component, event, helper) {
        var recId = component.get("v.recordId"); 
        helper.refreshSprint(component, recId, "manual");
    },
    updateProjectTasksColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.projectTasksSortedBy", fieldName);
        component.set("v.projectTasksSortedDirection", sortDirection);
        helper.sortDataTable(component, fieldName, sortDirection,"v.sprintTaskItems");
    },
    handleProjectTasksRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var hasEditAccess = component.get('v.hasEditAccess'); 
        var hasRemoveAccess = component.get('v.hasRemoveAccess');
        var formattedStatus = row.formattedStatus;
        switch (action.name) {
            case 'view':
                helper.viewRecord(row); 
                break;
            default:
                if (!hasEditAccess) {
                    return null;
                }
                switch (action.name) {
                    case 'start':
                        if (formattedStatus == 'open') {
                            helper.updateItem(component, row, "Start");
                        } else {
                            helper.viewRecord(row); 
                        }
                        break;
                    case 'complete': 
                        if (formattedStatus == 'inprogress' || formattedStatus == 'readytotest' || formattedStatus == 'testing' || formattedStatus == 'readytodeploy') {
                            helper.updateItem(component, row, "Complete"); 
                        } else {
                            helper.viewRecord(row); 
                        }
                        break;
                    case 'remove':
                        if (!hasEditAccess) {
                            return null;
                        }
                        helper.removeItem(component, row, "Remove");
                        var projectTaskFilterChangeEvent = $A.get("e.c:ProjectTaskFilterChange");
                        projectTaskFilterChangeEvent.fire();
                        break;
                    default:
                        helper.viewRecord(row);
                        break;
                }
        }
    },
    onFirstPage: function(component, event, helper) {
        helper.loadProjectTasks(component, 1);
    },
    onPreviousPage: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        page = page - 1;
        helper.loadProjectTasks(component, page);
    },
    onNextPage: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        page = page + 1;
        helper.loadProjectTasks(component, page);
    },
    onLastPage: function(component, event, helper) {
        var page = component.get("v.pages") || 1;
        helper.loadProjectTasks(component, page);
    },
    filterChangeHandler: function(component, event, helper) {
        var filterObject = component.get("v.filterObject");
        if (event.getParam("searchKey") !== undefined) {
            filterObject.searchKey = event.getParam("searchKey");
        }
        if (event.getParam("typeKey") !== undefined) {
            filterObject.typeKey = event.getParam("typeKey");
        }
        helper.loadProjectTasks(component);
    },
    searchKeyChangeHandler : function(component, event) {
        var projectTaskFilterChangeEvent = $A.get("e.c:ProjectTaskFilterChange");
        projectTaskFilterChangeEvent.setParams({
            "searchKey": event.getParam("value")
        });
        projectTaskFilterChangeEvent.fire();
    },
    typeKeyChangeHandler : function(component, event) {
        var projectTaskFilterChangeEvent = $A.get("e.c:ProjectTaskFilterChange");
        projectTaskFilterChangeEvent.setParams({
            "typeKey": event.getParam("value")
        });
        projectTaskFilterChangeEvent.fire();
    },
    hideProjectBacklog : function (component, event, helper) {
        var cmpProjectBacklog = component.find("projectBacklog");
        $A.util.removeClass(cmpProjectBacklog, 'slds-show');
        $A.util.addClass(cmpProjectBacklog, 'slds-hide');        
        var cmpSprintDetails = component.find("sprintDetails");
        $A.util.removeClass(cmpSprintDetails, 'slds-large-size_8-of-12');
        $A.util.addClass(cmpSprintDetails, 'slds-large-size_12-of-12');
        var cmpSprintTasks = component.find("sprintTasks");
        $A.util.addClass(cmpSprintTasks, 'shrinkMarginTop');     
        var cmpHideButton = component.find("hideBacklogIcon");
        $A.util.removeClass(cmpHideButton, 'slds-show');
        $A.util.addClass(cmpHideButton, 'slds-hide');
        var cmpShowButton = component.find("showBacklogIcon");
        $A.util.removeClass(cmpShowButton, 'slds-hide');
        $A.util.addClass(cmpShowButton, 'slds-show');        
        component.set("v.showRemoveButton",false);       
    },
    showProjectBacklog : function (component, event, helper) {
        var cmpProjectBacklog = component.find("projectBacklog");
        $A.util.removeClass(cmpProjectBacklog, 'slds-hide');
        $A.util.addClass(cmpProjectBacklog, 'slds-show');        
        var cmpSprintDetails = component.find("sprintDetails");
        $A.util.removeClass(cmpSprintDetails, 'slds-large-size_12-of-12');
        $A.util.addClass(cmpSprintDetails, 'slds-large-size_8-of-12');        
        var cmpSprintTasks = component.find("sprintTasks");
        $A.util.removeClass(cmpSprintTasks, 'shrinkMarginTop'); 
        var cmpHideButton = component.find("hideBacklogIcon");
        $A.util.removeClass(cmpHideButton, 'slds-hide');
        $A.util.addClass(cmpHideButton, 'slds-show');
        var cmpShowButton = component.find("showBacklogIcon");
        $A.util.removeClass(cmpShowButton, 'slds-show');
        $A.util.addClass(cmpShowButton, 'slds-hide');       
        component.set("v.showRemoveButton",true);
    },
    newProjectTask : function (component, event, helper) {
        var recId = component.get("v.targetFields.AgouraFree__Project__c");
        window.open('/lightning/o/AgouraFree__ProjectTask__c/new?AgouraFree__project='+recId, '_blank');
    }
})
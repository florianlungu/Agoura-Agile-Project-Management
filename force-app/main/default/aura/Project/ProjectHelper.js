({
    checkAccess: function (component, recId) {
        var action = component.get("c.recordAccess");
        action.setParams({
            "recId": recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var hasEditAccess, hasDeleteAccess, hasDeleteSprintTaskAccess = false;
            if (result.hasEditAccess == true) {
                component.set("v.hasEditAccess", true);
                hasEditAccess = true;
            }
            if (result.hasDeleteAccess == true) {
                component.set("v.hasDeleteAccess", true);
                hasDeleteAccess = true;
            }
            if (result.hasTransferAccess == true) {
                component.set("v.hasTransferAccess", true);
            }
            if (result.hasDeleteSprintTaskAccess == true) {
                component.set("v.hasDeleteSprintTaskAccess", true);
                hasDeleteSprintTaskAccess = true;
            }
            
            this.setWebPageTitle(component, recId);  
            this.loadUsers(component, recId);
            this.loadTagList(component, recId);
            this.loadIdeaList(component, recId);
            this.loadAccountList(component, recId);    
            
            var actions = [{ label: 'View', name: 'view' }];
            var itemActions = [{ label: 'View', name: 'view' }];
            if (hasEditAccess == true) {
                actions.push({ label: 'Edit', name: 'edit' });
                itemActions.push({ label: 'Edit', name: 'edit' });
                itemActions.push({ label: 'Delete', name: 'delete' });
            }
            if (hasDeleteSprintTaskAccess) {
                actions.push({ label: 'Delete', name: 'delete' });
            }
                        
            this.loadFieldLabelMapSprints(component, recId, actions);
            this.loadFieldLabelMapTasks(component, recId, actions);
            this.loadFieldLabelMapItems(component, recId, itemActions);
        });
        $A.enqueueAction(action);
    },
    loadUsers: function (component, projectId) {
        var action = component.get("c.getUsers");
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
            var executiveSponsor = [];
            var productOwner = [];
            var scrumMaster = [];
            var owner = [];
            var createdBy = [];
            var lastModifiedBy = [];
            var readShareList = [];
            var editShareList = [];
            var canSortBacklog = false;
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].id,
                    sObjectType: result[i].sObjectType,
                    icon: result[i].icon,
                    title: result[i].title,
                    subtitle: result[i].sObjectType + ' • ' + result[i].title
                };
                if (result[i].subtitle == 'Executive Sponsor') {
                    executiveSponsor.push(resultItem);
                } else if (result[i].subtitle == 'Product Owner') {
                    productOwner.push(resultItem);
                    if(result[i].id == userId) {
                        canSortBacklog = true;
                    }
                } else if (result[i].subtitle == 'Scrum Master') {
                    scrumMaster.push(resultItem);
                    if(result[i].id == userId) {
                        canSortBacklog = true;
                    }
                } else if (result[i].subtitle == 'Owner') {
                    owner.push(resultItem);
                    editShareList.push(resultItem);
                } else if (result[i].subtitle == 'Created By') {
                    createdBy.push(resultItem);
                } else if (result[i].subtitle == 'Last Modified By') {
                    lastModifiedBy.push(resultItem);
                } else if (result[i].subtitle == 'Read Access') {
                    readShareList.push(resultItem);
                } else if (result[i].subtitle == 'Edit Access') {
                    editShareList.push(resultItem);
                }   
            }
            component.set("v.executiveSponsorList", executiveSponsor);
            component.set("v.productOwnerList", productOwner);
            component.set("v.scrumMasterList", scrumMaster);
            component.set("v.ownerList", owner);
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
            component.set("v.canSortBacklog", canSortBacklog);
            component.set("v.readAccessList", readShareList);
            component.set("v.editAccessList", editShareList);
        });
        $A.enqueueAction(action);
    },    
    loadTagList: function (component, projectId) {
        var action = component.get("c.getProjectTags");
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
            var projectTags = [];            
            for (var i = 0, len = result.length; i < len; i++) {
                var projectTag = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Tag__c',
                    icon: 'standard:topic',
                    title: result[i].Name,
                    subtitle: 'Tag • ' + result[i].Name
                };
                projectTags.push(projectTag);
            }
            component.set("v.tagList", projectTags);
        });
        $A.enqueueAction(action);
    },    
    loadIdeaList: function (component, projectId) {
        var action = component.get("c.getIdeaProjects");
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
            var ideaProjects = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var ideaProject = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__IdeaBoard__c',
                    icon: 'standard:solution',
                    title: result[i].AgouraFree__Title__c,
                    subtitle: 'Idea Board • ' + result[i].Name
                };
                ideaProjects.push(ideaProject);
            }
            component.set("v.ideaBoardList", ideaProjects);
        });
        $A.enqueueAction(action);
    },    
    loadAccountList: function (component, projectId) {
        var action = component.get("c.getRelatedAccount");
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
            var accounts = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var ideaProject = {
                    id: result[i].Id,
                    sObjectType: 'Account',
                    icon: 'standard:account',
                    title: result[i].Name,
                    subtitle: 'Account • ' + result[i].Id
                };
                accounts.push(ideaProject);
            }
            component.set("v.accountList", accounts);
        });
        $A.enqueueAction(action);
    }, 
    loadProjectGoals: function (component, projectId) {
        var action = component.get("c.getProjectGoals");
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
            var projectGoals = [];
            var projectMilestones = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].Id,
                    type: result[i].AgouraFree__Type__c,
                    title: result[i].AgouraFree__Title__c,
                    startDate: result[i].AgouraFree__Start_Date__c,
                    targetDate: result[i].AgouraFree__Target_Date__c,
                    progress: result[i].AgouraFree__Progress__c,
                    comments: result[i].AgouraFree__Comments__c
                };
                if (result[i].AgouraFree__Type__c == 'Project Goal') {
                    resultItem.goalIconName = 'action:new_campaign';
                } else { 
                    resultItem.goalIconName = 'action:priority';
                }  
                projectGoals.push(resultItem);
            }
            component.set("v.projectGoalsList", projectGoals);            
            component.set("v.projectMilestonesList", projectMilestones);     
        });
        $A.enqueueAction(action);
    },
    sortDataTable: function (cmp, fieldName, sortDirection, dataList) {
        var data = cmp.get(dataList);
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set(dataList, data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    viewRecord: function(row) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": row.id });
        navigateEvent.fire();
    },
    editRecord: function(row) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": row.id
        });
        editRecordEvent.fire();
    },
    removeProjectItem: function(component) { 
        var projectId = component.get("v.recordId");  
        var itemType = component.get("v.showConfirmDeleteWhat");
        var rowId = component.get("v.showConfirmDeleteWhatId");
        var action = component.get("c.removeProjectItem");
        action.setParams({
            "recId": rowId                    
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = itemType + " was deleted.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                if (itemType == 'Project Goal' || itemType == 'Project Milestone') {
                    this.loadProjectGoals(component, projectId);                    
                } else if (itemType == 'Project Link') {
                    this.loadProjectLinks(component, projectId);                    
                } else if (itemType == 'Project Risk') {
                    this.loadProjectRisks(component, projectId);                    
                } else if (itemType == 'Project Stakeholder' || itemType == 'Project Team Member') {
                    this.loadProjectStakeholders(component, projectId);                    
                } else if (itemType == 'Project Swim Lane') {
                    this.loadSwimLaneList(component, projectId);                    
                }
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();  
            }
            else if (state === "ERROR") {
                this.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    }, 
    loadProjectRisks: function (component, projectId) {
        var action = component.get("c.getProjectRisks");
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
            var projectRisks = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].Id,
                    title: result[i].AgouraFree__Title__c,
                    type: 'Project Risk',
                    probability: result[i].AgouraFree__Probability__c,
                    impact: result[i].AgouraFree__Impact__c,
                    status: result[i].AgouraFree__Status__c,
                    response: result[i].AgouraFree__Response__c
                };
                projectRisks.push(resultItem);                               
            }
            component.set("v.projectRisksList", projectRisks);               
        });
        $A.enqueueAction(action);
    }, 
    loadProjectStakeholders: function (component, projectId) {
        var action = component.get("c.getProjectStakeholders");
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
            var projectTeam = [];
            var projectStakeholders = [];
            var swimLane = '';
            for (var i = 0, len = result.length; i < len; i++) {
                if (result[i].AgouraFree__Swim_Lane__r == null) {
                    swimLane = '';
                } else {
                    swimLane = result[i].AgouraFree__Swim_Lane__r.AgouraFree__Title__c;
                }
                var resultItem = {
                    id: result[i].Id,                            
                    type: result[i].AgouraFree__Type__c,
                    swimLane: swimLane,
                    name: result[i].AgouraFree__User__r.Name,
                    title: result[i].AgouraFree__User__r.Title,
                    raci: result[i].AgouraFree__RACI__c
                };
                if (result[i].AgouraFree__Type__c == 'Project Team Member') {
                    projectTeam.push(resultItem);
                } else if (result[i].AgouraFree__Type__c == 'Project Stakeholder') {
                    projectStakeholders.push(resultItem);
                }                            
            }
            component.set("v.projectTeamList", projectTeam);
            component.set("v.projectStakeholdersList", projectStakeholders);               
        });
        $A.enqueueAction(action);
    },    
    loadSwimLaneList: function (component, projectId) {
        var action = component.get("c.getProjectSwimLanes");
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
            var swimLanes = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].Id,                    
                    type: 'Project Swim Lane',
                    title: result[i].AgouraFree__Title__c
                };
                swimLanes.push(resultItem);                               
            }
            component.set("v.projectSwimLanesList", swimLanes);               
        });
        $A.enqueueAction(action);
    }, 
    loadProjectSprints: function (component, projectId) {
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
            for (var i = 0, len = result.length; i < len; i++) {
                var status = "Closed";
                var today = new Date();
                today.setHours(0,0,0,0);
                var endDateStr = result[i].AgouraFree__End_Date__c;
                if (endDateStr != null) {
                    var endDate = new Date(endDateStr.substr(0,4), (endDateStr.substr(5,2)-1), endDateStr.substr(8,2));
                    if (endDate >= today || !result[i].AgouraFree__End_Date__c) {
                        status = "Open";
                    }
                }                
                var resultItem = {
                    id: result[i].Id,
                    type: 'Project Sprint',
                    sprintNum: result[i].AgouraFree__Sprint_Number__c,
                    targetPoints: result[i].AgouraFree__Target_Points__c,
                    completedPoints: result[i].AgouraFree__Completed_Points__c,
                    status: status,
                    startDate: result[i].AgouraFree__Start_Date__c,
                    endDate: result[i].AgouraFree__End_Date__c,
                    wentWell: result[i].AgouraFree__What_went_well__c,
                    notWell: result[i].AgouraFree__What_did_not_go_well__c,
                    doDifferent: result[i].AgouraFree__What_can_we_do_different_next_time__c
                };  
                projectSprints.push(resultItem);                               
            }
            component.set("v.projectSprintsList", projectSprints);
            component.set("v.projectRetrospectivesList", projectSprints);            
        });
        $A.enqueueAction(action);
    },    
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
            component.set("v.unassignedPoints", result.unassignedPoints);               
        });
        $A.enqueueAction(action);
    },
    removeProjectSprint: function(component) { 
        var projectId = component.get("v.recordId");  
        var rowId = component.get("v.showConfirmDeleteWhatId");
        var action = component.get("c.removeProjectSprint");
        action.setParams({
            "sprintId": rowId                    
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastMsg = "Project Sprint was deleted.";
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                this.loadProjectSprints(component, projectId); 
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();  
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            }
        });        
        $A.enqueueAction(action);        
    },	
    setWebPageTitle: function (component, projectId) {
        var action = component.get("c.getProjectTitle");
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
            for (var i = 0, len = result.length; i < len; i++) {
                document.title = result[i].AgouraFree__Title__c;
                component.set("v.windowTitle", document.title);           
            }
        });
        $A.enqueueAction(action);
    }, 
    loadProjectLinks: function (component, projectId) {
        var action = component.get("c.getProjectLinks");
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
            var projectLinks = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var owner = '';
                if (result[i].AgouraFree__User__r != null) {
                    owner = result[i].AgouraFree__User__r.Name;
                } 
                var resultItem = {
                    id: result[i].Id,                    
                    type: 'Project Link',
                    title: result[i].AgouraFree__Title__c,
                    url: result[i].AgouraFree__URL__c,
                    owner: owner
                };
                projectLinks.push(resultItem);                               
            }
            component.set("v.projectLinksList", projectLinks);               
        });
        $A.enqueueAction(action);
    },
    confirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteWhat", "Project");
        component.set("v.showConfirmDeleteModal", true);
    },
    confirmClone: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Clone Project");
        component.set("v.showConfirmAsk", "What do you want to include in the project clone?");
        component.set("v.showConfirmAskMore", "Each item will be limited to 1000 of each type.")
        component.set("v.showConfirmModal", true);
    },
    confirmChangeOwner: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Change Owner");
        component.set("v.showConfirmAsk", "Select a new owner of this project and it's related records."
                      + " Note: Salesforce will automatically clear the additional read and edit access list"
                      + " when the Record Owner changes.");
        component.set("v.showConfirmModal", true);
    },
    doRefreshChatterFeed: function(component) {
        var recId = component.get("v.recordId");  
        $A.createComponent("forceChatter:feed", {"type": "record", "subjectId" : recId}, function(recordFeed) {
            if (component.isValid()) {
                var feedContainer = component.find("feedContainer");
                feedContainer.set("v.body", recordFeed);
            }            
        });
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
    },
    validateFields: function (component, fieldList) {
        var allGood = true;
        for (var i = 0; i < fieldList.length; i++) {          
            var inputField = component.find(fieldList[i]);
            if (inputField.get('v.validity').valid == false) {
                inputField.showHelpMessageIfInvalid();
                allGood = false;
            }            
        }        
        return allGood;
    },
    isChatterEnabled: function (component) {
        var action = component.get("c.checkChatterEnabled");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.chatterEnabled", result);
        });
        $A.enqueueAction(action);
    },
    loadFieldLabelMap: function (component) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Status__c", "AgouraFree__Executive_Sponsor__c", "AgouraFree__Product_Owner__c", "AgouraFree__Scrum_Master__c", 
                         "AgouraFree__Mission_Statement__c", "AgouraFree__Product__c", "AgouraFree__Deliverables__c", "AgouraFree__KPIs__c", "AgouraFree__Value_Trackers__c", 
                         "AgouraFree__Assumptions__c", "AgouraFree__Constraints__c", "AgouraFree__Comments__c", "AgouraFree__Project_Abbreviation__c",
                         "AgouraFree__IsTemplate__c"];
        action.setParams({
            "objectName": "AgouraFree__Project__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            component.set('v.fieldLabelMap',response.getReturnValue());  
        });
        $A.enqueueAction(action);
    },
    loadFieldLabelMapSprints: function (component, recId, actions) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Sprint_Number__c", "AgouraFree__Target_Points__c", "AgouraFree__Completed_Points__c", "AgouraFree__Start_Date__c", 
                         "AgouraFree__End_Date__c", "AgouraFree__What_went_well__c", "AgouraFree__What_did_not_go_well__c", 
                         "AgouraFree__What_can_we_do_different_next_time__c"];
        action.setParams({
            "objectName": "AgouraFree__Sprint__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            var fieldLabelMap = response.getReturnValue();            
            var retrospectivesColumns = [
                {label: fieldLabelMap.AgouraFree__Sprint_Number__c, fieldName: 'sprintNum', type: 'number', sortable: false, initialWidth: 150, 
                 cellAttributes: { alignment: 'left' }},                
                {label: fieldLabelMap.AgouraFree__What_went_well__c, fieldName: 'wentWell', type: 'text', sortable: false},
                {label: fieldLabelMap.AgouraFree__What_did_not_go_well__c, fieldName: 'notWell', type: 'text', sortable: false},
                {label: fieldLabelMap.AgouraFree__What_can_we_do_different_next_time__c, fieldName: 'doDifferent', type: 'text', sortable: false},
                {type: 'action', typeAttributes: {rowActions: actions} }                
            ]; 
            component.set("v.projectRetrospectivesColumns", retrospectivesColumns);
            var sprintsColumns = [
                {label: fieldLabelMap.AgouraFree__Sprint_Number__c, fieldName: 'sprintNum', type: 'number', sortable: true, 
                 cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMap.AgouraFree__Target_Points__c, fieldName: 'targetPoints', type: 'number', sortable: true, 
                 cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMap.AgouraFree__Completed_Points__c, fieldName: 'completedPoints', type: 'number', sortable: true, 
                 cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMap.AgouraFree__Start_Date__c, fieldName: 'startDate', type: 'date-local', sortable: true},
                {label: fieldLabelMap.AgouraFree__End_Date__c, fieldName: 'endDate', type: 'date-local', sortable: true},
                {type: 'action', typeAttributes: {rowActions: actions} }                
            ]; 
            component.set("v.projectSprintsColumns", sprintsColumns);
            this.loadProjectSprints(component, recId); 
        });
        $A.enqueueAction(action);
    },
    loadFieldLabelMapTasks: function (component) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Title__c", "AgouraFree__Type__c", "AgouraFree__Status__c", "AgouraFree__Points__c", "AgouraFree__Due_Date__c", 
                         "AgouraFree__Priority__c", "AgouraFree__Assigned_To__c", "AgouraFree__Order__c"];
        action.setParams({
            "objectName": "AgouraFree__ProjectTask__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            component.set('v.fieldLabelMapTasks',response.getReturnValue());  
        });
        $A.enqueueAction(action);
    },
    loadFieldLabelMapItems: function (component, recId, itemActions) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Type__c", "AgouraFree__Title__c", "AgouraFree__Start_Date__c", "AgouraFree__Target_Date__c", "AgouraFree__Progress__c", 
                         "AgouraFree__Comments__c", "AgouraFree__Status__c", "AgouraFree__Probability__c", "AgouraFree__Impact__c", "AgouraFree__Response__c", 
                         "AgouraFree__User__c", "AgouraFree__RACI__c", "AgouraFree__URL__c"];
        action.setParams({
            "objectName": "AgouraFree__ProjectItem__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            var fieldLabelMap = response.getReturnValue();  
            component.set('v.fieldLabelMapItems',fieldLabelMap);  
            
            var goalsColumns = [
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true, 
                 cellAttributes: { iconName: {fieldName: 'goalIconName'} }},
                {label: fieldLabelMap.AgouraFree__Start_Date__c, fieldName: 'startDate', type: 'date-local', initialWidth: 150, sortable: true},
                {label: fieldLabelMap.AgouraFree__Target_Date__c, fieldName: 'targetDate', type: 'date-local', initialWidth: 150, sortable: true},
                {label: fieldLabelMap.AgouraFree__Progress__c, fieldName: 'progress', type: 'number', initialWidth: 150, sortable: true, 
                 cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMap.AgouraFree__Comments__c, fieldName: 'comments', type: 'text', sortable: false},
                {type: 'action', typeAttributes: {rowActions: itemActions} }               
            ];
            component.set("v.projectGoalsColumns", goalsColumns);
            this.loadProjectGoals(component, recId);
            
            var risksColumns = [
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true, 
                 cellAttributes: { iconName: 'standard:dashboard' }},
                {label: fieldLabelMap.AgouraFree__Status__c, fieldName: 'status', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMap.AgouraFree__Probability__c, fieldName: 'probability', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMap.AgouraFree__Impact__c, fieldName: 'impact', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMap.AgouraFree__Response__c, fieldName: 'response', type: 'text', sortable: true},
                {type: 'action', typeAttributes: {rowActions: itemActions} }               
            ];
            component.set("v.projectRisksColumns", risksColumns);
            this.loadProjectRisks(component, recId); 
            
            this.loadSwimLaneList(component, recId); 
            var swimLaneColumns = [
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: false, 
                 cellAttributes: { iconName: 'action:flow' }},
                {type: 'action', typeAttributes: {rowActions: itemActions} }                  
            ]; 
            component.set("v.projectSwimLanesColumns", swimLaneColumns);
            
            var stakeholderColumns = [
                {label: 'Name', fieldName: 'name', type: 'text', sortable: true, 
                 cellAttributes: { iconName: 'standard:avatar'}},                               
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},                
                {label: fieldLabelMap.AgouraFree__RACI__c, fieldName: 'raci', type: 'text', sortable: true},       
                {type: 'action', typeAttributes: {rowActions: itemActions} }                
            ];
            component.set("v.projectStakeholdersColumns", stakeholderColumns);            
            var teamColumnsPlus = [
                {label: 'Swim Lane', fieldName: 'swimLane', type: 'text', initialWidth: 250, sortable: true},   
                {label: 'Name', fieldName: 'name', type: 'text', sortable: true,  
                 cellAttributes: { iconName: 'standard:avatar'}},                                    
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},     
                {type: 'action', typeAttributes: {rowActions: itemActions} }                    
            ];           
            var teamColumns = [ 
                {label: 'Name', fieldName: 'name', type: 'text', sortable: true, 
                 cellAttributes: { iconName: 'standard:avatar'}},                                     
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},     
                {type: 'action', typeAttributes: {rowActions: itemActions} }                    
            ];           
            component.set("v.projectTeamColumns", teamColumns);            
            component.set("v.projectTeamColumnsPlus", teamColumnsPlus);
            this.loadProjectStakeholders(component, recId);   
            
            var linksColumns = [
                {label: fieldLabelMap.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},
                {label: fieldLabelMap.AgouraFree__URL__c, fieldName: 'url', type: 'url', sortable: true},
                {label: 'Product Link Owner', fieldName: 'owner', type: 'text', initialWidth: 300, sortable: true},
                {type: 'action', typeAttributes: {rowActions: itemActions} }               
            ];
            component.set("v.projectLinksColumns", linksColumns);
            this.loadProjectLinks(component, recId); 
        });
        $A.enqueueAction(action);
    }
})
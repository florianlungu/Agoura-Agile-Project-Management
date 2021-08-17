({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
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
            for (var i = 0, len = result.length; i < len; i++) {
                if (result[i].HasEditAccess == true) {
                    component.set("v.hasEditAccess", true);
                }
                if (result[i].HasDeleteAccess == true) {
                    component.set("v.hasDeleteAccess", true);
                }
            } 
        });
        $A.enqueueAction(action);
    },	
    setWebPageTitle: function (component, recId) {        
        var action = component.get("c.getWebPageTitle");
        action.setParams({
            "recId": recId
        });
        var status = '';
        var timeEst = '';
        var timeLogged = '';
        var timeRemaining = '';
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            for (var i = 0, len = result.length; i < len; i++) {
                document.title = result[i].AgouraFree__Task_Number__c + " " + result[i].AgouraFree__Title__c;  
                component.set("v.windowTitle", document.title);               
                status = result[i].AgouraFree__Status__c;
                timeEst = result[i].AgouraFree__Time_Estimate__c;
                timeLogged = result[i].AgouraFree__Time_Logged__c;
                timeRemaining = result[i].AgouraFree__Time_Remaining__c;
            }
            if (status == 'In Progress' || status == 'Ready to Test' || status == 'Testing' || status == 'Ready to Deploy') {
                component.set("v.showCompleteButton", true);   
            }         
            component.set("v.timeEst", this.convertTimeToString(timeEst));
            component.set("v.timeLogged", this.convertTimeToString(timeLogged));
            component.set("v.timeRemaining", this.convertTimeToString(timeRemaining));
        });
        $A.enqueueAction(action);        
    },
    loadUsers: function (component, recId) {
        var action = component.get("c.getUsers");
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
            var createdBy = [];
            var lastModifiedBy = [];
            var assignedTo = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].id,
                    sObjectType: result[i].sObjectType,
                    icon: result[i].icon,
                    title: result[i].title,
                    subtitle: result[i].sObjectType + ' • ' + result[i].title
                };
                if (result[i].subtitle == 'Created By') {
                    createdBy.push(resultItem);
                } else if (result[i].subtitle == 'Last Modified By') {
                    lastModifiedBy.push(resultItem);
                } else if (result[i].subtitle == 'Assigned To') {
                    assignedTo.push(resultItem);
                }                
            }
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
            component.set("v.assignedToSelection", assignedTo);
        });
        $A.enqueueAction(action);
    },    
    loadProject: function (component, recId) {
        var action = component.get("c.getProject");
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
            var projects = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var project = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: result[i].AgouraFree__Title__c,
                    subtitle: 'Project • ' + result[i].Name
                };
                projects.push(project);
            }
            component.set("v.projectSelection", projects);
            component.set("v.cloneProjectSelection", projects);
        });
        $A.enqueueAction(action);
    },    
    loadSprint: function (component, recId) {
        var action = component.get("c.getSprint");
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
            var sprints = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var sprint = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Sprint__c',
                    icon: 'standard:work_order',
                    title: result[i].AgouraFree__Sprint_Name__c,
                    subtitle: 'Sprint • ' + result[i].Name
                };
                sprints.push(sprint);
            }
            component.set("v.sprintSelection", sprints);
        });
        $A.enqueueAction(action);
    },    
    loadMasterTask: function (component, recId) {
        var action = component.get("c.getMasterTask");
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
            var tasks = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var gotMasterTask = result[i].AgouraFree__Master_Task__c;
                if (!(gotMasterTask == null || gotMasterTask == '')){
                    var task = {
                        id: result[i].AgouraFree__Master_Task__c,
                        sObjectType: 'AgouraFree__ProjectTask__c',
                        icon: 'standard:task',
                        title: result[i].AgouraFree__Master_Task__r.AgouraFree__Task_Number__c,
                        subtitle: 'Project Task • ' + result[i].AgouraFree__Master_Task__r.Name
                    };
                    tasks.push(task);
                }
            }
            component.set("v.masterTaskSelection", tasks);
        });
        $A.enqueueAction(action);
    },    
    loadSubTasks: function (component, recId) {
        var action = component.get("c.getSubTasks");
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
            var tasks = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var task = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__ProjectTask__c',
                    icon: 'standard:task',
                    title: result[i].AgouraFree__Task_Number__c,
                    subtitle: 'Project Task • ' + result[i].Name
                };
                tasks.push(task);
            }
            component.set("v.subTasksSelection", tasks);
        });
        $A.enqueueAction(action);
    },    
    loadAccountList: function (component, recId) {
        var action = component.get("c.getRelatedAccount");
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
    loadTagList: function (component, projectTaskId) {
        var action = component.get("c.getProjectTaskTags");
        action.setParams({
            "projectTaskId": projectTaskId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var projectTaskTags = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var projectTaskTag = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Tag__c',
                    icon: 'standard:topic',
                    title: result[i].Name,
                    subtitle: 'Tag • ' + result[i].Name
                };
                projectTaskTags.push(projectTaskTag);
            }
            component.set("v.tagList", projectTaskTags);
        });
        $A.enqueueAction(action);
    },
    convertTimeToString: function(timeStr) {
        if (timeStr == null || timeStr == '') {
            return null;
        }
        var result = '';
        var integer = parseInt(timeStr, 10);
        if (integer >= 60) {
            var tmpInt = integer/60;
            var tmpStr = tmpInt.toString();
            result += parseInt(tmpStr, 10) + 'h ';
            integer = integer - (parseInt(tmpStr, 10)*60);
        }
        if (integer > 0) {
            result += integer + 'm ';
        }
        result = result.trim();        
        return result;
    },
    assignToMe : function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.doAssignToMe");
        action.setParams({"taskId": taskId});
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  "Project Task updated", "type": "success"});
                resultsToast.fire();
                window.location.reload();
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            }
        });
        $A.enqueueAction(action);
    },
    confirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", true);
    },
    updateTasksPlusSprint: function (component, projectId, sprintId) {
        var action = component.get("c.updateOrderCompletedPoints");
        action.setParams({
            "projectId": projectId,
            "sprintId": sprintId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Project ' + projectId + ' task sort order & sprint completed points successfully updated');
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            }
        });
        $A.enqueueAction(action); 
    },
    updateTasks: function (component, projectId) {
        var action = component.get("c.updateOrder");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Project ' + projectId + ' task sort order updated');
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
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
    },
    loadChatterFeed: function(component) {
        var action = component.get("c.checkChatterEnabled");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.chatterEnabled", result);
            if (result) {
                var recId = component.get("v.recordId");  
                $A.createComponent("forceChatter:feed", {"type": "record", "subjectId" : recId}, function(recordFeed) {
                    if (component.isValid()) {
                        var feedContainer = component.find("feedContainer");
                        feedContainer.set("v.body", recordFeed);
                    }            
                }); 
            }
        });
        $A.enqueueAction(action);        
    },
    confirmClone: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Clone Project Task");
        component.set("v.showConfirmAsk", "Select the project to clone the project task to:");
        component.set("v.showConfirmModal", true);
    },
    confirmMove: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Move Project Task");
        component.set("v.showConfirmAsk", "Select the project to move the project task to:");
        component.set("v.showConfirmModal", true);
    },
    loadFieldLabelMap: function (component) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Title__c", "AgouraFree__Type__c", "AgouraFree__Status__c", "AgouraFree__Points__c", "AgouraFree__Due_Date__c", 
                         "AgouraFree__Priority__c", "AgouraFree__Assigned_To__c", "AgouraFree__Order__c", "AgouraFree__Summary__c", "AgouraFree__Description__c", 
                         "AgouraFree__Reported_Date__c", "AgouraFree__Reported_By__c", "AgouraFree__Blocked__c", "AgouraFree__Product_Owner__c", 
                         "AgouraFree__Swim_Lane__c", "AgouraFree__Value__c", "AgouraFree__Bug_Type__c", "AgouraFree__Accept__c", "AgouraFree__Project_Team__c", 
                         "AgouraFree__Start_Date__c", "AgouraFree__Master_Task__c", "AgouraFree__End_Date__c", "AgouraFree__Affected_Version__c", 
                         "AgouraFree__Time_Estimate__c", "AgouraFree__Version__c", "AgouraFree__Time_Logged__c", "AgouraFree__Fix_Version__c", 
                         "AgouraFree__Time_Remaining__c", "AgouraFree__Resolution__c", "AgouraFree__Resolved_Date__c", "AgouraFree__Components__c", 
                         "AgouraFree__Dependencies__c", "AgouraFree__Comments__c", "AgouraFree__Sub_Tasks__c", "AgouraFree__URL__c"];
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
            component.set('v.fieldLabelMap',response.getReturnValue());  
        });
        $A.enqueueAction(action);
    },
    doRefreshChatterFeed: function(component) {
        var recId = component.get("v.recordId");  
        $A.createComponent("forceChatter:feed", {"type": "record", "subjectId" : recId}, function(recordFeed) {
            if (component.isValid()) {
                var feedContainer = component.find("feedContainer");
                feedContainer.set("v.body", recordFeed);
            }            
        });
    }
})
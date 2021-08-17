({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({"recordId": recId});
        navEvt.fire();
    },    
    hasEditAccess: function (component, recId) {
        var action = component.get("c.recordAccess");
        action.setParams({"recId": recId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var userAccess = false;
            for (var i = 0, len = result.length; i < len; i++) {
                if (result[i].HasEditAccess == true) {
                    userAccess = true;
                }
            }
            if (userAccess == false) {
                var toastMsg = "Edit access denied to record id " + recId;
                console.log(toastMsg);
                component.set("v.recordError", toastMsg); 
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "error"});
                resultsToast.fire();
                this.doCancel(component);
            } else {   
                component.set("v.hasEditAccess", true);
                component.set("v.modalContext", "Edit");
                this.setWebPageTitle(component, recId);
                this.loadProject(component, recId); 
                this.loadSprint(component, recId); 
                this.loadMasterTask(component, recId); 
                this.loadSubTasks(component, recId); 
                this.loadUsers(component, recId);  
                this.loadAccountList(component, recId);
                this.loadTagList(component, recId);
            }
        });
        $A.enqueueAction(action);
    },
    hasCreateAccess: function (component) {
        var action = component.get("c.createAccess");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            if (result == false) {
                var toastMsg = "Create access denied";
                console.log(toastMsg);
                component.set("v.recordError", toastMsg); 
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "error"});
                resultsToast.fire();
                this.doCancel(component);
            } else {   
                component.set("v.hasEditAccess", true);
                component.find("forceRecord").getNewRecord(
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
                var myPageRef = component.get("v.pageReference");
                var projectId = myPageRef.state.AgouraFree__project;
                this.loadDefaultProject(component, projectId);  
                document.title = "New Project Task";
                component.set("v.windowTitle", document.title); 
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__ProjectTask__c"});
            homeEvt.fire();
        } else {
            this.navigateTo(component, recId);
        }
    },	
    setWebPageTitle: function (component, recId) {   
        var fieldValue = '';
        var action = component.get("c.getWebPageTitle");
        action.setParams({
            "recId": recId
        });
        var isBug = false;
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
                document.title = "Edit " + result[i].AgouraFree__Task_Number__c;
                component.set("v.windowTitle", document.title);
                component.set("v.blockedValue", (result[i].AgouraFree__Blocked__c ? 'Yes' : ''));
                if (result[i].AgouraFree__Type__c == "Bug") {
                    isBug = true; 
                } 
                fieldValue = result[i].AgouraFree__Type__c;
                timeEst = result[i].AgouraFree__Time_Estimate__c;
                timeLogged = result[i].AgouraFree__Time_Logged__c;
                timeRemaining = result[i].AgouraFree__Time_Remaining__c;
            }
            if (isBug) {
                this.showHide(component,"propBugType","Show");
                this.showHide(component,"propResolution","Show");
                this.showHide(component,"propResolvedDate","Show");
                this.showHide(component,"propNormalStatus","Hide");
                this.showHide(component,"propBugStatus","Show");
            } else {
                this.showHide(component,"propBugType","Hide");
                this.showHide(component,"propResolution","Hide");
                this.showHide(component,"propResolvedDate","Hide");
                this.showHide(component,"propNormalStatus","Show");
                this.showHide(component,"propBugStatus","Hide");            
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
                    subtitle: result[i].sObjectType + ' â€¢ ' + result[i].title
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
                    subtitle: 'Project â€¢ ' + result[i].Name
                };
                projects.push(project);
            }
            component.set("v.projectSelection", projects);            
            if (projects.length > 0) {
                this.loadSwimLaneList(component, projects[0].id);
            }
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
                    subtitle: 'Sprint â€¢ ' + result[i].Name
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
                        subtitle: 'Project Task â€¢ ' + result[i].AgouraFree__Master_Task__r.Name
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
                    subtitle: 'Project Task â€¢ ' + result[i].Name
                };
                tasks.push(task);
            }
            component.set("v.subTasksSelection", tasks);
        });
        $A.enqueueAction(action);
    },
    joinArray : function(value){
        if(value == null) return null;        
        if(Array.isArray(value) == false) return value;        
        return value.join(';');
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
                    subtitle: 'Tag â€¢ ' + result[i].Name
                };
                projectTaskTags.push(projectTaskTag);
            }
            component.set("v.tagList", projectTaskTags);
            component.set("v.tagSelection", projectTaskTags);
        });
        $A.enqueueAction(action);
    },  
    updateProjectTaskTags: function (component, projectTaskId) {
        var tagSelection = component.get("v.tagSelection");
        var tagList = component.get("v.tagList");
        
        // add project tag
        for (var x = 0; x < tagSelection.length; x++) {
            var found = false;
            for (var y = 0; y < tagList.length; y++) {
                if (tagSelection[x].id === tagList[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.addProjectTaskTag");
                action.setParams({
                    "tagId": tagSelection[x].id,
                    "projectTaskId": projectTaskId
                });
                $A.enqueueAction(action);
            }
        }
        
        // remove project tag
        for (var x = 0; x < tagList.length; x++) {
            var found = false;
            for (var y = 0; y < tagSelection.length; y++) {
                if (tagList[x].id === tagSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeProjectTaskTag");
                action.setParams({
                    "tagId": tagList[x].id,
                    "projectTaskId": projectTaskId
                });
                $A.enqueueAction(action);
            }
        }        
    }, 
    loadDefaultProject: function (component, recId) {
        var action = component.get("c.getDefaultProject");
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
                    subtitle: 'Project â€¢ ' + result[i].Name
                };
                projects.push(project);
            }
            component.set("v.projectSelection", projects);
            if (projects.length > 0) {
                this.loadSwimLaneList(component, projects[0].id);
            }
        });
        $A.enqueueAction(action);
    },
    showHide: function(component, componentName, actionName) {
        var cmpDetails = component.find(componentName);
        if (actionName == "Show") {
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show');
        } else {
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide');
        }
    },
    updatePostSave: function(component, recId, oldSprintId) {
        var action = component.get("c.saveProjectTaskData");
        action.setParams({
            "recId": recId,
            "oldSprintId": oldSprintId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                var updatedRecord = response.getReturnValue();
                var toastMsg = "Project Task " + updatedRecord.AgouraFree__Task_Number__c + " was saved.";
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();                 
                var recId = updatedRecord.Id;
                window.location = '/lightning/r/AgouraFree__ProjectTask__c/'+recId+'/view';
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            } else {
                console.log("Unknown error");
            }
        });        
        $A.enqueueAction(action);   
    },
    convertToTime: function(timeStr) {
        // function returns timeStr in minutes
        if (timeStr == null || timeStr == '') {
            return null;
        }
        var result = 0; 
        var timeArray = timeStr.split(' ');
        var valuesEntered = timeArray.length;
        var str = '';
        for (var i = 0; i < valuesEntered; i++) {
            str = timeArray[i].toString();
            str = str.toLowerCase();
            var justNumbers = str.replace(/(?!-)[^0-9.]/g, '');
            if (str.includes("h")) {
                result += justNumbers * 60;
            } else if (str.includes("m")) {
                result += parseInt(justNumbers);
            }
        }
        return result;        
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
    doTimeUpdate : function(component) { 
        var propAddTime = document.getElementById("propAddTime").value;
        var timeRemaining = component.get("v.timeRemaining");
        if (propAddTime != null && propAddTime != '') {
            var timeLogged = component.get("v.timeLogged");
            if (timeLogged == null || timeLogged == '') {
                component.set("v.timeLogged", propAddTime);
            } else {
                var timeLoggedNum = this.convertToTime(timeLogged) + this.convertToTime(propAddTime); 
                component.set("v.timeLogged", this.convertTimeToString(timeLoggedNum));
            }
        }        
        if (document.getElementById("propRemainingTimeRadio1").checked) {
            if (propAddTime != null && propAddTime != '') {
                if (timeRemaining != null && timeRemaining != '') {
                    var newTimeRemaining = this.convertToTime(timeRemaining) - this.convertToTime(propAddTime);
                    component.set("v.timeRemaining", this.convertTimeToString(newTimeRemaining));
                }
            }
        } else if (document.getElementById("propRemainingTimeRadio3").checked) {
            var propSetTimeRemaining = document.getElementById("propSetTimeRemaining").value;
            if (propSetTimeRemaining != null && propSetTimeRemaining != '') {
                var propSetTimeRemainingNum = this.convertToTime(propSetTimeRemaining);
                component.set("v.timeRemaining", this.convertTimeToString(propSetTimeRemainingNum));
            }
        } else if (document.getElementById("propRemainingTimeRadio4").checked) {
            var propReduceTimeRemaining = document.getElementById("propReduceTimeRemaining").value;
            if (propReduceTimeRemaining != null && propReduceTimeRemaining != '') {
                if (timeRemaining != null && timeRemaining != '') {
                    var newTimeRemaining2 = this.convertToTime(timeRemaining) - this.convertToTime(propReduceTimeRemaining);
                    component.set("v.timeRemaining", this.convertTimeToString(newTimeRemaining2)); 
                }
            }
        }        
        component.find('propAddTime').set("v.value","");
        component.find('propSetTimeRemaining').set("v.value","");
        component.find('propReduceTimeRemaining').set("v.value","");      
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
                    title: result[i].AgouraFree__Title__c
                };
                swimLanes.push(resultItem);                               
            }
            component.set("v.projectSwimLanesList", swimLanes);  
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
                    subtitle: 'Account â€¢ ' + result[i].Id
                };
                accounts.push(ideaProject);
            }
            component.set("v.accountList", accounts);
            component.set("v.accountSelection", accounts);
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
    isDesktop: function (component) {
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
            var result = {
                topDiv: 'slds-modal slds-fade-in-open',
                secondDiv: 'modal-container slds-modal__container',
                headerDiv: 'slds-modal__header',
                mainDiv: 'slds-modal__content slds-p-around_medium slds-grid slds-wrap',
                footerDiv: 'slds-modal__footer'
            };
            component.set("v.formStyle", result);
        } else {
            var result = {
                topDiv: '',
                secondDiv: '',
                headerDiv: 'slds-p-around_medium slds-align_absolute-center',
                mainDiv: 'slds-p-around_medium slds-grid slds-wrap',
                footerDiv: 'slds-p-around_medium'
            };
            component.set("v.formStyle", result);
        }
    },
    chatterFeedPost: function(component, recId) {
        var newPost = {
            sObjectType: 'FeedItem',
            ParentId: recId,
            Type: 'TextPost',
            IsRichText: true,
            Body: component.find('chatterTextPostField').get("v.value")
        };        
        var action = component.get("c.doChatterFeedPost");
        action.setParams({"newPost": newPost});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                return;
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            } else {
                console.log("Unknown error");
            }
        });        
        $A.enqueueAction(action);   
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
    }
})
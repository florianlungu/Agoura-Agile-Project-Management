({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
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
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    userAccess = true;
                }
            });
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
                this.loadUsers(component, recId);   
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
                    "AgouraFree__ProjectItem__c",
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
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        if(projectId == null || projectId == '') {
            if (!recId) {
                var homeEvt = $A.get("e.force:navigateToObjectHome");
                homeEvt.setParams({"scope": "AgouraFree__Project__c"});
                homeEvt.fire();
            } else {this.navigateTo(component, recId);}            
        } else {this.navigateTo(component, projectId);}
    },	
    setWebPageTitle: function (component, recId) {        
        var action = component.get("c.getWebPageTitle");
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
            if (result != null) {
                var typeStr = result.AgouraFree__Type__c;
                var imageStr = '';
                var isUserType = false;
                var userTypes = ["Executive Sponsor", "Product Owner", "Project Document Owner", 
                                 "Project Stakeholder", "Project Team Member", "Scrum Master"];
                if (typeStr == 'Project Document Owner') {
                    document.title = "Edit Project Record Owner";                    
                } else {
                    document.title = "Edit " + typeStr;
                }
                
                if (typeStr == 'Project Goal' || typeStr == 'Project Milestone') {
                    imageStr = 'action:new_campaign';
                } else if (typeStr == 'Project Link') {
                    imageStr = 'action:web_link';
                } else if (typeStr == 'Project Risk') {
                    imageStr = 'standard:dashboard';
                } else if (typeStr == 'Project Swim Lane') {
                    imageStr = 'action:flow';   
                } else if (userTypes.indexOf(typeStr) > -1) {
                    isUserType = true;
                }                
                component.set("v.itemImage", imageStr);
                component.set("v.windowTitle", document.title); 
                component.set("v.isUserType", isUserType); 
            }
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
            var userSelection = [];
            result.forEach(function(item) {
                var result = {
                    id: item.id,
                    sObjectType: item.sObjectType,
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.sObjectType + ' • ' + item.title
                };
                if (item.subtitle == 'Created By') {
                    createdBy.push(result);
                } else if (item.subtitle == 'Last Modified By') {
                    lastModifiedBy.push(result);
                } else if (item.subtitle == 'AgouraFree__User__c') {
                    userSelection.push(result);
                }                
            });
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
            component.set("v.userSelection", userSelection);
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
            if (result != null) {
                var project = {
                    id: result.Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: result.AgouraFree__Title__c,
                    subtitle: 'Project • ' + result.Name
                };
                component.set("v.projectSelection", project);
                this.loadSwimLaneList(component, result.Id); 
            }
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
            result.forEach(function(item) {
                var resultItem = {
                    id: item.Id,
                    title: item.AgouraFree__Title__c
                };
                swimLanes.push(resultItem);                               
            });
            component.set("v.projectSwimLanesList", swimLanes);  
        });
        $A.enqueueAction(action);
    },
    showError: function (errMessage) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({"message":  errMessage, "type": "error"});
        resultsToast.fire();  
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
    loadFieldLabelMap: function (component) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Type__c", "AgouraFree__Title__c", "AgouraFree__Start_Date__c", "AgouraFree__Target_Date__c", "AgouraFree__Progress__c", 
                         "AgouraFree__Comments__c", "AgouraFree__Status__c", "AgouraFree__Probability__c", "AgouraFree__Impact__c", "AgouraFree__Response__c", 
                         "AgouraFree__User__c", "AgouraFree__RACI__c", "AgouraFree__URL__c", "AgouraFree__Description__c"];
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
            component.set('v.fieldLabelMap',response.getReturnValue());  
        });
        $A.enqueueAction(action);
    }
})
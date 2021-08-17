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
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    component.set("v.hasEditAccess", true);
                }
                if (item.HasDeleteAccess == true) {
                    component.set("v.hasDeleteAccess", true);
                }
            });    
        });
        $A.enqueueAction(action);
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
                    document.title = "Project Record Owner: " + result.AgouraFree__Title__c;                    
                } else {
                    document.title = typeStr + ": " + result.AgouraFree__Title__c;
                }
                if (typeStr == 'Project Goal') {
                    imageStr = 'action:new_campaign';
                } else if (typeStr == 'Project Milestone') {
                    imageStr = 'action:priority';
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
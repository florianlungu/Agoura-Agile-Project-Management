({
    loadIdeaTagList: function (component, ideaId) {
        var action = component.get("c.getIdeaTags");
        action.setParams({
            "ideaId": ideaId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var ideaTags = [];
            result.forEach(function(item) {
                var ideaTag = {
                    id: item.Id,
                    sObjectType: 'AgouraFree__Tag__c',
                    icon: 'standard:topic',
                    title: item.Name,
                    subtitle: 'Tag • ' + item.Name
                };
                ideaTags.push(ideaTag);
            });
            component.set("v.ideaTagList", ideaTags);
        });
        $A.enqueueAction(action);
    },
    loadIdeaProjectList: function (component, ideaId) {
        var action = component.get("c.getIdeaProjects");
        action.setParams({
            "ideaId": ideaId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var ideaProjects = [];
            result.forEach(function(item) {
                var ideaProject = {
                    id: item.Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: item.AgouraFree__Title__c,
                    subtitle: 'Project • ' + item.Name
                };
                ideaProjects.push(ideaProject);
            });
            component.set("v.ideaProjectList", ideaProjects);
        });
        $A.enqueueAction(action);
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
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    component.set("v.hasEditAccess", true);
                }
                if (item.HasDeleteAccess == true) {
                    component.set("v.hasDeleteAccess", true);
                }
                if (item.HasTransferAccess == true) {
                    component.set("v.hasTransferAccess", true);
                }
            });    
        });
        $A.enqueueAction(action);
    },
    loadUsers: function (component, ideaId) {
        var action = component.get("c.getUsers");
        action.setParams({
            "ideaId": ideaId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var owner = [];
            var createdBy = [];
            var lastModifiedBy = [];
            var readShareList = [];
            var editShareList = [];
            result.forEach(function(item) {
                var result = {
                    id: item.id,
                    sObjectType: item.sObjectType,
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.sObjectType + ' • ' + item.title
                };
                if (item.subtitle == 'Owner') {
                    owner.push(result);
                    editShareList.push(result);
                } else if (item.subtitle == 'Created By') {
                    createdBy.push(result);
                } else if (item.subtitle == 'Last Modified By') {
                    lastModifiedBy.push(result);
                } else if (item.subtitle == 'Read Access') {
                    readShareList.push(result);
                } else if (item.subtitle == 'Edit Access') {
                    editShareList.push(result);
                }                
            });
            component.set("v.ownerList", owner);
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
            component.set("v.readAccessList", readShareList);
            component.set("v.editAccessList", editShareList);
        });
        $A.enqueueAction(action);
    },	
    setWebPageTitle: function (component, recId) {
        var action = component.get("c.getIdeaBoardTitle");
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
                document.title = item.AgouraFree__Title__c;
                component.set("v.windowTitle", document.title);           
            });
        });
        $A.enqueueAction(action);
    },
    confirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", true);
    },
    cloneRecord : function(component, event, helper) {
        var action = component.get("c.createCloneIdeaBoard");
        var recId = component.get("v.recordId");
        action.setParams({
            "recId": recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({"message":  "Idea Board cloned", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var cloneRecordEvent = $A.get("e.force:editRecord");
                cloneRecordEvent.setParams({
                    "recordId": result
                });
                cloneRecordEvent.fire();
            }
            else if (state === "ERROR") {
                this.handleError(response);
                return;
            }
        });
        $A.enqueueAction(action);
    },
    editRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__IdeaBoard__c/'+recId+'/edit';
    },
    confirmChangeOwner: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Change Owner");
        component.set("v.showConfirmAsk", "Select a new owner of this Idea Board."
                      + " Note: Salesforce will automatically clear the additional read and edit access list"
                      + " when the Record Owner changes.");
        component.set("v.showConfirmModal", true);
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
        var fieldList = ["AgouraFree__Problem__c", "AgouraFree__Existing_Alternatives__c", "AgouraFree__Solution__c", "AgouraFree__Key_Metrics__c", 
                         "AgouraFree__Unique_Value_Proposition__c", "AgouraFree__High_Level_Concept__c", "AgouraFree__Unfair_Advantage__c", 
                         "AgouraFree__Channels__c", "AgouraFree__Customer_Segment__c", "AgouraFree__Early_Adopters__c", "AgouraFree__Title__c", 
                         "AgouraFree__Cost_Structure__c", "AgouraFree__Revenue_Streams__c", "AgouraFree__Comments__c", "AgouraFree__Status__c"];
        action.setParams({
            "objectName": "AgouraFree__IdeaBoard__c",
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
    hasProjects: function (component) {
        var action = component.get("c.hasProjectObject");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.hasProjects", result);
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
    },
    isChatterEnabled: function (component) {
        var action = component.get("c.checkChatterEnabled");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.chatterEnabled", result);
        });
        $A.enqueueAction(action);
    }
})
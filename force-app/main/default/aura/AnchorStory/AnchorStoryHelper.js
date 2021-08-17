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
        var timeEst = '';
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
                timeEst = item.AgouraFree__Time_Estimate__c;
            });         
            component.set("v.timeEst", this.convertTimeToString(timeEst));
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
            var owner = [];
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
                } else if (item.subtitle == 'Owner') {
                	owner.push(result);
                }                
            });
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
            component.set("v.ownerList", owner);
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
            result.forEach(function(item) {
                var gotMasterTask = item.AgouraFree__Master_Task__c;
                if (!(gotMasterTask == null || gotMasterTask == '')){
                    var task = {
                        id: item.AgouraFree__Master_Task__c,
                        sObjectType: 'AgouraFree__AnchorStory__c',
                        icon: 'standard:task',
                        title: item.AgouraFree__Master_Task__r.AgouraFree__Title__c,
                        subtitle: 'Anchor Story • ' + item.AgouraFree__Master_Task__r.Name
                    };
                    tasks.push(task);
                }
            });
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
            result.forEach(function(item) {
                var task = {
                    id: item.Id,
                    sObjectType: 'AgouraFree__AnchorStory__c',
                    icon: 'standard:task',
                    title: item.AgouraFree__Title__c,
                    subtitle: 'Anchor Story • ' + item.Name
                };
                tasks.push(task);
            });
            component.set("v.subTasksSelection", tasks);
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
    cloneRecord : function(component, event, helper) {
        var action = component.get("c.createCloneAnchorStory");
        var recId = component.get("v.recordId");
        action.setParams({
            "recId": recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({ "message": "Anchor Story cloned", "type": "success"});
                resultsToast.fire();
                var result = response.getReturnValue();
                var cloneRecordEvent = $A.get("e.force:editRecord");
                cloneRecordEvent.setParams({"recordId": result});
                cloneRecordEvent.fire();
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
    confirmChangeOwner: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Change Owner");
        component.set("v.showConfirmAsk", "Select a new owner of this Anchor Story");
        component.set("v.showConfirmModal", true);
    },
    editRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__AnchorStory__c/'+recId+'/edit';
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
        var fieldList = ["AgouraFree__Description__c", "AgouraFree__Search_Terms__c", "AgouraFree__Type__c", "AgouraFree__Acceptance_Criteria__c", 
                         "AgouraFree__Value__c", "AgouraFree__Priority__c", "AgouraFree__Points__c", "AgouraFree__Time_Estimate__c", "AgouraFree__Master_Task__c", 
                         "AgouraFree__Components__c", "AgouraFree__Dependencies__c", "AgouraFree__Comments__c", "AgouraFree__Title__c",
                         "AgouraFree__Summary__c", "AgouraFree__Product_Owner__c", "AgouraFree__Project_Team__c", "AgouraFree__Sub_Tasks__c", "AgouraFree__URL__c"];
        action.setParams({
            "objectName": "AgouraFree__AnchorStory__c",
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
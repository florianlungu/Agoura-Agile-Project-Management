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
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    component.set("v.hasEditAccess", true);
                    component.set("v.modalContext", "Edit");
                }
                if (item.HasDeleteAccess == true) {
                    component.set("v.hasDeleteAccess", true);
                    component.set("v.modalContext", "Edit");
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
            result.forEach(function(item) {
                document.title = "Tag " + item.Name;
                component.set("v.windowTitle", document.title);         
            });
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
            var owner = [];
            var createdBy = [];
            var lastModifiedBy = [];
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
                } else if (item.subtitle == 'Created By') {
                    createdBy.push(result);
                } else if (item.subtitle == 'Last Modified By') {
                    lastModifiedBy.push(result);
                }                
            });
            component.set("v.ownerList", owner);
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
        });
        $A.enqueueAction(action);
    },
    confirmChangeOwner: function(component, event, helper) {
        component.set("v.showConfirmTitle", "Change Owner");
        component.set("v.showConfirmAsk", "Select a new owner of this Tag");
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
    confirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", true);
    },
    editRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        window.location = '/lightning/r/AgouraFree__Tag__c/'+recId+'/edit';
    },
    hasProjects: function (component) {
        var action = component.get("c.hasProjectObject");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.hasProjects", result);
        });
        $A.enqueueAction(action);
    }
})
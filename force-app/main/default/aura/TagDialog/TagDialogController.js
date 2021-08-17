({
    doInit : function(component, event, helper) {
        helper.isDesktop(component);
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.hasEditAccess(component, recId); 
        } else {
            helper.hasCreateAccess(component);
        }   
        helper.hasProjects(component);       	
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var nameField = component.find('propName');
        var nameValue = nameField.get('v.value');
        if(nameValue == null || nameValue == '') {
            nameField.set('v.validity', {valid:false, badInput :true});
            nameField.showHelpMessageIfInvalid();
            return null;
        } 
        component.set("v.targetFields.Name", component.find('propName').get("v.value"));
        var forIdeaBoards = document.getElementById('forIdeaBoards');
        component.set("v.targetFields.AgouraFree__For_IdeaBoards__c", forIdeaBoards.checked);
        
        var hasProjects = component.get("v.hasProjects");  
        if (hasProjects) {
            var forProjects = document.getElementById('forProjects');
            var forProjectTasks = document.getElementById('forProjectTasks');
            component.set("v.targetFields.AgouraFree__For_Projects__c", forProjects.checked); 
            component.set("v.targetFields.AgouraFree__For_ProjectTasks__c", forProjectTasks.checked); 
        }
        
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var recName = component.get("v.targetFields.Name");
            var toastMsg = "Tag \"" + recName + "\" was saved.";
            if (!recName) {
                toastMsg = "New Tag saved.";
            } 
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();  
                var recId = result.recordId;
                helper.navigateTo(component, recId);
            } else if (result.state === "ERROR") {
                var errors = result.getError();
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
    },
    cancelDialog: function(component, event, helper) {
        helper.doCancel(component);    
    }
})
({
    doInit : function(component, event, helper) {
        helper.isDesktop(component);
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.hasEditAccess(component, recId); 
        } else {
            helper.hasCreateAccess(component);
        }
        helper.loadFieldLabelMap(component);
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var propType = component.get("v.targetFields.AgouraFree__Type__c");
        var recId = component.get("v.recordId");
        if (!recId) {
            helper.showError("Project Item cannot be manually created. Please create the item from within the project"); 
            return null;          
        }        
        var isUserType = component.get("v.isUserType");
        var userSelection = component.get("v.userSelection");
        var userSelectionId = (userSelection.length > 0) ? userSelection[0].id : '';    
        var titleValue = '';
        if (isUserType) {
            if(userSelectionId == null || userSelectionId == '') {
                helper.showError("Please select a User before saving");  
                return null;
            } 
            titleValue = userSelectionId;
        } else {            
            titleValue = component.find('propTitle').get("v.value"); 
            if(titleValue == null || titleValue == '') {
                var titleField = component.find('propTitle');
                titleField.set('v.validity', {valid:false, badInput :true});
                titleField.showHelpMessageIfInvalid();
                return null;
            }
            if (propType == 'Project Link') {    
                var urlField = component.find('propURL');
                var urlValue = urlField.get("v.value"); 
                var re = new RegExp("^((http|https)://)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$");
                if(re.test(urlValue) == false) {
                    urlField.set('v.validity', {valid:false, badInput:true});
                    urlField.showHelpMessageIfInvalid();
                    return null;
                } else if(urlValue == null || urlValue == '') {
                    urlField.set('v.validity', {valid:false, valueMissing:true});
                    urlField.showHelpMessageIfInvalid();
                    return null;
                }
            } 
        } 
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';
        if(projectId == null || projectId == '') {
            helper.showError("Please select a project before saving"); 
            return null;
        }
        
        // save record
        component.set("v.targetFields.AgouraFree__Project__c", (project.length > 0) ? project[0].id : ''); 
        component.set("v.targetFields.AgouraFree__Type__c", propType); 
        component.set("v.targetFields.Name", titleValue);
        if (propType == 'Project Goal') {
            component.set("v.targetFields.AgouraFree__Start_Date__c", component.find('propStartDate').get("v.value")); 
            component.set("v.targetFields.AgouraFree__Target_Date__c", component.find('propTargetDate').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Progress__c", component.find('propProgress').get("v.value"));   
            component.set("v.targetFields.AgouraFree__Comments__c", component.find('propComments').get("v.value"));  
        } else if (propType == 'Project Milestone') {
            component.set("v.targetFields.AgouraFree__Start_Date__c", ""); 
            component.set("v.targetFields.AgouraFree__Target_Date__c", component.find('propTargetDate').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Progress__c", component.find('propProgress').get("v.value"));   
            component.set("v.targetFields.AgouraFree__Comments__c", component.find('propComments').get("v.value"));  
        } else {
            component.set("v.targetFields.AgouraFree__Start_Date__c", ""); 
            component.set("v.targetFields.AgouraFree__Target_Date__c", "");  
            component.set("v.targetFields.AgouraFree__Progress__c", "");   
            component.set("v.targetFields.AgouraFree__Comments__c", "");  
        }
        if (propType == 'Project Link') {
            component.set("v.targetFields.AgouraFree__URL__c", component.find('propURL').get("v.value")); 
        } else {
            component.set("v.targetFields.AgouraFree__URL__c", ""); 
        }
        if (propType == 'Project Risk') {
            component.set("v.targetFields.AgouraFree__Status__c", component.find('propStatus').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Probability__c", component.find('propProbability').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Impact__c", component.find('propImpact').get("v.value"));   
            component.set("v.targetFields.AgouraFree__Description__c", component.find('propDescription').get("v.value")); 
            component.set("v.targetFields.AgouraFree__Response__c", component.find('propResponse').get("v.value"));  
        } else {
            component.set("v.targetFields.AgouraFree__Status__c", "");  
            component.set("v.targetFields.AgouraFree__Probability__c", "");
            component.set("v.targetFields.AgouraFree__Impact__c", "");
            component.set("v.targetFields.AgouraFree__Description__c", "");
            component.set("v.targetFields.AgouraFree__Response__c", "");
        }
        if (isUserType) {
            component.set("v.targetFields.AgouraFree__User__c", userSelectionId); 
            if (propType == 'Project Team Member') {
                component.set("v.targetFields.AgouraFree__Swim_Lane__c", component.find('propSwimLane').get("v.value"));
                component.set("v.targetFields.AgouraFree__RACI__c", "");
            } else if (propType == 'Project Stakeholder') {
                component.set("v.targetFields.AgouraFree__Swim_Lane__c", "");
                component.set("v.targetFields.AgouraFree__RACI__c", component.find('propRACI').get("v.value"));
            }
        } else {
            component.set("v.targetFields.AgouraFree__User__c", "");
            component.set("v.targetFields.AgouraFree__Swim_Lane__c", "");
            component.set("v.targetFields.AgouraFree__RACI__c", "");            
        }
        
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var toastMsg = propType + " \"" + titleValue + "\" was saved.";
            if (isUserType) {
                toastMsg = propType + " \"" + userSelection[0].title + "\" was saved.";
            }
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();  
                var recId = result.recordId;
                var project = component.get("v.projectSelection");
                var projectId = (project.length > 0) ? project[0].id : '';
                if (projectId != null) {
                    helper.navigateTo(component, projectId);                    
                } else {
                    helper.navigateTo(component, recId);
                }
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
    },
    lookupProjectSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propProject').search(serverSearchAction);
    },
    lookupLinkOwnerSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propOwner').search(serverSearchAction);
    },
    lookupUserSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propUser').search(serverSearchAction);
    }
})
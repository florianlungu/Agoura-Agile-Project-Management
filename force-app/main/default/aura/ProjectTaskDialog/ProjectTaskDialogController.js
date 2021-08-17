({
    doInit : function(component, event, helper) {
        helper.isDesktop(component);
        var recId = component.get("v.recordId");        
        if (recId) {
            helper.hasEditAccess(component, recId); 
        } else {
            helper.hasCreateAccess(component);
        }	 
        helper.isChatterEnabled(component);
        helper.loadFieldLabelMap(component);
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    cancelDialog: function(component, event, helper) {
        helper.doCancel(component);       
    },
    lookupAssignedToSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propAssignedTo').search(serverSearchAction);
    },
    updateBugFields: function (component, event, helper) {
        var fieldValue = component.find('propType').get("v.value");
        if (fieldValue == "Bug") {
            var statusValue = component.find('propNormalStatus').get("v.value");
            if (statusValue != 'Done') {
                component.set("v.propBugStatus", statusValue);     
            }
            helper.showHide(component,"propBugType","Show");
            helper.showHide(component,"propResolution","Show");
            helper.showHide(component,"propResolvedDate","Show");
            helper.showHide(component,"propNormalStatus","Hide");
            helper.showHide(component,"propBugStatus","Show");       
        } else {
            var statusValue = component.find('propBugStatus').get("v.value");
            if (statusValue != 'Resolved') {
                component.set("v.propNormalStatus", statusValue);     
            }   
            helper.showHide(component,"propBugType","Hide");
            helper.showHide(component,"propResolution","Hide");
            helper.showHide(component,"propResolvedDate","Hide");
            helper.showHide(component,"propNormalStatus","Show");
            helper.showHide(component,"propBugStatus","Hide");  
        } 
    },
    lookupProjectSprintSearch : function(component, event, helper) {
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';  
                if (projectId == null || projectId == '') {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"message":  "Please select a project first", "type": "error"});
            resultsToast.fire();  
            return null;
        }
        const serverSearchAction = component.get('c.sprintSearch');
        component.find('propSprint').search(serverSearchAction);
    },
    lookupProjectTaskSearch : function(component, event, helper) {
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';  
                if (projectId == null || projectId == '') {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"message":  "Please select a project first", "type": "error"});
            resultsToast.fire();  
            return null;
        }
        const serverSearchAction = component.get('c.projectTaskSearch');
        component.find('propMasterTask').search(serverSearchAction);
    },
    lookupAccountSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.accountSearch');
        component.find('propAccount').search(serverSearchAction);
    },
    lookupTagSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.tagSearch');
        component.find('propTags').search(serverSearchAction);
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var nameField = component.find('propTitle');
        var nameValue = nameField.get('v.value');
        if(nameValue == null || nameValue == '') {
            nameField.set('v.validity', {valid:false, badInput :true});
            nameField.showHelpMessageIfInvalid();
            return null;
        } 
        var project = component.get("v.projectSelection");
        var projectId = (project.length > 0) ? project[0].id : '';  
        if (projectId == null || projectId == '') {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"message":  "Please select a project before saving", "type": "error"});
            resultsToast.fire();  
            return null;
        }
        
        var recId = component.get("v.recordId");    
        helper.doTimeUpdate(component);
        var assignedToSelection = component.get("v.assignedToSelection");     
        var sprintSelection = component.get("v.sprintSelection");
        var masterTaskSelection = component.get("v.masterTaskSelection");
        var blockedSelection = helper.joinArray(component.get("v.blockedValue"));
        var statusSelection = "";      
        var taskType = component.find('propType').get("v.value");
        if (taskType == "Bug") {
            statusSelection = component.find('propNormalStatus').get("v.value");
        } else {           
            statusSelection = component.find('propBugStatus').get("v.value");
        }
        var formattedStatus = statusSelection;
        formattedStatus = formattedStatus.replace(/\s+/g, '');
        formattedStatus = formattedStatus.toLowerCase();
        var endDate = component.find('propEndDate').get("v.value");
        if (statusSelection == 'Canceled' || statusSelection == 'Resolved' || statusSelection == 'Done') {
            if (endDate == null || endDate == '') {  
                endDate = new Date();
                endDate.setHours(0,0,0,0);
            }
        } else {
            endDate = null;
        }
        var startDate = component.find('propStartDate').get("v.value");
        if (startDate == null || startDate == '') {
            if (!(statusSelection == 'Open' || statusSelection == 'Canceled')) {
                startDate = new Date();
                startDate.setHours(0,0,0,0);
            }
        }
        var timeEstimate = helper.convertToTime(component.find('propTimeEstimate').get("v.value"));
        var timeLogged = helper.convertToTime(component.get("v.timeLogged"));
        var timeRemaining = helper.convertToTime(component.get("v.timeRemaining"));
        var oldSprintId = component.get("v.targetFields.AgouraFree__Sprint__c");
        var account = component.get("v.accountSelection");      
        
        // set data
        component.set("v.targetFields.AgouraFree__Project__c", (project.length > 0) ? project[0].id : '');
        component.set("v.targetFields.AgouraFree__Title__c", nameValue); 
        component.set("v.targetFields.AgouraFree__Description__c", component.find('propDescription').get("v.value"));
        component.set("v.targetFields.AgouraFree__URL__c", component.find('propURL').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Type__c", taskType); 
        component.set("v.targetFields.AgouraFree__Status__c", statusSelection);
        component.set("v.targetFields.AgouraFree__Formatted_Status__c", formattedStatus); 
        component.set("v.targetFields.AgouraFree__Points__c", component.find('propPoints').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Assigned_To__c", (assignedToSelection.length > 0) ? assignedToSelection[0].id : '');  
        component.set("v.targetFields.AgouraFree__Reported_By__c", component.find('propReportedBy').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Blocked__c", (blockedSelection == 'Yes' ? true : false)); 
        component.set("v.targetFields.AgouraFree__Reported_Date__c", component.find('propReportedDate').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Swim_Lane__c", component.find('propSwimLane').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Value__c", component.find('propValue').get("v.value"));   
        component.set("v.targetFields.AgouraFree__Due_Date__c", component.find('propDueDate').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Priority__c", component.find('propPriority').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Accept__c", component.find('propAccept').get("v.value"));   
        component.set("v.targetFields.AgouraFree__Account__c", (account.length > 0) ? account[0].id : '');    
        component.set("v.targetFields.AgouraFree__Sprint__c", (sprintSelection.length > 0) ? sprintSelection[0].id : ''); 
        component.set("v.targetFields.AgouraFree__Start_Date__c", startDate);  
        component.set("v.targetFields.AgouraFree__Master_Task__c", (masterTaskSelection.length > 0) ? masterTaskSelection[0].id : '');  
        component.set("v.targetFields.AgouraFree__End_Date__c", endDate);  
        component.set("v.targetFields.AgouraFree__Affected_Version__c", component.find('propAffectedVersion').get("v.value"));         
        component.set("v.targetFields.AgouraFree__Time_Estimate__c", timeEstimate);  
        component.set("v.targetFields.AgouraFree__Version__c", component.find('propVersion').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Time_Logged__c", timeLogged);  
        component.set("v.targetFields.AgouraFree__Fix_Version__c", component.find('propFixVersion').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Time_Remaining__c", timeRemaining);  
        component.set("v.targetFields.AgouraFree__Components__c", component.find('propComponents').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Dependencies__c", component.find('propDependencies').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Comments__c", component.find('propComments').get("v.value")); 
        
        if (taskType == "Bug") {  
            component.set("v.targetFields.AgouraFree__Bug_Type__c", component.find('propBugType').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Resolution__c", component.find('propResolution').get("v.value"));  
            component.set("v.targetFields.AgouraFree__Resolved_Date__c", component.find('propResolvedDate').get("v.value"));             
        } else {
            component.set("v.targetFields.AgouraFree__Bug_Type__c", "");  
            component.set("v.targetFields.AgouraFree__Resolution__c", "");  
            component.set("v.targetFields.AgouraFree__Resolved_Date__c", "");             
        }
        
        // save changes
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state); 
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {                
                var recId = result.recordId;
        		helper.updateProjectTaskTags(component, recId); 
                var chatterEnabled = component.get("v.chatterEnabled"); 
                if (chatterEnabled) {
                    var content = component.find('chatterTextPostField').get("v.value");
                    if (typeof content !== "undefined") {
                        helper.chatterFeedPost(component, recId); 
                    }                                       
                }
                helper.updatePostSave(component, recId, oldSprintId);
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
    editTimeLogged : function(component, event, helper) {
        var radiobtn = document.getElementById("propRemainingTimeRadio1");
        radiobtn.checked = true;
        helper.showHide(component,"propTimeLoggedView","Hide");
        helper.showHide(component,"propTimeLoggedEdit","Show");
    },
    clearTimeLogged : function (component, event, helper) {
      component.set("v.timeLogged", "");  
    },
    editTimeRemaining : function(component, event, helper) {
        var radiobtn = document.getElementById("propRemainingTimeRadio3");
        radiobtn.checked = true;
        helper.showHide(component,"propTimeLoggedView","Hide");
        helper.showHide(component,"propTimeLoggedEdit","Show");
    },
    editTimeCancel : function(component, event, helper) {
        component.find('propAddTime').set("v.value","");
        component.find('propSetTimeRemaining').set("v.value","");
        component.find('propReduceTimeRemaining').set("v.value","");
        helper.showHide(component,"propTimeLoggedEdit","Hide");
        helper.showHide(component,"propTimeLoggedView","Show");
    },
    editTimeUpdate : function(component, event, helper) { 
        helper.doTimeUpdate(component);
        helper.showHide(component,"propTimeLoggedEdit","Hide");
        helper.showHide(component,"propTimeLoggedView","Show");        
    },
    lookupProjectSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.projectSearch');
        component.find('propProject').search(serverSearchAction);
    }
})
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
        helper.loadFieldHelpMap(component);        
        helper.loadNumRecords(component, recId); 
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var fieldList = ["propTitle","propProjectAbbreviation"];
        var allGood = helper.validateFields(component, fieldList);  
        if (allGood == false) {return false;}
                
        var isTemplateSelection = helper.joinArray(component.get("v.isTemplateValue")); 
        /*
        // Record Num Validation
        var numRecords = component.get("v.numRecords");
        if (isTemplateSelection == 'Yes' && numRecords['templates'] > 0) {
        var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"type":"error", "title": "Error!", "message": "Project template cannot be saved because Agoura Free is limited to 1 project template record."});
            resultsToast.fire();  
            return;
        } else if (isTemplateSelection != 'Yes' && numRecords['projects'] > 2) {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({"type":"error", "title": "Error!", "message": "Project cannot be saved because Agoura Free is limited to 3 project records."});
            resultsToast.fire();   
            return;
        }
        */
                
        // save record
        var recId = component.get("v.recordId");
        var executiveSponsor = component.get("v.executiveSponsorSelection");
        var productOwner = component.get("v.productOwnerSelection");
        var scrumMaster = component.get("v.scrumMasterSelection");
        var account = component.get("v.accountSelection");      
        var ideaBoard = component.get("v.ideaBoardSelection"); 
        component.set("v.targetFields.AgouraFree__Title__c", component.find('propTitle').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Status__c", component.find('propStatus').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Project_Abbreviation__c", component.find('propProjectAbbreviation').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Executive_Sponsor__c", (executiveSponsor.length > 0) ? executiveSponsor[0].id : '');  
        component.set("v.targetFields.AgouraFree__Product_Owner__c", (productOwner.length > 0) ? productOwner[0].id : '');  
        component.set("v.targetFields.AgouraFree__Scrum_Master__c", (scrumMaster.length > 0) ? scrumMaster[0].id : '');   
        component.set("v.targetFields.AgouraFree__IsTemplate__c", (isTemplateSelection == 'Yes' ? true : false)); 
        component.set("v.targetFields.AgouraFree__Account__c", (account.length > 0) ? account[0].id : '');    
        component.set("v.targetFields.AgouraFree__Idea_Board__c", (ideaBoard.length > 0) ? ideaBoard[0].id : '');  
        component.set("v.targetFields.AgouraFree__Mission_Statement__c", component.find('propMissionStatement').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Product__c", component.find('propProduct').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Deliverables__c", component.find('propDeliverables').get("v.value"));  
        component.set("v.targetFields.AgouraFree__KPIs__c", component.find('propKPIs').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Value_Trackers__c", component.find('propValueTrackers').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Assumptions__c", component.find('propAssumptions').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Constraints__c", component.find('propConstraints').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Comments__c", component.find('propComments').get("v.value")); 
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var recName = component.get("v.targetFields.AgouraFree__Title__c");
            var toastMsg = "Project \"" + recName + "\" was saved.";
            if (!recName) {
                toastMsg = "New Project saved.";
            } 
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                var recId = result.recordId;
                
                // update related objects
                helper.updateProjectTags(component, recId);
                helper.updateAccessList(component, recId);
                helper.updateProjectTasks(component, recId);
                helper.updateStakeholders(component, recId);
                
                resultsToast.setParams({"message":  toastMsg, "type": "success"});
                resultsToast.fire();  
                helper.navigateTo(component, recId);
            } else if (result.state === "ERROR") {
                var errors = "";
                for (var i = 0; result.error.length > i; i++){
                    var errorStr = result.error[i].message;
                    if (errorStr.includes("AgouraFree__Title__c duplicates value")) {
                        errors = errors + 'A project with this title already exists. Please enter an unique project title.';  
                    } else if (errorStr.includes("AgouraFree__Project_Abbreviation__c duplicates value")) {
                        errors = errors + 'The project abbreviation is already in use. Please enter an unique project abbreviation.';  
                    } else {
                      errors = errors + errorStr;  
                    }
                }
                resultsToast.setParams({"type":"error", "title": "Error!", "message": errors});
                resultsToast.fire();
            } else {
                var errors = "";
                for (var i = 0; result.error.length > i; i++){
                    errors = errors + result.error[i].message;
                }
                console.log('Unknown problem, state: ' + result.state + ', error: ' + errors);
            }
        }));
    },
    cancelDialog: function(component, event, helper) {
        helper.doCancel(component);
    },
    lookupExecutiveSponsorSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propExecutiveSponsor').search(serverSearchAction);
    },
    lookupProductOwnerSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propProductOwner').search(serverSearchAction);
    },
    lookupScrumMasterSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userOnlySearch');
        component.find('propScrumMaster').search(serverSearchAction);
    },
    lookupTagSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.tagSearch');
        component.find('propTags').search(serverSearchAction);
    },
    lookupAccountSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.accountSearch');
        component.find('propAccount').search(serverSearchAction);
    },
    lookupIdeaBoardSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.ideaBoardSearch');
        component.find('propIdeaBoards').search(serverSearchAction);
    },
    lookupReadSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userSearch');
        component.find('propReadAccess').search(serverSearchAction);
    },
    lookupEditSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.userSearch');
        component.find('propEditAccess').search(serverSearchAction);
    }
})
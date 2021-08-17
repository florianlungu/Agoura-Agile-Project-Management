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
    cancelDialog: function(component, event, helper) {
        helper.doCancel(component);      
    },
    saveRecord : function(component, event, helper) {
        // field validation
        var fieldList = ["propName","propType"];
        var allGood = helper.validateFields(component, fieldList);  
        if (allGood == false) {return false;}
        
        var recId = component.get("v.recordId"); 
        var masterTaskSelection = component.get("v.masterTaskSelection");        
        var timeEstimate = helper.convertToTime(component.find('propTimeEstimate').get("v.value"));
        
        // set data
        component.set("v.targetFields.AgouraFree__Title__c", component.find('propName').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Description__c", component.find('propDescription').get("v.value")); 
        component.set("v.targetFields.AgouraFree__URL__c", component.find('propURL').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Type__c", component.find('propType').get("v.value"));   
        component.set("v.targetFields.AgouraFree__Points__c", component.find('propPoints').get("v.value"));       
        component.set("v.targetFields.AgouraFree__Value__c", component.find('propValue').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Priority__c", component.find('propPriority').get("v.value")); 
        component.set("v.targetFields.AgouraFree__Accept__c", component.find('propAccept').get("v.value"));   
        component.set("v.targetFields.AgouraFree__Search_Terms__c", component.find('propSearchTerms').get("v.value"));       
        component.set("v.targetFields.AgouraFree__Master_Task__c", (masterTaskSelection.length > 0) ? masterTaskSelection[0].id : '');                
        component.set("v.targetFields.AgouraFree__Time_Estimate__c", timeEstimate); 
        component.set("v.targetFields.AgouraFree__Components__c", component.find('propComponents').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Dependencies__c", component.find('propDependencies').get("v.value"));  
        component.set("v.targetFields.AgouraFree__Comments__c", component.find('propComments').get("v.value")); 
                   
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var recName = component.get("v.targetFields.AgouraFree__Title__c");
            var toastMsg = "Anchor Story \"" + recName + "\" was saved.";
            if (!recName) {
               toastMsg = "New Anchor Story saved.";
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
    lookupAnchorStorySearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.anchorStorySearch');
        component.find('propMasterTask').search(serverSearchAction);
    }
})
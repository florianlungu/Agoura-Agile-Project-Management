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
        var fieldList = ["propTitle"];
        var allGood = helper.validateFields(component, fieldList);  
        if (allGood == false) {return false;}
        
        // update related objects
        var recId = component.get("v.recordId");
        helper.updateIdeaTags(component, recId);
        helper.updateAccessList(component, recId);
        
        // save record         
        component.set("v.ideaBoardRecord.AgouraFree__Title__c", component.find('propTitle').get("v.value"));  
        component.set("v.ideaBoardRecord.AgouraFree__Status__c", component.find('propStatus').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Problem__c", component.find('propProblem').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Existing_Alternatives__c", component.find('propExistingAlternatives').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Solution__c", component.find('propSolution').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Key_Metrics__c", component.find('propKeyMetrics').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Unique_Value_Proposition__c", component.find('propUniqueValueProposition').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__High_Level_Concept__c", component.find('propHighLevelConcept').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Unfair_Advantage__c", component.find('propUnfairAdvantage').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Channels__c", component.find('propChannels').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Customer_Segment__c", component.find('propCustomerSegment').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Early_Adopters__c", component.find('propEarlyAdopters').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Cost_Structure__c", component.find('propCostStructure').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Revenue_Streams__c", component.find('propRevenueStreams').get("v.value"));
        component.set("v.ideaBoardRecord.AgouraFree__Comments__c", component.find('propComments').get("v.value"));
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var recName = component.get("v.ideaBoardRecord.Name");
            var toastMsg = "Idea Board \"" + recName + "\" was saved.";
            if (!recName) {
                toastMsg = "New Idea Board saved.";
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
    },
    lookupTagSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.tagSearch');
        component.find('propTags').search(serverSearchAction);
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
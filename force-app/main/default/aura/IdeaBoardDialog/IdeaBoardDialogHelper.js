({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },    
    hasEditAccess: function (component, recId) {
        var action = component.get("c.recordAccess");
        action.setParams({"recId": recId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var userAccess, hasTransferAccess = false;
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    userAccess = true;
                }
                if (item.HasTransferAccess == true) {
                    hasTransferAccess = true;
                }
            });
            if (userAccess == false) {
                var toastMsg = "Edit access denied to record id " + recId;
                console.log(toastMsg);
                component.set("v.recordError", toastMsg); 
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "error"});
                resultsToast.fire();
                this.doCancel(component);
            } else {   
                component.set("v.hasEditAccess", true);
                component.set("v.hasTransferAccess", hasTransferAccess);
                component.set("v.modalContext", "Edit");
                this.loadIdeaTagList(component, recId);          
                this.loadUsers(component, recId); 
                this.setWebPageTitle(component, recId); 
            }
        });
        $A.enqueueAction(action);
    },
    hasCreateAccess: function (component) {
    var action = component.get("c.createAccess");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            if (result == false) {
                var toastMsg = "Create access denied";
                console.log(toastMsg);
                component.set("v.recordError", toastMsg); 
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({"message": toastMsg, "type": "error"});
                resultsToast.fire();
                this.doCancel(component);
            } else {   
                document.title = "New Idea Board";
                component.set("v.hasEditAccess", true);
                component.find("forceRecord").getNewRecord(
                    "AgouraFree__IdeaBoard__c",
                    null,
                    false,
                    $A.getCallback(function() {
                        var rec = component.get("v.ideaBoardRecord");
                        var error = component.get("v.recordError");
                        if (error || (rec === null)) {
                            console.log("Error initializing record template: " + error);
                            return;
                        }
                    })
                );	
                document.title = "New Idea Board";
                component.set("v.windowTitle", document.title);
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__IdeaBoard__c"});
            homeEvt.fire();
        } else {
            this.navigateTo(component, recId);
        }
    },    
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
            component.set("v.tagSelection", ideaTags);
        });
        $A.enqueueAction(action);
    },  
    updateIdeaTags: function (component, ideaId) {
        var tagSelection = component.get("v.tagSelection");
        var ideaTagList = component.get("v.ideaTagList");
        
        // add idea tag
        for (var x = 0; x < tagSelection.length; x++) {
            var found = false;
            for (var y = 0; y < ideaTagList.length; y++) {
                if (tagSelection[x].id === ideaTagList[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.addIdeaTag");
                action.setParams({
                    "tagId": tagSelection[x].id,
                    "ideaId": ideaId
                });
                $A.enqueueAction(action);
            }
        }
        
        // remove idea tag
        for (var x = 0; x < ideaTagList.length; x++) {
            var found = false;
            for (var y = 0; y < tagSelection.length; y++) {
                if (ideaTagList[x].id === tagSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeIdeaTag");
                action.setParams({
                    "tagId": ideaTagList[x].id,
                    "ideaId": ideaId
                });
                $A.enqueueAction(action);
            }
        }        
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
                if (item.subtitle == 'Read Access') {
                    readShareList.push(result);
                } else if (item.subtitle == 'Edit Access') {
                    editShareList.push(result);
                }                
            });
            component.set("v.readAccessList", readShareList);
            component.set("v.readAccessSelection", readShareList);
            component.set("v.editAccessList", editShareList);
            component.set("v.editAccessSelection", editShareList);
        });
        $A.enqueueAction(action);
    },
    updateAccessList: function (component, ideaId) {
        var readAccessSelection = component.get("v.readAccessSelection");
        var readAccessList = component.get("v.readAccessList");
        var editAccessSelection = component.get("v.editAccessSelection");
        var editAccessList = component.get("v.editAccessList");
        
        // remove sharing access
        for (var x = 0; x < editAccessList.length; x++) {
            var found = false;
            for (var y = 0; y < editAccessSelection.length; y++) {
                if (editAccessList[x].id === editAccessSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeIdeaSharingAccess");
                action.setParams({
                    "ideaId": ideaId,
                    "userId": editAccessList[x].id                    
                });
                $A.enqueueAction(action);
            }
        }  
        for (var x = 0; x < readAccessList.length; x++) {
            var found = false;
            for (var y = 0; y < readAccessSelection.length; y++) {
                if (readAccessList[x].id === readAccessSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeIdeaSharingAccess");
                action.setParams({
                    "ideaId": ideaId,
                    "userId": readAccessList[x].id                    
                });
                $A.enqueueAction(action);
            }
        }  
        
        // add sharing access
        for (var x = 0; x < editAccessSelection.length; x++) {
            var found = false;
            for (var y = 0; y < editAccessList.length; y++) {
                if (editAccessSelection[x].id === editAccessList[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.addIdeaSharingAccess");
                action.setParams({
                    "ideaId": ideaId,
                    "userId": editAccessSelection[x].id,
                    "accessLevel": "Edit"
                });
                $A.enqueueAction(action);
            }
        }
        for (var x = 0; x < readAccessSelection.length; x++) {
            var found = false;
            for (var y = 0; y < readAccessList.length; y++) {
                if (readAccessSelection[x].id === readAccessList[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.addIdeaSharingAccess");
                action.setParams({
                    "ideaId": ideaId,
                    "userId": readAccessSelection[x].id,
                    "accessLevel": "Read"
                });
                $A.enqueueAction(action);
            }
        }    
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
                document.title = "Edit " + item.AgouraFree__Title__c;
                component.set("v.windowTitle", document.title);
            });
        });
        $A.enqueueAction(action);
    },
    validateFields: function (component, fieldList) {
        var allGood = true;
        for (var i = 0; i < fieldList.length; i++) {          
            var inputField = component.find(fieldList[i]);
            if (inputField.get('v.validity').valid == false) {
                inputField.showHelpMessageIfInvalid();
                allGood = false;
            }
        }        
        return allGood;
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
    isDesktop: function (component) {
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
            var result = {
                topDiv: 'slds-modal slds-fade-in-open',
                secondDiv: 'modal-container slds-modal__container',
                headerDiv: 'slds-modal__header',
                mainDiv: 'slds-modal__content slds-p-around_medium slds-grid slds-wrap',
                footerDiv: 'slds-modal__footer'
            };
            component.set("v.formStyle", result);
        } else {
            var result = {
                topDiv: '',
                secondDiv: '',
                headerDiv: 'slds-p-around_medium slds-align_absolute-center',
                mainDiv: 'slds-p-around_medium slds-grid slds-wrap',
                footerDiv: 'slds-p-around_medium'
            };
            component.set("v.formStyle", result);
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
    }
})
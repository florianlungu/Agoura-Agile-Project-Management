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
            var userAccess = false;
            if (result.hasEditAccess == true) {
                userAccess = true;
            }
            
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
                if (result.hasTransferAccess == true) {
                    component.set("v.hasTransferAccess", true);
                }
                component.set("v.modalContext", "Edit");
                this.setWebPageTitle(component, recId);    
                this.loadUsers(component, recId);
                this.loadTagList(component, recId);
                this.loadAccountList(component, recId);
                this.loadIdeaList(component, recId);             
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
                component.set("v.hasEditAccess", true);
                component.find("forceRecord").getNewRecord(
                    "AgouraFree__Project__c",
                    null,
                    false,
                    $A.getCallback(function() {
                        var rec = component.get("v.targetFields");
                        var error = component.get("v.recordError");
                        if (error || (rec === null)) {
                            console.log("Error initializing record template: " + error);
                            return;
                        }
                    })
                );	
                document.title = "New Project";
                component.set("v.windowTitle", document.title);
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__Project__c"});
            homeEvt.fire();
        } else {
            this.navigateTo(component, recId);
        }
    }, 
    loadUsers: function (component, projectId) {
        var action = component.get("c.getUsers");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var executiveSponsor = [];
            var productOwner = [];
            var scrumMaster = [];
            var readShareList = [];
            var editShareList = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].id,
                    sObjectType: result[i].sObjectType,
                    icon: result[i].icon,
                    title: result[i].title,
                    subtitle: result[i].sObjectType + ' • ' + result[i].title
                };
                if (result[i].subtitle == 'Executive Sponsor') {
                    executiveSponsor.push(resultItem);
                } else if (result[i].subtitle == 'Product Owner') {
                    productOwner.push(resultItem);
                } else if (result[i].subtitle == 'Scrum Master') {
                    scrumMaster.push(resultItem);
                } else if (result[i].subtitle == 'Read Access') {
                    readShareList.push(resultItem);
                } else if (result[i].subtitle == 'Edit Access') {
                    editShareList.push(resultItem);
                }           
            }
            component.set("v.executiveSponsorList", executiveSponsor);
            component.set("v.executiveSponsorSelection", executiveSponsor);
            component.set("v.productOwnerList", productOwner);
            component.set("v.productOwnerSelection", productOwner);
            component.set("v.scrumMasterList", scrumMaster);
            component.set("v.scrumMasterSelection", scrumMaster);
            component.set("v.readAccessList", readShareList);
            component.set("v.readAccessSelection", readShareList);
            component.set("v.editAccessList", editShareList);
            component.set("v.editAccessSelection", editShareList);
        });
        $A.enqueueAction(action);
    },    
    loadTagList: function (component, projectId) {
        var action = component.get("c.getProjectTags");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var projectTags = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var projectTag = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Tag__c',
                    icon: 'standard:topic',
                    title: result[i].Name,
                    subtitle: 'Tag • ' + result[i].Name
                };
                projectTags.push(projectTag);
            }
            component.set("v.tagList", projectTags);
            component.set("v.tagSelection", projectTags);
        });
        $A.enqueueAction(action);
    },  
    updateProjectTags: function (component, projectId) {
        var tagSelection = component.get("v.tagSelection");
        var tagList = component.get("v.tagList");
        
        // add project tag
        for (var x = 0; x < tagSelection.length; x++) {
            var found = false;
            for (var y = 0; y < tagList.length; y++) {
                if (tagSelection[x].id === tagList[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.addProjectTag");
                action.setParams({
                    "tagId": tagSelection[x].id,
                    "projectId": projectId
                });
                $A.enqueueAction(action);
            }
        }
        
        // remove project tag
        for (var x = 0; x < tagList.length; x++) {
            var found = false;
            for (var y = 0; y < tagSelection.length; y++) {
                if (tagList[x].id === tagSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeProjectTag");
                action.setParams({
                    "tagId": tagList[x].id,
                    "projectId": projectId
                });
                $A.enqueueAction(action);
            }
        }        
    },    
    loadAccountList: function (component, projectId) {
        var action = component.get("c.getRelatedAccount");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var accounts = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var ideaProject = {
                    id: result[i].Id,
                    sObjectType: 'Account',
                    icon: 'standard:account',
                    title: result[i].Name,
                    subtitle: 'Account • ' + result[i].Id
                };
                accounts.push(ideaProject);
            }
            component.set("v.accountList", accounts);
            component.set("v.accountSelection", accounts);
        });
        $A.enqueueAction(action);
    },    
    loadIdeaList: function (component, projectId) {
        var action = component.get("c.getIdeaProjects");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var ideaProjects = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var ideaProject = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__IdeaBoard__c',
                    icon: 'standard:solution',
                    title: result[i].AgouraFree__Title__c,
                    subtitle: 'Idea Board • ' + result[i].Name
                };
                ideaProjects.push(ideaProject);
            }
            component.set("v.ideaBoardList", ideaProjects);
            component.set("v.ideaBoardSelection", ideaProjects);
        });
        $A.enqueueAction(action);
    },    
    updateAccessList: function (component, projectId) {
        var editAccessSelection = component.get("v.editAccessSelection");
        var editAccessList = component.get("v.editAccessList");
        var readAccessSelection = component.get("v.readAccessSelection");
        var readAccessList = component.get("v.readAccessList");
        
        // remove sharing access
        for (var x = 0; x < editAccessList.length; x++) {
            var found = false;
            for (var y = 0; y < editAccessSelection.length; y++) {
                if (editAccessList[x].id === editAccessSelection[y].id) {
                    found = true;
                }
            }
            if (found === false) {
                var action = component.get("c.removeProjectSharingAccess");
                action.setParams({
                    "projectId": projectId,
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
                var action = component.get("c.removeProjectSharingAccess");
                action.setParams({
                    "projectId": projectId,
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
                var action = component.get("c.addProjectSharingAccess");
                action.setParams({
                    "projectId": projectId,
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
                var action = component.get("c.addProjectSharingAccess");
                action.setParams({
                    "projectId": projectId,
                    "userId": readAccessSelection[x].id,
                    "accessLevel": "Read"
                });
                $A.enqueueAction(action);
            }
        }
    },    
    setWebPageTitle: function (component, projectId) {
        var action = component.get("c.getProjectTitle");
        action.setParams({
            "projectId": projectId
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            for (var i = 0, len = result.length; i < len; i++) {
                document.title = result[i].AgouraFree__Title__c;
                component.set("v.isTemplateValue", (result[i].AgouraFree__IsTemplate__c ? 'Yes' : ''));
                component.set("v.windowTitle", document.title); 
                component.set("v.origProjAbbrev", result[i].AgouraFree__Project_Abbreviation__c);           
            }
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
    updateProjectTasks: function (component, recId) {        
        // if the project abbreviation has changed, update all the project tasks 
        var origProjAbbrev = component.get("v.origProjAbbrev"); 
        var curProjAbbrev = component.get("v.targetFields.AgouraFree__Project_Abbreviation__c");
        
        if (origProjAbbrev != curProjAbbrev) {
            var action = component.get("c.updateProjectTaskAbbreviation");
            action.setParams({
                "projectId": recId,
                "projectAbbrev": curProjAbbrev
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Project '+recId+' Abbreviation on Project Tasks has been successfully updated');
                } else if (state === "ERROR") {
                    this.handleError(response);
                    return;
                }
            });
            $A.enqueueAction(action); 
        }
    },
    updateStakeholders: function (component, recId) {
        var action = component.get("c.updateProjectStakeholders");
            action.setParams({
                "projectId": recId,
                "execSponsorId": this.handleNulls(component.get("v.targetFields.AgouraFree__Executive_Sponsor__c")),
                "productOwnerId": this.handleNulls(component.get("v.targetFields.AgouraFree__Product_Owner__c")),
                "docOwnerId": this.handleNulls(component.get("v.targetFields.OwnerId")),
                "scrumMasterId": this.handleNulls(component.get("v.targetFields.AgouraFree__Scrum_Master__c"))
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Project ' + recId + ' stakeholders successfully updated');
                } else if (state === "ERROR") {
                    this.handleError(response);
                    return;
                }
            });
            $A.enqueueAction(action); 
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
    handleNulls: function (userField) {
        if(userField == null || userField == '') { 
            return null;
        } else {
            return userField;
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
        var fieldList = ["AgouraFree__Status__c", "AgouraFree__Executive_Sponsor__c", "AgouraFree__Product_Owner__c", "AgouraFree__Scrum_Master__c", 
                         "AgouraFree__Mission_Statement__c", "AgouraFree__Product__c", "AgouraFree__Deliverables__c", "AgouraFree__KPIs__c", "AgouraFree__Value_Trackers__c", 
                         "AgouraFree__Assumptions__c", "AgouraFree__Constraints__c", "AgouraFree__Comments__c", "AgouraFree__Project_Abbreviation__c",
                         "AgouraFree__IsTemplate__c", "AgouraFree__Title__c"];
        action.setParams({
            "objectName": "AgouraFree__Project__c",
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
    loadFieldHelpMap: function (component) {
        var action = component.get("c.getFieldHelpMap");
        var fieldList = ["AgouraFree__Project_Abbreviation__c", "AgouraFree__Title__c"];
        action.setParams({
            "objectName": "AgouraFree__Project__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            component.set('v.fieldHelpMap',response.getReturnValue());  
        });
        $A.enqueueAction(action);
    },
    joinArray : function(value){
        if(value == null) return null;        
        if(Array.isArray(value) == false) return value;        
        return value.join(';');
    },    
    loadNumRecords: function (component, recId) {
        var action = component.get("c.getNumRecords");
        action.setParams({
            "recId": recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var numRecordsMap = response.getReturnValue();  
            component.set('v.numRecords',numRecordsMap);  
        });
        $A.enqueueAction(action);
    }
})
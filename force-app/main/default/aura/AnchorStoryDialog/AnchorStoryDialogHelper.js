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
            var userAccess = false;
            result.forEach(function(item) {
                if (item.HasEditAccess == true) {
                    userAccess = true;
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
                component.set("v.modalContext", "Edit");
                this.setWebPageTitle(component, recId);
                this.loadMasterTask(component, recId); 
                this.loadSubTasks(component, recId); 
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
                    "AgouraFree__AnchorStory__c",
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
                document.title = "New Anchor Story";
                component.set("v.windowTitle", document.title);
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({"scope": "AgouraFree__AnchorStory__c"});
            homeEvt.fire();
        } else {
            this.navigateTo(component, recId);
        }
    },
    setWebPageTitle: function (component, recId) {   
        var fieldValue = '';
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
                document.title = "Edit " + item.AgouraFree__Title__c;
                component.set("v.windowTitle", document.title);
                timeEst = item.AgouraFree__Time_Estimate__c;              
            });            
            component.set("v.timeEst", this.convertTimeToString(timeEst));              
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
    convertToTime: function(timeStr) {
        // function returns timeStr in minutes
        if (timeStr == null || timeStr == '') {
            return null;
        }
        var result = 0; 
        var timeArray = timeStr.split(' ');
        var valuesEntered = timeArray.length;
        var str = '';
        for (var i = 0; i < valuesEntered; i++) {
            str = timeArray[i].toString();
            str = str.toLowerCase();
            var justNumbers = str.replace(/(?!-)[^0-9.]/g, '');
            if (str.includes("h")) {
                result += justNumbers * 60;
            } else if (str.includes("m")) {
                result += parseInt(justNumbers);
            }
        }
        return result;        
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
        var fieldList = ["AgouraFree__Description__c", "AgouraFree__Search_Terms__c", "AgouraFree__Type__c", "AgouraFree__Acceptance_Criteria__c", 
                         "AgouraFree__Value__c", "AgouraFree__Priority__c", "AgouraFree__Points__c", "AgouraFree__Time_Estimate__c", "AgouraFree__Master_Task__c", 
                         "AgouraFree__Components__c", "AgouraFree__Dependencies__c", "AgouraFree__Comments__c", "AgouraFree__Title__c",
                         "AgouraFree__Summary__c", "AgouraFree__Product_Owner__c", "AgouraFree__Project_Team__c", "AgouraFree__URL__c"];
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
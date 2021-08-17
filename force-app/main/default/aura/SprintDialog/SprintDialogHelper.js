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
                this.loadProject(component, recId);    
                this.loadUsers(component, recId);  
                this.setRetrospectiveFields(component, recId);             
                this.setWorkDayChoices(component, "Init");
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
                    "AgouraFree__Sprint__c",
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
                var myPageRef = component.get("v.pageReference");
                var projectId = myPageRef.state.AgouraFree__project;
                this.loadDefaultProject(component, projectId); 
                document.title = "New Sprint";
                component.set("v.windowTitle", document.title);
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function(component) {
        var recId = component.get("v.recordId");        
        if (!recId) {
            var project = component.get("v.projectSelection");
            var projectId = (project.length > 0) ? project[0].id : '';
            if(projectId == null || projectId == '') {
                var homeEvt = $A.get("e.force:navigateToObjectHome");
                homeEvt.setParams({"scope": "AgouraFree__Sprint__c"});
                homeEvt.fire();          
            } else {this.navigateTo(component, projectId);}
        } else {this.navigateTo(component, recId);} 
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
                document.title = "Edit " + item.AgouraFree__Project__r.AgouraFree__Title__c + " Sprint " + item.AgouraFree__Sprint_Number__c;
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
                if (item.subtitle == 'Created By') {
                    createdBy.push(result);
                } else if (item.subtitle == 'Last Modified By') {
                    lastModifiedBy.push(result);
                }                
            });
            component.set("v.createdByList", createdBy);
            component.set("v.lastModifiedByList", lastModifiedBy);
        });
        $A.enqueueAction(action);
    }, 
    loadProject: function (component, recId) {
        var action = component.get("c.getProject");
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
            var projects = [];
            result.forEach(function(item) {
                var project = {
                    id: item.Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: item.AgouraFree__Title__c,
                    subtitle: 'Project • ' + item.Name
                };
                projects.push(project);
            });
            component.set("v.projectSelection", projects);
        });
        $A.enqueueAction(action);
    },
    updateRetrospectiveFields: function (component, fieldValue) {
        if (fieldValue == null || fieldValue == "") {
            var cmpDetails = component.find("retrospectiveFields");
            $A.util.removeClass(cmpDetails, 'slds-show');
            $A.util.addClass(cmpDetails, 'slds-hide');
        } else {
            var cmpDetails = component.find("retrospectiveFields");
            $A.util.removeClass(cmpDetails, 'slds-hide');
            $A.util.addClass(cmpDetails, 'slds-show');           
        }
    },	
    setRetrospectiveFields: function (component, recId) {        
        var action = component.get("c.getEndDate");
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
            var endDate = "";    
            result.forEach(function(item) {
                endDate = item.AgouraFree__End_Date__c;
            });
            this.updateRetrospectiveFields(component,endDate);
        });
        $A.enqueueAction(action);        
    }, 
    loadDefaultProject: function (component, recId) {
        var action = component.get("c.getDefaultProject");
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
            var projects = [];
            result.forEach(function(item) {
                var project = {
                    id: item.Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: item.AgouraFree__Title__c,
                    subtitle: 'Project • ' + item.Name
                };
                projects.push(project);
            });
            component.set("v.projectSelection", projects);
            this.loadDefaultFields(component, recId);
        });
        $A.enqueueAction(action);
    }, 
    loadDefaultFields: function (component, recId) {
        var action = component.get("c.getDefaultFields");
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
            var workDays = "";
            result.forEach(function(item) {  
                var sprintLength = item.AgouraFree__Sprint_Length__c;
                component.set("v.defaultSprintLength", sprintLength);            
                component.set("v.defaultTargetPoints", item.AgouraFree__Target_Points__c);      
                component.set("v.defaultVersion", item.AgouraFree__Version__c);  
                var workDaysValueStr = item.AgouraFree__Work_Days_Report__c;
                var workDaysValueArray = workDaysValueStr.split(';');
                var startDate = new Date(item.AgouraFree__End_Date__c);
                var endDate = new Date(item.AgouraFree__End_Date__c);
                startDate.setTime(startDate.getTime() + (864e5*2));
                var sprintDays = 0;
                if (sprintLength == '1 week') {
                    sprintDays = 7;
                } else if (sprintLength == '2 weeks') {
                    sprintDays = 14;
                } else if (sprintLength == '3 weeks') {
                    sprintDays = 21;
                } else if (sprintLength == '4 weeks') {
                    sprintDays = 28;
                }
                if (sprintLength == '1 week') {
                    endDate.setTime(startDate.getTime() + (864e5*6));
                } else if (sprintLength == '2 weeks') {
                    endDate.setTime(startDate.getTime() + (864e5*13));
                } else if (sprintLength == '3 weeks') {
                    endDate.setTime(startDate.getTime() + (864e5*20));
                } else if (sprintLength == '4 weeks') {
                    endDate.setTime(startDate.getTime() + (864e5*27));
                }
                var sMonth = "0" + (startDate.getMonth() + 1);
                var sDate = "0" + startDate.getDate();
                var eMonth = "0" + (endDate.getMonth() + 1);
                var eDate = "0" + endDate.getDate();
                component.set("v.defaultStartDate", startDate.getFullYear() + "-" + sMonth.slice(-2) + "-" + sDate.slice(-2));  
                component.set("v.defaultEndDate", endDate.getFullYear() + "-" + eMonth.slice(-2) + "-" + eDate.slice(-2)); 
                var endDate2 = new Date(endDate);
                endDate2.setTime(endDate2.getTime() + (864e5*2));
                var dateList = [];
                var row = 1;
                for (var i = 1; i <= sprintDays; i++) {
                    var thisDate = new Date(startDate);
                    thisDate.setTime(thisDate.getTime() + (864e5*(i-1)));
                    if (endDate == null || thisDate < endDate2) {
                        var day = $A.localizationService.formatDate(thisDate, "EEE");
                        var isSelected = workDaysValueArray.includes(i.toString());
                        var result = {
                            row: row,
                            day: day,
                            label: $A.localizationService.formatDate(thisDate, "dd-MMM"),
                            value: i,
                            isSelected: isSelected
                        };
                        dateList.push(result); 
                        if (day == 'Sun') {
                            row += 1;
                        }                   
                    } 
                }
                component.set("v.workDayChoices", dateList);
            });
        });
        $A.enqueueAction(action);
    }, 
    setWorkDayChoices: function (component, action) {
        if (action == "Init") {
            var recId = component.get("v.recordId"); 
            var action = component.get("c.getStartDate");
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
                var startDate = result[0].AgouraFree__Start_Date__c;
                var endDate = result[0].AgouraFree__End_Date__c;
                var sprintLength = result[0].AgouraFree__Sprint_Length__c;
                var workDaysValueStr = result[0].AgouraFree__Work_Days_Report__c || '';                
                this.setWorkDayChoices2(component, startDate, endDate, sprintLength, workDaysValueStr);
            });
            $A.enqueueAction(action); 
        } else {
            var startDate = component.find('propStartDate').get("v.value"); 
            var endDate = component.find('propEndDate').get("v.value"); 
            var sprintLength = component.find('propSprintLength').get("v.value");  
            var workDaysField = document.getElementsByName('workDays');
            var workDaysValue = [];
            for(var i = 0; i < workDaysField.length; ++i) {
                if(workDaysField[i].checked) {
                    workDaysValue.push(workDaysField[i].value);
                }
            }
            workDaysValue.sort(function(a,b){return a - b});
            var workDaysValueStr = workDaysValue.join(';');
            this.setWorkDayChoices2(component, startDate, endDate, sprintLength, workDaysValueStr);
        }
    }, 
    setWorkDayChoices2: function (component, startDate, endDate, sprintLength, workDaysValueStr) {
        component.set("v.startDate", startDate);        
        if (startDate != null) {
            var workDaysValueArray = workDaysValueStr.split(';');
            var sprintDays = 0;
            if (sprintLength == '1 week') {
                sprintDays = 7;
            } else if (sprintLength == '2 weeks') {
                sprintDays = 14;
            } else if (sprintLength == '3 weeks') {
                sprintDays = 21;
            } else if (sprintLength == '4 weeks') {
                sprintDays = 28;
            }
            var endDate2 = new Date(endDate);
            endDate2.setTime(endDate2.getTime() + (864e5*2));
            var dateList = [];
            var row = 1;
            for (var i = 1; i <= sprintDays; i++) {
                var thisDate = new Date(startDate);
                thisDate.setTime(thisDate.getTime() + (864e5*i));
                if (endDate == null || thisDate < endDate2) {
                    var day = $A.localizationService.formatDate(thisDate, "EEE");
                    var isSelected = workDaysValueArray.includes(i.toString());
                    var result = {
                        row: row,
                        day: day,
                        label: $A.localizationService.formatDate(thisDate, "dd-MMM"),
                        value: i,
                        isSelected: isSelected
                    };
                    dateList.push(result); 
                    if (day == 'Sun') {
                        row += 1;
                    }                   
                } 
            }
            component.set("v.workDayChoices", dateList);  
        } else {
            component.set("v.workDayChoices", ""); 
        }
    },
    doSaveRecord: function (component) {
        var tempRec = component.find("forceRecord");
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var project = component.get("v.projectSelection");
            var projectName = project[0].title;
            var recName = component.get("v.targetFields.AgouraFree__Sprint_Number__c");
            var toastMsg = projectName + " Sprint " + recName + " was saved.";
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                resultsToast.setParams({"message": toastMsg, "type": "success"});
                resultsToast.fire();  
                var recId = result.recordId;
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recId
                });
                navEvt.fire();
            } else if (result.state === "ERROR") {
                this.handleError(result);
                return;
            } else {
                console.log("Unknown error");
            }
        }));
    },
    setSprintNumberCompletedPoints: function (component, projectId) {
        var action = component.get("c.updateSprintNumberCompletedPoints");
        action.setParams({
            "projectId": projectId,
            "sprintId": component.get("v.targetFields.Id")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue(); 
            if (state === "SUCCESS") {
                component.set("v.targetFields.AgouraFree__Sprint_Number__c", result.AgouraFree__Sprint_Number__c);
                component.set("v.targetFields.AgouraFree__Sprint_Name__c", 'Sprint ' + result.AgouraFree__Sprint_Number__c);
                component.set("v.targetFields.AgouraFree__Completed_Points__c", result.AgouraFree__Completed_Points__c);
                this.doSaveRecord(component);
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
        var fieldList = ["AgouraFree__Sprint_Number__c", "AgouraFree__Target_Points__c", "AgouraFree__Completed_Points__c", "AgouraFree__Start_Date__c", 
                         "AgouraFree__End_Date__c", "AgouraFree__What_went_well__c", "AgouraFree__What_did_not_go_well__c", 
                         "AgouraFree__What_can_we_do_different_next_time__c", "AgouraFree__Sprint_Length__c", "AgouraFree__Version__c", 
                         "AgouraFree__Work_Days_Report__c", "AgouraFree__Sprint_Goal__c"];
        action.setParams({
            "objectName": "AgouraFree__Sprint__c",
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
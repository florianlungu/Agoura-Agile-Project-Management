({
    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    checkAccess: function (component, recId) {
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
            for (var i = 0, len = result.length; i < len; i++) {
                if (result[i].HasEditAccess == true) {
                    component.set("v.hasEditAccess", true);
                }
                if (result[i].HasDeleteAccess == true) {
                    component.set("v.hasDeleteAccess", true);
                }                
            }    
        });
        $A.enqueueAction(action);
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
            for (var i = 0, len = result.length; i < len; i++) {
                document.title = result[i].AgouraFree__Project__r.AgouraFree__Title__c + " Sprint " + result[i].AgouraFree__Sprint_Number__c;
                component.set("v.windowTitle", document.title);           
            }
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
            for (var i = 0, len = result.length; i < len; i++) {
                var project = {
                    id: result[i].Id,
                    sObjectType: 'AgouraFree__Project__c',
                    icon: 'standard:drafts',
                    title: result[i].AgouraFree__Title__c,
                    subtitle: 'Project • ' + result[i].Name
                };
                projects.push(project);
            }
            component.set("v.projectSelection", projects);
        });
        $A.enqueueAction(action);
    },
    confirmDelete: function(component, event, helper) {
        component.set("v.showConfirmDeleteModal", true);
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
    // Sprint Task List
    loadSprintTaskItems: function (component, sprintId, doAction) {
        var action = component.get("c.getSprintTaskItems");
        action.setParams({
            "sprintId": sprintId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var sprintTaskItems = [];
            var projectSwimLaneSelection = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var tableStatus = result[i].AgouraFree__Status__c + (result[i].AgouraFree__Blocked__c ? ' (Blocked)' : '');
                var assignedToName = '';
                if (result[i].AgouraFree__Assigned_To__r != null) {
                    assignedToName = result[i].AgouraFree__Assigned_To__r.Name;
                }
                var swimLaneTitle = '';
                if (result[i].AgouraFree__Swim_Lane__r != null) {
                    swimLaneTitle = result[i].AgouraFree__Swim_Lane__r.AgouraFree__Title__c;                   
                } 
                var sprintTaskItem = {
                    projectId: result[i].AgouraFree__Project__c,
                    sprintId: component.get("v.recordId"),
                    projectTaskId: result[i].Id,
                    taskName: result[i].AgouraFree__Task_Number__c,
                    title: result[i].AgouraFree__Title__c,
                    type: result[i].AgouraFree__Formatted_Type__c,
                    status: result[i].AgouraFree__Status__c,
                    formattedStatus: result[i].AgouraFree__Formatted_Status__c,
                    tag: "",
                    points: result[i].AgouraFree__Points__c,
                    assignedTo: result[i].AgouraFree__Assigned_To__c,
                    assignedToName: assignedToName,
                    blocked:result[i].AgouraFree__Blocked__c,
                    tableStatus: tableStatus,
                    swimLaneId: result[i].AgouraFree__Swim_Lane__c,
                    swimLaneTitle: swimLaneTitle
                };
                sprintTaskItems.push(sprintTaskItem);
                if (!projectSwimLaneSelection.includes(swimLaneTitle)) {
                    projectSwimLaneSelection.push(swimLaneTitle);                
                }
            }
            component.set("v.sprintTaskItems", sprintTaskItems);
            projectSwimLaneSelection.sort();
            component.set("v.projectSwimLaneSelection", projectSwimLaneSelection);
            this.calculateSprint(component);
            if (doAction == 'Update') {
                var resultsToast = $A.get("e.force:showToast");          
                resultsToast.setParams({"message": "Project Task updated", "type": "success"});
                resultsToast.fire()
            }
        });
        $A.enqueueAction(action);
    },
    updateItem: function (component, sprintTaskItem, doAction) {
        var action = component.get("c.updateSprintTaskItem");
        var sprintId = component.get("v.recordId")
        action.setParams({
            "sprintTaskId": sprintTaskItem.projectTaskId,
            "sprintId": sprintId,
            "doAction": doAction
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            this.loadAssignedToList(component, sprintId);
            this.loadSprintTaskItems(component, sprintId, 'Update');
            this.loadBurnUpChartData(component, sprintId); 
            this.calculateSprint(component);
        });
        $A.enqueueAction(action);
    },
    updateSwimLane: function (component, sprintTaskItem, swimLaneId) {
        var sprintId = component.get("v.recordId");
        var action = component.get("c.updateTaskSwimLane");
        action.setParams({
            "sprintTaskId": sprintTaskItem.projectTaskId,
            "swimLaneId": swimLaneId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            this.loadSprintTaskItems(component, sprintId, 'Update');
            this.loadBurnUpChartData(component, sprintId); 
            this.calculateSprint(component);
        });
        $A.enqueueAction(action);
    },
    removeItem: function (component, sprintTaskItem, doAction) {
        var action = component.get("c.updateSprintTaskItem");
        action.setParams({
            "sprintTaskId": sprintTaskItem.projectTaskId,
            "sprintId": null,
            "doAction": doAction
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            console.log(result);
            var sprintTaskItems = component.get("v.sprintTaskItems");
            for (var i = 0; i < sprintTaskItems.length; i++) {
                if (sprintTaskItems[i].projectTaskId === sprintTaskItem.projectTaskId) {
                    sprintTaskItems.splice(i, 1);
                    component.set("v.sprintTaskItems", sprintTaskItems);
                    this.calculateSprint(component);
                    return;
                }
            }
        });
        $A.enqueueAction(action);
    },	
    loadTargetPoints: function (component, sprintId) {        
        var action = component.get("c.getTargetPoints");
        action.setParams({
            "sprintId": sprintId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            for (var i = 0, len = result.length; i < len; i++) {
                component.set("v.targetPoints", result[i].AgouraFree__Target_Points__c);  
            }
        });
        $A.enqueueAction(action);        
    },
    calculateSprint: function (component) {
        var sprintTaskItems = component.get("v.sprintTaskItems");
        var oldSprintPoints = component.get("v.sprintPoints");
        var sprintPoints = 0;
        var completedPoints = 0;
        if (sprintTaskItems && Array.isArray(sprintTaskItems)) {
            for (var i = 0, len = sprintTaskItems.length; i < len; i++) {
                sprintPoints = sprintPoints + (sprintTaskItems[i].points || 0);                
                if (sprintTaskItems[i].status == "Resolved" || sprintTaskItems[i].status == "Done") {
                    completedPoints = completedPoints + (sprintTaskItems[i].points || 0);
                }  
            }
            component.set("v.sprintPoints", sprintPoints);
            component.set("v.completedPoints", completedPoints);
            var sprintPointsEl = component.find("sprintPoints");
            if (sprintPointsEl && sprintPointsEl.getElement()) {
                var numAnim = new CountUp(sprintPointsEl.getElement(), oldSprintPoints, sprintPoints, 0, 0.5);
                numAnim.start();
            }
        };
    },
    viewRecord: function(row) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": row.projectTaskId });
        navigateEvent.fire();
    },
    hasRemoveAccess: function (component, recId) {
        var action = component.get("c.removeAccess");
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
            component.set('v.hasRemoveAccess', result);    
        });
        $A.enqueueAction(action);
    },
    sortDataTable: function (cmp, fieldName, sortDirection, dataList) {
        var data = cmp.get(dataList);
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set(dataList, data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    loadBurnUpChartData: function (component, sprintId) {
        var action = component.get("c.getCompletedPoints");
        action.setParams({
            "sprintId": sprintId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var sprintTaskItems = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var thisDate = new Date(result[i].AgouraFree__End_Date__c);
                var sprintTaskItem = {
                    endDate: $A.localizationService.formatDateUTC(thisDate, "dd-M-yyyy"),
                    points: result[i].points || 0
                };
                sprintTaskItems.push(sprintTaskItem);
            }
            component.set("v.burnUpChartData", sprintTaskItems);
        });
        $A.enqueueAction(action);
    },    
    loadSwimLaneList: function (component, recId) {
        var action = component.get("c.getProjectSwimLanes");
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
            var swimLanes = [];
            for (var i = 0, len = result.length; i < len; i++) {
                var resultItem = {
                    id: result[i].Id,
                    title: result[i].AgouraFree__Title__c
                };
                swimLanes.push(resultItem);
            }
            if (swimLanes.length > 0) {
                var resultItem = {
                    id: null,
                    title: '--None--'
                };
                swimLanes.unshift(resultItem);  
            }
            component.set("v.projectSwimLanesList", swimLanes);  
        });
        $A.enqueueAction(action);
    },
    loadAssignedToList: function (component, recId) {
        var action = component.get("c.getAssignedToList");
        if (typeof action !== 'undefined') {
            action.setParams({"recId": recId});
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "ERROR") {
                    this.handleError(response);
                    return;
                }
                var result = response.getReturnValue();
                var assignedTo = [];
                for (var i = 0, len = result.length; i < len; i++) {
                    var resultItem = {
                        id: result[i].id,
                        sObjectType: result[i].sObjectType,
                        icon: result[i].icon,
                        title: result[i].title,
                        subtitle: result[i].sObjectType + ' • ' + result[i].title
                    };
                    assignedTo.push(resultItem);
                }
                component.set("v.assignedToList", assignedTo);
            });
            $A.enqueueAction(action);
        }
    },
    loadProjectTasks : function(component, page) {
        var action = component.get("c.getProjectTasks");
        var pageSize = component.get("v.pageSize");
        action.setParams({
            "filters": JSON.stringify(component.get("v.filterObject")),
            "pageSize": pageSize,
            "pageNumber": page || 1,
            "sprintId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            // console.log('# getProjectTasks callback %f', (performance.now() - startTime));
            var result = response.getReturnValue();
            component.set("v.items", result.items);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.max(Math.ceil(result.total/pageSize),1));
        });
        var startTime = performance.now();
        $A.enqueueAction(action);
    },
    refreshSprint : function (component, recId, actionTrigger) {     
        var refreshWait = component.get("v.refreshWait");
        if (refreshWait && actionTrigger !== "manual") {
            component.set("v.refreshWait", false);
        } else {
            this.loadAssignedToList(component, recId);
            this.loadSwimLaneList(component, recId);
            this.loadSprintTaskItems(component, recId, 'Init'); 
            this.loadBurnUpChartData(component, recId); 
            this.loadTargetPoints(component, recId); 
            this.loadProjectTasks(component); 
            if (actionTrigger === "manual") {            
                var resultsToast = $A.get("e.force:showToast");          
                resultsToast.setParams({"message": "Sprint Task List updated", "type": "success"});
                resultsToast.fire()
            }            
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
    },
    loadFieldLabelMapTasks: function (component, recId) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Title__c", "AgouraFree__Type__c", "AgouraFree__Status__c", "AgouraFree__Points__c", "AgouraFree__Due_Date__c", 
                         "AgouraFree__Priority__c", "AgouraFree__Assigned_To__c", "AgouraFree__Order__c", "AgouraFree__Task_Number__c"];
        action.setParams({
            "objectName": "AgouraFree__ProjectTask__c",
            "fieldList": fieldList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }   
            var fieldLabelMapTasks = response.getReturnValue();
            component.set('v.fieldLabelMapTasks',fieldLabelMapTasks);  
            
            // Sprint Task List
            var actions = [
                { label: 'View', name: 'view' },
                { label: 'Start', name: 'start' },
                { label: 'Complete', name: 'complete' },            
                { label: 'Edit', name: 'edit' },
                { label: 'Remove', name: 'remove' }
            ];  
            var columns = [
                {label: fieldLabelMapTasks.AgouraFree__Task_Number__c, fieldName: 'taskName', type: 'text', initialWidth: 110, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Type__c, fieldName: 'type', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Status__c, fieldName: 'status', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Points__c, fieldName: 'points', type: 'number', initialWidth: 100, sortable: true, cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMapTasks.AgouraFree__Assigned_To__c, fieldName: 'assignedToName', type: 'text', initialWidth: 300, sortable: true},
                {type: 'action', typeAttributes: {rowActions: actions} } 
            ];
            component.set("v.columns", columns); 
            
            var actionsNoRemove = [
                { label: 'View', name: 'view' },
                { label: 'Start', name: 'start' },
                { label: 'Complete', name: 'complete' },            
                { label: 'Edit', name: 'edit' }
            ];  
            var columnsNoRemove = [
                {label: fieldLabelMapTasks.AgouraFree__Task_Number__c, fieldName: 'taskName', type: 'text', initialWidth: 110, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Type__c, fieldName: 'type', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Status__c, fieldName: 'status', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Points__c, fieldName: 'points', type: 'number', initialWidth: 100, sortable: true, cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMapTasks.AgouraFree__Assigned_To__c, fieldName: 'assignedToName', type: 'text', initialWidth: 300, sortable: true},
                {type: 'action', typeAttributes: {rowActions: actionsNoRemove} } 
            ];
            component.set("v.columnsNoRemove", columnsNoRemove); 
            
            var actionsNoEdit = [
                { label: 'View', name: 'view' }
            ];  
            var columnsNoEdit = [
                {label: fieldLabelMapTasks.AgouraFree__Task_Number__c, fieldName: 'taskName', type: 'text', initialWidth: 110, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Title__c, fieldName: 'title', type: 'text', sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Type__c, fieldName: 'type', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Status__c, fieldName: 'status', type: 'text', initialWidth: 150, sortable: true},
                {label: fieldLabelMapTasks.AgouraFree__Points__c, fieldName: 'points', type: 'number', initialWidth: 100, sortable: true, cellAttributes: { alignment: 'left' }},
                {label: fieldLabelMapTasks.AgouraFree__Assigned_To__c, fieldName: 'assignedToName', type: 'text', initialWidth: 300, sortable: true},
                {type: 'action', typeAttributes: {rowActions: actionsNoEdit} } 
            ];
            component.set("v.columnsNoEdit", columnsNoEdit);            
            
            this.loadAssignedToList(component, recId);
            this.loadSwimLaneList(component, recId);
            this.loadSprintTaskItems(component, recId, 'Init'); 
            this.loadBurnUpChartData(component, recId); 
            this.loadTargetPoints(component, recId);
            
            // Backlog
            var filterObject = {
                searchKey: '',
                typeKey: ''
            };
            component.set("v.filterObject", filterObject);
            this.loadProjectTasks(component);   
        });
        $A.enqueueAction(action);
    }
})
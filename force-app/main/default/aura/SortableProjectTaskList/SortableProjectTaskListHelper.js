({
    reorderMethod : function(component, event, helper, doAction) {
        // original list
        var origList = [];
        var lastOrderNumber = 0;
        var projectTasks = component.get("v.projectTaskSortList");    
        if (projectTasks && Array.isArray(projectTasks)) {
            for (var i = 0, len = projectTasks.length; i < len; i++) {
                var resultItem = {
                    Id: projectTasks[i].Id,
                    AgouraFree__Order__c: projectTasks[i].AgouraFree__Order__c
                };
                if (projectTasks[i].AgouraFree__Order__c != '' && projectTasks[i].AgouraFree__Order__c != null) {
                    lastOrderNumber = projectTasks[i].AgouraFree__Order__c;
                }
                origList.push(resultItem);
            }           
        }
        
        // set temp new sort number
        var newIndex = component.get("v.newIndex");         
        var oldIndex = component.get("v.oldIndex"); 
        if (doAction == "First") {
            origList[oldIndex].AgouraFree__Order__c = 0;
        } else if (doAction == "Last") {
            origList[oldIndex].AgouraFree__Order__c = 999999;
        } else if (newIndex < oldIndex) {
            origList[oldIndex].AgouraFree__Order__c = origList[newIndex].AgouraFree__Order__c - 0.1;
        } else if (newIndex > oldIndex) { 
            if (origList[newIndex] == undefined) {
                origList[oldIndex].AgouraFree__Order__c = lastOrderNumber + 0.1;
            } else {
                if (origList[newIndex].AgouraFree__Order__c == '' || origList[newIndex].AgouraFree__Order__c == null) {
                    origList[oldIndex].AgouraFree__Order__c = lastOrderNumber + 0.1;
                } else {
                    origList[oldIndex].AgouraFree__Order__c = origList[newIndex].AgouraFree__Order__c + 0.1;
                }
            }
        }
        
        var newList = [];
        var resultItem = {
            Id: origList[oldIndex].Id,
            AgouraFree__Order__c: origList[oldIndex].AgouraFree__Order__c
        };
        newList.push(resultItem); 
        
        // update
        var action = component.get("c.sortProjectTasks");
        var projectId = component.get("v.recStr"); 
        action.setParams({
            "projectId": projectId,
            "projectTasksData": newList
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var page = component.get("v.page") || 1;
            this.loadProjectTasks(component, "Reorder", page);           
        });
        $A.enqueueAction(action);    
    },    
    loadProjectTasks: function (component, doAction, page) {
        var action = component.get("c.getProjectTasks");
        var pageSize = component.get("v.pageSize");
        action.setParams({
            "filters": JSON.stringify(component.get("v.filterObject")),
            "pageSize": pageSize,
            "pageNumber": page || 1,
            "projectId": component.get("v.recStr")
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            this.isDesktop(component);
            var result = response.getReturnValue();
            if (result != null) {
                component.set("v.projectTasks", result.items);
                component.set('v.projectTaskSortList',result.sortlist); 
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                if (result.total == 0) {
                    component.set("v.pages", 1);
                } else {
                    component.set("v.pages", Math.max(Math.ceil(result.total/pageSize),1));
                }                
            } else {
                component.set("v.page", 1);
                component.set("v.total", 0);
                component.set("v.pages", 1);    
            }
            var myEvent = $A.get("e.Agoura:sortevent");            
            
            $( "#sortable" ).sortable({
                start: function(e, ui) {
                    // creates a temporary attribute on the element with the old index
                    $(this).attr('data-previndex', ui.item.index());
                },
                update: function(e, ui) {
                    var v = component.get("v.bropped");
                    component.set("v.bropped",!v);
                },
                beforeStop: function( event, ui ) {
                    var newIndex = ui.item.index();
                    var oldIndex = $(this).attr('data-previndex');
                    component.set("v.newIndex",newIndex);
                    component.set("v.oldIndex",oldIndex);
                    $(this).removeAttr('data-previndex');
                }
            });                        
            $( "#sortable" ).sortable({
                cancel: ".ui-state-disabled"
            });            
            $( "#sortable td" ).disableSelection();
            
            if (doAction == "Refresh" || doAction == "Delete") {         
                var resultsToast = $A.get("e.force:showToast");          
                resultsToast.setParams({"message": "Project Task List refreshed", "type": "success"});
                resultsToast.fire()
            } else if (doAction == "Reorder") {         
                var resultsToast = $A.get("e.force:showToast");          
                resultsToast.setParams({"message": "Project Task List updated", "type": "success"});
                resultsToast.fire()
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
    isDesktop: function (component) {
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
            component.set("v.isDesktop", "");
        } else {
            component.set("v.isDesktop", "slds-hide");
        }
    }
})
({
    loadRecords: function (component, doAction, page) {
        var viewName = component.get("v.view");
        var actionName = "";
        if (viewName == "Home") {
            actionName = "c.getHomeRecordList";
        } else {
           actionName = "c.getViewRecordList"; 
        } 
        var action = component.get(actionName);
        var pageSize = component.get("v.pageSize");
        action.setParams({
            "filters": JSON.stringify(component.get("v.filterObject")),
            "pageSize": pageSize,
            "pageNumber": page || 1,
            "viewName": viewName
        }); 
        action.setCallback(this,function(response){  
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }          
            var result = response.getReturnValue();
            if (result != null) {
                var itemList = [];                
                
                // Home Query
                if (viewName == 'Home') {
                    var viewItems = result.viewItems;
                    for (var i = 0, len = viewItems.length; i < len; i++) {
                        var recordItem = {
                            id: viewItems[i].id,
                            uniqueId: viewItems[i].uniqueId,
                            icon: viewItems[i].icon,
                            objectName: viewItems[i].sObjectType,
                            title: viewItems[i].title,
                            status: viewItems[i].status,
                            blocked: viewItems[i].blocked,
                            createdDate: viewItems[i].createdDate,
                            lastModifiedDate: viewItems[i].lastModifiedDate,
                            canEdit: viewItems[i].canEdit
                        };
                        itemList.push(recordItem);                       
                    }                    
                    component.set("v.itemList", itemList);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);                
                    
                    component.set("v.pages", Math.max(Math.ceil(result.total/pageSize),1));
                    var viewTotal = '';    
                    if (result.ideaBoardTotal !== undefined) {
                        if (result.ideaBoardTotal == 1) {
                            viewTotal = viewTotal + '1 Idea Board - ';
                        } else if (result.ideaBoardTotal > 0) {
                            viewTotal = viewTotal + result.ideaBoardTotal + ' Idea Boards - ';
                        }
                    }
                    if (result.projectTotal == 1) {
                        viewTotal = viewTotal + '1 Project - ';
                    } else if (result.projectTotal > 0) {
                        viewTotal = viewTotal + result.projectTotal + ' Projects - ';
                    }
                    if (result.sprintTotal == 1) {
                        viewTotal = viewTotal + '1 Sprint - ';
                    } else if (result.sprintTotal > 0) {
                        viewTotal = viewTotal + result.sprintTotal + ' Sprints - ';
                    }
                    if (result.taskTotal == 1) {
                        viewTotal = viewTotal + '1 Project Task - ';
                    } else if (result.taskTotal > 0) {
                        viewTotal = viewTotal + result.taskTotal + ' Project Tasks - ';
                    }
                    if (viewTotal.length > 3) {
                        viewTotal = viewTotal.substring(0, viewTotal.length - 3);
                    }
                    component.set("v.viewTotal", result.total + " Records ( " + viewTotal + " )");
                    
                // Anchor Stories, Idea Boards, Project Tasks, Projects, Sprints, Tags Query    
                } else if (['Anchor Stories', 'Idea Boards', 'Project Tasks', 'Projects', 'Project Templates', 'Sprints', 'Tags'].indexOf(viewName) >= 0) {
                    var viewItems = result.viewItems;
                    for (var i = 0, len = viewItems.length; i < len; i++) {
                       var recordItem = {
                            id: viewItems[i].id,
                            uniqueId: viewItems[i].uniqueId,
                            icon: viewItems[i].icon,
                            objectName: viewItems[i].sObjectType,
                            title: viewItems[i].title,
                            status: viewItems[i].status,
                            blocked: viewItems[i].blocked,
                            points: viewItems[i].points,
                            otherString: viewItems[i].otherString,
                            createdDate: viewItems[i].createdDate,
                            lastModifiedDate: viewItems[i].lastModifiedDate,
                            canEdit: viewItems[i].canEdit
                        };
                        itemList.push(recordItem); 
                    }
                    
                    component.set("v.itemList", itemList);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total); 
                    component.set("v.pages", Math.max(Math.ceil(result.total/pageSize),1));
                    if (result.total == 1) {
                        component.set("v.viewTotal", result.total + " Record");                        
                    } else {
                        component.set("v.viewTotal", result.total + " Records");
                    }    
                }
            }
            
            if (doAction == "Refresh") {         
                var resultsToast = $A.get("e.force:showToast");          
                resultsToast.setParams({"message": "Record List refreshed", "type": "success"});
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
    loadFieldLabelMap: function (component, viewName) {
        var action = component.get("c.getFieldLabelMap");
        var fieldList = ["AgouraFree__Title__c", "AgouraFree__Status__c"];
        var objectName = "";
        
        if (viewName == "Projects" || viewName == "Project Templates") {
            objectName = "AgouraFree__Project__c";
        } else if (viewName == "Sprints") {
            objectName = "AgouraFree__Project__c";
        } else if (viewName == "Project Tasks") {
            objectName = "AgouraFree__ProjectTask__c";
        } else if (viewName == "Anchor Stories") {
            objectName = "AgouraFree__AnchorStory__c";
            fieldList = ["AgouraFree__Title__c", "AgouraFree__Points__c", "AgouraFree__Search_Terms__c"];
        } else if (viewName == "Tags") {
            objectName = "AgouraFree__Tag__c";
            fieldList = ["Name"];
        } else if (viewName == "Idea Boards") {
            objectName = "AgouraFree__IdeaBoard__c";
        }
        
        action.setParams({
            "objectName": objectName,
            "fieldList": fieldList
        });
        if (objectName != "") {
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
    }
})
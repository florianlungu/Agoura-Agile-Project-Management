({
    doinit: function(component, event, helper) {  
        var filterObject = {
            searchKey: '',
            typeKey: '',
            rowKey: '10',
            sprintKey: 'BacklogLatest'
        };
        component.set("v.filterObject", filterObject);
        helper.loadProjectTasks(component, "Initial Page Load", 1);
    },    
    doaction: function(component, event, helper){        
        helper.reorderMethod(component, event, helper, "Manual Move");
    },
    toBottomTaskHandler: function(component, event, helper){ 
        var oldIndex = event.getSource().get("v.value");
        component.set("v.oldIndex",oldIndex);
        helper.reorderMethod(component, event, helper, "Last");
    },
    toTopTaskHandler: function(component, event, helper){ 
        var oldIndex = event.getSource().get("v.value");
        component.set("v.oldIndex",oldIndex);
        helper.reorderMethod(component, event, helper, "First");
    },
    addNewProjectTask : function(component, event, helper) {
        var projectId = component.get("v.recStr"); 
        var addNewTaskEvent = $A.get("e.force:createRecord");        
		addNewTaskEvent.setParams({
    		"entityApiName": "AgouraFree__ProjectTask__c",
    		"defaultFieldValues": {'AgouraFree__Project__c' : projectId}
		});
		addNewTaskEvent.fire(); 
    },
    refreshProjectTasksList : function(component, event, helper) {
        var page = component.get("v.page") || 1;
        helper.loadProjectTasks(component, "Refresh", page);
    },
    onFirstPage: function(component, event, helper) {
        helper.loadProjectTasks(component, "Page", 1);
	},
    onPreviousPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        page = page - 1;
        helper.loadProjectTasks(component, "Page", page);
	},
	onNextPage: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        page = page + 1;
        helper.loadProjectTasks(component, "Page", page);
	},
	onLastPage: function(component, event, helper) {
		var page = component.get("v.pages") || 1;
        helper.loadProjectTasks(component, "Page", page);
	},
    filterChangeHandler: function(component, event, helper) {
        var filterObject = component.get("v.filterObject");
        if (event.getParam("searchKey") !== undefined) {
	        filterObject.searchKey = event.getParam("searchKey");
        }
        if (event.getParam("typeKey") !== undefined) {
	        filterObject.typeKey = event.getParam("typeKey");
        } 
        if (event.getParam("rowKey") !== undefined) {
	        filterObject.rowKey = event.getParam("rowKey");
            component.set("v.pageSize", event.getParam("rowKey"));
        } 
        if (event.getParam("sprintKey") !== undefined) {
	        filterObject.sprintKey = event.getParam("sprintKey");
        }        
        helper.loadProjectTasks(component, "Refresh", 1);
    }
})
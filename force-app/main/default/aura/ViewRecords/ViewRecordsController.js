({
    doInit: function(component, event, helper) { 
        var viewName = component.get("v.view");
        var assignedKey = '';
        if (viewName == 'Home') {
            assignedKey = 'Me';
        }
        var filterObject = {
            searchKey: '',
            statusKey: '',
            rowKey: '10',
            assignedKey: assignedKey
        };
        component.set("v.filterObject", filterObject);        
        if (['Home', 'Idea Boards', 'Project Tasks', 'Projects', 'Project Templates', 'Sprints'].indexOf(viewName) >= 0) {
            component.set("v.showView", "1");
        } else if (viewName == 'Tags') {
            component.set("v.showView", "2");
        } else if (viewName == 'Anchor Stories') {
            component.set("v.showView", "3");
        }
        helper.loadFieldLabelMap(component, viewName);
        helper.loadRecords(component, "Initial Page Load", 1);
    },
    refreshProjectTasksList : function(component, event, helper) {
        var page = component.get("v.page") || 1;
        helper.loadRecords(component, "Refresh", page);
    },
    onFirstPage: function(component, event, helper) {
        helper.loadRecords(component, "Page", 1);
    },
    onPreviousPage: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        page = page - 1;
        helper.loadRecords(component, "Page", page);
    },
    onNextPage: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        page = page + 1;
        helper.loadRecords(component, "Page", page);
    },
    onLastPage: function(component, event, helper) {
        var page = component.get("v.pages") || 1;
        helper.loadRecords(component, "Page", page);
    },
    filterChangeHandler: function(component, event, helper) {
        var filterObject = component.get("v.filterObject");
        if (event.getParam("searchKey") !== undefined) {
            filterObject.searchKey = event.getParam("searchKey");
        }
        if (event.getParam("statusKey") !== undefined) {
            filterObject.statusKey = event.getParam("statusKey");
        } 
        if (event.getParam("assignedKey") !== undefined) {
            filterObject.assignedKey = event.getParam("assignedKey");
        } 
        if (event.getParam("rowKey") !== undefined) {
            filterObject.rowKey = event.getParam("rowKey");
            component.set("v.pageSize", event.getParam("rowKey"));
        }        
        helper.loadRecords(component, "Refresh", 1);
    }
})
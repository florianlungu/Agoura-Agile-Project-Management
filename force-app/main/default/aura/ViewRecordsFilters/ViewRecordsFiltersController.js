({
    doInit: function(component, event, helper) { 
        var viewName = component.get("v.view");              
        if (['Home', 'Project Tasks', 'Projects', 'Project Templates', 'Sprints'].indexOf(viewName) >= 0) {
            component.set("v.showView", "1");
        } else if (viewName == 'Tags' || viewName == 'Anchor Stories') {
            component.set("v.showView", "2");
        } else if (viewName == 'Idea Boards') {
            component.set("v.showView", "3");
        }
        helper.hasProjects(component);
    },
	searchKeyChangeHandler : function(component, event) {
        var changeEventSearch = $A.get("e.c:ViewRecordsFilterChange");
        changeEventSearch.setParams({
            "searchKey": event.getParam("value")
        });
        changeEventSearch.fire();
	},
    statusKeyChangeHandler : function(component, event) {
        var changeEventStatus = $A.get("e.c:ViewRecordsFilterChange");
        changeEventStatus.setParams({
            "statusKey": event.getParam("value")
        });
        changeEventStatus.fire();
    },
    assignedKeyChangeHandler : function(component, event) {
        var changeEventAssigned = $A.get("e.c:ViewRecordsFilterChange");
        changeEventAssigned.setParams({
            "assignedKey": event.getParam("value")
        });
        changeEventAssigned.fire();
    },
    rowKeyChangeHandler : function(component, event) {
        var changeEventRow = $A.get("e.c:ViewRecordsFilterChange");
        changeEventRow.setParams({
            "rowKey": event.getParam("value")
        });
        changeEventRow.fire();
    },
    refreshRecordList : function(component, event) {
        var changeEventRefresh = $A.get("e.c:ViewRecordsFilterChange");
        changeEventRefresh.fire();
	}
})
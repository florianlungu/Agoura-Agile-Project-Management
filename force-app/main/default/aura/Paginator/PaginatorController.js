({
    firstPage : function(component) {
        var paginatorEvent = component.getEvent("firstPage");
        paginatorEvent.fire();
    },
    previousPage : function(component) {
        var paginatorEvent = component.getEvent("previousPage");
        paginatorEvent.fire();
    },    
    nextPage : function(component) {
        var paginatorEvent = component.getEvent("nextPage");
        paginatorEvent.fire();
    },
    lastPage : function(component) {
        var paginatorEvent = component.getEvent("lastPage");
        paginatorEvent.fire();
    }
})
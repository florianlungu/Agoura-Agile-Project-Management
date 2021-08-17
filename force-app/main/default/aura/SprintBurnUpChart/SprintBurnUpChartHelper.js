({
    getData : function(component) {
        var labelList = component.get("v.labelList");         
        var labelListBig = component.get("v.labelListBig");        
        var targetPointsList = component.get("v.targetPointsList");
        var sprintTaskItems = component.get("v.burnUpChartData");
        var data = [];
        var completedPoints = 0;
        var completedPointsList = [];
        var today = new Date();
        var dailyTotal = new Date();
        var labelDate = new Date();
        var todayLabel = $A.localizationService.formatDate(today, "dd-MMM");
        var decomposed;        
        var thisDateStr = '';
        for (var i = 0; i < labelListBig.length; i++) {
            completedPoints = 0;
            decomposed = labelListBig[i].split("-");
            labelDate= new Date(decomposed[2], decomposed[1]-1, decomposed[0]);
            for (var j = 0; j < sprintTaskItems.length; j++) {
                decomposed = sprintTaskItems[j].endDate.split("-");
                dailyTotal = new Date(decomposed[2], decomposed[1]-1, decomposed[0]);
                if (dailyTotal <= labelDate) {
                    completedPoints += sprintTaskItems[j].points || 0;
                }
            }
            if (today < labelDate) {
                break;
            }
            completedPointsList.push(completedPoints);
            if (todayLabel == labelList[i]) {
                break;
            }
        }        
        data = {
            labels: labelList,
            datasets: [
                { 
                    label: "Completed Points",
                    borderColor: "#93d475",
                    backgroundColor: "#93d475",
                    fill: false,
                    data: completedPointsList
                },
                {
                    label: "Target Points",
                    borderColor: "#e1e4ee",
                    backgroundColor: "#e1e4ee",
                    fill: false,
                    pointRadius: 0,
                    data: targetPointsList
                }
            ]
        };        
        return data
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
    }
})
({
    scriptsLoaded : function(component, event, helper) {
        var sprintId = component.get("v.recStr");
        var action = component.get("c.getStartDate");
        action.setParams({
            "recId": sprintId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                helper.handleError(response);
                return;
            }
            var result = response.getReturnValue();
            var startDate = result[0].AgouraFree__Start_Date__c;
            var workDaysStr = result[0].AgouraFree__Work_Days_Report__c;
            if (workDaysStr == null || workDaysStr == '') {
                return null;
            }
            var workDaysArray = workDaysStr.split(';');
            var targetPoints = result[0].AgouraFree__Target_Points__c;
            var labelList = [];
            var labelListBig = [];
            var targetPointsList = []; 
            
            if (startDate != null) {
                var sprintDays = workDaysArray.length;
                var dailyTargetPoints = 0;
                for (var i = 0; i < sprintDays; i++) {
                    var thisDate = new Date(startDate);
                    thisDate.setTime(thisDate.getTime() + (864e5*workDaysArray[i]));
                    dailyTargetPoints += targetPoints/sprintDays;
                    
                    labelList.push($A.localizationService.formatDate(thisDate, "dd-MMM"));                    
                    labelListBig.push($A.localizationService.formatDate(thisDate, "dd-M-yyyy"));
                    targetPointsList.push(Math.round(dailyTargetPoints));
                }
                component.set("v.labelList", labelList);
                component.set("v.labelListBig", labelListBig);
                component.set("v.targetPointsList", targetPointsList);                
                var data = helper.getData(component);        
                var ctx = component.find("chart").getElement();
                component.chart = new Chart(ctx,{
                    type: 'line',
                    data: data,
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        legend: {
                            position: "right",
                            display: false
                        },
                        tooltips: {
                            mode: 'label'
                        }
                    }            
                });                
            }
        });
        $A.enqueueAction(action); 
    },    
    projectTaskItemsChangeHandler: function(component, event, helper) {
        if (component.chart && component.chart.data && component.chart.data.datasets[0]) {
            var data = helper.getData(component);
            component.chart.data.datasets[0].data = data.datasets[0].data;
            if (data.datasets[1] && component.chart.data.datasets[1]) {
                component.chart.data.datasets[1].data = data.datasets[1].data;
            }
            component.chart.update();
        }
    }   
})
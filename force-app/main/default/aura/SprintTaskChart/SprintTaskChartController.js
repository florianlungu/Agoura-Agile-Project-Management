({
    scriptsLoaded : function(component) {        
        var data = {
            labels: ["Resolved", "Done", "Ready to Deploy", "Testing", "Ready to Test", "In Progress", "Open", "Canceled"],
            datasets: [
                {
                    data: [0, 0, 0, 0, 0, 1],
                    backgroundColor: [
                        "rgba(65,146,73,.8)",
                        "rgba(120,201,83,.8)",
                        "rgba(255,204,51,.8)",
                        "rgba(168,69,220,.8)",
                        "rgba(249,111,183,.8)",
                        "rgba(51,204,255,.8)",
                        "rgba(11,111,206,.8)",
                        "rgba(102,102,102,.8)"
                    ],
                    hoverBackgroundColor: [
                        "rgba(65,146,73,.8)",
                        "rgba(120,201,83,.8)",
                        "rgba(255,204,51,.8)",
                        "rgba(168,69,220,.8)",
                        "rgba(249,111,183,.8)",
                        "rgba(51,204,255,.8)",
                        "rgba(11,111,206,.8)",
                        "rgba(102,102,102,.8)"
                    ]
                }
            ]
        };        
        var ctx = component.find("chart").getElement();
        component.chart = new Chart(ctx,{
            type: 'doughnut',
            data: data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutoutPercentage: 60,
                legend: {
                    position: "right",
                    display: false
                }
            }            
        });        
    },    
    projectTaskItemsChangeHandler: function(component) {
        if (component.chart && component.chart.data && component.chart.data.datasets[0]) {
            var sprintTaskItems = component.get("v.sprintTaskItems");
            if (sprintTaskItems && Array.isArray(sprintTaskItems)) {
                var map = {};
                sprintTaskItems.forEach(function(sprintTaskItem) {
                    map[sprintTaskItem.formattedStatus] = (map[sprintTaskItem.formattedStatus] || 0) + (sprintTaskItem.points || 0);
                });
                var data = [
                    map.resolved || 0,
                    map.done || 0,
                    map.readytodeploy || 0,
                    map.testing || 0,
                    map.readytotest || 0,
                    map.inprogress || 0,                    
                    map.open || 0,
                    map.canceled || 0
                ];
                component.chart.data.datasets[0].data = data;
                component.chart.update();
            }
        }
    }    
})
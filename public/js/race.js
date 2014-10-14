function removeNavClasses() {
	$('ul.nav li').removeClass('active');
}

function getGraphData(containers, race_id) {
	var d1= [];
	var markers;
	$.getJSON('/gr', {race_id: race_id},
		function(data) {
			var d1 =  data['all'];
			var d2 =  data['male'];
			var d3 =  data['female'];
			markers = data["markers"];
			
			googleLine(containers['finishTime'], data);
			//bar(containers['finishTime'], [d1,d2,d3], markers, data['race']);
		}
	);	
	
	$.getJSON('/gender', {race_id: race_id},
		function(data) {
			var d = [['Male', data['m']], ['Female', data['f']]];		
			googlePie(containers['gender'], d);
		}
	);
	
	$.getJSON('/ageGroup', {race_id: race_id},
		function(data) {			
			ageGroupPie(containers['ageGroup'], data);
			//chocoPie(containers['ageGroup'], data);
		}
	);
}

function compareAge(container, data) {
	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn('string', 'AgeGroup');
	dataTable.addColumn('number', data['race1_title']);
	dataTable.addColumn('number', data['race2_title']);
	dataTable.addRows(data['data']);
	
	var chart = new google.visualization.ColumnChart(container);
	var options = { 
		chartArea: {left: 50, top: 50, width: 700, height: 500},
		legend: {position: 'top'},
		vAxis: {minValue: 0}
		};
	chart.draw(dataTable, options);
}

function compareGender(container, data) {
	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn('string', 'RaceName');
	dataTable.addColumn('number', 'Male');
	dataTable.addColumn('number', 'Female');
	dataTable.addRows(data['data']);
	
	var chart = new google.visualization.ColumnChart(container);
	var options = { 
		vAxis: {minValue: 0},
		legend: {position: 'top'},
		chartArea: {left: 50, top: 50, width: 700, height: 500}
		};
	chart.draw(dataTable, options);
}

function compareLines(container, data, callback) {
	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn('timeofday', 'Pace');
	dataTable.addColumn('number', data['race1_title']);
	dataTable.addColumn('number', data['race2_title']);
	dataTable.addRows(data['data']);
	
	var chart = new google.visualization.LineChart(container);

 	var options = {
		curveType: 'function',
		chartArea: {left: 50, top: 50, width: 700, height: 500},
		vAxis: {minValue:0},
		legend: {position: 'top'},
		width: '800px',
		hAxis: { ticks: [{v:[0,3,0], f:'3:00'}, {v:[0,3,30], f:'3:30'}, {v:[0,4,0], f:'4:00'}, 
			{v:[0,4,30], f:'4:30'}, {v:[0,5,0], f:'5:00'}, {v:[0,5,30], f:'5:30'}, {v:[0,6,0], f:'6:00'}, 
			{v:[0,6,30], f:'6:30'}, {v:[0,7,0], f:'7:00'}, {v:[0,7,30], f:'7:30'}, {v:[0,8,0], f:'8:00'}] }
		};
		
	google.visualization.events.addListener(chart, 'ready', function() {
		callback();
	});
	chart.draw(dataTable, options);
}

function googleLine(container, data) {
	var dataTable = new google.visualization.DataTable();
	dataTable.addColumn('timeofday', 'Finish Time');
	dataTable.addColumn('number', 'Count');
	dataTable.addRows(data['male']);
	
	var dataTableF = new google.visualization.DataTable();
	dataTableF.addColumn('timeofday', 'Finish Time');
	dataTableF.addColumn('number', 'Count');
	dataTableF.addRows(data['female']);
	
	var current = 0;
	var dt = [dataTable, dataTableF];
	var button = document.getElementById('button');
	
	var chart = new google.visualization.LineChart(container);

 	var options = { 
		chartArea: {left: 50, width: 800, height: 350},
		curveType: 'none',
		width: '800px',
		title: data['title'] + '. ' + 'Мужчины.', 
		animation:{
	        duration: 1500,
	        easing: 'out'
	      }
		};
	
		 
	chart.draw(dt[current], options);
	
	$('#male_but').on('click', function(){
		options['title'] = data['title'] + '. ' + 'Мужчины';
		chart.draw(dataTable, options);
		$('#female_but').removeClass('active');
		$('#male_but').addClass('active');
	});
	
	$('#female_but').on('click', function(){
		options['title'] = data['title'] + '. ' + 'Женщины';		
		chart.draw(dataTableF, options);
		$('#male_but').removeClass('active');
		$('#female_but').addClass('active');
	});
}

function googleStackedBar(container, data) {
	var arr = [];
	console.log(data['data']);
	arr.push(["Race", "Мужчины", "Женщины", {role: 'annotation'}]);
	$.each(data['data'], function(i,o) {
		arr.push([o[0], o[1], o[2], o[0]]);
	});
	
	console.log(arr);
	
	var dt = google.visualization.arrayToDataTable(arr);
	var options = {
		title: 'Число участников в московских забегах',
        legend: { position: 'top', maxLines: 3 },
		height: '400px',
		width: '800px',
        bar: { groupWidth: '75%' },
        isStacked: true,
		annotations: {alwaysOutside: true, textStyle:{color: 'black', fontSize:12}},
		hAxis: {maxValue: 7000, minValue: 0},
		vAxis: {textPosition: 'none', textStyle: {fontSize: 6}},
		chartArea: {left: 20, top:40, width: 800, height:500},
		animation:{
	        duration: 1500,
	        easing: 'out'
	      }
	};
	
	var chart = new google.visualization.BarChart(container);
	
	chart.draw(dt, options);
}

function googlePie(container, data) {
	var arr = [];
	arr.push(["Gender", "Count"]);
	$.each(data, function(i,o) {
		arr.push(o);
	});
	var data = google.visualization.arrayToDataTable(arr);
	
	var options = {
          title: 'Gender distribution',
          legend: 'top',
          pieSliceText: 'percentage',
			chartArea: {left: 20, width: 800}
		};
	var chart = new google.visualization.PieChart(container);
    chart.draw(data, options);
}

function stackedBar(container, data) {
	var d1 = data['male'];
	var d2 = data['female'];
	var labels = data['labels'];
	var markers = [];
	
	$.each(d1, function(o, a){markers.push([0, a[1]])});
	
	
	
	console.log(markers);
		console.log(d1);
	
	var graph = Flotr.draw(container,[
	{ data: markers, markers: {show: true, position: 'lm', horizontal: true, stacked:true, labelFormatter: function (o) { return labels[o.index][1]; }}},
    { data : d1, label : 'Male' },
    { data : d2, label : 'Female' }
  	], {
    legend : {
      backgroundColor : '#D2E8FF', // Light blue 
		position: 'se',
		show: false
    },
	xaxis: {min:0},
    bars : {
      show : true,
      stacked : true,
	  horizontal: true,
      barWidth : 0.6,
      lineWidth : 1,
      shadowSize : 0
    },
    grid : {
      verticalLines : true,
      horizontalLines : true
    },
	mouse: {track: true}
  });
}

function bar(container, data, ticks, title) {
	
//    var d1 = [[0, 1], [1, 22], [2, 66], [3, 140], [4, 164], [5, 154], [6, 130], [7, 96], [8, 65], [9, 38], [10, 21], [11, 5], [12, 5], [13, 1], [14, 1], [15, 1]],
var i,
    graph;
	
    // Draw Graph
    graph = Flotr.draw(container, [{data:data[0], color: '#000000', label: 'All'}, {data:data[1], color: 'blue', label: 'Male'}, {data: data[2], color: 'red', label: 'Female'}], {
        xaxis: {
            ticks: ticks,
            noTicks: 0,
			labelsAngle: 45
        },
        yaxis: {
            min: 0,
            autoscaleMargin: 1
        },
        grid: {
            minorVerticalLines: true
        },
        bars: {
            show: false,
            barWidth: 1
        },
		selection : { mode : 'x', fps : 30 },
		title: title,
		subtitle: 'Число завершивших в диапазон времени (чиптайм)',
		mouse: {
            track: true
        },
		fontSize:7,
		HtmlText : false,
		legend: {
            position: 'ne',
            backgroundColor: '#D2E8FF'
        }
    });
}

function ageGroupPie(container, data) { 
	var arr = [];
	arr.push(["AgeGroup", "Count"]);
	$.each(data, function(i,o) {
		arr.push(o);
	});
	
	var data = google.visualization.arrayToDataTable(arr);
	
	var options = {
          title: 'Age group distribution',
          legend: 'top',
          pieSliceText: 'percentage',
			chartArea: {left: 20, width: 800}
		};
	var chart = new google.visualization.PieChart(container);
    chart.draw(data, options);
}

function chocoPie(container, data) {
	var titles = [];
	var pieData = [];
	
	data.forEach(function(obj) {	
		titles.push(obj[0]);
		pieData.push({data: [[0, obj[1]]], label: obj[0]});
	});
	
	var index = -1;	
	graph = Flotr.draw(container, 
		pieData, 
	{
        HtmlText: false,
        grid: {
            verticalLines: false,
            horizontalLines: false
        },
        xaxis: {
            showLabels: false
        },
        yaxis: {
            showLabels: false
        },
        pie: {
            show: true,
            explode: 6,
			labelFormatter: function (pie, slice) {
				index++;
				if (slice/pie < 0.05)
					return '';
				else
					return titles[index] + ' ' + (100*slice/pie).toFixed(1) + '%';
			}
        },
        mouse: {
            track: true
        },
        legend: {
            position: 'se',
            backgroundColor: '#D2E8FF'
        }
    });
}

function pie(container, data) {

    var
    d1 = [data[0]],
    d2 = [data[1]],
    graph;
	
	var title = [data[0][0], data[1][0]];
	var index = -1;
    graph = Flotr.draw(container, [
    {
        data: d1,
        label: 'Male'
    },
    {
        data: d2,
        label: 'Female'
    }], 
	{
        HtmlText: false,
        grid: {
            verticalLines: false,
            horizontalLines: false
        },
        xaxis: {
            showLabels: false
        },
        yaxis: {
            showLabels: false
        },
        pie: {
            show: true,
            explode: 6,
			labelFormatter: function (pie, slice) {
				index++;
				return title[index] + ' ' + (100*slice/pie).toFixed(1) + '%';
			}
        },
        mouse: {
            track: true
        },
        legend: {
            position: 'se',
            backgroundColor: '#D2E8FF'
        }
    });
}
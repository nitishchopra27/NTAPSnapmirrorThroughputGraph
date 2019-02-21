#---------------------------------------------------------[Script Parameters]------------------------------------------------------
Param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter the IP address of OPM Server")] 
        [string]$opmServer,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter the Start Date")] 
        [string]$startDate,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter the End Date")] 
        [string]$endDate,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter the name of chart")] 
        [string]$chartName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,HelpMessage="Enter the name of chart")] 
        [string[]]$objids = @()
)
Function MySQLOPM {
    Param(
      [Parameter(
      Mandatory = $true,
      ParameterSetName = '',
      ValueFromPipeline = $true)]
      [string]$Switch,
      [string]$Query
      )

    if($switch -match 'performance') {
        $MySQLDatabase = 'netapp_performance'
    }
    elseif($switch -match 'model'){
        $MySQLDatabase = 'netapp_model_view'    
    }
    $MySQLAdminUserName = 'reportuser'
    $MySQLAdminPassword = 'Netapp123'
    #$MySQLDatabase = 'netapp_performance'
    #$MySQLDatabase = 'netapp_model_view'
    $MySQLHost = $opmServer
    $ConnectionString = "server=" + $MySQLHost + ";port=3306;Integrated Security=False;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase

    Try {
      #[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
      [void][System.Reflection.Assembly]::LoadFrom("E:\ssh\L080898\MySql.Data.dll")
      $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
      $Connection.ConnectionString = $ConnectionString
      $Connection.Open()

      $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
      $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
      $DataSet = New-Object System.Data.DataSet
      $RecordCount = $dataAdapter.Fill($dataSet, "data")
      $DataSet.Tables[0]
      }

    Catch {
      Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
     }

    Finally {
      $Connection.Close()
    }
}
$query = @"
SELECT
firstnode.StartTime,firstnode.Throughput1,
secnode.Throughput2,
thirdnode.Throughput3,
forthnode.Throughput4,
fifthnode.Throughput5,
sixnode.Throughput6
FROM
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput1
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[0])"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS firstnode,
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput2
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[1])"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS secnode,
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput3
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[2])"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS thirdnode,
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput4
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[3]))"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS forthnode,
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput5
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[4])"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS fifthnode,
(
	SELECT
	netapp_performance.summary_networklif.objid as objid,
	Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000), '%Y:%m:%d:%H:%i') AS StartTime,
	Round((netapp_performance.summary_networklif.opmLifThroughput/1000000),1) AS Throughput6
	FROM
	netapp_performance.summary_networklif
	WHERE
	netapp_performance.summary_networklif.objid="$($objids[5])"
	AND
	(Date_Format(FROM_UNIXTIME(netapp_performance.summary_networklif.fromtime/1000),'%Y:%m:%d') between "$startDate" and "$endDate")
) AS sixnode
Where (firstnode.StartTime = secnode.StartTime AND
      thirdnode.StartTime = firstnode.StartTime AND
      forthnode.StartTime = firstnode.StartTime AND
      fifthnode.StartTime = firstnode.StartTime AND
      sixnode.StartTime = firstnode.StartTime 
      )
"@

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition
 
# chart object
   $chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
   $chart1.Width = 1200
   $chart1.Height = 600
   $Chart1.Left = 10
   $Chart1.Top = 10
   $chart1.BackColor = [System.Drawing.Color]::White
   $Chart1.BorderColor = 'Black'
   $Chart1.BorderDashStyle = 'Solid'
 
# title 
   $chartTitleName = "Snapmirror Throughput"+" - "+$chartName
   [void]$chart1.Titles.Add("$chartTitleName")
   $chart1.Titles[0].Font = "Arial,13pt"
   $chart1.Titles[0].Alignment = "topLeft"
 
# chart area 
   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
   $chartarea.Name = "ChartArea1"
   $chartarea.AxisX.Title = "Date"
   $chartarea.AxisY.Title = "MBps"
   $chartarea.AxisY.Interval = 10
   $chartarea.AxisX.Interval = 20
   $chart1.ChartAreas.Add($chartarea)
 
# legend 
   $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
   $legend.name = "Legend1"
   $chart1.Legends.Add($legend)
 
# data source
   $perfdata =  MySQLOPM -Switch performance -Query $query
   $datasource1 = [ordered]@{}
   for ($i = 0; $i -lt $perfdata.length; $i+=1) {
    $datasource1.Add($perfdata.StartTime[$i], ($perfdata.Throughput1[$i]+$perfdata.Throughput2[$i]+$perfdata.Throughput3[$i]+$perfdata.Throughput4[$i]+$perfdata.Throughput5[$i]+$perfdata.Throughput6[$i]));
   }
   #$datasource1 = [ordered]@{}
   #for ($i = 0; $i -lt $perfdata.length; $i+=1) {
   # $datasource1.Add($perfdata.StartTime[$i], $perfdata.Throughput[$i]);
   #}
 
# data series 1 - Snapmirror Throughput
   [void]$chart1.Series.Add("Snapmirror Throughput")
   
# chart type
  $chart1.Series["Snapmirror Throughput"].Points.DataBindXY($datasource1.keys, $datasource1.values)
  #$Chart.Series["Snapmirror Throughput"].Sort([System.Windows.Forms.DataVisualization.Charting.PointSortOrder]::Ascending, "Y")
  $chart1.Series["Snapmirror Throughput"].ChartType = "line"
   
# chart parameters
   $chart1.Series["Snapmirror Throughput"].IsVisibleInLegend = $true
   $chart1.Series["Snapmirror Throughput"].ChartArea = "ChartArea1"
   $chart1.Series["Snapmirror Throughput"].Legend = "Legend1"
   $chart1.Series["Snapmirror Throughput"].Color = "Blue"
   $chart1.Series["Snapmirror Throughput"].Points.DataBindXY($dataSource1.Keys, $datasource1.values)
 
# display the chart area on a form
   $form = NEw-Object Windows.Forms.Form
   $form.Text = "Snapmirror Throughput"
   $form.Width = 1500
   $form.Height = 800
   $form.Controls.Add($chart1)
   $form.Add_Shown({$form.Activate()})
   $form.ShowDialog()

# save chart
  $chartlocation = $scriptpath+"\"+$chartName+".png"
  $chart1.SaveImage($chartlocation,"png")

# Example
# Primary Site
# .\Get-SnapmirrorThroughputGraph.ps1 -opmServer 192.168.100.137 -startDate '2018:05:01' -endDate '2018:05:31' -chartName snowy -objids 1731826,1731825,1731824,1731823,1731822,1731821
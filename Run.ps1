. .\Expenses.ps1

$monzoExport = "c:\src\blog-monzo-expenses\Example\March2018Export.csv"
$exportFolder = "c:\temp\expenses\March2018"

Export-ExpenseFromMonzo -MonzoExport $monzoExport -ExportFolder $exportFolder
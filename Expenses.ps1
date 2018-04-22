Function Get-ExtensionFromContentType
{
    Param
    (
        [string] $ContentType
    )
    
    switch($ContentType)
    {
        "image/jpeg" { "jpg" }
    }
}

Function Get-ExpenseTypeFromCategory
{
    Param
    (
        [string] $Category
    )

    switch($Category)
    {
        "eating_out" { "Meals"}
        "groceries" { "Meals" }
        "entertainment" { "Entertainment" }
        "transport" { "Travel" }
        default { "Other" }
    }
}

Function Export-ExpenseFromMonzo
{
    Param
    (
        [string] $MonzoExport
        ,[string] $ExportFolder
    )

    if(-not(Test-Path $ExportFolder))
    {
        New-Item -Path $ExportFolder -ItemType Directory
    }

    $entries = Import-Csv -Path $MonzoExport
    $expenseEntries = $entries | Where-Object { $_.notes -like "*#expense*" }

    $expenseId = 1

    $outExpenses = @()
    foreach($expense in $expenseEntries)
    {
        $hasReceipt = "No"
        $imagePathWithoutExtension = $exportFolder + "\Receipt_$expenseId"
        if($expense.receipt -match "\[([^,]+).*\]")
        {
            $expenseImage = Invoke-WebRequest -Uri $Matches[1] -OutFile $imagePathWithoutExtension -PassThru
            $extension = Get-ExtensionFromContentType -ContentType $expenseImage.Headers.'Content-Type'
            if($extension -eq $null)
            {
                # It'll get a photo viewer to launch
                $extension = "jpg"
            }
            Rename-Item -Path $imagePathWithoutExtension -NewName "Receipt_$expenseId.$extension"
            $hasReceipt = "Yes"
        }

        $outExpenses += [pscustomobject]@{
            Id = $expenseId
            Date = [DateTime]::Parse($expense.created).ToString("yyyy-MM-dd")
            Type = Get-ExpenseTypeFromCategory $expense.category
            Currency = $expense.currency
            Amount = ([double]$expense.amount) * -1
            HasReceipt = $hasReceipt
        }

        $expenseId++
    }

    $outExpenses | Export-Csv -Path "$exportFolder\Expenses.csv" -NoTypeInformation
}
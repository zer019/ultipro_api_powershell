function Get-UKGEmploymentDetails {
    [CmdletBinding(DefaultParameterSetName = "AllActive")]
    param (
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllActive")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $RootURI,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllActive")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $Authorization,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllActive")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $APIKey,
        [Parameter(Mandatory, ParameterSetName = "AllActive")]
        [switch]
        $GetAllActive,
        [Parameter(Mandatory, ParameterSetName = "AllActive")]
        [validaterange(1,10000)]
        [int]
        $Perpage,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [switch]
        $GetOneRecord,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [string]
        $UKGEmployeeID
    )
    
    begin {
        if (!([Net.ServicePointManager]::SecurityProtocol -eq "Tls12")) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        $Results = [System.Collections.Generic.List[System.Object]]::new()
        $headers = [System.Collections.Generic.Dictionary[[string], [string]]]::new()
        $headers.Add('Authorization', ('Basic {0}' -f $Authorization))
        $headers.Add('us-customer-api-key', "$APIKey")
        $headers.Add('ContentType', 'applictaion/json')
        switch ($PScmdlet.ParameterSetName) {
            "AllActive" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/employment-details?page=1&per_page={1}&employeeStatusCode=A" -f $RootURI,$PerPage
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
            "One" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/employment-details?employeeId={1}" -f $RootURI, $UKGEmployeeID
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
        }
    }
    
    process {
        $page = 1
        Try {
            Write-Verbose "Calling $($webRequest.Uri), page $page"
            $WR = Invoke-WebRequest @webRequest
            $resultset = $wr.Content | ConvertFrom-Json
            foreach ($r in $resultset) {
                $Results.Add($r)
            }
            Write-Verbose "$($Results.Count) records returned"
        }
        Catch {
            $Error[0].Exception.Message
            break
        }
        try{
            $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            $LastLinkCheck = (($wr.Headers.Link.Split(',') | Where-Object {$_ -like "*last*"}).split(';')[0].split('?')[1].split('&')| Where-Object {$_ -match [regex]"^page\=\d+"}).split('=')[1]

        }
        catch{}        
        while ($nextLinkCheck) {
            $page++
            if ($nextLinkCheck) {
                $nextURI = $nextLinkCheck.split(';')[0].replace('<', '').replace('>', '')
            }
            Else {
                break
            }
            try {
                Write-Verbose "Getting page $page of $LastLinkCheck."
                $WR = Invoke-WebRequest -Uri $nextURI -Headers $headers -Method Get -ErrorAction Stop -UseBasicParsing
                $resultset = $WR.Content | ConvertFrom-Json
                foreach ($r in $resultset) {
                    $Results.Add($r)
                }
                Write-Verbose "$($Results.Count) records returned."
            }
            catch {
                $Error[0].Exception.Message
                return $Results
                break
            }
            try{
                $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            }
            catch{}
        }
    }
    
    end {
        Write-Verbose "Returning results."
        return $Results        
    }
}

function Get-UKGPersonDetails {
    [CmdletBinding(DefaultParameterSetName = "AllRecords")]
    param (
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $RootURI,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $Authorization,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $APIKey,
        [Parameter(Mandatory, ParameterSetName = "AllRecords")]
        [switch]
        $GetAllActive,
        [Parameter(Mandatory, ParameterSetName = "AllRecords")]
        [validaterange(1,10000)]
        [int]
        $Perpage,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [switch]
        $GetOneRecord,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [string]
        $UKGEmployeeID
    )
    
    begin {
        if (!([Net.ServicePointManager]::SecurityProtocol -eq "Tls12")) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        $Results = [System.Collections.Generic.List[System.Object]]::new()
        $headers = [System.Collections.Generic.Dictionary[[string], [string]]]::new()
        $headers.Add('Authorization', ('Basic {0}' -f $Authorization))
        $headers.Add('us-customer-api-key', "$APIKey")
        $headers.Add('ContentType', 'applictaion/json')
        switch ($PScmdlet.ParameterSetName) {
            "AllRecords" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/person-details?page=1&per_page={1}" -f $RootURI,$Perpage
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
            "One" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/person-details/{1}" -f $RootURI, $UKGEmployeeID
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
        }
        
    }
    
    process {
        $page = 1
        Try {
            Write-Verbose "Calling $($webRequest.Uri), page $page"
            $WR = Invoke-WebRequest @webRequest
            $resultset = $wr.Content | ConvertFrom-Json
            foreach ($r in $resultset) {
                $Results.Add($r)
            }
            Write-Verbose "$($Results.Count) records returned"
        }
        Catch {
            $Error[0].Exception.Message
            break
        }
        try{
            $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            $LastLinkCheck = (($wr.Headers.Link.Split(',') | Where-Object {$_ -like "*last*"}).split(';')[0].split('?')[1].split('&')| Where-Object {$_ -match [regex]"^page\=\d+"}).split('=')[1]

        }
        catch{}        
        while ($nextLinkCheck) {
            $page++
            if ($nextLinkCheck) {
                $nextURI = $nextLinkCheck.split(';')[0].replace('<', '').replace('>', '')
            }
            Else {
                break
            }
            try {
                Write-Verbose "Getting page $page of $LastLinkCheck."
                $WR = Invoke-WebRequest -Uri $nextURI -Headers $headers -Method Get -ErrorAction Stop -UseBasicParsing
                $resultset = $WR.Content | ConvertFrom-Json
                foreach ($r in $resultset) {
                    $Results.Add($r)
                }
                Write-Verbose "$($Results.Count) records returned"
            }
            catch {
                $Error[0].Exception.Message
                return $Results
                break
            }
            try{
                $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            }
            catch{}
        }        
    }
    
    end {
        Write-Verbose "Returning results."
        return $Results                
    }
}

function Get-UKGEmployeeChanges {
    [CmdletBinding(DefaultParameterSetName = "AllRecords")]
    param (
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $RootURI,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $Authorization,
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = "AllRecords")]
        [Parameter(ParameterSetName = "One")]
        [string]
        $APIKey,
        [Parameter(Mandatory, ParameterSetName = "AllRecords")]
        [switch]
        $GetAllActive,
        [Parameter(Mandatory, ParameterSetName = "AllRecords")]
        [datetime]
        $StartDate,
        [Parameter(Mandatory, ParameterSetName = "AllRecords")]
        [validaterange(1,200)]
        [int]
        $Perpage,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [switch]
        $GetOneRecord,
        [Parameter(Mandatory, ParameterSetName = "One")]
        [string]
        $UKGEmployeeID
    )
    
    begin {
        if (!([Net.ServicePointManager]::SecurityProtocol -eq "Tls12")) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        $Results = [System.Collections.Generic.List[System.Object]]::new()
        $headers = [System.Collections.Generic.Dictionary[[string], [string]]]::new()
        $headers.Add('Authorization', ('Basic {0}' -f $Authorization))
        $headers.Add('us-customer-api-key', "$APIKey")
        $headers.Add('ContentType', 'applictaion/json')
        $StartDateUTC = $StartDate.ToUniversalTime().ToString("yyyy-MM-dd`\thh:mm:ss.msZ")
        switch ($PScmdlet.ParameterSetName) {
            "AllRecords" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/employee-changes?page=1&per_page={1}&startDate={2}" -f $RootURI,$PerPage,$StartDateUTC
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
            "One" {
                $webRequest = @{
                    Uri             = "{0}/personnel/v1/employee-changes/{1}" -f $RootURI, $UKGEmployeeID
                    Headers         = $headers
                    Method          = "Get"
                    ErrorAction     = "Stop"
                    UseBasicParsing = $true
                }
            }
        }
        
    }
    
    process {
        $page = 1
        Try {
            Write-Verbose "$webRequest"
            $WR = Invoke-WebRequest @webRequest
            $resultset = $wr.Content | ConvertFrom-Json
            foreach ($r in $resultset) {
                $Results.Add($r)
            }
        }
        Catch {
            $Error[0].Exception.Message
            break
        }
        try{
            $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            $LastLinkCheck = (($wr.Headers.Link.Split(',') | Where-Object {$_ -like "*last*"}).split(';')[0].split('?')[1].split('&')| Where-Object {$_ -match [regex]"^page\=\d+"}).split('=')[1]

        }
        catch{}        
        while ($nextLinkCheck) {
            $page++
            if ($nextLinkCheck) {
                $nextURI = $nextLinkCheck.split(';')[0].replace('<', '').replace('>', '')
            }
            Else {
                break
            }
            try {
                Write-Verbose "Getting page $page of $LastLinkCheck."
                $WR = Invoke-WebRequest -Uri $nextURI -Headers $headers -Method Get -ErrorAction Stop -UseBasicParsing
                $resultset = $WR.Content | ConvertFrom-Json
                foreach ($r in $resultset) {
                    $Results.Add($r)
                }
            }
            catch {
                $Error[0].Exception.Message
                return $Results
                break
            }
            try{
                $nextLinkCheck = ($WR.Headers.Link.Split(',') | Where-Object { $_ -like "*next*" })
            }
            catch{}
        }        
    }
    
    end {
        return $Results                
    }
}
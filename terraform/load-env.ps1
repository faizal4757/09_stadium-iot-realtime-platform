$envFile = Join-Path $PSScriptRoot "..\.env"

if (-not (Test-Path $envFile)) {
    throw ".env file not found: $envFile"
}

Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*?)\s*$') {
        $name = $Matches[1].Trim()
        $value = $Matches[2].Trim().Trim('"').Trim("'")

        switch ($name) {
            "AWS_ACCESS_KEY_ID" {
                $env:AWS_ACCESS_KEY_ID = $value
            }
            "AWS_SECRET_ACCESS_KEY" {
                $env:AWS_SECRET_ACCESS_KEY = $value
            }
            "AWS_DEFAULT_REGION" {
                $env:AWS_DEFAULT_REGION = $value
            }
            "DATABRICKS_HOST" {
                $env:DATABRICKS_HOST = $value
            }
            "DATABRICKS_TOKEN" {
                $env:DATABRICKS_TOKEN = $value
            }
        }
    }
}

Write-Host "AWS and Databricks environment variables loaded."

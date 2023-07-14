# install the DAC framework from here
# https://www.microsoft.com/en-us/download/confirmation.aspx?id=100297

if(!(Get-Module -Name SqlServer)){
    Install-Module -Name SqlServer -Force –AllowClobber
    Import-Module SqlServer
}
$ServerName = "localhost"

$sql = "
SELECT name
FROM sys.databases
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','distribution')
"

$data = Invoke-sqlcmd -Query $sql -ServerInstance $ServerName -Database master

$data | ForEach-Object {

$DatabaseName = $_.name

#
# Run sqlpackage
#
&"C:\Program Files\Microsoft SQL Server\150\DAC\bin\sqlpackage.exe" `
    /Action:extract `
    /SourceServerName:$ServerName `
    /SourceDatabaseName:$DatabaseName `
    /TargetFile:.\$DatabaseName.dacpac `
    /p:ExtractReferencedServerScopedElements=False `
    /p:IgnorePermissions=False

}


# test db connection string
$connectionString = "Data Source=localhost;Initial Catalog=AvianTranslator;Integrated Security=True"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$sqlConnection.Open()
$sqlConnection.Close()

#get connection string
# Get connection string for the Azure database
$ServerName  = "aviantranslatorsql"
$DatabaseName = "aviantranslatordb"
$connstring=$(az sql db show-connection-string --name $DatabaseName --server $ServerName --client ado.net --auth-type ADIntegrated --output tsv)

Connect-AzAccount -Tenant '4f8875af-ac0b-46ee-8a73-3634138f5818'
$access_token = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token
Invoke-Sqlcmd -ServerInstance $($ServerName).database.windows.net -Database $DatabaseName -AccessToken $access_token -TrustServerCertificate -query 'SELECT * FROM sys.databases'

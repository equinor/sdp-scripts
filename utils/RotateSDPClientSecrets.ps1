$alphabets= "abcdefghijklmnopqstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^_-&*()"
$endDate = (Get-Date).AddDays(365)

$char = for ($i = 0; $i -lt $alphabets.length; $i++) { $alphabets[$i] }

$servicePrincipals = @(
    'sdpaks-prod-psql'
)

foreach ($sp in $servicePrincipals)
{
    $string = ""

    for ($i = 1; $i -le 63; $i++)
    {
        $string += $(get-random $char)
    }
    write-host `n
    #echo $string

    echo "Creating new clientSecret for app registration $($sp)"

    $pw = ConvertTo-SecureString -String $string -AsPlainText -Force
    #New-AzADAppCredential -DisplayName $sp -Password $pw -EndDate $endDate

    echo "Updating keyvault secret for $($sp)"

    Set-AzKeyVaultSecret -VaultName SDPVault -Name ($sp + "-password") -SecretValue $pw
}
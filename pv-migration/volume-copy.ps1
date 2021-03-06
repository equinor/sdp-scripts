# Root
$originRgName = 'sdpaksVeleroBackup'

# Destination
$destSaRgName = 'temp-rg'
$destSaName = 'tempstaccgit'
$destContainerName = 'migrate'
$destDiskRgName = 'temp-rg'

$snapshotList = @(
 ('kubernetes-dynamic-pvc-653ceceb-e696-11e9-8-c4804ba6-b0c8-47d1-a7cc-9d53a3fce09a'), 
 ('kubernetes-dynamic-pvc-6564ea18-e696-11e9-8-1d00dc63-d933-4b1d-a2f0-f7055988713a')
)	

#kubernetes-dynamic-pvc-66c040cf-f7bb-11e8-9-585d989d-c8ee-4082-a3a4-52e61eb4da91
#kubernetes-dynamic-pvc-52776c99-38dc-11e9-8-5179a56f-df6b-4aff-8cca-e0bc879f6a72
#kubernetes-dynamic-pvc-528e4578-38dc-11e9-8-a0fbddd8-ca8c-4d20-b33b-4fb45cb8fedc

$snapshotList[0]
$snapshotList[1]


# $destList = "verdaccio-pv", "data-matomo-mariadb-pv", "volume-matomo-pv"
$destList = "hgir-db-pv", "hgir-sqlite-pv"


$storageAccountKey = Get-AzStorageAccountKey -resourceGroupName $destSaRgName -AccountName $destSaName
$destinationContext = New-AzStorageContext -StorageAccountName $destSaName -StorageAccountKey ($storageAccountKey).Value[0]

$rootUri = "https://tempstaccgit.blob.core.windows.net/migrate/"
$storageAccountId = "/subscriptions/b18da12e-efa1-4642-8fec-b6580b00212c/resourceGroups/$destSaRgName/providers/Microsoft.Storage/storageAccounts/$destSaName"

for  ($i = 0; $i -lt $destList.Length; $i++) {

    echo "Iteration: $i"
    $sas = Grant-AzSnapshotAccess -ResourceGroupName $originRgName -SnapshotName $snapshotList[$i] -DurationInSecond 3600 -Access Read
    echo "Creating blob: $destList[$i]..."
    Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $destContainerName -DestContext $destinationContext -DestBlob $destList[$i] -Force
    echo "Blob Created."
} 

    echo "Creating Disk image:" $destList[0] 
    $uri = $rootUri + $destList[0]
    $diskConfig = New-AzDiskConfig -AccountType "Premium_LRS" -Location "norwayeast" -CreateOption Import -StorageAccountId $storageAccountId -SourceUri $uri 
    New-AzDisk -Disk $diskConfig -ResourceGroupName $destDiskRgName -DiskName $destList[0]

    echo "Creating Disk image:" $destList[1] 
    $uri = $rootUri + $destList[1]
    $diskConfig = New-AzDiskConfig -AccountType "Premium_LRS" -Location "norwayeast" -CreateOption Import -StorageAccountId $storageAccountId -SourceUri $uri 
    New-AzDisk -Disk $diskConfig -ResourceGroupName $destDiskRgName -DiskName $destList[1]


# We are Moving our prod Kubernetes-cluster to norwayeast this afternoon. Will affect npm.equinor.com termporarily. Jenkins instances and Gitlab are not affected.
# scale flux down
# remove namespace (included pvs and pvcs)
#kubectl delete ns prod
#kubectl create ns prod

# Edit PVC generated by your release to point to new PV
<#


#>
#  helm del --purge release
# scale flux up

# finished.
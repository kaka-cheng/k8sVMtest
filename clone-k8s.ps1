# ==========================================
# VMware K8s Full Clone Script
# ==========================================

$vmrun = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

$baseVMX = "C:\vm\k8s-base\k8s-base.vmx"

$targetPath = "C:\vm"

$vms = @(
    "k8s-master",
    "k8s-worker1",
    "k8s-worker2"
)

foreach ($vm in $vms) {

    Write-Host ""
    Write-Host "================================="
    Write-Host "Creating Full Clone: $vm"
    Write-Host "================================="

    $newPath = "$targetPath\$vm"

    # 建立資料夾
    New-Item -ItemType Directory -Force -Path $newPath | Out-Null

    # Full Clone
    & $vmrun clone `
        $baseVMX `
        "$newPath\$vm.vmx" `
        full `
        -cloneName=$vm

    Write-Host "$vm clone completed"
}

Write-Host ""
Write-Host "================================="
Write-Host "All Full Clones Completed!"
Write-Host "================================="

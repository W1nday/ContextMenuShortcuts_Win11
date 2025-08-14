# ���ܣ�����ָ�����Ƶ�AppxӦ�ò�ж��
# ʹ�÷������޸��·���APP_NAME�ؼ��ʣ��Թ���Ա������нű�

# ���ã�����Ҫж�ص�Ӧ�����ƹؼ��ʣ�����"NumenShield"��
$APP_NAME = "NumenShield"

# ����Ƿ��Թ���Ա�������
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "���Թ���Ա������д˽ű���"
    pause
    exit 1
}

try {
    # ���Ұ����ؼ��ʵ�Ӧ�ð�
    Write-Host "���ڲ��Ұ��� '$APP_NAME' ��Ӧ�ð�..."
    $appPackages = Get-AppxPackage *$APP_NAME*

    if ($appPackages.Count -eq 0) {
        Write-Warning "δ�ҵ����ư��� '$APP_NAME' ��Ӧ�ð������Բ���ϵͳ�������Ӧ��..."
        # ���Բ���ϵͳ����װ��Ӧ�ã���������û���
        $appPackages = Get-AppxPackage -AllUsers *$APP_NAME*
    }

    if ($appPackages.Count -eq 0) {
        Write-Warning "δ�ҵ��κ��� '$APP_NAME' ƥ���Ӧ�ð����������ⲿ�����Ӧ�ã���������ע������..."
        
        # ��ʾ�ֶ�����ע�������ⲿ��������PackageFullName�������
        Write-Host @"
        �������ⲿλ�ò����Ӧ�ã������ֶ�����ע���
        1. ��ע���༭����regedit��
        2. ����������·����ɾ�������Ŀ��
           - HKEY_CLASSES_ROOT\*\shell\��Ӧ����ز˵��
           - HKEY_CLASSES_ROOT\Directory\shell\��Ӧ����ز˵��
        3. ������Դ��������Ч
"@
        pause
        exit 0
    }

    # ��ʾ�ҵ���Ӧ�ð�
    Write-Host "`n�ҵ�����ƥ���Ӧ�ð���"
    $appPackages | ForEach-Object {
        Write-Host "----------------------------------------"
        Write-Host "Ӧ�����ƣ�$($_.Name)"
        Write-Host "����������$($_.PackageFullName)"
        Write-Host "��װλ�ã�$($_.InstallLocation)"
    }

    # ȷ��ж��
    $response = Read-Host "`n�Ƿ�ж����������Ӧ�ã�(Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "��ȡ��ж�ز�����"
        pause
        exit 0
    }

    # ִ��ж��
    $appPackages | ForEach-Object {
        Write-Host "`n����ж�أ�$($_.PackageFullName)..."
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction Stop
        Write-Host "ж�سɹ���$($_.Name)"
    }

    # ����������Ҽ��˵�������ⲿ����Ӧ�ã�
    Write-Host "`n���ڳ��������Ҽ��˵�����..."
    $registryPaths = @(
        "HKLM:\SOFTWARE\Classes\*\shell",
        "HKLM:\SOFTWARE\Classes\Directory\shell",
        "HKCU:\SOFTWARE\Classes\*\shell",
        "HKCU:\SOFTWARE\Classes\Directory\shell"
    )

    #foreach ($path in $registryPaths) {
    #    if (Test-Path $path) {
    #        Get-ChildItem -Path $path | Where-Object { $_.PSChildName -match $APP_NAME } | ForEach-Object {
    #            Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    #            Write-Host "��ɾ��ע��������$($_.PSPath)"
    #        }
    #    }
    #}

    # ������Դ������ˢ�²˵�
    Write-Host "`n����ˢ��ϵͳ�˵�..."
    taskkill /f /im explorer.exe 2>&1 | Out-Null
    start explorer.exe 2>&1 | Out-Null

    Write-Host "`n���в�����ɣ�"
    pause
}
catch {
    Write-Error "����ʧ�ܣ�$_"
    pause
    exit 1
}

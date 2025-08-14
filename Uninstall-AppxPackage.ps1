# 功能：查找指定名称的Appx应用并卸载
# 使用方法：修改下方的APP_NAME关键词，以管理员身份运行脚本

# 配置：设置要卸载的应用名称关键词（例如"NumenShield"）
$APP_NAME = "NumenShield"

# 检查是否以管理员身份运行
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "请以管理员身份运行此脚本！"
    pause
    exit 1
}

try {
    # 查找包含关键词的应用包
    Write-Host "正在查找包含 '$APP_NAME' 的应用包..."
    $appPackages = Get-AppxPackage *$APP_NAME*

    if ($appPackages.Count -eq 0) {
        Write-Warning "未找到名称包含 '$APP_NAME' 的应用包。尝试查找系统级部署的应用..."
        # 尝试查找系统级安装的应用（针对所有用户）
        $appPackages = Get-AppxPackage -AllUsers *$APP_NAME*
    }

    if ($appPackages.Count -eq 0) {
        Write-Warning "未找到任何与 '$APP_NAME' 匹配的应用包。可能是外部部署的应用，尝试清理注册表残留..."
        
        # 提示手动清理注册表（针对外部部署且无PackageFullName的情况）
        Write-Host @"
        可能是外部位置部署的应用，建议手动清理注册表：
        1. 打开注册表编辑器（regedit）
        2. 导航到以下路径并删除相关条目：
           - HKEY_CLASSES_ROOT\*\shell\【应用相关菜单项】
           - HKEY_CLASSES_ROOT\Directory\shell\【应用相关菜单项】
        3. 重启资源管理器生效
"@
        pause
        exit 0
    }

    # 显示找到的应用包
    Write-Host "`n找到以下匹配的应用包："
    $appPackages | ForEach-Object {
        Write-Host "----------------------------------------"
        Write-Host "应用名称：$($_.Name)"
        Write-Host "完整包名：$($_.PackageFullName)"
        Write-Host "安装位置：$($_.InstallLocation)"
    }

    # 确认卸载
    $response = Read-Host "`n是否卸载以上所有应用？(Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "已取消卸载操作。"
        pause
        exit 0
    }

    # 执行卸载
    $appPackages | ForEach-Object {
        Write-Host "`n正在卸载：$($_.PackageFullName)..."
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction Stop
        Write-Host "卸载成功：$($_.Name)"
    }

    # 清理残留的右键菜单（针对外部部署应用）
    Write-Host "`n正在尝试清理右键菜单残留..."
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
    #            Write-Host "已删除注册表残留：$($_.PSPath)"
    #        }
    #    }
    #}

    # 重启资源管理器刷新菜单
    Write-Host "`n正在刷新系统菜单..."
    taskkill /f /im explorer.exe 2>&1 | Out-Null
    start explorer.exe 2>&1 | Out-Null

    Write-Host "`n所有操作完成！"
    pause
}
catch {
    Write-Error "操作失败：$_"
    pause
    exit 1
}

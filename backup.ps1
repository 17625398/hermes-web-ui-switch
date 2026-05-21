<#
===========================================================================
              hermes-web-ui-switch - 部署模式切换功能备份脚本
===========================================================================

一、项目简介
------------
hermes-web-ui-switch 是 Hermes Web UI 的延伸功能，提供在运行时动态切换
本地/分离部署模式的能力。

二、脚本用途
-----------
本脚本用于备份 hermes-web-ui-switch 相关的自定义代码修改，
确保在 Hermes Web UI 升级时能够保留这些修改。

三、备份文件列表
---------------
以下文件会被备份：

1. ConnectionSettings.vue
   - 路径: packages/client/src/components/hermes/settings/ConnectionSettings.vue
   - 说明: 连接设置组件，包含本地/分离部署模式切换功能

2. SettingsView.vue
   - 路径: packages/client/src/views/hermes/SettingsView.vue
   - 说明: 设置页面主视图，包含连接标签页配置

3. zh.ts
   - 路径: packages/client/src/i18n/locales/zh.ts
   - 说明: 中文国际化翻译文件（含连接设置相关翻译）

4. en.ts
   - 路径: packages/client/src/i18n/locales/en.ts
   - 说明: 英文国际化翻译文件（含连接设置相关翻译）

四、升级时恢复备份
------------------
当 Hermes Web UI 升级后，按以下步骤恢复 hermes-web-ui-switch 功能：

1. 确保备份目录存在: D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\

2. 手动复制备份文件到对应位置：

   copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\components\hermes\settings\ConnectionSettings.vue" ^
        "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\components\hermes\settings\"

   copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\views\hermes\SettingsView.vue" ^
        "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\views\hermes\"

   copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\i18n\locales\zh.ts" ^
        "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"

   copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\i18n\locales\en.ts" ^
        "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"

3. 重启 Web UI 服务使修改生效

五、执行备份
------------
直接运行此脚本即可创建备份：
.\backup.ps1

备份目录: D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\

===========================================================================
#>

$sourceBase = "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui"
$backupBase = "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch"

Write-Host "==========================================================================="
Write-Host "              hermes-web-ui-switch - 部署模式切换功能备份脚本"
Write-Host "==========================================================================="
Write-Host ""

# 创建备份目录
if (-not (Test-Path $backupBase)) {
    New-Item -ItemType Directory -Path $backupBase -Force | Out-Null
    Write-Host "创建备份目录: $backupBase"
}

# 备份的文件列表
$filesToBackup = @(
    "packages/client/src/components/hermes/settings/ConnectionSettings.vue",
    "packages/client/src/views/hermes/SettingsView.vue",
    "packages/client/src/i18n/locales/zh.ts",
    "packages/client/src/i18n/locales/en.ts"
)

Write-Host "开始备份文件..."
Write-Host ""

foreach ($file in $filesToBackup) {
    $sourcePath = Join-Path $sourceBase $file
    $backupPath = Join-Path $backupBase $file
    
    if (Test-Path $sourcePath) {
        # 创建目标目录
        $backupDir = Split-Path $backupPath -Parent
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        # 复制文件
        Copy-Item -Path $sourcePath -Destination $backupPath -Force
        Write-Host "✓ 已备份: $file"
    } else {
        Write-Host "✗ 文件不存在: $file"
    }
}

Write-Host ""
Write-Host "==========================================================================="
Write-Host "备份完成！"
Write-Host "备份目录: $backupBase"
Write-Host ""
Write-Host "升级时恢复方法:"
Write-Host "1. 将 backup/hermes-web-ui-switch/ 下的文件复制到对应位置"
Write-Host "2. 重启 Web UI 服务"
Write-Host "==========================================================================="
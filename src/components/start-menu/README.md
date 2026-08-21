# Windows 11 Start Menu Glass Theme

这是一个独立的 Windows 11 开始菜单视觉组件，使用官方 Windhawk 模块 **Windows 11 Start Menu Styler** 的样式设置。它只调整开始菜单打开时的玻璃层、搜索框、应用悬停、账户与电源按钮，不替换 Explorer、桌面壁纸、Dock 或应用列表。

## 视觉

- 黑曜石底色，深红主光，紫晶和冰蓝细边。
- 统一的半透明毛玻璃、圆角和低亮度悬停状态。
- 保留 Windows 的实时固定应用、搜索、推荐、账户和电源菜单；不生成假的应用数据。
- 默认不携带动漫、人物或第三方图片。可在本机显式传入自己拥有使用权的图片作为背景。

## 前置条件

1. Windows 11。
2. 已从 [Windhawk 官方网站](https://windhawk.net/) 安装 Windhawk。
3. 已在 Windhawk 中安装并启用 `Windows 11 Start Menu Styler`。
4. 使用管理员 PowerShell 执行实际应用或恢复命令。

## 预览与应用

默认命令只显示计划，不写入注册表：

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\apply-start-menu-theme.ps1
```

确认后才显式应用：

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\apply-start-menu-theme.ps1 -Apply
```

使用你拥有权利的本地图片作为背景：

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\apply-start-menu-theme.ps1 -Apply -BackgroundImage "D:\Wallpapers\my-art.png"
```

图片路径只保存在执行这条命令的那台电脑的 Windhawk 设置中，不会写入或上传到本仓库。建议使用 PNG、JPG、JPEG 或 BMP，并把人物或高亮内容放在右侧，为左侧应用文字留出空间。

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\verify-start-menu-theme.ps1
```

验证脚本是只读的；它检查 Windhawk 设置、视觉规则和开始菜单宿主状态，不会打开开始菜单或修改系统。

## 恢复

首次实际应用时，脚本会先把原始 Windhawk Start Menu Styler 设置备份到：

```text
%LOCALAPPDATA%\ObsidianGlassDesktop\start-menu-theme\backups
```

恢复预览：

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\restore-start-menu-theme.ps1
```

确认后恢复：

```powershell
powershell -ExecutionPolicy Bypass -File .\src\components\start-menu\restore-start-menu-theme.ps1 -Apply
```

恢复只导入本组件第一次实际应用前保存的 Windhawk 配置，并重启当前用户的开始菜单与搜索宿主以刷新视觉。不会重启 Explorer、不会卸载 Windhawk、不会删除软件或个人文件。

## 公共发布边界

- 不包含任何本机 `.reg` 备份、日志、截图、账户信息或用户图片。
- 不自动安装 Windhawk 或模块。
- 不会随 `start-current.ps1` 自动运行；开始菜单主题始终需要用户显式执行 `-Apply`。

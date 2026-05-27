# 非常传输

[English](README.md) | [日本語](README_ja.md)

非常传输是 ExtraSync 的中文名。它是 ZeroTraceBrowser 的 Android 手机端伙伴应用，第一版只专注一件实用的事情：通过本地 Wi-Fi，把手机里的原始照片可靠地上传到已配对的 PC。

手机端会先发送照片元数据清单，然后只上传桌面端要求的原始文件。目标目录、导入状态、哈希、重复判断和最终整理都由 ZeroTraceBrowser 负责。

## 为什么做这个工具

很多时候，我们并不需要复杂的云相册，也不想为了导照片反复插线、复制、核对。我们只是想要一个可靠、免费、在本地网络里工作的手机照片传输工具。

非常传输就是为这个小而重要的需求做的：

- 手机和 PC 在同一个 Wi-Fi 下配对
- 手机枚举照片并发送 manifest
- PC 判断哪些文件需要上传
- 手机上传被请求的原始照片
- 已导入、重复、已在本地删除标记的项目不会反复上传

## 下载 / 安装

非常传输目前通过 Android APK 分发。

1. 从 GitHub Releases 下载最新版 `ExtraSync-vX.Y.Z-android.apk`。
2. 在 Android 手机上打开 APK。
3. 如系统提示“安装未知应用”，请允许当前文件管理器或浏览器安装。
4. 安装后打开非常传输，并与同一 Wi-Fi 下的 ZeroTraceBrowser 配对。

详细步骤见 [Install ExtraSync On Android](docs/InstallAndroid.md)。

适合被搜索到的关键词：

- 安卓照片传输到电脑
- Android 照片 Wi-Fi 传输
- 手机照片备份到 PC
- 免费照片传输工具
- 不用云盘传照片
- 本地 Wi-Fi 文件传输
- 手机同步 ZeroTraceBrowser

## 当前范围

- 扫描或粘贴 ZeroTraceBrowser 桌面端配对二维码 JSON。
- 保存已配对的桌面目标。
- 从 Android 媒体库发送照片 manifest 批次。
- 上传桌面端要求的原始照片。
- 支持自动连续同步和停止。
- 保留“相似照片”入口作为后续功能占位，但当前不实装。

当前手机端不做本机重复照片扫描、不做清理复核、不删除或整理手机相册。

## 项目结构

```text
app/                         Flutter Android 应用
  lib/
    main.dart                 入口
    src/
      app/                    应用组合、路由、主题
      features/
        dashboard/            上传优先的首页
        sync/                 配对、manifest、上传、自动同步界面
        settings/             设置与语言切换
      shared/                 i18n、设置、存储、平台桥接

core/                        为未来可移植逻辑预留
docs/                        产品、架构、安全说明
```

## Android 优先

当前工程只保留 Android 主线。Web、Windows、iOS 和旧的 native 占位目录都不属于当前交付范围，已经从活跃工程中移除。

## 安全边界

- 照片只会发送到已配对的本地 PC。
- 手机端不删除、不重排手机相册。
- 同步可以从手机端停止。
- 桌面端返回的已导入、重复、已本地删除状态会被手机端记录，用于后续跳过。

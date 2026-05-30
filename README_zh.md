# 非常传输 - Android 手机照片通过本地 Wi-Fi 传到电脑

[English](README.md) | [日本語](README_ja.md)

非常传输是 ExtraSync 的中文名。它是一款免费、本地优先的 Android 照片传输工具，用来通过本地 Wi-Fi 把手机里的原始照片发送到 Windows PC。它与 ZeroTraceBrowser 配合使用，让你不用云盘、订阅服务或反复插 USB 线，也能把 Android 手机照片备份到电脑。

手机端会先发送照片元数据清单，然后只上传桌面端要求的原始文件。目标目录、导入状态、哈希、重复判断和最终整理都由 ZeroTraceBrowser 负责。

## 为什么做这个工具

很多时候，我们并不需要复杂的云相册，也不想为了导照片反复插线、复制、核对。我们只是想要一个可靠、免费、在本地网络里工作的手机照片传输工具。

非常传输就是为这个小而重要的需求做的：

- 手机和 PC 在同一个 Wi-Fi 下配对
- 手机枚举照片并发送 manifest
- PC 判断哪些文件需要上传
- 手机上传被请求的原始照片
- 已导入、重复、已在本地删除标记的项目不会反复上传

如果你正在找“Android 照片传输到电脑”“手机照片通过 Wi-Fi 备份到 PC”“不用云盘传照片”或“本地 Wi-Fi 文件传输工具”，非常传输就是面向这个场景做的。

## 相关项目

非常传输需要配合桌面端 ZeroTraceBrowser 使用。桌面端负责目标目录、重复判断、导入记录和最终整理。

- 项目地址：[ZeroTraceBrowser](https://github.com/feilong-pixel/ZeroTraceBrowser)
- 克隆地址：`git clone https://github.com/feilong-pixel/ZeroTraceBrowser.git`

## 下载 / 安装

非常传输目前通过 Android APK 分发。

当前已发布版本：[ExtraSync v0.1.1](https://github.com/feilong-pixel/ZeroTraceMobile/releases/tag/v0.1.1)

Android 手机到 PC 的同步主链路已经完成真机验收。已验收范围包括：扫码配对、单批次传输、自动传输、10 张 manifest 批次、上传到 PC 的图片可正常打开、同步总数可信。详见 [Android Sync Acceptance](docs/AndroidSyncAcceptance.md)。

1. 从发布页面下载 `ExtraSync-v0.1.1-android.apk`。
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
- 通过本地记录的终态项目实现续传跳过，识别键为 `server_id + root_id + device_id + item_id`。
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

---
name: minimax-image-rec
description: MiniMax 图片内容识别工具。调用 MiniMax VLM 模型识别图片中的文字、数字、图表、表格等内容。适用场景：(1) 用户发送图片并要求识别分析；(2) 用户要求读取图片中的文字；(3) 需要提取图片内数据（如股票截图、文档、票据）时。
---

# MiniMax Image Recognition (VLM) Skill

基于 [MiniMax VLM](https://platform.minimaxi.com/) 模型的图片内容识别工具，可提取图片中的文字、数字、图表、表格等所有信息。

零依赖，只需 Node.js 18+，开箱即用。

## 特性

- 识别图片中的文字、数字、表格、图表
- 支持中英文混合内容
- 支持 png / jpg / jpeg / webp / gif 格式
- 自定义识别提示词，聚焦关注内容
- 零外部依赖，纯 Node.js 内置模块实现
- 完整的安装引导，交互式配置 API Key

## 快速开始

### 1. 安装

```bash
git clone https://github.com/toto2016/minimax-image-rec-skill.git
cd minimax-image-rec-skill
bash install.sh
```

安装脚本会自动：
- 检测 Node.js 环境
- 引导你输入 MiniMax API Key
- 生成 `.env` 配置文件

### 2. 获取 API Key

前往 [MiniMax 开放平台](https://platform.minimaxi.com/) 注册账号并创建 API Key。

### 3. 使用

```bash
node image-rec.mjs <图片路径> [识别提示词]
```

**示例：**

```bash
# 通用识别（自动分析所有内容）
node image-rec.mjs screenshot.png

# 提取文字
node image-rec.mjs doc.png "请提取图片中所有文字内容"

# 分析表格
node image-rec.mjs table.png "请详细描述图片中的表格结构和数据"

# 识别票据
node image-rec.mjs receipt.jpg "请提取图片中所有金额和日期信息"
```

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| 图片路径 | 要识别的图片文件路径（必填） | — |
| 识别提示词 | 告诉模型关注哪些内容（可选） | 分析图片所有内容 |

## 典型场景

1. **数据录入**：拍照 → 识别 → 自动填入表格
2. **文档数字化**：纸质文档拍照 → 提取文字 → 转存文本
3. **截图分析**：识别系统截图中的数据信息
4. **票据报销**：识别发票、收据上的金额和日期

## 作为 WorkBuddy / OpenClaw / QClaw Skill 使用

1. 将本目录复制到你的 skill 目录（如 `~/.workbuddy/skills/minimax-image-rec/`）
2. 运行 `bash install.sh` 配置 API Key
3. 重启客户端，skill 即可加载

## 环境变量

可通过 `.env` 文件或系统环境变量配置：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `MINIMAX_API_KEY` | MiniMax API Key（必填） | — |
| `MINIMAX_API_HOST` | API 地址 | `api.minimaxi.com` |

## 错误处理

| 错误信息 | 原因 | 解决方法 |
|----------|------|----------|
| `未配置 MINIMAX_API_KEY` | 未设置 API Key | 运行 `install.sh` 或手动创建 `.env` |
| `文件不存在` | 图片路径错误 | 确认文件路径正确 |
| `请求超时` | 网络问题或图片太大 | 检查网络，重试 |
| `解析失败` | API 返回格式异常 | 检查 API Key 是否有效 |

## License

MIT

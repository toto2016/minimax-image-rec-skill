#!/usr/bin/env node
/**
 * MiniMax 图片识别 CLI（VLM）
 *
 * 环境变量（优先从 .env 文件读取）:
 *   MINIMAX_API_KEY   - MiniMax API Key（必填）
 *   MINIMAX_API_HOST  - API 地址（默认 api.minimaxi.com）
 *
 * 用法:
 *   node image-rec.mjs <图片路径> [识别提示词]
 *
 * 输出: 识别结果到 stdout，错误信息到 stderr
 */

import { readFileSync, existsSync } from "node:fs";
import { request } from "node:https";
import { extname, join } from "node:path";

// ─── 配置读取（支持 .env 文件）──────────────────────────────
function loadEnv() {
  // 搜索顺序：脚本所在目录 → 当前工作目录
  const envPaths = [
    join(import.meta.dirname, ".env"),
    join(process.cwd(), ".env"),
  ];
  for (const envPath of envPaths) {
    if (existsSync(envPath)) {
      const content = readFileSync(envPath, "utf8");
      for (const line of content.split("\n")) {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith("#")) {
          const eqIdx = trimmed.indexOf("=");
          if (eqIdx > 0) {
            const key = trimmed.slice(0, eqIdx).trim();
            const val = trimmed.slice(eqIdx + 1).trim();
            if (!process.env[key]) process.env[key] = val;
          }
        }
      }
    }
  }
}

loadEnv();

const API_KEY = process.env.MINIMAX_API_KEY || "";
const API_HOST = process.env.MINIMAX_API_HOST || "api.minimaxi.com";
const EXT_MAP = { ".png": "png", ".jpg": "jpeg", ".jpeg": "jpeg", ".webp": "webp", ".gif": "gif" };
const DEFAULT_PROMPT = "请仔细分析这张图片，详细描述所有内容，包括文字、数字、图表、表格等。如果有中文请保留原文。";

// ─── 主函数 ────────────────────────────────────────────────
function main() {
  if (!API_KEY) {
    process.stderr.write("错误: 未配置 MINIMAX_API_KEY\n");
    process.stderr.write("请在 .env 文件或环境变量中设置 MiniMax API Key\n");
    process.stderr.write("参考 .env.example\n");
    process.exit(1);
  }

  const imagePath = process.argv[2];
  const prompt = process.argv[3] || DEFAULT_PROMPT;

  if (!imagePath) {
    process.stderr.write("用法: node image-rec.mjs <图片路径> [识别提示词]\n");
    process.stderr.write("示例: node image-rec.mjs screenshot.png\n");
    process.stderr.write("示例: node image-rec.mjs doc.pdf.png \"请提取图片中所有文字\"\n");
    process.exit(1);
  }

  const ext = extname(imagePath).toLowerCase();
  const mime = EXT_MAP[ext] || "jpeg";

  if (!existsSync(imagePath)) {
    process.stderr.write(`错误: 文件不存在 "${imagePath}"\n`);
    process.exit(1);
  }

  let b64;
  try {
    b64 = readFileSync(imagePath).toString("base64");
  } catch (e) {
    process.stderr.write(`读取文件失败: ${e.message}\n`);
    process.exit(1);
  }

  const dataUrl = `data:image/${mime};base64,${b64}`;
  const payload = JSON.stringify({ prompt, image_url: dataUrl });

  const req = request({
    hostname: API_HOST,
    path: "/v1/coding_plan/vlm",
    method: "POST",
    headers: {
      Authorization: `Bearer ${API_KEY}`,
      "Content-Type": "application/json",
      "MM-API-Source": "Minimax-MCP",
    },
    timeout: 120000,
  }, (res) => {
    let data = "";
    res.on("data", (c) => (data += c));
    res.on("end", () => {
      try {
        const parsed = JSON.parse(data);
        if (parsed.content) {
          process.stdout.write(parsed.content);
        } else {
          process.stderr.write(`VLM error: ${JSON.stringify(parsed)}\n`);
          process.exit(1);
        }
      } catch {
        process.stderr.write(`解析失败: ${data.substring(0, 300)}\n`);
        process.exit(1);
      }
    });
  });

  req.on("error", (e) => {
    process.stderr.write(`请求失败: ${e.message}\n`);
    process.exit(1);
  });
  req.on("timeout", () => {
    req.destroy();
    process.stderr.write("请求超时（120s）\n");
    process.exit(1);
  });

  req.write(payload);
  req.end();
}

main();

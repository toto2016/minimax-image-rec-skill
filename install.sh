#!/bin/bash
# MiniMax Image Recognition (VLM) Skill 安装脚本
# 用法: bash install.sh

set -e

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SKILL_DIR/.env"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  MiniMax Image Recognition (VLM)     ║${NC}"
echo -e "${CYAN}║  Skill 安装向导                       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── Step 1: 检查 Node.js ───
echo -e "${YELLOW}[1/3]${NC} 检查 Node.js 环境..."

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ 未找到 Node.js${NC}"
    echo ""
    echo "请先安装 Node.js（需要 18 或更高版本）："
    echo "  macOS:  brew install node"
    echo "  Linux:  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -"
    echo "  通用:   https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js 版本过低（当前 $(node --version)，需要 ≥ 18）${NC}"
    exit 1
fi

echo -e "${GREEN}✅${NC} Node.js $(node --version)"

# ─── Step 2: 配置 API Key ───
echo ""
echo -e "${YELLOW}[2/3]${NC} 配置 MiniMax API Key..."

if [ -f "$ENV_FILE" ]; then
    # 从现有 .env 中读取（不暴露具体值）
    source "$ENV_FILE" 2>/dev/null || true
    if [ -n "$MINIMAX_API_KEY" ]; then
        MASKED_KEY="${MINIMAX_API_KEY:0:6}...${MINIMAX_API_KEY: -4}"
        echo -e "${GREEN}✅${NC} 已检测到现有配置 (Key: ${MASKED_KEY})"
        read -p "是否重新配置？[y/N] " reconfig
        if [[ "$reconfig" =~ ^[Yy]$ ]]; then
            rm -f "$ENV_FILE"
            echo "已清除旧配置，重新配置..."
        else
            echo -e "${GREEN}✅${NC} 保留现有配置"
            # 跳到验证
            echo ""
            echo -e "${YELLOW}[3/3]${NC} 验证安装..."
            if [ -f "$SKILL_DIR/image-rec.mjs" ]; then
                echo -e "${GREEN}✅${NC} image-rec.mjs 就绪"
            else
                echo -e "${RED}❌${NC} image-rec.mjs 不存在"
                exit 1
            fi
            echo ""
            echo -e "${GREEN}安装完成！${NC}"
            echo ""
            echo "使用方式:"
            echo "  node image-rec.mjs <图片路径> [识别提示词]"
            echo ""
            echo "示例:"
            echo "  node image-rec.mjs screenshot.png"
            echo "  node image-rec.mjs doc.png \"请提取图片中所有文字\""
            exit 0
        fi
    fi
fi

echo ""
echo -e "${CYAN}请访问 MiniMax 开放平台获取 API Key：${NC}"
echo -e "  https://platform.minimaxi.com/"
echo ""
read -p "请输入你的 MiniMax API Key: " input_key

if [ -z "$input_key" ]; then
    echo -e "${RED}❌ API Key 不能为空${NC}"
    exit 1
fi

read -p "API Host [api.minimaxi.com]: " input_host
MINIMAX_API_HOST="${input_host:-api.minimaxi.com}"

cat > "$ENV_FILE" << EOF
# MiniMax Image Rec Skill - 环境配置
# 请勿将此文件提交到公开仓库

MINIMAX_API_KEY=${input_key}
MINIMAX_API_HOST=${MINIMAX_API_HOST}
EOF

chmod 600 "$ENV_FILE"
echo -e "${GREEN}✅${NC} 配置已保存到 .env（权限已设为 600）"

# ─── Step 3: 验证 ───
echo ""
echo -e "${YELLOW}[3/3]${NC} 验证安装..."

if [ -f "$SKILL_DIR/image-rec.mjs" ]; then
    echo -e "${GREEN}✅${NC} image-rec.mjs 就绪"
else
    echo -e "${RED}❌${NC} image-rec.mjs 不存在"
    exit 1
fi

# ─── 完成 ───
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ 安装完成！                       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "使用方式:"
echo "  cd $SKILL_DIR"
echo "  node image-rec.mjs <图片路径> [识别提示词]"
echo ""
echo "示例:"
echo "  node image-rec.mjs screenshot.png"
echo '  node image-rec.mjs doc.png "请提取图片中所有文字"'
echo "  node image-rec.mjs table.png \"分析表格结构和数据\""
echo ""
echo -e "${CYAN}详细说明请查看 SKILL.md${NC}"

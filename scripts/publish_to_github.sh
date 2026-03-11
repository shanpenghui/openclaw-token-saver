#!/bin/bash
# publish_to_github.sh - 一键发布到 GitHub
set -euo pipefail

SKILL_DIR="$HOME/.openclaw/workspace/skills/token-saver"
REPO_URL="https://github.com/shanpenghui/openclaw-token-saver.git"
VERSION="v1.0.0"

echo "🚀 OpenClaw Token Saver - GitHub 发布脚本"
echo "=========================================="
echo ""

# 检查技能目录
if [[ ! -d "$SKILL_DIR" ]]; then
    echo "❌ 技能目录不存在: $SKILL_DIR"
    exit 1
fi

cd "$SKILL_DIR"

# 检查是否已经是 git 仓库
if [[ -d ".git" ]]; then
    echo "⚠️  已存在 git 仓库，跳过初始化"
else
    echo "📦 初始化 git 仓库..."
    git init
    echo "✓ Git 仓库初始化完成"
fi

echo ""
echo "📝 添加文件到 git..."
git add SKILL.md README.md CONTRIBUTING.md RELEASE_GUIDE.md
git add scripts/ references/

echo ""
echo "当前将要提交的文件:"
git status --short

echo ""
read -p "确认提交? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 取消提交"
    exit 1
fi

# 提交
echo ""
echo "💾 提交更改..."
git commit -m "Initial release: OpenClaw Token Saver $VERSION

🚀 功能:
- 📊 成本分析工具 (analyze_costs.py)
- 🧹 一键优化脚本 (optimize_workspace.sh)
- 📚 定价指南 + 最佳实践
- 🎯 真实省钱: 60-90% 成本降低

基于 Jetson Orin Nano 高频机器人开发实测。
" || echo "⚠️  没有新的更改需要提交"

# 检查远程仓库
echo ""
if git remote | grep -q origin; then
    echo "✓ 远程仓库已配置: $(git remote get-url origin)"
else
    echo "🔗 添加远程仓库..."
    git remote add origin "$REPO_URL"
    echo "✓ 远程仓库已添加: $REPO_URL"
fi

# 推送
echo ""
echo "📤 准备推送到 GitHub..."
echo "仓库: $REPO_URL"
echo "分支: main"
echo ""
read -p "确认推送? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 取消推送"
    exit 1
fi

git branch -M main
git push -u origin main

echo ""
echo "✓ 推送成功！"
echo ""

# 创建 tag
echo "🏷️  创建版本标签: $VERSION"
if git tag | grep -q "$VERSION"; then
    echo "⚠️  标签 $VERSION 已存在，跳过创建"
else
    git tag -a "$VERSION" -m "Release $VERSION

OpenClaw Token Saver - 首个正式版

🎯 核心功能:
- 成本分析工具
- 一键清理脚本
- 完整定价指南
- 最佳实践清单

💰 验证效果:
- 轻度用户: 68% 降低
- 中度用户: 69% 降低
- 重度用户: 77% 降低

基于 Jetson Orin Nano 实测。
"
    git push origin "$VERSION"
    echo "✓ 标签已创建并推送"
fi

echo ""
echo "=========================================="
echo "✅ 发布完成！"
echo "=========================================="
echo ""
echo "下一步:"
echo ""
echo "1. 访问 GitHub 创建 Release:"
echo "   https://github.com/shanpenghui/openclaw-token-saver/releases/new"
echo ""
echo "2. 填写 Release 信息:"
echo "   - Tag: $VERSION"
echo "   - Title: Token Saver $VERSION - Initial Release | 首个正式版"
echo "   - Description: 复制 RELEASE_GUIDE.md 中的模板"
echo ""
echo "3. 上传文件:"
echo "   - 打包技能: cd ~/.openclaw/workspace && \\"
echo "     python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-saver"
echo "   - 上传: token-saver.skill"
echo ""
echo "4. 提交到 ClawHub:"
echo "   https://clawhub.com"
echo ""
echo "5. 分享到社区:"
echo "   - Discord: https://discord.com/invite/clawd"
echo "   - Twitter: #OpenClawSaver"
echo ""
echo "仓库地址: https://github.com/shanpenghui/openclaw-token-saver"

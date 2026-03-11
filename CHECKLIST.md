# 📋 发布清单 - OpenClaw Token Saver

按顺序完成以下步骤即可发布到 GitHub 并分享到社区。

## ✅ 准备阶段

- [x] 技能已创建并测试通过
- [x] 双语 README 已准备（中文优先）
- [x] 脚本已测试（`test_skill.sh` 通过）
- [x] 文档已完善（SKILL.md, pricing_guide.md, best_practices.md）
- [ ] 最终打包验证

```bash
cd ~/.openclaw/workspace
python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-saver
```

预期输出: `token-saver.skill` (~32KB)

## 📦 GitHub 发布

### 1. 创建 GitHub 仓库

**在 GitHub 网站 (https://github.com/new) 上操作:**

- **仓库名**: `openclaw-token-saver`
- **描述**: `Reduce OpenClaw API costs by 60-90% | OpenClaw 省钱神器`
- **可见性**: Public
- **不要**勾选 "Add a README file"（我们已经有了）
- **不要**勾选 "Add .gitignore"
- **许可证**: MIT License

### 2. 推送代码

**选项 A: 使用自动化脚本（推荐）**

```bash
cd ~/.openclaw/workspace/skills/token-saver
./scripts/publish_to_github.sh
```

脚本会自动完成:
- ✅ 初始化 git 仓库
- ✅ 添加文件并提交
- ✅ 关联远程仓库
- ✅ 推送到 GitHub
- ✅ 创建版本标签

**选项 B: 手动操作**

```bash
cd ~/.openclaw/workspace/skills/token-saver

# 初始化
git init
git add .
git commit -m "Initial release: OpenClaw Token Saver v1.0.0"

# 推送
git remote add origin https://github.com/shanpenghui/openclaw-token-saver.git
git branch -M main
git push -u origin main

# 打标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. 创建 Release

访问: https://github.com/shanpenghui/openclaw-token-saver/releases/new

**填写表单:**

- **Tag**: v1.0.0
- **Release title**: `Token Saver v1.0.0 - Initial Release | 首个正式版`
- **Description**: 复制 `RELEASE_GUIDE.md` 中"### 2. 创建Release"的模板内容
- **Attach files**: 上传 `~/.openclaw/workspace/token-saver.skill`
- 点击 **Publish release**

## 🌐 社区分享

### 4. 提交到 ClawHub

访问: https://clawhub.com

- **Name**: Token Saver
- **Category**: Productivity / Development Tools
- **Tags**: optimization, costs, tokens, billing, workspace, 省钱
- **Short description**: 
  - 英文: Reduce OpenClaw API costs by 60-90%
  - 中文: OpenClaw 省钱神器，降低 60-90% API 费用
- **Repository**: https://github.com/shanpenghui/openclaw-token-saver
- **Download**: https://github.com/shanpenghui/openclaw-token-saver/releases/latest/download/token-saver.skill

### 5. Discord 分享

加入 OpenClaw Discord: https://discord.com/invite/clawd

在 `#skills` 频道发布:

```markdown
🚀 **新技能发布: Token Saver | 省钱神器**

让你的 OpenClaw API 费用降低 60-90%！

📊 **功能:**
- 成本分析工具
- 一键清理脚本
- 定价完全指南

💰 **真实效果:**
- 轻度用户: 省 68%
- 重度用户: 省 77% (¥110/月)

🔗 GitHub: https://github.com/shanpenghui/openclaw-token-saver
📦 下载: https://github.com/shanpenghui/openclaw-token-saver/releases/tag/v1.0.0

基于 Jetson Orin Nano 高频机器人开发实测。
首次优化仅需 30 分钟，长期受益。
```

### 6. 社交媒体（可选）

**Twitter/X:**

```
🤖 刚发布了 Token Saver - OpenClaw 省钱神器！

通过自动化 workspace 优化，API 费用从 ¥143/月 → ¥33/月（省 77%）

完美适配高频编程/调试场景

⚡ 试试看: https://github.com/shanpenghui/openclaw-token-saver

#OpenClaw #AIOptimization #开源
```

**知乎/掘金（如果你用）:**

标题: "OpenClaw Token Saver：让你的 AI API 费用降低 77% 的开源工具"

正文: 可以基于 README.md 中文部分扩展

## 📊 后续维护

### 7. 收集反馈

- 关注 GitHub Issues
- 在 Discussions 中与用户互动
- 收集真实使用数据（优化前后对比）

### 8. 持续更新

**当有新功能/改进时:**

```bash
cd ~/.openclaw/workspace/skills/token-saver

# 1. 修改文件
# ... 编辑 ...

# 2. 测试
./scripts/test_skill.sh

# 3. 提交
git add .
git commit -m "Add: [功能描述]"
git push

# 4. 创建新版本
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# 5. 打包
cd ~/.openclaw/workspace
python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py skills/token-saver

# 6. 在 GitHub 创建新 Release，上传新的 .skill 文件
```

## 🎯 成功指标

发布成功的标志:

- [ ] GitHub 仓库可访问
- [ ] Release 页面有 token-saver.skill 文件
- [ ] README 正确显示（中英双语）
- [ ] ClawHub 上已提交
- [ ] Discord 社区已分享
- [ ] 至少收到 1 个 star ⭐（自己先 star）

## 💡 提示

1. **README.md 很重要** - 用户第一眼看到的，确保清晰易懂
2. **真实数据最有说服力** - 分享你自己的省钱案例
3. **及时回复 Issues** - 建立信任，促进社区成长
4. **保持更新** - 定期同步 OpenClaw 官方更新

## 🆘 遇到问题？

- **Git 推送失败**: 检查 GitHub 个人访问令牌（PAT）设置
- **打包失败**: 运行 `test_skill.sh` 排查问题
- **README 显示异常**: 检查 Markdown 语法
- **技能不触发**: 检查 SKILL.md 的 description 字段

需要帮助？在 Discord 提问或查看 OpenClaw 文档。

---

**祝发布顺利！🎉**

完成后记得在这里打勾，追踪你的进度。

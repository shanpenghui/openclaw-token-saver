# Contributing to Token Optimizer

感谢你考虑为Token Optimizer贡献！这个skill旨在帮助OpenClaw用户节省API成本，你的贡献可以帮助更多人。

## 如何贡献

### 1. 报告Bug或建议

在 [GitHub Issues](../../issues) 中创建issue：

**Bug报告模板**:
```markdown
**描述问题**
简要描述遇到的问题

**重现步骤**
1. 运行 `...`
2. 看到错误 `...`

**预期行为**
应该发生什么

**实际行为**
实际发生了什么

**环境**
- OpenClaw版本: 
- Python版本:
- 操作系统:
```

**功能建议模板**:
```markdown
**建议功能**
描述你想要的功能

**使用场景**
这个功能解决什么问题？

**替代方案**
你考虑过的其他方法
```

### 2. 分享你的省钱数据

在 [Discussions](../../discussions) 中分享你的优化成果：

```markdown
**使用场景**: 高频编程 / 日常聊天 / 生产机器人

**优化前月度成本**: ¥XXX
**优化后月度成本**: ¥XXX
**节省比例**: XX%

**具体优化措施**:
- [ ] 清理workspace
- [ ] 使用/new替代/reset
- [ ] 批量操作
- [ ] 其他: [描述]

**额外心得**:
[可选]分享你发现的其他技巧
```

### 3. 提交代码改进

#### 开发流程

```bash
# 1. Fork仓库并克隆
git clone https://github.com/YOUR_USERNAME/openclaw-token-optimizer
cd openclaw-token-optimizer

# 2. 创建功能分支
git checkout -b feature/your-feature-name

# 3. 进行修改
# 编辑文件...

# 4. 测试
./scripts/test_skill.sh

# 5. 提交
git add .
git commit -m "Add: [简要描述你的改进]"

# 6. 推送并创建PR
git push origin feature/your-feature-name
```

#### 代码规范

**脚本规范** (Bash/Python):
- 使用 `set -euo pipefail` (Bash)
- 添加适当的错误处理
- 包含帮助信息 (`--help`)
- 遵循现有代码风格

**文档规范**:
- 使用清晰的标题结构
- 提供具体的例子
- 包含预期输出
- 保持简洁（避免冗余）

**提交信息**:
- 使用有意义的前缀: `Add:`, `Fix:`, `Update:`, `Remove:`
- 第一行<50字符（英文）或<25字符（中文）
- 可选的详细描述从第三行开始

### 4. 改进文档

文档改进包括：
- 修正拼写/语法错误
- 添加更清晰的示例
- 更新过时的信息
- 翻译（英文↔️中文）

直接编辑相关文件并提交PR。

### 5. 添加新优化策略

如果你发现新的省钱技巧：

1. 在 `references/best_practices.md` 中添加
2. 如果需要自动化，添加到 `scripts/`
3. 更新 `SKILL.md` 的相关部分
4. 运行测试确保不破坏现有功能

**示例PR**:
```markdown
## 添加新优化: 子目录缓存控制

**背景**
发现大量用户在skills/子目录存储大文件导致缓存膨胀

**改进**
1. 在 best_practices.md 添加"子目录组织"章节
2. 更新 optimize_workspace.sh 支持 --max-skill-size 参数
3. 添加自动检测并建议移动大文件

**测试**
- [x] 运行 test_skill.sh 通过
- [x] 手动测试新参数
- [x] 更新文档

**预期节省**
对于有大型skill的用户，可额外节省10-30K tokens
```

## 优先级

当前需要帮助的领域（按优先级）：

### 高优先级
1. **真实使用数据收集** - 分享你的优化前后对比
2. **Bug修复** - 报告并修复发现的问题
3. **跨平台测试** - Windows/macOS兼容性验证

### 中优先级
4. **性能优化** - 提升脚本执行速度
5. **新的省钱策略** - 发现并文档化新技巧
6. **可视化工具** - 图表、仪表板等

### 低优先级
7. **多语言支持** - 翻译文档
8. **集成测试** - 自动化测试套件
9. **CI/CD** - GitHub Actions自动化

## 代码审查标准

PR会根据以下标准审查：

- ✅ **测试**: 通过 `test_skill.sh`
- ✅ **文档**: 改动有对应的文档更新
- ✅ **向后兼容**: 不破坏现有功能
- ✅ **简洁性**: 代码清晰易懂
- ✅ **实用性**: 解决真实问题

## 贡献者认可

所有贡献者会被添加到：
- `CONTRIBUTORS.md` 文件
- Release notes中的致谢部分

重大贡献者（>5个有意义的PR）会被邀请成为维护者。

## 许可证

通过贡献，你同意你的代码以MIT许可证发布。

## 行为准则

- 🤝 友好、包容、尊重他人
- 💬 建设性反馈，避免人身攻击
- 🎯 专注于技术问题，而非个人偏好
- 📚 帮助新手，分享知识

## 问题？

不确定如何开始？在 [Discussions](../../discussions) 中提问，或在Discord的OpenClaw频道@维护者。

---

**感谢你让Token Optimizer变得更好！** 🙏

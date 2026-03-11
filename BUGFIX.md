# Bug 修复记录

## 2026-03-11

### Bug 1: optimize_workspace.sh 语法错误

**问题描述**:
运行 `optimize_workspace.sh --dry-run` 时出现错误：
```
syntax error: operand expected (error token is "[0;34m[INFO][0m ...")
```

**原因**:
`trim_verbose_logs` 函数返回值（通过 `echo "$tokens_saved"`）被直接用于后续的算术运算，但该函数内部的 `log_info` 输出混入了返回值。

**修复**:
```bash
# 修复前
trim_verbose_logs
memory_tokens=$(archive_memory_files)

# 修复后
trim_tokens=$(trim_verbose_logs)
memory_tokens=$(archive_memory_files)
```

将 `trim_verbose_logs` 的返回值捕获到变量，避免输出污染。

**影响**: 中等 - 脚本无法正常运行

**状态**: ✅ 已修复

---

### Bug 2: analyze_costs.py 日志格式不匹配

**问题描述**:
脚本假设日志文件为 `~/.openclaw/logs/usage.jsonl`，但 OpenClaw 实际日志结构不同：
- 会话日志在 `~/.openclaw/agents/main/sessions/*.jsonl`
- 无统一的 usage.jsonl 文件

**影响**: 高 - 成本分析功能无法使用

**状态**: ⚠️ 待适配

**建议修复**:
1. 添加 `--session-log` 参数支持直接解析会话日志
2. 自动扫描 sessions 目录并聚合统计
3. 兼容多种日志格式

---

### Bug 3: 颜色代码在某些终端显示异常

**问题描述**:
ANSI 颜色代码在部分终端（如 PTY 环境）可能显示为转义序列。

**影响**: 低 - 仅影响显示美观

**状态**: 📝 已知问题

**临时方案**: 添加 `--no-color` 参数禁用颜色输出

---

## 测试建议

在发布前应测试以下场景：

1. ✅ 空 workspace（首次使用）
2. ✅ 有旧日志的 workspace
3. ⚠️ 大量技能的 workspace（未完整测试）
4. ⚠️ Windows/macOS 兼容性（未测试）

## 未来改进

1. 支持多种日志格式
2. 添加详细的错误提示
3. 跨平台兼容性测试
4. 集成测试套件

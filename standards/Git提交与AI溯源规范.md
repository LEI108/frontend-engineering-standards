# Git 提交与 AI 溯源规范

> 版本：1.0.0  
> 适用范围：采用 Git 且可能由 AI 参与的前端或全栈项目

本规范让历史能够回答：一个提交解决了什么、为何这样改、由谁审核、如何追溯。commit 只保存逻辑摘要；详细推理、文件清单和完整验证进入 PR 或变更记录。

## 1. 不可跳过的人工审核

只要本次变更有 AI 实质参与，无论由 AI 执行 commit 还是 AI 只输出命令交给人工执行，都必须先完成 staged diff 的人工审核。

顺序必须是：

```text
检查工作区和全部差异
→ 按逻辑目标规划提交
→ 精确暂存文件或 hunk
→ 复核 staged diff 和验证证据
→ 实际人工审核
→ 填写真实 trailers
→ commit
```

commit、push、变基、合并和发布分别需要相应授权。获得代码修改授权不等于获得这些权限。

## 2. 提交规划

### 2.1 先看完整工作区

至少检查：

```powershell
git status --short
git diff --stat
git diff
git diff --cached --stat
git diff --cached
```

未跟踪文件也要逐个判断。不得用 AI 摘要替代 diff，不得覆盖或顺带提交用户已有工作。

### 2.2 按目标聚类

一个 commit 只表达一个可回滚的逻辑目标，而不是“若干文件”或“这次对话做过的所有事”。出现下列情况通常应拆分：

- 新功能与无关 bug 修复；
- 页面行为与纯格式化；
- 多个彼此独立的视觉缺陷；
- 业务代码与无关部署/运维文档；
- 不同风险、不同验证方式或不同追踪 ID；
- 标题需要多个主要 type，正文充满“顺带”。

只有当拆开会造成不可运行、不可迁移或不一致发布时才合并，并在正文说明原子耦合原因。

### 2.3 精确暂存

优先使用明确文件和交互式 hunk：

```powershell
git add -- path/to/file-a path/to/file-b
git add -p -- path/to/mixed-file
```

不得把 `git add -A` 作为通用模板。一个文件包含多个目标时，应按 hunk 暂存；无法安全分割时先整理工作区或调整提交计划。

## 3. Commit 结构

```text
<type>(<scope>)!: <简洁中文结果>

<可选正文>

<trailers>
```

示例：

```text
feat(arrange): 增加学段年级班级级联筛选
fix(preview): 修复弹窗关闭后对象地址未释放
docs(spec): 建立前端开发正式规范
```

### 3.1 Type

| Type | 用途 |
| --- | --- |
| `feat` | 新增用户或业务能力 |
| `fix` | 修复不符合既定行为的问题 |
| `refactor` | 调整结构且预期不改变外部行为 |
| `perf` | 以性能改进为主要目的 |
| `docs` | 仅文档 |
| `test` | 仅测试或测试基础设施 |
| `style` | 不改变逻辑的格式或纯视觉调整；项目可进一步限制含义 |
| `build` | 构建、依赖和打包配置 |
| `ci` | CI/CD 和质量门禁 |
| `chore` | 其他维护事项 |
| `revert` | 回滚既有提交 |

`type` 和 `scope` 使用小写英文。scope 是稳定的领域或模块名，不是文件名、人员名或临时任务号。项目应在技术基线中维护自己的 scope 列表。

### 3.2 Subject

- 使用中文描述合并后的结果，避免“修改代码”“优化页面”等空话。
- 只表达一个主要目标，不列文件和实现步骤。
- 末尾不加句号；保持一行可读。50/72 字符是可读性建议，不是机械拒收线。

### 3.3 Body

正文可选。复杂或高风险变更建议简要说明：动机、关键行为、影响边界、实际验证、未验证项和变更记录编号。

正文不应逐文件复述 diff、粘贴日志、记录整段推理或堆叠多个追踪记录。细节放入 `AI-Trace` 对应文档。

## 4. AI Trailers

### 4.1 基础结构

AI 参与的 commit 必须以连续 trailer 段结束：

```text
AI-Usage: assist|generate|transform
AI-Review: <actual-reviewer-or-team>
AI-Trace: <change-id>
```

- 值必须精确使用 `assist`、`generate` 或 `transform`，不使用 `generated`、`transformed`。
- `AI-Review` 必须是真实完成 commit 前审核的人员或团队。
- `AI-Trace` 默认使用一个主要变更 ID；多个无关 ID 表明提交很可能应该拆分。
- 完全人工提交若项目要求所有 commit 均带 trailer，可以使用 `AI-Usage: none`。

### 4.2 可选 Trailer

项目可以配置：

```text
Risk-Level: R0|R1|R2|R3
Refs: <issue-or-decision-id>
BREAKING CHANGE: <description>
```

风险等级影响验证强度，但三个基础 AI trailers 不以风险等级为条件。

## 5. 提交前门禁

暂存后至少执行：

```powershell
git diff --cached --check
git diff --cached --stat
git diff --cached
git status --short
```

人工审核人应核对：

```text
[ ] staged diff 只包含计划中的一个逻辑目标
[ ] 没有无关格式化、调试、临时文件和用户预存修改
[ ] 业务、接口、权限、数据和错误合同正确
[ ] 验证结果与正文表述一致，未执行项没有冒充通过
[ ] 没有 Token、Cookie、密钥、个人数据或内部敏感内容
[ ] 标题、正文和 trailers 与实际变更一致
[ ] AI-Review 是当前实际审核人/团队
```

审核未完成时停止在这里，不生成或执行 commit。

## 6. PowerShell 安全模板

以下模板只能在 staged diff 已由人工审核后使用：

```powershell
$commitType = 'feat'
$commitScope = 'arrange'
$commitSummary = '增加学段年级班级级联筛选'
$aiUsage = 'generate'
$aiReviewer = Read-Host 'Enter the actual reviewer or review team'
$aiTrace = Read-Host 'Enter the current change ID'

if ([string]::IsNullOrWhiteSpace($aiReviewer) -or $aiReviewer -match '[<>]|待填写|TBD|unreviewed') {
  throw 'AI-Review 必须是实际审核人或团队，不能使用占位值。'
}

$commitMessage = @"
$commitType($commitScope): $commitSummary

验证：已执行本提交对应的针对性检查，详情见变更记录。
变更记录：$aiTrace

AI-Usage: $aiUsage
AI-Review: $aiReviewer
AI-Trace: $aiTrace
"@

$commitMessage | git commit -F -
```

审核标识和追踪号必须输入当前提交的真实值。AI 不得在未知审核人时替用户猜测。

## 7. 提交后检查

```powershell
git log -1 --format='%B'
git log -1 --format='%(trailers:key=AI-Usage)'
git log -1 --format='%(trailers:key=AI-Review)'
git log -1 --format='%(trailers:key=AI-Trace)'
git status --short
```

检查实际提交内容和 trailer 解析结果。commit 成功不代表 push 已获授权。

## 8. PR、分支与历史

- PR 应聚焦一个主要目标，说明用户结果、风险、验证和未完成项；UI 变更按项目要求附目标视口证据。
- 分支同步、rebase、merge、squash 和发布策略由项目配置，不写成全行业唯一方案。
- 不对他人已基于其工作的共享分支擅自 rebase。
- 已推送或发布的历史不应仅为了美化标题而重写；用修复提交或补充记录更正。
- 不通过历史改写掩盖 AI 参与、审核缺失或实际风险。

## 9. 项目配置项

每个项目应声明：默认分支、允许 type、稳定 scope、合并策略、变更记录目录、是否所有人工提交也带 trailer、是否启用 `Risk-Level`、允许的审核主体、提交/推送权限、钩子和 CI 命令。

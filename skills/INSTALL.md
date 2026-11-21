# Skill 安装与维护

`skills/` 是团队受控源，个人 Codex skills 目录是部署副本。不要直接在个人安装副本中形成唯一修改；修改应回到本规范包并重新安装。

## 安装

在规范包根目录执行：

```powershell
.\scripts\install-skills.ps1
```

安装指定 Skill：

```powershell
.\scripts\install-skills.ps1 -Names frontend-design,precision-frontend-engineering
```

脚本默认使用 `CODEX_HOME/skills`；未设置 `CODEX_HOME` 时使用当前用户目录下的 `.codex/skills`。也可以显式传入：

```powershell
.\scripts\install-skills.ps1 -Destination '<your-skills-directory>'
```

已存在同名目录时默认停止，不覆盖。确认需要更新时使用 `-Replace`；脚本会先把旧目录移动到带时间戳的备份目录，再安装新副本。

安装后重新启动或刷新支持 Skill 发现的客户端，并核对四个名称是否可见。

## 不安装时

可在任务中要求 AI 显式读取本包中的 `skills/<name>/SKILL.md`。这种方式适合不支持 Skill 自动发现的工具，但必须让 AI 继续读取入口中指向的条件 reference。

## 维护

1. 在本包受控副本中修改；
2. 运行 `scripts/verify-package.ps1`；
3. 更新 `manifest.yaml` 的 bundle changes 和包版本（如有实质变化）；
4. 在独立任务上验证触发和执行效果；
5. 重新安装，保留旧副本备份；
6. 不把 MCP、`.env`、缓存或业务项目数据放进 Skill 目录。

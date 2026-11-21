# Lanhu MCP 集成与安全指南

> 版本：1.0.0  
> 定位：`lanhu-design-build` 的外部工具依赖说明，不包含 MCP 源码和凭据

## 1. 为什么独立维护

Lanhu MCP 是独立 Python 服务，拥有自己的依赖、Playwright 浏览器、运行数据、Cookie、安全边界和升级周期。正式前端规范包只登记兼容合同，不复制服务源码，避免把外部运行组件与团队规范耦合。

上游仓库：`https://github.com/LEI108/lanhu-mcp-masterjson.git`

本规范核查的兼容提交：

```text
8b3f320f97dfda9527d2e78464c868c3abff0abc
```

核查时项目元数据显示 `1.0.0`，MasterJSON 增强仍记录在 `Unreleased`。在出现带相同能力的正式 tag 前，应按提交哈希锁定，不把该兼容状态误称为稳定发布版。

许可证：MIT。团队如另行镜像或离线分发源码，必须保留许可证和来源记录，并单独维护升级与安全流程。

## 2. 兼容能力

`lanhu-design-build` 当前依赖以下工具合同：

```text
lanhu_health_check
lanhu_resolve_invite_link
lanhu_get_design_workflow
lanhu_list_product_documents
lanhu_get_pages
lanhu_get_ai_analyze_page_result
lanhu_get_designs
lanhu_inspect_design_capabilities
lanhu_get_design_layers
lanhu_get_layer_tree
lanhu_get_property_evidence
lanhu_get_ai_analyze_design_result
lanhu_get_design_slices
```

关键兼容点：单设计工具支持显式 `design_id` 和 `version_id`；图层、子树和逐属性证据支持完整性/分页；能力检查区分 DDS、MasterJSON、整稿、样式面板来源和资源。

连接后以实时 Tool Schema 和 `lanhu_get_design_workflow` 为准。缺少版本锁、完整子树或属性证据能力时，停止设计实现并升级/重启 MCP，不能静默按旧合同继续。

## 3. 运行前提

- Python 3.10 或更高的受支持版本；
- Git；
- Playwright Chromium；
- 可访问目标项目的合法 Lanhu 账号；
- 本机可写但不进入 Git 的运行数据目录；
- MCP 客户端支持 stdio 或 Streamable HTTP；
- 项目当前锁定的 Python 依赖，其中 FastMCP 兼容版本为 `2.14.7`。

安装和启动命令应以锁定提交中的 `README.md`、`ai-install-guide.md` 和 `DEPLOY.md` 为准，不从本规范复制过期命令。

## 4. 安全配置

1. 从仓库的 `config.example.env` 创建本机 `.env`。
2. 真实 `LANHU_COOKIE` 只能由用户在本机填写。
3. AI 不得读取、打印、复制、索要或提交 Cookie 值，也不得尝试从浏览器提取凭据。
4. 客户端配置只引用启动脚本或 HTTP 地址，不包含 Cookie。
5. `.env`、data、logs、缓存、截图和证据目录不得提交到业务仓库或规范包。
6. 运行数据可能包含受限设计、文案和图片，应按项目数据分类控制访问、留存和删除。
7. Cookie 失效时由用户重新登录并只更新本机 `.env`；重启后重新执行健康检查。

不要通过关闭 TLS、导出 Cookie 到命令行、写入 Docker Compose、粘贴聊天或输出日志来排障。

## 5. 客户端接入

### stdio

客户端配置应引用当前机器上的启动脚本绝对路径，例如概念形式：

```json
{
  "mcpServers": {
    "lanhu": {
      "command": "<shell-or-command>",
      "args": ["<ABSOLUTE_PATH_TO_REPOSITORY>/run-stdio-script"]
    }
  }
}
```

不同客户端的字段可能不同，必须查当前客户端文档。不得把示例占位符直接当成可运行配置。

### HTTP

Docker 或常驻服务可使用项目文档提供的 HTTP 模式。进程启动或端口可访问只证明传输层存在，不证明工具注册、Cookie、项目权限、网络和 Chromium 均可用。

## 6. 健康与兼容检查

连接后先调用 `lanhu_health_check`，分别确认：

- MCP tools/resources；
- Cookie 是否配置；
- 目标项目访问权限；
- 网络域名可达性；
- Chromium；
- 存储可写性。

随后在实际设计任务中调用 `lanhu_get_design_workflow`，并按 Skill 锁定设计和版本。空资源列表可以是正常状态；客户端尚未完成 MCP 初始化、Cookie 失效、项目无权限、网络失败和 Chromium 缺失必须分别诊断。

## 7. 升级流程

1. 记录当前可用提交、Python、依赖和客户端配置；
2. 阅读上游 changelog 和 Tool Schema 变化；
3. 在隔离环境安装候选提交；
4. 运行项目测试和 Python 编译检查；
5. 验证 stdio/HTTP 初始化、健康检查、版本锁、图层分页、完整子树、属性证据和整稿资源；
6. 用非敏感测试项目完成一次只读证据链；
7. 更新本指南的兼容提交和 Skill（如需要）；
8. 保留回退到旧提交的方式。

不要仅因仓库版本号变大就自动升级团队环境。

## 8. 故障报告

报告工具名、阶段、原始结构化诊断、是否已进入网络阶段、设计/版本身份、已取得证据、缺失证据、可靠替代来源和是否阻断。不要把所有失败统一归因于 Cookie，也不要把 DDS 缺失误报为 MasterJSON 主链不可用。

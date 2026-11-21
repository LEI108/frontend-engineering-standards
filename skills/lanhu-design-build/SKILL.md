---
name: lanhu-design-build
description: Use Lanhu MCP evidence to plan, implement, and verify design-to-code pages, chart-based business homepages, and data dashboards. Use when Codex receives a Lanhu share or project link, must reproduce or refine a UI from Lanhu designs, needs MasterJSON layers, per-property evidence, or slices, or is building a cockpit with scaling, charts, autoplay, scrolling, and interaction requirements. Enforces explicit implementation authorization, exact design/version locking, source provenance, complete layer and property reads, target-repository reuse, code-quality contracts, and honest visual acceptance.
---

# Lanhu Design Build

Build from traceable Lanhu evidence while keeping requirement discussion, evidence acquisition, implementation, and acceptance as separate gates.

## Load the relevant references

- Before any Lanhu tool call, read [references/lanhu-evidence.md](references/lanhu-evidence.md).
- When any page or module contains charts or data visualizations, read [references/chart-runtime.md](references/chart-runtime.md). A chart-heavy ordinary homepage stays on the main workflow.
- Read [references/data-dashboard.md](references/data-dashboard.md) only for a cockpit, command center, wall display, fixed logical canvas, or page-level coordinated autoplay/scrolling.
- Before modifying or reviewing target code, read [references/code-quality.md](references/code-quality.md).
- Before modifying the target project and again before handoff, read [references/acceptance.md](references/acceptance.md).

## Respect the current stage

1. Identify whether the user requested confirmation, read-only analysis, implementation, or verification.
2. If the handoff says to wait for phrases such as “开始构建” or equivalent authorization, do not inspect the design or target repository until the allowed stage.
3. Treat read authorization and write authorization separately. Read-only inspection never implies permission to modify business code.
4. Stop and request the missing input only when a critical design, business, API, asset, or environment decision cannot be established safely.

## Protect secrets and user work

- Never read, print, quote, copy, or commit the Lanhu Cookie or other `.env` secrets.
- Read applicable `AGENTS.md` files before target-repository work.
- Preserve unrelated worktree changes and follow the repository's existing stack and conventions.
- Do not modify the Lanhu MCP repository while performing a business-page task unless the user separately requests MCP maintenance.

## Execute the gated workflow

### 1. Confirm requirements

- Track facts as `confirmed`, `tentative`, `pending`, `conflicting`, or `risky`.
- Resolve user-visible conflicts before implementation; do not silently choose between business requirements and the design.
- Record target route, data ownership, interactions, responsive behavior, asset constraints, and acceptance scope.

### 2. Inspect the target repository

- Identify framework and versions, routing, existing page/module, chart library, component library, assets, API layer, mock conventions, and available verification commands.
- Prefer source-level reuse of existing business behavior and data adapters.
- Treat installed packages as evidence, not permission to introduce a new abstraction or dependency.

### 3. Acquire and lock design evidence

- Follow the exact tool order and failure contract in `references/lanhu-evidence.md`.
- Lock `project_id`, `design_id`, `version_id`, `design_name`, and `canvas.local_frame` before module analysis.
- Pass the locked `design_id` and `version_id` to every single-design call.
- If the live latest version differs from an earlier handoff, report the drift and use only the version the user authorizes.
- Do not begin visual implementation while the full preview or required MasterJSON evidence is blocked.

### 4. Build implementation maps

- Maintain the module ledger, property ledger, asset map, and source-reuse map defined in `references/acceptance.md`.
- Read the parent, all required descendants, and every layer-tree page until the MCP reports completeness.
- Call `lanhu_get_property_evidence` for each implemented visual module and continue every property page until `complete=true`.
- Map each implemented property to `source_raw`, `normalized_value`, actual `lanhu_panel_css`, or explicitly labeled `derived_css`; keep unavailable properties pending.
- Keep screenshot estimates labeled as estimates; never present them as exact design values.
- Do not begin design-driven CSS or chart styling for a module while its required subtree or property ledger is incomplete unless the user explicitly accepts the gap.

### 5. Plan and implement minimally

- State the exact files and anchors before edits when the change is non-trivial.
- Reuse current components, charts, assets, routes, and data adapters before creating new ones.
- Download approved assets into the target repository; do not leave Lanhu remote URLs in generated production code.
- Keep real empty data, loading, errors, explicit mocks, and missing contracts distinguishable.
- Apply the comment and runtime-selector contract from `references/code-quality.md`; explain important structure, responsibilities, core processing, and non-obvious decisions without line-by-line narration.
- Implement only confirmed scope. Do not invent APIs, interactions, breakpoints, or design details.

### 6. Verify by risk

- Run focused static checks, then runtime checks, then visual and interaction checks as applicable.
- At the first runnable render, capture the target resolution. Stop accumulating visual patches when the page is grossly distorted, a semantic container is wrong, or a selector misses; diagnose evidence mapping, DOM structure, compiled CSS, and computed style first.
- Verify at the locked logical design resolution and separately inspect important module crops.
- Exercise hover, focus, tooltip, tab, selector, scroll, drag, autoplay, pause/resume, resize, empty, loading, and error behavior that exists in scope.
- Report each verification layer independently. A successful build does not prove runtime, visual, backend, or device acceptance.

## Report honestly

Return:

- the locked design identity and evidence availability;
- files changed and requirements implemented;
- design evidence used and any derived values;
- checks actually executed and their boundaries;
- unresolved differences, blocked items, and required human validation.

Never claim “一比一还原” or full completion unless the acceptance conditions in `references/acceptance.md` were actually satisfied.

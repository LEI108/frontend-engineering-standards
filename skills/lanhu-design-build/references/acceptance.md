# Implementation and acceptance contract

Read this before business-project edits and before final handoff.

## Contents

- Pre-edit checkpoint
- Required implementation maps
- First-render feedback gate
- Verification ladder
- Visual and interaction acceptance
- Pre-handoff review
- Completion language

## Pre-edit checkpoint

Confirm or explicitly mark pending:

- target route and repository;
- applicable `AGENTS.md` instructions;
- framework, component library, chart library, and versions;
- locked project/design/version and `canvas.local_frame`;
- verified full preview and MasterJSON completeness;
- complete module and per-property evidence;
- module ledger, property ledger, asset map, and source-reuse map;
- business data/API ownership and empty semantics;
- required interactions and scaling strategy;
- asset source, export scale, destination, and naming;
- applicable `code-quality.md`, `chart-runtime.md`, and `data-dashboard.md` references loaded;
- write authorization.

If a pending item changes user-visible behavior materially, stop for a decision. Otherwise state the narrow assumption and continue.

## Required implementation maps

### Module ledger

Maintain one row per module:

| Module | Layer ID/path | Exact evidence | Derived/estimated evidence | Source/API | Interaction | Code location | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |

Allowed status values:

- `confirmed`
- `tentative`
- `pending`
- `conflicting`
- `risky`
- `implemented`
- `verified`

Do not mark a module verified solely because its component compiled.

### Property ledger

Maintain a row for every implemented high-impact geometry, typography, color/gradient, border, radius, shadow, opacity, asset, and chart property:

| Module/layer path | Property | `source_raw` | `normalized_value` | `lanhu_panel_css` | `derived_css` | Implementation location | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |

Use only these source states:

- `source` — exact structured source is available;
- `normalized` — geometry changed only by `design_scale`;
- `panel` — a real Lanhu panel/API value is present;
- `derived` — a deterministic implementation value was produced and explained;
- `estimated` — measured from a screenshot and explicitly approximate;
- `pending` — no reliable value has been obtained;
- `not_applicable` — verified irrelevant to this implementation.

Do not use a conventional `14px`, `16px`, common gray, generic radius, spacing, shadow, or chart palette when the row is `pending`. Continue every `lanhu_get_property_evidence.next_offset` until `complete=true` before treating the module's property ledger as complete.

### Asset map

| Visible asset/decoration | Layer/slice source | Export scale | Local destination | Implementation use | Status |
| --- | --- | --- | --- | --- | --- |

Record formal slices, MasterJSON source assets, CSS-drawn shapes, fonts, and missing assets separately. Do not replace an available formal asset with an approximation without an explicit reason.

### Source-reuse map

| Existing source | Reusable behavior | Required design change | API/data differences | Interaction/lifecycle differences | Decision |
| --- | --- | --- | --- | --- | --- |

Compare components, API calls and parameters, adapters, tabs/filters, charts, tooltips, autoplay/scrolling, empty/error states, and cleanup as applicable. A matching filename or visual resemblance alone does not prove source-level reuse.

## First-render feedback gate

At the first runnable render, capture the page at the locked logical resolution before accumulating polish patches.

Stop and diagnose first when any of these occur:

- gross page distortion or a clearly wrong macro layout;
- an internal asset size was used as the semantic module size;
- a Less/Sass selector compiled but did not affect the intended DOM;
- a component-library default structure prevents the required result;
- the page relies on widespread conventional values instead of the property ledger.

Inspect the evidence mapping, actual DOM, compiled selector, scoped/deep/teleport behavior, winning rule, and relevant `getComputedStyle` values. Resume visual refinement only after the cause is identified.

## Verification ladder

Report each level independently:

1. **Source/static** — target files reviewed; lint, type check, or compile performed.
2. **Runtime** — the target route rendered in the actual application without relevant console/runtime errors.
3. **Visual** — full-page and important module comparisons completed at the locked logical design resolution.
4. **Interaction** — in-scope hover, focus, tooltip, tabs, filters, scroll, drag, autoplay, pause/resume, and resize behavior exercised.
5. **Data** — real non-empty, real empty, loading, error, explicit mock, and missing-contract states tested as applicable.
6. **External** — backend, device, deployment, crawler, or stakeholder acceptance completed when required.

Never infer a higher level from a lower one.

## Visual comparison

- Render at the logical design resolution from `canvas.local_frame`; do not compare a `3840×2160` exported preview against a `1920×1080` logical page without accounting for scale.
- Capture the full page and crop high-risk modules such as headers, dense charts, tables, legends, decorative frames, and nested controls.
- Compare geometry, hierarchy, typography, color/gradient, border, shadow, opacity, assets, clipping, and stacking.
- For high-risk nodes, compare rendered `getComputedStyle` with the implementation value and record browser-driven differences.
- Record whether a difference comes from design evidence, business requirements, browser rendering, missing assets/fonts, or an intentional implementation decision.
- Re-check after real fonts and images load.

Pixel-diff tooling can assist but cannot judge business correctness, dynamic data, animation timing, or acceptable browser font rasterization by itself.

## Interaction acceptance

For every interactive module, verify:

- initial state;
- user-triggered transition;
- automatic transition where required;
- continuity after manual interaction;
- hover/focus pause and resume;
- hidden-page or route-leave cleanup;
- keyboard/focus behavior where the control is actionable;
- empty/error behavior without broken layout.

## Pre-handoff review

Before final reporting:

- inspect the changed diff against `code-quality.md`, including the what/does/why comment contract;
- confirm no Cookie, token, `.env` value, Lanhu remote production URL, or generated evidence artifact is staged;
- identify visible or hidden mocks and remove temporary mock routing or labels that are outside the accepted scope;
- remove only temporary routes, debug controls, timers, assets, variables, imports, and comments introduced by the current change;
- verify derived CSS, accepted deviations, and missing evidence are listed in the handoff;
- keep unrelated user work untouched.

## Completion language

Use the narrowest true statement:

- “代码实现完成，已通过静态检查”
- “目标路由已完成运行验证”
- “已在锁定设计分辨率完成整稿和局部视觉核对”
- “已完成约定交互与数据状态验证”
- “已由用户/业务方验收”

Only say “一比一还原” when the locked design, complete evidence, runtime, visual, interaction, data, and required external acceptance have all passed with no undisclosed material differences.

## Final handoff

Include:

- locked design/version and evidence sources;
- exact changed files;
- requirements implemented;
- derived values or accepted deviations;
- commands and runtime checks actually performed;
- visual and interaction evidence obtained;
- unresolved blockers, missing contracts, and validation the user must still perform.

# Code quality and runtime CSS contract

Read this before editing or reviewing target code. Apply the target repository's conventions first.

## Contents

- Comment contract
- Structure and component boundaries
- Runtime selector verification
- Derived CSS and browser behavior
- Review gate

## Comment contract

Use comments to help the next developer identify **what a section is**, **what important code does**, and **why a non-obvious decision exists**. Do not optimize for comment count.

### 1. Identify core template modules

Place a short comment before a major business region, complex interaction region, or structurally non-obvious template block.

```vue
<!-- 学情趋势：展示当前筛选周期的班级成绩变化 -->
<section class="learning-trend">...</section>
```

Do not comment every wrapper, text node, or obvious element.

### 2. Explain important state and constants

Comment state whose lifetime, unit, source, coupling, or reset behavior is not obvious.

```js
// 轮播步骤同时包含页签和周期，避免两个独立定时器组合出无效状态。
const carouselSteps = [...]
```

Do not comment self-explanatory state such as `loading` or `activeTab` unless it has a special constraint.

### 3. State each key method's responsibility

Add a one- or two-line responsibility comment above important business, interaction, chart, data-adapter, and utility methods.

```js
// 根据当前角色合并首页模块权限，并保留接口返回顺序。
function buildVisibleModules(...) { ... }
```

Skip trivial assignments and one-line lifecycle glue whose meaning is already explicit.

### 4. State each API method's purpose

Explain the business purpose and important verified filters of an API wrapper. Do not invent request fields, response semantics, freshness, or backend guarantees.

```js
// 获取当前学校和学段的首页教学概览；空数组表示接口成功但暂无数据。
function fetchTeachingOverview(params) { ... }
```

### 5. Explain core internal processing

Comment only important transformations, branches, state synchronization, stale-response protection, and cleanup inside a method.

```js
// 仅提交当前筛选版本的响应，防止快速切换后旧请求覆盖新页面。
if (requestVersion !== activeRequestVersion) return
```

Do not restate syntax such as `// 遍历数组` immediately above `items.map(...)`.

### 6. Explain non-obvious reasons

Place the reason next to compatibility workarounds, derived CSS, unusual layout choices, timer coordination, browser limitations, or deliberate deviations from the design source.

```css
/* border-image 会覆盖普通边框绘制，因此圆角由外层裁切容器负责。 */
.panel-frame { ... }
```

Record the actual reason. Do not use vague comments such as “特殊处理” or “防止报错”.

### 7. Identify every important chart configuration

State which business visualization an option builder serves and what the non-obvious encoding represents.

```js
// 班级能力雷达图：维度顺序必须与蓝湖标签的顺时针顺序保持一致。
function createAbilityRadarOption(data) { ... }
```

Keep chart-specific differences visible. Do not hide them behind a generic-theme comment.

### 8. Divide long style sections

Use short section comments in long style files to expose layout hierarchy, module styles, states, responsive/scaling rules, and scoped overrides.

```less
// 页面骨架
...

// 学情趋势模块
...

// Element UI 局部覆盖
...
```

Do not add a heading before a tiny or self-contained style block.

### 9. Keep comments accurate and restrained

- Keep most comments to one or two lines.
- Update comments in the same change when behavior changes.
- Remove comments made obsolete by the current change.
- Describe verified behavior, not intended behavior that the code does not provide.
- Avoid decorative prose, jokes, blame, temporary conversation, and historical narration.
- Reject line-by-line comments that add no information beyond identifiers and syntax.

## Structure and component boundaries

- Prefer semantic page regions and native controls when their behavior fits; do not replace every node with a `div`.
- Split components by business responsibility, independent data ownership, interaction lifecycle, or meaningful reuse. Do not create a component for every visual rectangle.
- Preserve the target project's naming, Vue/React version, styling language, component library, chart wrapper, and accessibility patterns.
- Use absolute positioning for design-backed macro placement only when required. Use Grid, Flex, table layout, or normal flow inside modules when they preserve behavior and dynamic content better.
- Keep component-library reuse conditional on semantic and visual fit. A package being installed is not proof that its default component matches the design.

## Runtime selector verification

A successful Less/Sass build proves syntax only. Before treating a style fix as effective:

1. Inspect the rendered DOM and the actual class/attribute hierarchy.
2. Inspect the compiled selector and confirm it matches that DOM.
3. Check scoped attributes, CSS Modules names, `:deep()`/`::v-deep`, teleport/portal targets, pseudo-elements, and specificity when applicable.
4. Read `getComputedStyle` for high-risk typography, geometry, color, border, shadow, overflow, transform, and stacking properties.
5. Confirm the intended rule is the winning rule, not merely present in a stylesheet.

If the selector does not match, stop adding stronger overrides. Correct the selector or DOM ownership first.

## Derived CSS and browser behavior

- Preserve the design source and implementation value separately.
- Use `lanhu_panel_css` only when the MCP reports a real panel/API source.
- Label deterministic conversions from MasterJSON as `derived_css` and record why the target stack needs them.
- Treat screenshot measurements as estimates, never as exact CSS evidence.
- Verify browser interactions such as `border-image` with `border-radius`, gradients with opacity, transformed clipping, filters, masks, font fallback, pseudo-elements, and stacking contexts at runtime.
- When mechanically copying source CSS renders incorrectly, retain the source record, implement the smallest justified derived form, and verify the full page plus the affected crop.

## Review gate

Before handoff, inspect the changed diff and confirm:

- core template regions, key methods, APIs, chart configurations, and non-obvious decisions have useful comments;
- obvious lines are not mechanically narrated;
- comments still match the code;
- selectors match the runtime DOM and high-risk computed styles were checked when a browser run was available;
- any derived CSS or deliberate deviation is traceable in the handoff.

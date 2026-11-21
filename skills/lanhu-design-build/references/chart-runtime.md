# Chart and data-visualization runtime

Use this reference for any ordinary page or dashboard that contains charts or data visualizations. The presence of many charts does not turn a responsive business homepage into a data-dashboard branch.

## Keep chart evidence module-specific

- Map each chart's container geometry, typography, colors, gradients, borders, legend, axes, grid, series, symbols, tooltip, labels, and empty state to design evidence or an explicitly recorded derived decision.
- Do not replace exact per-chart evidence with a generic ECharts theme or one universal option builder.
- Share only genuinely common mechanics. Keep business encodings, scale domains, series order, label formatting, and interactions visible per chart.
- Distinguish the semantic module container from decorative frames, chart plot bounds, and exported assets.

## Manage chart lifecycle

- Reuse the installed ECharts/Vue wrapper and its current registration pattern.
- Initialize only after the container exists and has non-zero dimensions; use `nextTick` or the framework equivalent when required.
- When project fonts affect labels, wait for font readiness before the first important measurement where practical.
- Resize through the existing wrapper, `ResizeObserver`, or one coalesced viewport handler. Avoid competing resize systems.
- Resize after a hidden tab, collapsed panel, dialog, or route section becomes visible.
- Choose merge behavior deliberately. Full replacement can remove stale series but reset interactive state.
- Dispose chart instances, observers, handlers, timers, and pending work during teardown.
- Synchronize custom scrollbars and ECharts `dataZoom` through one source of truth.

## Preserve data semantics

Keep these states distinct:

- loading;
- successful non-empty data;
- successful empty data;
- backend/API error;
- explicit development mock;
- unknown or unconfirmed contract.

Do not turn an API failure into `[]`, cache it as success, or silently replace it with attractive mock data. Keep the real adapter path intact and label temporary mocks in code and handoff.

## Handle requests only as needed

Do not add a cache merely because a chart exists. When filters, rapid switching, pagination, refresh, or autoplay can overlap requests:

- key data by every business filter that changes the response;
- deduplicate same-key in-flight requests when the API semantics allow it;
- prevent an older response from overwriting newer selected state;
- cache successful empty data only as a genuine successful response;
- do not write failures into a success cache;
- define TTL, invalidation, and capacity only when caching is actually required.

Keep manual and automatic transitions on the same reactive state and request path.

## Test dynamic volume

Exercise applicable states, not only the design sample count:

- zero items;
- one item;
- the design-sample count;
- just enough content to overflow;
- a large result set;
- long labels or text;
- zero, negative, decimal, and extreme values where the business domain permits them.

Check axis domains, label collisions, truncation, tooltips, legends, table height, overflow, empty states, and whether interactions remain reachable.

## Verify charts

At minimum, check:

- initial layout before and after fonts/assets settle;
- target-resolution full page and high-risk chart crops;
- rendered legend, axis, grid, labels, series order, colors, gradients, and tooltip;
- resize and hidden-container reactivation;
- rapid filter changes and stale-response protection when applicable;
- loading, empty, error, mock, and unknown-contract states;
- disposal after route leave or component replacement.

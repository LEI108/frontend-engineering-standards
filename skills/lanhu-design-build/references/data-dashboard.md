# Data dashboard branch

Use this branch only for data cockpits, command centers, wall displays, fixed logical canvases, or pages with coordinated page-level autoplay/automatic scrolling. Keep a responsive business homepage on the main workflow even when it contains many charts. Also apply `chart-runtime.md` whenever charts exist.

The following company patterns were observed on 2026-08-08 in these repository-relative locations:

- `proj_jia_class_web/src/views/dataCockpit`
- `proj_inner_zida_school_web/src/views/schoolCockpit/brain_new`

Re-read the current target code before reuse. These are candidate patterns, not universal defaults.

## Choose scaling from evidence

1. Read `canvas.local_frame`; never assume `1920×1080` or infer it from preview pixels.
2. Inspect the target project's existing screen shell and product requirement.
3. Choose and record one strategy:
   - independent `scaleX/scaleY` to fill the viewport, accepting distortion;
   - uniform `min(scaleX, scaleY)` with centering/letterboxing;
   - responsive layout with breakpoint-driven reflow.
4. Do not replace an established project strategy without an explicit requirement.

For the observed company non-uniform pattern, use a fixed logical canvas, `transform-origin: left top`, independent viewport ratios, and hidden outer overflow. Coalesce resize events with `requestAnimationFrame`; consider `visualViewport.resize`; remove listeners and cancel frames on teardown.

Test at the design ratio, ultrawide, narrow/windowed, and browser zoom conditions. Check text deformation and chart legibility when independent scaling is used.

## Model page-level autoplay as explicit state

- Represent a simple carousel as an ordered step list and one active index.
- Represent nested tabs/filters as composite steps such as `{ tab, period }`; do not run independent timers that create invalid combinations.
- After manual selection, synchronize the carousel index so the next automatic step continues from the user's state.
- Let manual and automatic changes update the same reactive state and request path.
- Do not start autoplay when the content has zero or one valid step.
- Pause on hover and keyboard focus when the module is interactive.
- Pause relevant carousels while a detail dialog or blocking overlay is open.
- Stop while `document.hidden`; restart from current state when visible.
- Respect `prefers-reduced-motion` when autoplay is decorative.
- Clear intervals, listeners, and pending work on teardown.

## Implement automatic scrolling deliberately

- Enable only when content actually overflows by a meaningful distance.
- Use one `requestAnimationFrame` loop for smooth scrolling.
- Pause on hover/focus and synchronize stored position after manual scrolling.
- Define whether the endpoint loops, reverses, stops, or pages; do not choose silently.
- Avoid cloning rows unless continuous-loop duplication is confirmed and its accessibility impact is handled.
- Cancel animation frames on teardown and reduce/disable motion when required.

## Choose number animation minimally

- Reuse an existing project counter when it meets formatting and animation needs.
- For a small Vue 3 scope, a local `requestAnimationFrame` counter can be simpler than adding a dependency.
- A Vue 2 repository may already include `vue-count-to`; verify actual usage and compatibility first.
- Use a component-library Statistic only when its styling and behavior match.
- Do not add VueUse, CountUp, or another package solely because it is popular.

Preserve separators, decimals, units, update direction, duration, reduced-motion behavior, and teardown. Animate real value transitions, not every render.

## Coordinate dashboard requests and caches

Add this model only when dashboard filters, autoplay, re-entry, or repeated modules justify caching:

- Build the cache key from the module plus every response-changing context, such as school/tenant, period, grade, tab/project, date, page, and page size.
- Keep successful data, in-flight requests, and retry timing as distinct concepts.
- Reuse an unexpired success entry; deduplicate a same-key in-flight request.
- Cache a successful empty result as empty data. Never cache a failure as empty or successful data.
- Use a short retry boundary only to prevent request storms; keep the error state visible.
- Compare the current filter key or request version before committing a response.
- Define per-module TTL, explicit invalidation, and a maximum entry count or LRU policy.
- Invalidate on relevant school/tenant/user changes, confirmed refresh/save events, date boundaries, and other business changes.
- On route leave, clear timers and component-owned in-flight references. Decide explicitly whether module-level success data survives re-entry.

Do not force one global cache abstraction onto modules with different freshness and ownership semantics.

## Schedule first load and pagination

- Prioritize shell and critical summary modules instead of blocking the whole page on one global `Promise.all` when the product permits progressive rendering.
- Isolate module failures so one rejected request does not erase unrelated successful modules.
- For paginated lists, include page, page size, and all filters in request/cache identity.
- Choose preloading only when result size, freshness, and network cost justify it.
- Keep page failure local and retryable; do not turn it into a successful empty page.

## Verify dashboard behavior

In addition to `chart-runtime.md`, check:

- the chosen page-scaling strategy at all required viewport shapes;
- page-level autoplay order and manual-to-auto continuity;
- hover/focus, dialog, visibility, and route-leave pause/cleanup;
- automatic-scroll overflow threshold, endpoints, and manual interaction;
- zero, one, design-count, just-overflow, large, long-text, and extreme-value states;
- progressive first load and isolated module failures;
- cache hit, expiry, invalidation, same-key deduplication, failure, retry boundary, and stale-response rejection when caching exists;
- timers, observers, charts, requests, and animation frames after route leave.

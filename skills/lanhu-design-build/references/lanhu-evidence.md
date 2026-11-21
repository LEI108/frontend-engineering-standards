# Lanhu evidence workflow

Use this contract before reading or implementing from a Lanhu design.

## Contents

- Source of truth
- Tool sequence
- Version and canvas rules
- Capability and readiness rules
- Value provenance and completeness
- Assets and failure reporting

## Source of truth

Apply this order when instructions differ:

1. Current user requirements and stage authorization.
2. Target repository `AGENTS.md` and current source/runtime behavior.
3. Live `lanhu_get_design_workflow` output and current MCP tool schemas.
4. This reference.

Do not trust an old prompt, cached design ID, or prior version as current without checking it live.

## Tool sequence

1. Call `lanhu_health_check` with the project URL when available.
   - Report tools, resources, Cookie/project access, network, Chromium, and storage separately.
   - An empty MCP resource registry can still be ready; a client-side “server not ready” failure occurs before Lanhu business APIs.
   - If the live schemas lack the parameters described here, stop and request an MCP restart instead of using an older contract silently.
2. For `/link/#/invite` URLs, call `lanhu_resolve_invite_link` with `invite_url`.
3. Call `lanhu_get_design_workflow` and follow its current gates.
4. Call `lanhu_get_designs` and select only from returned designs.
5. Record a design lock:

   ```text
   project_id
   team_id when present
   design_id
   design_name
   version_id
   canvas.local_frame after capability inspection
   ```

6. Call `lanhu_inspect_design_capabilities` with the locked `design_id` and `version_id`.
7. Call `lanhu_get_ai_analyze_design_result` with the same IDs, normally using `output_mode=files`; read `context.md`, `manifest.json`, and the returned preview resource.
8. Query modules through `lanhu_get_design_layers`, then `lanhu_get_layer_tree`; continue every `next_offset` until `complete=true`.
9. For each visual module selected for implementation, call `lanhu_get_property_evidence` with the same design/version lock and module root. Continue every property page until `complete=true`.
10. Call `lanhu_get_design_slices` only when asset metadata is needed. Treat it as data-only output.

## Version and canvas rules

- Pass the locked `design_id` and `version_id` to every single-design tool.
- Omitting `version_id` means intentionally reading the current latest version; never omit it accidentally during an implementation session.
- If the latest version changes after requirements or implementation started, stop mixing evidence. Report the old and new IDs and ask which version controls the task.
- Use `canvas.local_frame` as the logical implementation canvas.
- Treat `canvas.normalized_frame.x/y` as the design-tool workspace origin, not page-local coordinates.
- Treat design-list and `preview_metadata_size` dimensions as preview metadata.
- Treat analyzer preview dimensions as downloaded raster pixels; they can differ from the logical canvas because of export scale.

## Capability and readiness rules

Keep these statuses separate:

- MCP/tool readiness
- authenticated project access
- DDS availability
- MasterJSON availability
- raw-layer availability and completeness
- preview address advertised
- preview download verified
- real style-panel CSS source availability and reason
- asset metadata availability
- visual implementation blocked/unblocked

DDS is optional. A DDS `10011` failure does not invalidate working MasterJSON or a verified preview.

`style_panel_css.available=false` means the current MCP has no real panel/API source and did not make a panel-CSS request. Do not report it as a transient read failure. Use only the listed fallback sources and keep the panel field unavailable.

MasterJSON and a verified full preview serve different purposes:

- MasterJSON supplies traceable geometry, hierarchy, text, style, and asset evidence.
- The full preview validates visual relationships and overall composition.

Do not claim complete visual implementation if required MasterJSON or the full preview remains blocked unless the user explicitly accepts that evidence gap.

## Value provenance

Preserve these meanings:

| Value | Meaning | Allowed use |
| --- | --- | --- |
| `source_raw` | Original MasterJSON field | Traceability; never relabel as panel CSS |
| `normalized_value` | `source_raw` converted only by `design_scale` | Logical geometry evidence |
| `lanhu_panel_css` | CSS actually returned by a Lanhu panel/API | Use as panel evidence only when present |
| `derived_css` | Deterministic conversion from structured data | Implementation aid with an explicit derived label |

Do not round, convert color syntax, collapse gradients, or merge visible layers merely for aesthetic consistency. Apply a conversion only when the target stack requires it, and retain the source.

## Completeness rules

- A parent frame is not evidence of its internal shapes, text, assets, or stacking order.
- A page of flat results is not complete while `next_offset` exists.
- A subtree is not complete while `complete=false`, `truncated=true`, or a continuation exists.
- A property ledger is not complete while `lanhu_get_property_evidence` returns `next_offset`, `truncated=true`, or `complete=false`.
- Prefer a unique layer ID after discovery. Reject ambiguous paths instead of guessing.
- Persist module queries when supported so later implementation can be traced to exact design/version evidence.

The property tool projects evidence for the module root selected by the caller. It does not decide which visual layer is the business semantic container. Establish that mapping from the complete tree, full preview, target source, and requirements before treating property rows as implementation ownership.

## Assets

- Slice output contains names, paths, scale metadata, and URLs; it does not choose platform/scale, download, rename, or write into the business project.
- Confirm the target platform, export scale, destination, and naming convention before writing assets.
- Download only after target-project write authorization, verify non-empty content, and keep a failure list.
- Do not leave Lanhu remote URLs in production code.

## Failure report

For every failure, report:

- tool name and stage;
- original structured diagnostic or recognizable error;
- whether a network request was attempted when known;
- design/version identity involved;
- evidence already acquired;
- missing evidence and whether a reliable alternative exists;
- whether implementation is blocked.

Never turn an input-encoding, client lifecycle, local storage, or schema-version problem into a generic Cookie/network diagnosis.

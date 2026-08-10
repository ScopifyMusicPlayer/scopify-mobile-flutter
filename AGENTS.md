# Scopify Mobile Agent Instructions

This directory is the standalone Flutter client. The root `AGENTS.md` governs
the Web and Electron applications; this file governs code under
`frontend/apps/mobile`.

## Read First

- `docs/structure.md`: where Flutter code belongs and which boundaries apply.
- `docs/project-plan.md`: current milestone and acceptance criteria.
- `docs/technical-stack.md`: confirmed packages and ownership rules.
- `docs/mobile-pages.md`: page, drawer, modal, and state specifications.
- `docs/web-design-language.md`: visual language to map into Flutter tokens.
- `CONTEXT.md`: domain vocabulary only. Do not put implementation decisions in it.

Before exploring unfamiliar code, use `codegraph explore`. Preserve unrelated
working-tree changes and do not create empty directory trees in anticipation of
future milestones.

## Structure

- `pages/<business>/` owns its routes, local layouts, components, providers,
  API functions, and DTOs as needed.
- Root `layouts/` is only for cross-business layout: App Shell, shared detail,
  modal, and player geometry.
- Put a component in `components/shared/` only after two business areas truly
  share its semantics and interaction. Similar appearance alone is not enough.
- A Page selects route and async state. A Layout owns geometry and slots. A
  Component renders a focused product element.
- Normal data flows through Riverpod to a same-business thin API, then Dio.
  Do not add forwarding Repository, Interface, or Adapter layers.
- Only long-lived, single-owner capabilities belong in `modules/`, including
  playback, session, QR login, endpoint, and recognition.

## Implementation Rules

- Material 3 is the only UI foundation. Use `AppTokens` and `AppMotion`; do not
  repeat raw brand colors, radii, spacing, or animation timings in pages.
- `go_router` and generated typed routes are the only page-navigation entry.
- Widgets never import Dio, SQLite, secure storage, or audio plugins directly.
- Keep first-release pages on Fixture data until the current milestone calls for
  real integrations. Fixture states must make loading, data, empty, and error
  reproducible.
- Put product strings behind the selected localization system once it is added.
- Prefer small Fakes and Provider overrides in tests; mock platform boundaries
  only when a Fake cannot express the behavior.

## Verification

Run the narrowest relevant checks first, then use `flutter analyze` and
`flutter test` before handoff. The current manual target is the Android
Emulator; do not expand the milestone to iOS or device E2E without agreement.

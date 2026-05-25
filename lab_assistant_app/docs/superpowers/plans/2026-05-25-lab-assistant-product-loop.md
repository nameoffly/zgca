# Lab Assistant Product Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing Flutter prototype into a testable local product loop that matches `方案介绍.docx`: record process evidence, structure reports, compare experiment versions, and produce traceable exploration insights.

**Architecture:** Keep the app Flutter-only for the hackathon MVP, with local model/service abstractions that can later be replaced by real STT, LLM, storage, and vector search backends. UI screens consume a single `AppState` facade so every visible button changes state, opens a useful detail surface, or advances the workflow.

**Tech Stack:** Flutter 3.41, Dart 3.11, `flutter_test`, Material 3, no new runtime dependencies.

---

### Task 1: Domain Model And Service Loop

**Files:**
- Create: `lib/models/experiment.dart`
- Create: `lib/services/lab_workflow_service.dart`
- Test: `test/lab_workflow_service_test.dart`

- [ ] **Step 1: Write failing service tests**

Create tests for:
- demo experiment contains voice/image/instrument evidence
- generated report includes purpose, actual operations, condition changes, observations, metrics, raw evidence, and next suggestions
- version diff identifies changed variables and result differences
- insights include evidence links, uncertainty, next experiment action, and adoption state

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/lab_workflow_service_test.dart`
Expected: FAIL because model/service files do not exist yet.

- [ ] **Step 3: Implement minimal model/service**

Implement immutable-ish Dart classes and deterministic local service methods. Do not add network or persistence dependencies.

- [ ] **Step 4: Run tests to verify GREEN**

Run: `flutter test test/lab_workflow_service_test.dart`
Expected: PASS.

### Task 2: App State Workflow

**Files:**
- Modify: `lib/state/app_state.dart`
- Test: `test/app_state_test.dart`

- [ ] **Step 1: Write failing state tests**

Cover:
- setting title/goal/domain updates current draft
- starting recording marks the experiment as recording
- ending recording creates report, diff, and insights
- marking a transcript entry changes evidence/flag state
- export/adopt actions update observable state

- [ ] **Step 2: Run tests to verify RED**

Run: `flutter test test/app_state_test.dart`
Expected: FAIL before state is upgraded.

- [ ] **Step 3: Implement state facade**

Keep existing public properties where screens depend on them, add workflow properties, and ensure every user action emits `notifyListeners()`.

- [ ] **Step 4: Run tests to verify GREEN**

Run: `flutter test test/app_state_test.dart`
Expected: PASS.

### Task 3: UI Product Loop Upgrade

**Files:**
- Modify: `lib/screens/start_experiment_screen.dart`
- Modify: `lib/screens/recording_screen.dart`
- Modify: `lib/screens/ideas_screen.dart`
- Modify: `lib/widgets/section_card.dart`
- Modify: `lib/theme.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write failing widget tests**

Cover:
- start screen edits title/goal and starts recording
- recording screen buttons open safety/source/evidence/history/detail surfaces or mutate state
- finish recording navigates to整理 page with report, version comparison, and traceable insights
- export and idea adoption buttons produce stateful feedback

- [ ] **Step 2: Run widget tests to verify RED**

Run: `flutter test test/widget_test.dart`
Expected: FAIL before UI is wired to the upgraded state.

- [ ] **Step 3: Implement UI upgrade**

Use compact scientific mobile UI, fewer words, no dummy placeholder buttons. Keep core functions visible: record, evidence, structured report, version diff, insight, export, adopt next plan.

- [ ] **Step 4: Run widget tests to verify GREEN**

Run: `flutter test test/widget_test.dart`
Expected: PASS.

### Task 4: Polish, Analyze, And Build

**Files:**
- Modify as required by analyzer/build/test failures.

- [ ] **Step 1: Fix lint warnings**

Resolve `unnecessary_underscores` in `lib/widgets/wave_decoration.dart`.

- [ ] **Step 2: Run full verification**

Run:
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

Expected: all commands exit 0.

- [ ] **Step 3: Review button coverage**

Search for `占位`, `TODO`, and button handlers. Every button must either mutate state, open a meaningful sheet/dialog, or navigate.


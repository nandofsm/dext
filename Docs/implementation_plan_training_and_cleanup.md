# Implementation Plan - Training Content & Examples Reorganization

This plan has two objectives:
1.  **Trainer's Guide**: Enrich the `Docs\EXAMPLES_ROADMAP.md` with detailed lesson plans for the user to record their training.
2.  **Cleanup**: Reorganize the existing 41 example projects into a structured category system.

## Proposed Changes

### 1. Training Content Enrichment (Docs\EXAMPLES_ROADMAP.md)

- Add **Lesson Objectives** for each of the 7 stages.
- Add **Critical Concepts** to be explained (e.g., "Closure Capture", "ARC Side Effects").
- Add **Scripting Hints**: Pointers on what to show in the IDE for maximum impact.

### 2. Examples Reorganization

#### [MOVE] Existing folders to new categorical structure:
- **`Examples\Basics\`**: Core.LoggingDemo, Core.TestConfig, Net.RestClient.Demo.
- **`Examples\Web\`**: Web.MinimalAPI, Web.ControllerExample, Web.JwtAuthDemo, Web.SslDemo, etc.
- **`Examples\Data\`**: Orm.EntityDemo, Dext.Examples.MultiTenancy, Orm.Specification, etc.
- **`Examples\Networking\`**: Core.TestHttpParser, Net.RestClient.Demo.
- **`Examples\RealTime & UI\`**: Hubs, WebStencilsDemo, Desktop.MVVM.CustomerCRUD.
- **`Examples\Testing\`**: (Create or move specific test demos here).
- **`Examples\Archived_PoCs\`**: Move older or redundant demos here.

### 3. Training Projects Setup
- Create `Examples\MasterTraining\` with the 7 staged projects defined in the roadmap.

## Open Questions

> [!IMPORTANT]
> 1. **Project Group**: Should I update the `DextExamples.groupproj` to reflect the new directory structure? (Necessary for IDE browsing).
> 2. **Scripting detail**: For your recording, do you want me to write "Tutorial-style" READMEs inside each `MasterTraining` project?
> 3. **Existing Examples Quality**: Should I spend time refactoring the *code* of the 41 existing examples to bring them up to "Modern Dext" standards, or just reorganize them first?

## Verification Plan

### Manual Verification
- Verify that all 41 examples still compile after moving (updating relative paths in `.dproj` if necessary).
- Review the `EXAMPLES_ROADMAP.md` for "Trainer-friendliness".

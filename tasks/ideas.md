# Ideas Bin

Potential projects, someday/maybe, things to explore.

<!-- Format: - [ ] [DATE] Idea description -->

- [ ] [2025-11-25] **Multi-PC task sync via GitHub Issues** - Use `gh issue` CLI for real-time task sync between PCs. Labels: urgent, development, administration, ideas, waiting. Commands: `gh issue list --label dev`, `gh issue create --title "X" --label urgent`, `gh issue close <num>`. Can pivot to Notion later if needed.

## ClaudesHome Setup Fixes (2025-11-26 audit)

### High Priority
- [ ] [2025-11-26] **Fix admin module exports** - `ClaudesHomeAdmin.psd1` declares 81 functions but only 6 exist in `.psm1`. Either trim the manifest or properly export from platform scripts.
- [ ] [2025-11-26] **Centralize Doppler path** - Hardcoded in 7 files. Create shared helper or config variable.
- [ ] [2025-11-26] **Stop displaying passwords** - `Reset-UniversalPassword` prints passwords to console. Return success/failure only.

### Medium Priority
- [ ] [2025-11-26] **Implement or remove Five9 call stats script** - `scripts/integrations/five9/get-call-stats.ps1` has TODO stub, completely non-functional.
- [ ] [2025-11-26] **Add error handling to data scripts** - `export-records.ps1`, `query.ps1`, `count-records.ps1` lack proper validation.
- [ ] [2025-11-26] **Fix org alias inconsistency** - Using both `uat-jwt` and `PartialCopy` for same sandbox. Pick one.

### Low Priority
- [ ] [2025-11-26] **Delete orphan `nul` file** - Windows artifact in repo root.
- [ ] [2025-11-26] **Implement project shortcuts** - CLAUDE.md documents "work on salesforce" etc. but they don't exist.
- [ ] [2025-11-26] **Populate SOP directories** - `sops/five9/` and `sops/it/` are empty despite being referenced.
- [ ] [2025-11-26] **Start using meta tracking** - `usage-patterns.md` and `improvement-ideas.md` are empty.


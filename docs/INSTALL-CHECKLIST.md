# Session Management - Installation Checklist

Quick checklist to verify the Opus 4.5 default setup is working correctly.

## Step 1: Apply Configuration
```bash
source ~/.bashrc
```
**Expected:** No errors

---

## Step 2: Verify Environment Variable
```bash
echo $ANTHROPIC_MODEL
```
**Expected:** `opus`

✓ Pass / ✗ Fail: ___

---

## Step 3: Verify Settings File
```bash
cat ~/.claude/settings.json
```
**Expected:**
```json
{
  "model": "opus"
}
```

✓ Pass / ✗ Fail: ___

---

## Step 4: Run Full Diagnostic
```bash
cd ~/IdeaProjects/ClaudesHome
./scripts/session-manager.sh verify
```
**Expected:**
- ✓ ANTHROPIC_MODEL=opus
- ✓ Settings file exists
- ✓ Sessions directory status shown
- ✓ Happy CLI authenticated

✓ Pass / ✗ Fail: ___

---

## Step 5: Test Fresh Session
```bash
claude
```

**Expected:**
- Session starts
- Model indicator shows Opus or Claude Opus 4.5
- No errors about model

**In the session, type:**
```
What model are you?
```

**Expected response:** Should mention Opus 4.5

✓ Pass / ✗ Fail: ___

**Exit:** `Ctrl+D`

---

## Step 6: Test Resume Session
```bash
claude -c
```

**Expected:**
- Resumes the session you just exited
- Shows previous conversation
- Model is still Opus 4.5

✓ Pass / ✗ Fail: ___

**Exit:** `Ctrl+D`

---

## Step 7: Test Model Switching (Optional)
```bash
claude
```

**In session, type:**
```
/model sonnet
```

**Expected:**
- Confirms switch to Sonnet
- Works without errors

**Then type:**
```
/model opus
```

**Expected:**
- Confirms switch back to Opus
- Works without errors

✓ Pass / ✗ Fail: ___

**Exit:** `Ctrl+D`

---

## Step 8: Test Happy Integration
```bash
happy
```

**Expected:**
- Navigates to ClaudesHome
- Starts session with Opus 4.5
- No errors

✓ Pass / ✗ Fail: ___

**Exit:** `Ctrl+D`

---

## Step 9: Verify Session Storage
```bash
ls ~/.claude/projects/
```

**Expected:**
- Directory exists
- Shows project folders with encoded paths
- Recent activity visible

✓ Pass / ✗ Fail: ___

---

## Step 10: Test Session Manager Script
```bash
./scripts/session-manager.sh list
```

**Expected:**
- Shows sessions for current directory
- Lists recent sessions

✓ Pass / ✗ Fail: ___

---

## Troubleshooting

### If ANTHROPIC_MODEL is not set:
```bash
# Add to ~/.bashrc manually
echo 'export ANTHROPIC_MODEL=opus' >> ~/.bashrc
source ~/.bashrc
```

### If settings file missing:
```bash
echo '{"model":"opus"}' > ~/.claude/settings.json
```

### If sessions not saving:
```bash
# Check permissions
ls -la ~/.claude/
# Should be readable/writable by you
```

### If Happy not working:
```bash
happy doctor
happy auth status
```

---

## Quick Reference Commands

After successful installation:

| Task | Command |
|------|---------|
| Fresh session | `claude` |
| Resume last | `claude -c` |
| Pick session | `claude -r` |
| With Sonnet | `claude --model sonnet` |
| Happy fresh | `happy` |
| Happy resume | `happy -c` |
| Verify setup | `./scripts/session-manager.sh verify` |
| List sessions | `./scripts/session-manager.sh list` |

---

## Success Criteria

All checks should pass (✓):
1. ✓ Environment variable set
2. ✓ Settings file exists
3. ✓ Diagnostic passes
4. ✓ Fresh session works with Opus
5. ✓ Resume session works
6. ✓ Model switching works
7. ✓ Happy integration works
8. ✓ Sessions are stored
9. ✓ Session manager script works

**If all pass:** You're good to go! 🎉

**If any fail:** See troubleshooting section or `docs/session-management.md`

---

**Last Updated:** 2025-11-26
**Model:** Claude Opus 4.5

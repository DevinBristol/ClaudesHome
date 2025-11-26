# ClaudesHome Documentation

## Session Management

### Quick Start
- **[Quick Reference](quick-reference-sessions.md)** - TL;DR commands for sessions
- **[Full Guide](session-management.md)** - Comprehensive session management guide

### Key Takeaways
✓ **Opus 4.5 is now the default** for both Claude and Happy
✓ Start fresh session: `claude` or `happy`
✓ Resume last session: `claude -c` or `happy -c`
✓ Switch models anytime: `/model opus` or `/model sonnet`

### Tools
```bash
# Use the session manager script
./scripts/session-manager.sh new      # Fresh session
./scripts/session-manager.sh resume   # Continue last
./scripts/session-manager.sh verify   # Check config
./scripts/session-manager.sh help     # Full options
```

---

## Other Documentation

*More documentation coming as ClaudesHome grows...*

---

## Contributing to Docs

When adding new documentation:
1. Create your doc in this `docs/` folder
2. Add it to this README
3. Reference it in the main `CLAUDE.md` if relevant
4. Keep it concise and actionable

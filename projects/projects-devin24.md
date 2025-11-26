# Projects Map - Devin24 (Home PC)

**Current PC:** Devin24 (Home PC)
**Projects Root:** `C:\Users\devin\IdeaProjects`
**Last Updated:** 2025-11-26

---

## Active Projects on This PC

### Command Center
| Project | Path | GitHub | Description |
|---------|------|--------|-------------|
| **ClaudesHome** | `ClaudesHome` | [repo](https://github.com/DevinBristol/ClaudesHome) | ✅ Command center, task management, SOPs, scripts |

### AI/Automation Projects
| Project | Path | GitHub | Description |
|---------|------|--------|-------------|
| **DevinSwarm** | `DevinSwarm` | [repo](https://github.com/DevinBristol/DevinSwarm) | ✅ Salesforce + Node.js swarm project |
| **DSwarm** | `DSwarm` | Has git | Alternative swarm implementation |
| **DevAgentWorkspace** | `DevAgentWorkspace` | Has git | Development agent workspace |
| **DevinHub** | `DevinHub` | Has git | Hub for agent coordination |
| **salesforce-org-analysis** | `salesforce-org-analysis` | [repo](https://github.com/DevinBristol/salesforce-org-analysis) | ✅ SF org analysis/export tool |

### Other Projects
| Project | Path | Git | Description |
|---------|------|-----|-------------|
| **CodexRescue** | `CodexRescue` | No | Unknown - needs investigation |
| **WorkforceTemp** | `WorkforceTemp` | No | Workforce sandbox metadata |
| **empty1** | `empty1` | No | Empty/test directory |
| **patches** | `patches` | No | Patch files directory |

### Notable Files in Root
- `devinswarm.db.backup` - Database backup from DevinSwarm
- `fix-plan.patch` - Patch file for fixes

---

## Missing from This PC

These projects are on the Work PC but NOT on Home PC:
- **bristol-sf-project** - Main Salesforce development
- **Production** - Production metadata
- **PartialNewest** - Partial copy sandbox
- **salesforce-ai-agent** - AI-powered SF agent
- Various sandbox snapshots (FullCopy, etc.)

---

## Project Status

### ✅ Active & Synced
- ClaudesHome (command center)
- DevinSwarm (main swarm project)
- salesforce-org-analysis (org export tool)

### 🔍 Need Investigation
- **CodexRescue** - What is this?
- **DSwarm** - How different from DevinSwarm?
- **DevAgentWorkspace** - What agents?
- **DevinHub** - Purpose?

### 🗑️ Can Probably Delete
- empty1 (empty directory)
- patches (if patches applied)

---

## Quick Commands for This PC

```bash
# Navigate to projects
cd /mnt/c/Users/devin/IdeaProjects/ClaudesHome
cd /mnt/c/Users/devin/IdeaProjects/DevinSwarm
cd /mnt/c/Users/devin/IdeaProjects/salesforce-org-analysis

# Check git status of all projects
for dir in /mnt/c/Users/devin/IdeaProjects/*/; do
  [ -d "$dir/.git" ] && echo "$(basename "$dir"):" && git -C "$dir" status -s
done
```

---

## Sync Recommendations

1. **Clone missing critical projects from Work PC:**
   - bristol-sf-project (main SF development)
   - salesforce-ai-agent (AI agent)

2. **Investigate unknown projects:**
   - Check what CodexRescue is for
   - Determine if DSwarm vs DevinSwarm are duplicates
   - Review DevAgentWorkspace and DevinHub

3. **Clean up:**
   - Remove empty1 if not needed
   - Archive old patches

---

## GitHub Repos to Clone

If you want to sync with Work PC, clone these:
```bash
cd /mnt/c/Users/devin/IdeaProjects
git clone https://github.com/DevinBristol/bristol-sf-project.git
git clone https://github.com/DevinBristol/salesforce-ai-agent.git
```

---

## Notes

- This PC appears to be focused more on AI/automation projects
- Salesforce development projects mostly on Work PC
- ClaudesHome is properly synced between both PCs
- Several projects need GitHub remote setup
# Development Rules for Fret Not

## Git & Testing Protocol

### ⚠️ CRITICAL: Always Let User Test Before Committing

**RULE**: Never stage files or commit code without explicit user approval after testing.

**Workflow:**
1. Make code changes
2. Tell user changes are complete
3. **WAIT for user to test on simulator/device**
4. User will say "commit it" or similar when ready
5. Only then: stage files and commit

**Why**:
- User needs to verify functionality works correctly
- Bugs/issues often only appear when actually running the app
- Better to catch problems before they're committed to git history

**Example - CORRECT:**
```
Assistant: I've converted SongDetailView to push navigation and increased chord grid columns on iPad.
          The changes are ready for you to test.
User: [tests the app]
User: "Looks good, commit it"
Assistant: [stages and commits]
```

**Example - INCORRECT:**
```
Assistant: Changes complete. Committing now...
Assistant: [stages and commits without user testing]
❌ WRONG - user didn't get to test first!
```

---

## Code Changes Protocol

### Design System Compliance
- Always use design system components (`.warmCard()`, `.warmTextField()`, etc.)
- Never use manual styling like `.background(Color(.systemBackground))` without checking if design system equivalent exists
- Refer to: `/GuitarSongbook/DesignSystem/README.md`

### iPad Optimization
- Check if layout needs iPad-specific adjustments
- Use `UIDevice.current.userInterfaceIdiom == .pad` for device detection
- Consider column counts, spacing, max widths
- Refer to: `IPAD_AUDIT.md`

### Navigation Patterns
- Use push navigation (NavigationLink) for detail views
- Keep sheets for modal actions (forms, pickers, confirmations)
- Be consistent - same type of content should use same navigation pattern

---

## Communication Protocol

### When Changes Are Complete
1. ✅ Explain what was changed
2. ✅ List files modified
3. ✅ Say "Ready for you to test"
4. ❌ DON'T commit automatically
5. ❌ DON'T push automatically

### When User Says to Commit
1. ✅ Stage the relevant files (not xcuserstate)
2. ✅ Write descriptive commit message
3. ✅ Include co-author attribution
4. ❌ DON'T push unless user explicitly says "push"

---

## File Management

### Never Commit These Files
- `*.xcuserstate` - User-specific Xcode state
- `.DS_Store` - macOS folder metadata
- `*.swp`, `*~` - Editor temporary files

### Always Stage These When Modified
- Source files (`.swift`)
- Project files (`.xcodeproj/project.pbxproj`) when version changes
- Documentation (`.md` files)
- Assets when added

---

## Commit Message Format

```
Brief summary (50 chars or less)

Detailed description of changes:
- What was changed
- Why it was changed
- Any important notes

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

**Last Updated**: 2026-01-22
**Reminder**: These rules exist to ensure quality and user control. Always follow them.

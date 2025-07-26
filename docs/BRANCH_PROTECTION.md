# Branch Protection Setup

This document explains how to set up branch protection rules to ensure that all Pull Requests pass the required CI checks before merging.

## GitHub Branch Protection Rules

### Required Settings

To enable merge blocking when CI fails, configure the following branch protection rules for the `main` branch:

#### 1. Access Repository Settings
1. Go to your repository on GitHub: `https://github.com/iqbqioza/cj`
2. Click on **Settings** tab
3. Click on **Branches** in the left sidebar

#### 2. Add Branch Protection Rule
1. Click **Add rule**
2. In **Branch name pattern**, enter: `main`

#### 3. Configure Protection Settings

**Restrict pushes that create files larger than 100 MB:**
- ✅ Enable

**Require a pull request before merging:**
- ✅ Enable
- ✅ Require approvals: `1` (recommended)
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ Require review from code owners (if you have CODEOWNERS file)

**Require status checks to pass before merging:**
- ✅ Enable
- ✅ Require branches to be up to date before merging

**Required Status Checks:**
Add these status checks (they will appear after the first PR runs):
- `All Checks Passed` - Main CI status check
- `validate` - Project validation
- `test (ubuntu-latest)` - Ubuntu tests
- `test (macos-latest)` - macOS tests  
- `test (windows-latest)` - Windows tests
- `cross-compile` - Cross-compilation tests
- `memory-check` - Memory leak detection
- `static-analysis` - Static code analysis

**Restrict pushes that create files larger than 100 MB:**
- ✅ Enable

**Restrict force pushes:**
- ✅ Enable

**Allow deletions:**
- ❌ Disable (recommended for main branch)

#### 4. Admin Settings (Optional but Recommended)

**Do not allow bypassing the above settings:**
- ✅ Include administrators

This ensures that even repository administrators must follow the same rules.

## Status Check Configuration

### Primary Status Check

The main status check is `All Checks Passed`, which depends on all other CI jobs:

```yaml
all-checks-passed:
  name: All Checks Passed
  needs: [validate, test, cross-compile, memory-check, build-scripts, static-analysis]
```

This job will only succeed if ALL required jobs pass.

### Individual Status Checks

Each CI job creates its own status check:

| Job Name | Purpose | Failure Impact |
|----------|---------|----------------|
| `validate` | Project structure validation | Blocks merge |
| `test (ubuntu-latest)` | Ubuntu build and test | Blocks merge |
| `test (macos-latest)` | macOS build and test | Blocks merge |
| `test (windows-latest)` | Windows build and test | Blocks merge |
| `cross-compile` | Cross-platform builds | Blocks merge |
| `memory-check` | Memory leak detection | Blocks merge |
| `static-analysis` | Code quality checks | Blocks merge |

## Automatic PR Comments

The CI system automatically adds comments to PRs:

### Success Comment
```markdown
## ✅ All CI Checks Passed

Great work! All required checks have passed successfully.

**Passed Jobs:**
- ✅ Validation
- ✅ Tests (Ubuntu, macOS, Windows)
- ✅ Cross-compilation
- ✅ Memory leak detection
- ✅ Build scripts
- ✅ Static analysis

This PR is ready for review and merge! 🎉
```

### Failure Comment
```markdown
## ❌ CI Checks Failed

Some required checks failed. Please review the failed jobs and fix the issues before merging.

**Failed Jobs:**
- Validation: ❌
- Tests: ✅
- Cross-compilation: ❌
- Memory checks: ✅
- Build scripts: ✅
- Static analysis: ✅

Please check the Actions tab for detailed logs.
```

## Merge Button States

### When CI Passes ✅
- **Merge pull request** button is **enabled**
- **Squash and merge** button is **enabled**
- **Rebase and merge** button is **enabled**

### When CI Fails ❌
- All merge buttons are **disabled**
- GitHub shows: "Required status check 'All Checks Passed' has not passed"
- Contributors must fix issues and push new commits

## Troubleshooting Branch Protection

### Status Checks Not Appearing

If status checks don't appear in the branch protection settings:

1. **Create a test PR** to trigger the CI workflow
2. **Wait for CI to complete** (successful or failed)
3. **Refresh** the branch protection settings page
4. **Add the status checks** that now appear in the list

### Bypass Protection (Emergency)

Repository administrators can temporarily bypass protection:

1. Go to the PR page
2. Use **administrator override** option (if enabled)
3. **Document the reason** in PR comments
4. **Re-enable protection** immediately after merge

**⚠️ Warning:** Only use this for critical hotfixes.

### Common Status Check Names

After running CI, these checks will be available:

```
All Checks Passed
validate
test (ubuntu-latest)
test (macos-latest)
test (windows-latest)
cross-compile
memory-check
build-scripts
static-analysis
set-commit-status
```

## Testing Branch Protection

### Create a Test PR

1. **Create a new branch:**
   ```bash
   git checkout -b test-branch-protection
   ```

2. **Make a small change:**
   ```bash
   echo "// Test change" >> src/main.c
   git add src/main.c
   git commit -m "test: branch protection"
   git push origin test-branch-protection
   ```

3. **Create PR** and verify:
   - CI runs automatically
   - Merge button is disabled until CI passes
   - Status checks appear in PR

### Simulate CI Failure

To test merge blocking:

1. **Introduce a build error:**
   ```c
   // Add invalid C code to test failure
   invalid_syntax_here
   ```

2. **Push changes** and verify:
   - CI fails
   - Merge buttons remain disabled
   - Failure comment appears

3. **Fix the error** and verify:
   - CI passes
   - Merge buttons become enabled
   - Success comment appears

## Best Practices

### For Contributors

1. **Run tests locally** before pushing:
   ```bash
   make test
   ```

2. **Check CI status** before requesting review

3. **Fix CI failures** promptly

4. **Keep PRs focused** to minimize CI failures

### For Maintainers

1. **Review CI results** before code review

2. **Don't override protection** except for emergencies

3. **Update required checks** when adding new CI jobs

4. **Monitor CI performance** and optimize if needed

## CI Performance

### Parallel Execution

Jobs run in parallel where possible:
- `validate` runs first (fastest)
- `test`, `cross-compile`, `memory-check`, `static-analysis` run in parallel
- `all-checks-passed` waits for all others

### Typical Execution Times

| Job | Estimated Time |
|-----|----------------|
| validate | 30 seconds |
| test (ubuntu) | 2-3 minutes |
| test (macos) | 2-3 minutes |
| test (windows) | 3-4 minutes |
| cross-compile | 3-5 minutes |
| memory-check | 2-3 minutes |
| static-analysis | 1-2 minutes |

**Total time:** ~5-8 minutes for a full CI run.

## Integration with External Tools

### Commit Status API

The workflow sets commit statuses that can be used by:
- Third-party CI tools
- IDE integrations
- Bot integrations

### Status Context

Main status context: `ci/all-checks`

This can be referenced in:
- External monitoring tools
- Slack/Discord integrations
- Custom automation scripts
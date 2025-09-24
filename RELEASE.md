# Release Instructions

## Creating a Draft Release

1. Go to Actions in this repository
2. Click "Run workflow"
3. Fill in the inputs:
   - **CRIU version**: e.g., `4.1` (leave empty to use default)
   - **CRIU commit**: e.g., `abc123def` or `master` (overrides version if set)
   - **CRIU shasum**: Required SHA256 checksum for the source
   - **Build revision**: e.g., `r1`, `r2` (for build script changes, optional)
   - **Release type**: Select `draft` (default)
4. Click "Run workflow"

## Promoting Draft to Release

You can also do a release type `release` directly, in that case you don't need to promote a draft.

1. Go to Releases in this repository
2. Find your draft release
3. Click "Edit"
4. Uncheck "Save as draft"
5. Click "Publish release"

## Updating Default CRIU Version

When promoting a CRIU version permanently (not just for testing):

1. Create a PR to update the defaults in `CMakeLists.txt`:
   - Update `CRIU_VERSION`
   - Update `CRIU_SHASUM`
2. After PR is merged, normal CI builds will use the new version by default, this is important so that PRs will test against the latest release CRIU version we released for.
# Release Instructions

> [!WARNING]
> Important note: we normally relaese from the `master` branch, however
> when working on newer releases it could happen that there were some changes
> in upstream CRIU that break the release process or the artifacts.
> For that reason we also keep a `criu-dev` branch where we try to follow with the patches.
> We merge the `criu-dev` branch into master when the current version of CRIU in `CmakeLists.txt`
> is aligned with the version we just released (usually the latest tagged CRIU version).


> [!IMPORTANT]  
> Keep `CMakeLists.txt` aligned with the current version that works with the patches so that PR builds don't break.

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
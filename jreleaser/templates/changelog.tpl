# CRIU Static {{projectVersion}}

This is a static build of CRIU with all dependencies statically linked for maximum portability.

## 📋 Version Information

{{#contains projectVersion "-r"}}
**Upstream CRIU Version**: {{#split projectVersion "-"}}{{get . 0}}{{/split}}
**Build Revision**: {{#split projectVersion "-"}}{{get . 1}}{{/split}} (includes build system improvements/fixes)
{{/contains}}
{{^contains projectVersion "-r"}}
**Upstream CRIU Version**: {{projectVersion}}
**Build Revision**: Base build (no revisions)
{{/contains}}

## 📦 What's Included

Every binary release contains:
- The `criu` binary (statically linked)
- Static copies of `libcriu.o` and `protobuf-c.o`
- All required licenses and source code
- All the build files used to build the above 

## 📥 Download Options

Choose one of the following artifact types:
- **`.tar.gz`** - Standard compressed archive
- **`.sh`** - Self-extracting installer script

## 🔗 Links

- [CRIU Official Changelog](https://criu.org/Download/criu/{{projectVersion}})
- [CRIU Documentation](https://criu.org)
- [Project Repository]({{projectLinkHomepage}})

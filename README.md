# SBOMgen

SBOMgen is a free, open-source tool for generating **CycloneDX 1.6** Software Bills
of Materials (SBOMs) for Delphi applications. It analyses the MAP file produced by
the Delphi linker, cross-references detected units against the Delphi IDE library
paths and a maintained metadata catalog, and produces a standards-conformant SBOM
in CycloneDX 1.6 JSON format (ECMA-424, 1st Edition).

SBOMgen is designed with legacy Delphi codebases in mind. Generating an SBOM for
a project that has been in production for years is often more urgent than for a
new one, and SBOMgen works with MAP files from any Delphi version it can detect
in the Windows registry.

## Features

- CycloneDX 1.6 JSON output, validated against the official schema
- Detects Delphi RTL, VCL, FireDAC, Indy, and other bundled components automatically
- Identifies GetIt-installed packages via the CatalogRepository
- Maintained metadata catalog with built-in entries for common Delphi libraries
- Catalog-driven unit membership and prefix-based package resolution
- Per-project metadata editing with user-edit protection against catalog updates
- Optional CycloneDX CLI validation integration
- Supports multiple projects and multiple installed Delphi versions

## Prerequisites

SBOMgen requires the following to be installed before building:

### Delphi

- **Delphi 12.3 Athens** or **Delphi 13 Florence** — confirmed working
- Earlier versions including XE4 and later should work but have not been fully
  tested. Building on versions earlier than XE4 may require minor changes to
  the source. Community feedback on older compiler support is welcome.

### Third-party libraries

All of the following must be installed and available on the Delphi library path:

| Library | Version tested | License | Source |
|---|---|---|---|
| [Spring4D](https://bitbucket.org/sglienke/spring4d/) | 2.0.1 | Apache 2.0 | Bitbucket |
| [Konopka Signature VCL Controls (KSVC)](https://getitnow.embarcadero.com/bonus-ksvc/) | 8.0.1 | Proprietary (bundled with RAD Studio) | GetIt |
| [VirtualTreeView](https://github.com/Virtual-TreeView/Virtual-TreeView) | 8.3 | MPL 1.1 / LGPL | GitHub |
| [SynEdit](https://getitnow.embarcadero.com/synedit-for-vcl/) | 2025.03 | MPL 1.1 | GetIt |
| [Fundamentals5](https://github.com/fundamentalslib/fundamentals5) | 5.0 | BSD 2-Clause | GitHub |
| [SVGIconImageList](https://github.com/EtheaDev/SVGIconImageList) | 2.4.0 | Apache 2.0 | GitHub |
| [Image32](http://www.angusj.com/delphi/image32/Docs/_Body.htm) | 4.4 | BSL-1.0 | Author's site |
| [Clipper](http://www.angusj.com/delphi/clipper.php) | 2.3.7 | BSL-1.0 | Author's site |
| [MarkdownHelpViewer](https://github.com/EtheaDev/MarkdownHelpViewer) | 2.4.0 | Apache 2.0 | GitHub |

> **Note:** KSVC is bundled with RAD Studio and is available via GetIt at no
> additional cost. All other third-party libraries are open source.

> **Note:** MarkdownHelpViewer bundles the Ethea Markdown Help Viewer, HtmlViewer,
> Image32, SVGIconImageList, and Clipper components as source. There is no conflict
> with the separately installed SVGIconImageList, if that was installed via GetIt.

### Runtime

- **Windows** — SBOMgen reads the Windows registry to detect installed Delphi
  versions and requires Windows for all registry and file system operations.
- The **CycloneDX CLI** tool is optional but recommended for SBOM validation.
  Download the standalone `cyclonedx-win-x64.exe` from
  [https://github.com/CycloneDX/cyclonedx-cli/releases](https://github.com/CycloneDX/cyclonedx-cli/releases).

## Building

1. Clone or download the repository.
2. Ensure all third-party libraries listed above are installed and on the
   Delphi library search path.
3. Open `SBOMgen.dproj` in the Delphi IDE.
4. Select **Build → Build All**.
5. The executable will be produced in the `Win32\Release` or `Win64\Release`
   folder depending on your target platform.

The `Tests\` folder contains a separate DUnitX test project `SBOMgenTests.dproj`.
Build and run it independently to verify the unit test suite — 159 tests are
expected to pass.

## Getting Started

See the **SBOMgen User Manual** in the `Manual\` folder for full documentation,
including:

- What an SBOM is and why it matters
- How to configure a project
- How to work with the metadata catalog
- How to validate generated SBOMs

## Project Structure

```
SBOMgen/
├── *.pas, *.dfm       Source files
├── SBOMgen.dpr/.dproj Project files
├── Data/              SPDX license data
├── Help/              In-application help content
├── Manual/            User manual (PDF)
├── Tests/             DUnitX test project and fixtures
└── SBOM Test/         Sample MAP file and generated SBOM examples
```

## Related Tools

[DX.Comply](https://github.com/omonien/DX.Comply) by Olaf Monien is a
complementary Delphi SBOM tool that operates as a RAD Studio IDE plugin and
command-line tool. DX.Comply resolves every linked unit individually to its
DCU or BPL file with a SHA-256 hash. SBOMgen and DX.Comply serve different
workflows — DX.Comply for automated unit-level scanning, SBOMgen for curated
package-level metadata management.

## License

SBOMgen is released under the **MIT License**. See the `LICENSE` file for the
full license text.

## Disclaimer

**SBOMgen is provided as-is, without warranty of any kind.** You build and use
this software entirely at your own risk. The authors make no representations or
warranties of any kind, express or implied, regarding the correctness,
completeness, reliability, or suitability of the software or the SBOMs it
produces for any particular purpose, including regulatory compliance.

SBOMs generated by SBOMgen reflect the tool's analysis of the provided MAP
file and metadata catalog at the time of generation. It is the user's
responsibility to review and verify the accuracy of all generated output before
relying on it for compliance, legal, or security purposes.

This software is not legal advice. If you have questions about SBOM requirements
under specific regulations such as the EU Cyber Resilience Act or US Executive
Order 14028, consult appropriate legal counsel.

## Contributing

Contributions, bug reports, and feedback are welcome via the GitHub issue
tracker. Community testing on older Delphi versions is particularly valuable —
if you successfully build and run SBOMgen on a version not listed above, please
open an issue or pull request to update the documentation.

## Author

William Meyer — Embarcadero MVP

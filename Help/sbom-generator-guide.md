# SBOM Generator User Guide

## Quick Links
- [Getting Started](#getting-started)
- [Project Setup](#project-setup)
- [Package Metadata](#package-metadata)
- [Application Code](#application-code)
- [SBOM Generation](#sbom-generation)
- [Troubleshooting](#troubleshooting)

## What is an SBOM?

A Software Bill of Materials (SBOM) is a comprehensive inventory of all components, libraries, and dependencies used in your application. It documents:

- **Component names and versions** - What you're using
- **Suppliers** - Who created each component
- **Licenses** - Legal terms for each dependency
- **Hashes** - Integrity verification for security
- **Dependencies** - How components relate to each other

SBOMs are increasingly required for:
- Government contracts (NTIA minimum elements)
- Supply chain security audits
- License compliance verification
- Vulnerability management

This tool generates CycloneDX 1.6 format SBOMs for Delphi applications.

---

## Getting Started {#getting-started}

**Prerequisites:**
- Delphi MAP file from your compiled project
- Root folder paths where your source code lives
- Selected Delphi compiler version

**Quick Start:**
1. File → New Project or Open Project
2. Select your Delphi version
3. Choose your MAP file
4. Set root folders for internal code
5. Click "Detect Components"
6. Review and edit package metadata
7. Generate SBOM

Your first SBOM will likely have packages needing metadata - that's normal! Fill in the details once, and they're saved for future projects.

---

## Project Setup {#project-setup}

### Delphi Version Selection

Choose the compiler version used to build your application. This determines:
- System package versions (RTL, VCL, etc.)
- Registry locations for installed packages
- Library search paths

The tool detects installed Delphi versions automatically.

### MAP File Selection

**What is a MAP file?**  
A detailed memory map generated during compilation showing all modules linked into your executable.

**How to generate a MAP file:**
1. Project → Options → Building → Delphi Compiler → Linking
2. Set "Map file" to "Detailed"
3. Rebuild your project
4. MAP file appears alongside your .exe

**Location:**  
Usually: `Win64\Debug\YourApp.map` or `Win32\Debug\YourApp.map`

### Root Folders

Specify the root folders containing your source code — not third-party libraries. This tells the tool which modules are internal versus external.

Modules under these paths are classified as internal and appear on the Application Code tab. Everything else is treated as external and grouped into packages on the Packages tab.

Your project may span multiple source trees. The SBOMgen project itself is an example: the `SBOMgen` and `SharedUtils` folders are siblings, so both must be listed to index all internal modules.

Enter multiple paths separated by semicolons:

**Example:**
- `C:\Projects\SBOMgen;C:\Projects\SharedUtils`

You can also use the folder selection button to build the list interactively.

### Platform Selection

- **Win32** - 32-bit Windows application
- **Win64** - 64-bit Windows application

Must match your MAP file's platform. Affects which packages are detected from registry.

---

## Package Metadata {#package-metadata}

After detection, the Packages tab shows all external libraries detected in your application.

### Understanding the Display

**Tree View:**  
Each package shows:
- Package name
- Version
- Supplier

**Detail Panel:**  
Select a package to see/edit:
- Version number
- Supplier name
- Supplier URL
- License (SPDX identifier)
- Description

### Editing Metadata

1. Select a package in the tree
2. Edit fields in the detail panel
3. Click "Apply" to save changes
4. Changes are stored and reused across projects

**Show Incomplete Only:**  
Check this box to filter the list to packages missing required information (supplier or license).

### Common Licenses (SPDX IDs)

- `Apache-2.0` - Apache License
- `MIT` - MIT License
- `MPL-1.1` - Mozilla Public License
- `BSD-3-Clause` - BSD 3-Clause
- `GPL-3.0` - GNU GPL v3
- `LicenseRef-Proprietary` - Proprietary/commercial

Full list: https://spdx.org/licenses/

### Metadata Sources

**Built-in defaults:** ~20 common packages pre-populated  
**User-defined:** Your edits saved to `%APPDATA%\SBOMGenerator\package-metadata.json`  
**Unknown:** Packages needing your input

Fill in metadata once - it's remembered for all future projects!

---

## Application Code {#application-code}

This tab shows **your** internal modules (not third-party packages).

### Module Information

For each module:
- **File path** - Location in your source tree
- **File size** - Size in KB/MB
- **Last modified** - When file was last changed
- **Line count** - Approximate lines of code

### Detail View

Select a module to see:
- Full file path
- Detailed statistics
- Description

This helps verify the correct modules are classified as internal.

---

## SBOM Generation {#sbom-generation}

Once components are detected and metadata is complete:

1. Click "Generate SBOM"
2. Choose output location and filename
3. SBOM is generated in CycloneDX 1.6 JSON format

### What's Included

**Metadata Section:**
- Tool information (SBOM Generator version)
- Timestamp
- Your application details

**Components Section:**
- All external packages with full metadata
- Version numbers
- Suppliers and URLs
- SPDX license identifiers
- SHA-256 hashes (where available)
- Descriptions

**Dependencies Section:**
- Shows your application depends on all listed components
- Enables dependency graph analysis

### File Location

Default: Same folder as your MAP file  
Suggested naming: `YourApp-vX.Y.Z.sbom.json`

---

## Understanding the Output {#understanding-output}

### SBOM Structure
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "metadata": { ... },
  "components": [ ... ],
  "dependencies": [ ... ]
}
```

### Component Entry Example
```json
{
  "type": "library",
  "bom-ref": "pkg:generic/spring4d@2.0.1",
  "name": "Spring4D",
  "version": "2.0.1",
  "description": "Spring Framework for Delphi",
  "hashes": [
    {
      "alg": "SHA-256",
      "content": "6d2e4458d47e7de6..."
    }
  ],
  "supplier": {
    "name": "Stefan Glienke",
    "url": ["https://bitbucket.org/sglienke/spring4d/"]
  },
  "licenses": [
    {
      "license": {
        "id": "Apache-2.0"
      }
    }
  ]
}
```

### Hash Verification

SHA-256 hashes are computed from BPL files where available. These can be used to:
- Verify package integrity
- Detect tampering or corruption
- Confirm specific versions

---

## Troubleshooting {#troubleshooting}

### "No MAP file found"

**Solution:** Rebuild your project with detailed MAP file generation enabled:
- Project → Options → Building → Delphi Compiler → Linking
- Set "Map file" to "Detailed"

### "0 components detected"

**Causes:**
- MAP file is from a different project
- MAP file is empty or corrupted
- Root folders incorrectly set

**Solution:** Verify MAP file is recent and matches your application.

### "Package metadata incomplete"

**This is normal!** The first time you detect components, many will need metadata. Simply:
1. Check "Show incomplete only"
2. Fill in supplier and license information
3. Click Apply for each package
4. Information is saved for future use

### "Delphi version not detected"

**Solution:** Ensure Delphi is properly installed with registry keys at:
- `HKEY_CURRENT_USER\Software\Embarcadero\BDS\XX.0`

### "Hash computation failed"

**Causes:**
- BPL file not found in expected location
- Environment variables not expanded correctly

**Impact:** SBOM is still valid, just missing integrity hashes for affected packages.

---

## Tips and Best Practices

**Project Files:**  
Save your SBOM project (`.sbomproj`) to avoid re-entering settings each time.

**Version Control:**  
Commit SBOMs alongside releases for historical tracking:
```
releases/
  v1.0.0/
    MyApp.exe
    MyApp.sbom.json
  v1.1.0/
    MyApp.exe
    MyApp.sbom.json
```

**Team Sharing:**  
The package metadata file can be shared:  
`%APPDATA%\SBOMGenerator\package-metadata.json`

Copy this between team members so everyone has the same package information.

**Licensing:**  
When in doubt about a license, check the component's source repository or documentation. Many include LICENSE.txt files with SPDX identifiers.

**Updating:**  
Regenerate your SBOM whenever:
- You upgrade component versions
- You add new dependencies
- You release a new version of your application

---

## Additional Resources

- **CycloneDX Specification:** https://cyclonedx.org/specification/overview/
- **SPDX License List:** https://spdx.org/licenses/
- **NTIA SBOM Minimum Elements:** https://www.ntia.gov/sbom

---

## Support

For issues or questions:
- Check the Troubleshooting section above
- Review the log panel for diagnostic messages
- Consult the CycloneDX documentation for format questions

---

*SBOM Generator v1.0 - Meyer Design*
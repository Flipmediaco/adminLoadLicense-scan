# Magento adminLoadLicense Scanner

---

## Overview

This script scans a Magento 2 installation (both the filesystem and, if available, Git history) for evidence of a **remote code execution** vulnerability involving a function called `adminLoadLicense()`.

The malware was publicly reported by [Sansec](https://www.linkedin.com/posts/sansec_whoops-a-nasty-ecom-backdoor-has-been-quietly-activity-7321523021339373570-gkJF) and has been found in compromised modules from multiple Magento extension vendors.

If present, this function allows attackers to execute arbitrary code on affected Magento servers, potentially leading to full server compromise.

---

## Methodology

The script performs two main actions:

1. **Live Filesystem Scan**
   - Scans all `*.php` files under the `app/code/` and `vendor/` directories.
   - Searches for the presence of the `adminLoadLicense(` function.

2. **Git History Scan** (If Git is available)
   - Only offered if the Magento site is inside a Git repository.
   - Detects if the Git repository is a shallow clone and allows the user to skip or continue.
   - Offers two scanning modes:
     - **Deep Scan:** Scans all historical `app/code/*.php` files.
     - **Limited Scan:** Scans only historical files named like `license*.php` or `licence*.php` (case-insensitive).
   - Searches for occurrences of `adminLoadLicense(` in selected files across all commits.
   - Verbose progress output is shown during Git scanning.

---

## Usage

1. Clone or download this repository.

2. Make the script executable:

   ```bash
   chmod +x adminLoadLicense-scan.sh
   ```

3. Run the script:

   ```bash
   ./adminLoadLicense-scan.sh
   ```

4. Follow the prompts:
   - Enter the full path to the Magento document root.
   - If a Git repository is detected:
     - Choose whether to scan Git history.
     - If scanning Git history, select between a **deep scan** (all PHP files) or a **limited scan** (only licence/license files).
     - If a shallow clone is detected, choose whether to continue or skip Git history scanning.

5. Review the output:
   - Matches in the filesystem or Git history will be printed to the console.
   - If no matches are found, the script will confirm successful completion.

---

## Requirements

- Bash shell
- Standard UNIX utilities (`find`, `grep`, `xargs`, `git`)
- Access to the full Magento file structure
- (Optional) Full Git clone for complete Git history scanning (consider using `git fetch --unshallow` if your clone is shallow)

---

## Important Notes

- If the Git repository is detected as a shallow clone (`git clone --depth`), the script will warn you and offer to skip Git history scanning to avoid incomplete results.
- If the site is **not a Git repository**, the Git history scan will be automatically skipped.
- Scanning Git history can be time-consuming on large projects, especially in deep scan mode.
- The script focuses only on the `app/code/` directory during Git history scanning to maintain performance.

---

## Background and Source

The vulnerability was disclosed by Sansec, a leading Magento security research firm.  
Full details of the discovery are available here:

🔗 [Sansec LinkedIn Bulletin](https://www.linkedin.com/posts/sansec_whoops-a-nasty-ecom-backdoor-has-been-quietly-activity-7321523021339373570-gkJF?utm_source=share&utm_medium=member_desktop&rcm=ACoAAADEitEBwWmUdzu1Ro8wHl_5BZbilLekB_M)

---

## Disclaimer

This tool is provided for educational, auditing, and incident response purposes only.  
Always back up your data before running scripts on production systems.  
Use at your own risk.
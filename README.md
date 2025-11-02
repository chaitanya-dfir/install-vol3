# 🧠 Install Vol (Volatility 3 Safe Installer)

A **user-friendly PowerShell installer** for [Volatility 3](https://github.com/volatilityfoundation/volatility3) — designed to set up a **forensic-grade, isolated environment** on Windows **without requiring admin rights**.

This script automatically:

- Prompts for an installation folder (default → `C:\DFIR Tools\Volatility3`)
- Optionally lets you choose custom paths for `cache`, `output`, and `symbols`
- Creates a Python virtual environment (`venv`)
- Installs the latest **stable** Volatility 3 release from PyPI
- Adds a global `vol` command (safe user-level shim)
- Verifies the installation and provides update / uninstall steps

---

## ⚙️ Features

✅ No admin rights required  
✅ Self-contained – nothing touches system Python  
✅ Configurable cache/output/symbol paths  
✅ Predictable layout for forensic VMs & class labs  
✅ DFIR-friendly – reproducible, auditable install  

---

## 📦 Requirements

- **Windows 10 / 11**
- **Python 3.8 +** (must be in PATH)
- Internet access for PyPI  
  > 💡 Offline / air-gapped variant planned – see Roadmap.

---

## 🚀 Installation

### 1️⃣ Clone or download
```powershell
git clone https://github.com/<yourusername>/install-vol.git
cd install-vol
```

### 2️⃣ Run the installer
```powershell
.\install-vol.ps1
```
If PowerShell blocks the script:
```powershell
powershell -ExecutionPolicy Bypass -File .\install-vol.ps1
```

### 3️⃣ Follow the prompts

Example session:
```
Enter installation path or press Enter for default [C:\DFIR Tools\Volatility3]:
> D:\DFIR Tools\Memory Forensics\Volatility3

Enter path for Vol3 cache (Press Enter for default [...\cache]):
> E:\Vol3_Cache
```

---

## 🧪 Usage Examples

```powershell
# Check version
vol --version

# Basic system info
vol -f "D:\DFIR Tools\Volatility3\cases\snapshot.vmem" windows.info

# Process list
vol -f "D:\DFIR Tools\Volatility3\cases\snapshot.vmem" windows.pslist

# Network connections
vol -f "D:\DFIR Tools\Volatility3\cases\snapshot.vmem" windows.netscan
```

All plugin outputs and cache data are stored in the folders you chose during setup.

---

## 🔄 Updating Volatility 3

```powershell
cd "C:\DFIR Tools\Volatility3"
.env\Scripts\Activate.ps1
pip install --upgrade volatility3
```

---

## 🧹 Uninstalling

```powershell
Remove-Item "$env:LOCALAPPDATA\Microsoft\WindowsApps\vol.cmd" -Force
Remove-Item "C:\DFIR Tools\Volatility3" -Recurse -Force
```

---

## 📂 Default Folder Structure

```
Volatility3\
│   install-vol.ps1
│   venv\
│   vol.cmd
├── cache\
├── output\
├── symbols\
└── cases\
```

---

## 🧠 Why This Exists

Setting up Volatility 3 manually on Windows can be tedious — especially for:

- Students in restricted lab environments  
- Analysts who need reproducible forensic VM snapshots  
- Users avoiding system-wide Python installs  

**Install Vol** automates that entire process safely with full user control.

---

## 📅 Roadmap

- [ ] Offline / air-gapped install mode (pre-downloaded wheels)  
- [ ] Optional add-ons (YARA, Capstone, pefile)  
- [ ] Lightweight GUI wrapper  


---

## 👤 Author

**Chaitanya Shah**  
Cybersecurity & Digital Forensics Student  

[LinkedIn](https://www.linkedin.com/in/chaitanya-shah-dfir) | [GitHub](https://github.com/chaitanya-dfir)

---

## 💬 Acknowledgements

- [Volatility Foundation](https://github.com/volatilityfoundation)  
- [SANS DFIR Community](https://www.sans.org/cyber-security-courses/for500/)  
- All contributors to open-source forensics  

---

> — Chaitanya Shah

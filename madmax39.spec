# madmax39.spec — one-file build for macOS/Linux/Windows
# PyInstaller >= 6.x

from PyInstaller.utils.hooks import collect_all, collect_data_files, collect_submodules
from PyInstaller.building.build_main import Analysis, PYZ, EXE

# --- Gather third-party packages ---
# shamir_mnemonic: needs its wordlist/data
shamir_datas, shamir_bins, shamir_hidden = collect_all("shamir_mnemonic")

# cryptography: has extensions + data; pull everything
crypto_datas, crypto_bins, crypto_hidden = collect_all("cryptography")

# mnemonic: just data files (wordlists)
mnemonic_datas = collect_data_files("mnemonic")

# Some packages can be missed by static analysis; declare them explicitly.
# We also include ctypes so the frozen app carries stdlib ctypes.
extra_hidden = (
    list(set(shamir_hidden)) +
    list(set(crypto_hidden)) +
    collect_submodules("cryptography") +  # belt-and-suspenders
    ["mnemonic", "ctypes"]
)

# --- Datas & binaries to bundle ---
datas = (
    [("src/vendor", "vendor")] +  # your wrapper’s vendor helpers at runtime path ./vendor
    shamir_datas +
    crypto_datas +
    mnemonic_datas
)

binaries = shamir_bins + crypto_bins

# --- Build graph ---
a = Analysis(
    ["src/madmax39.py"],
    pathex=["src"],
    binaries=binaries,
    datas=datas,
    hiddenimports=extra_hidden,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,  # keep the PYZ archive (faster startup off disk if False? keep your previous choice)
)

pyz = PYZ(a.pure)  # (PyInstaller 6.x signature)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    name="madmax39",
    console=True,     # CLI tool
    # debug=False,
    # strip=False,
    # upx=False,
    # icon=None,
)


# madmax39.spec — one-file build
from PyInstaller.utils.hooks import collect_all, collect_data_files, collect_submodules
from PyInstaller.building.build_main import Analysis, PYZ, EXE

shamir_datas, shamir_bins, shamir_hidden = collect_all("shamir_mnemonic")
crypto_datas, crypto_bins, crypto_hidden = collect_all("cryptography")
mnemonic_datas = collect_data_files("mnemonic")

hiddenimports = (
    shamir_hidden
    + crypto_hidden
    + collect_submodules("cryptography")
    + ["mnemonic"]
)

a = Analysis(
    ["src/madmax39.py"],
    pathex=["src"],
    binaries=shamir_bins + crypto_bins,
    datas=[("src/vendor", "vendor")] + shamir_datas + crypto_datas + mnemonic_datas,
    hiddenimports=hiddenimports,
    noarchive=False,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    name="madmax39",
    console=True,
    onefile=True,  # the magic flag
)


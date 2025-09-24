# madmax39-binaries

Self-contained binaries for a tiny CLI wrapper that exposes **MadXanax’s** SLIP-39–based tools via one command:

- `--split` (default) → split a BIP-39 mnemonic into SLIP-39 (Shamir) shares  
- `--recover` → reconstruct a BIP-39 mnemonic from those shares  
- `--help` → show usage and links back upstream

## Why binaries?
- **Quick try** — no Python/venv setup  
- **Portable** — just run the file  
- **Longevity** — a plain executable has a chance to still run on an old PC decades from now

## Important note on SLIP-39 vs BIP-39
These tools are **not a full “SLIP-39 wallet.”** They apply the SLIP-39 Shamir sharing scheme **to the original BIP-39 mnemonic words**, then reconstruct **that same BIP-39 mnemonic**.  
This makes it much easier to back up and later restore **any BIP-39–compatible wallet** you already use—without migrating to a SLIP-39–native wallet format.

## Credits
All crypto logic is by **MadXanax**:  
- Split (SLIP39gen): <https://github.com/MadXanax/SLIP39gen>  
- Recover (SLIP39rec): <https://github.com/MadXanax/SLIP39rec>  

This repo adds a small dispatcher wrapper + reproducible build steps + prebuilt binaries.

---

## Safety model (read this!)
- Use **only** on **old, dedicated, permanently air-gapped** computers.  
- **Never** save or print seed phrases digitally.  
- Record secrets **on paper** or (preferably) **punched/engraved metal** only.  
- Treat all binaries as untrusted until you **reproduce them yourself** with the steps below.

---

## Binaries & layout
Release artifacts live under architecture folders:

~~~
dist/
├─ macos-arm64/      # Apple Silicon
│  └─ madmax39       # executable
├─ linux-x64/        # manylinux2014 (x86_64)
│  └─ madmax39
├─ linux-aarch64/    # manylinux2014 (ARM64)
│  └─ madmax39
└─ windows-x64/
   └─ madmax39.exe
~~~

Each release also includes `SHA256SUMS`.

---

## Usage

Run the appropriate binary for your platform:

~~~bash
# default = split
./madmax39            # macOS
./madmax39            # Linux
./madmax39.exe        # Windows

# explicit modes
./madmax39 --split
./madmax39 --recover
./madmax39 --help
~~~

---

## Reproducible builds

Scripts are in `scripts/` and drop results into `dist/ARCH/`.

### macOS (Apple Silicon, local build)

~~~bash
./scripts/build-macos-arm64.sh
# → dist/macos-arm64/madmax39
~~~

**Prereqs:** Xcode Command Line Tools, Homebrew Python (the script creates a venv & installs deps).

---

### Linux (manylinux2014) **from macOS** — x86_64

~~~bash
./scripts/build-linux-x64-manylinux.sh
# → dist/linux-x64/madmax39
~~~

### Linux (manylinux2014) **from macOS** — ARM64 (aarch64)

~~~bash
./scripts/build-linux-aarch64-manylinux.sh
# → dist/linux-aarch64/madmax39
~~~

> These Docker scripts use `quay.io/pypa/manylinux2014_*`, build OpenSSL 1.1.1w and a shared-lib Python 3.11, then run PyInstaller. The result is broadly compatible with old glibc.

---

### Windows x64 (build **on Windows**, Git Bash)

~~~bash
./scripts/build-windows-x64-gitbash.sh
# → dist/windows-x64/madmax39.exe
~~~

**Prereqs:**  
- Python 3.11 x64 (e.g., `winget install Python.Python.3.11`)  
- Git for Windows (for Git Bash)

---

### (Optional) Building on a Linux machine
- **With Docker + manylinux:** use the same two scripts above (you can drop the `--platform=...` when building natively on x86_64/aarch64).  
- **Native (no manylinux):** simpler but ties the binary to your distro’s glibc:
  ~~~bash
  python3 -m venv .venv && . .venv/bin/activate
  python -m pip install -U pip
  pip install pyinstaller shamir-mnemonic mnemonic cryptography
  rm -rf build dist/linux-[arch]
  pyinstaller madmax39.spec --distpath dist/linux-[arch]
  ~~~

---

## Verify downloads

After building (or after downloading a Release):

~~~bash
# builder: generate checksums
./scripts/make-checksums.sh
# → dist/SHA256SUMS

# user: verify
cd dist
shasum -a 256 -c SHA256SUMS
~~~

(Optionally sign `SHA256SUMS` with your GPG key and publish `SHA256SUMS.asc`.)

---

## Repo layout (simplified)

~~~
madmax39-binaries/
├─ src/
│  ├─ madmax39.py            # dispatcher wrapper
│  └─ vendor/
│     ├─ split_shares.py     # from SLIP39gen
│     └─ recover_seed.py     # from SLIP39rec
├─ madmax39.spec             # PyInstaller one-file spec (collects data, etc.)
├─ scripts/
│  ├─ build-macos-arm64.sh
│  ├─ build-linux-x64-manylinux.sh
│  ├─ build-linux-aarch64-manylinux.sh
│  ├─ build-windows-x64-gitbash.sh
│  └─ make-checksums.sh
├─ upstream-licenses/
│  ├─ SLIP39gen.LICENSE
│  └─ SLIP39rec.LICENSE
└─ README.md
~~~

---

## License
Upstream projects are **GPL-3.0**; distributing binaries means you must comply with GPL:
- Keep upstream licenses (see `upstream-licenses/`).  
- Provide source (this repo contains the wrapper and vendored scripts).  
- This repository is GPL-3.0 (or GPL-3.0-or-later).

---

**Reminder:** use air-gapped machines only, and never store mnemonics digitally. Paper or metal, always.

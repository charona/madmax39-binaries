# src/madmax39.py
import argparse
import os
import runpy
import signal
import sys

BASE_DIR = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))

def _sigint_quiet(signum, frame):
    # Exit immediately, no tracebacks, no threading shutdown noise
    os._exit(130)

def run_vendor(script_name: str) -> None:
    """Run a vendored script as if it were __main__, but exit cleanly on Ctrl-C."""
    script_path = os.path.join(BASE_DIR, "vendor", script_name)
    if not os.path.exists(script_path):
        sys.stderr.write(f"Internal error: vendor script not found: {script_path}\n")
        os._exit(2)
    try:
        runpy.run_path(script_path, run_name="__main__")
    except KeyboardInterrupt:
        os._exit(130)  # silent, conventional SIGINT code

def main() -> None:
    parser = argparse.ArgumentParser(
        prog="madmax39",
        description=(
            "Split/Recover BIP-39 mnemonics using SLIP-39 (Shamir) applied to the "
            "original BIP-39 words. Easier backup/restore for any BIP-39 wallet."
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("-s", "--split",   action="store_true", help="Split a BIP-39 mnemonic into shares (default).")
    mode.add_argument("-r", "--recover", action="store_true", help="Recover a BIP-39 mnemonic from shares.")
    parser.add_argument("-v", "--version", action="store_true", help="Show version info and exit.")
    args = parser.parse_args()

    if args.version:
        print("madmax39 wrapper — v1.0")
        os._exit(0)

    # Default to split if neither flag provided
    if args.recover:
        run_vendor("recover_seed.py")
    else:
        run_vendor("split_shares.py")

if __name__ == "__main__":
    try:
        signal.signal(signal.SIGINT, _sigint_quiet)
    except Exception:
        pass
    main()


#!/usr/bin/env python3
import argparse, runpy, sys, os, textwrap

def resource_dir():
    return getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))

def main():
    parser = argparse.ArgumentParser(
        prog="madmax39",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent("""\
            madmax39 — SLIP-39 split & recover wrapper
            ------------------------------------------------
            -s / --split     Split a 12 or 24-word BIP39 into SLIP-39 shares
            -r / --recover   Recover a BIP39 from SLIP-39 shares
            -h / --help      Show this help

            Upstream projects by MadXanax:
            - SLIP39gen  (split)   https://github.com/MadXanax/SLIP39gen
            - SLIP39rec  (recover) https://github.com/MadXanax/SLIP39rec
        """)
    )
    g = parser.add_mutually_exclusive_group()
    g.add_argument("-s", "--split",   action="store_true", help="Run splitter (default)")
    g.add_argument("-r", "--recover", action="store_true", help="Run recovery")
    args = parser.parse_args()

    base = resource_dir()
    vendor = os.path.join(base, "vendor")

    target = os.path.join(vendor, "recover_seed.py" if args.recover else "split_shares.py")
    runpy.run_path(target, run_name="__main__")

if __name__ == "__main__":
    main()


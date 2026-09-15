#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "version", nargs="?", help="optional version to check against the others"
    )
    args = parser.parse_args()
    version_arg = None if args.version is None else args.version.removeprefix("v")

    version_package_json = json.loads(Path("package.json").read_text())["version"]

    version_flake = json.loads(
        subprocess.run(
            ["nix", "eval", "--json", ".#eyg-vscode.version"],
            capture_output=True,
            check=True,
        ).stdout
    )

    if version_arg is None:
        if version_package_json != version_flake:
            print(
                f"Version mismatch: package.json has {version_package_json}, flake.nix has {version_flake}",
                file=sys.stderr,
            )
            sys.exit(1)
    else:
        if not (version_arg == version_package_json == version_flake):
            print(
                f"Version mismatch: provided argument {version_arg}, package.json has {version_package_json}, flake.nix has {version_flake}",
                file=sys.stderr,
            )
            sys.exit(1)


if __name__ == "__main__":
    main()

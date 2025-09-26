# Default action shows help
.DEFAULT_GOAL := help

.PHONY: help all mac linux-x64 linux-aarch64 windows-x64 checksums release release-all assets push test

help:
	@echo "madmax39-binaries — make targets:"
	@echo "  make help           - show this help (default)"
	@echo "  make all            - build mac + linux-x64 + linux-aarch64 + checksums"
	@echo "  make mac            - build macOS (Apple Silicon)"
	@echo "  make linux-x64      - build Linux x86_64 (manylinux, Docker)"
	@echo "  make linux-aarch64  - build Linux ARM64 (manylinux, Docker)"
	@echo "  make windows-x64    - build Windows x64 (run on Windows Git Bash)"
	@echo "  make checksums      - write dist/SHA256SUMS"
	@echo "  make release        - create signed release from dist/*/*"
	@echo "  make release-all    - build all + release"
	@echo "  make assets         - list latest release assets"
	@echo "  make push           - publish repo changes to GitHub"
	@echo "  make test           - interactive docker test of manylinux binaries"

# Build everything you can do from a Mac
all: mac linux-x64 linux-aarch64 checksums
	@echo "✅ All builds done. Artifacts in dist/*/*"

mac:
	@./scripts/build-macos-arm64.sh

linux-x64:
	@./scripts/build-linux-x64-manylinux.sh

linux-aarch64:
	@./scripts/build-linux-aarch64-manylinux.sh

# Run this on Windows (Git Bash) if you want the .exe there
windows-x64:
	@./scripts/build-windows-x64-gitbash.sh

checksums:
	@./scripts/make-checksums.sh

# Create a signed release from dist/*/* (uses github.sh)
release:
	@SIGN=1 ./github.sh release

# Build everything then release in one go
release-all: all release

assets:
	@./github.sh assets

push:
	@./github.sh push

test:
	@./scripts/test-manylinux.sh


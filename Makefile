vendor_lrs:
	rm -f src/monodromy/vendor/lrslib/bin/linux-x86_64 src/monodromy/vendor/lrslib/bin/win-amd64
	nix build .#lrs -o src/monodromy/vendor/lrslib/bin/linux-x86_64
	nix build .#lrs_mingw -o src/monodromy/vendor/lrslib/bin/win-amd64

vendor_lrs_darwin:
	rm -f src/monodromy/vendor/lrslib/bin/darwin
	mkdir -p src/monodromy/vendor/lrslib/bin/darwin
	nix build .#lrs -o src/monodromy/vendor/lrslib/bin/darwin/aarch64
	nix build .#lrs_071b_darwin_x86 -o src/monodromy/vendor/lrslib/bin/darwin/x86_64
	mkdir -p src/monodromy/vendor/lrslib/bin/darwin/bin
	for f in src/monodromy/vendor/lrslib/bin/darwin/aarch64/bin/*; do \
		fname=$$(basename $$f); \
		lipo -create -output src/monodromy/vendor/lrslib/bin/darwin/bin/$$fname src/monodromy/vendor/lrslib/bin/darwin/aarch64/bin/$$fname src/monodromy/vendor/lrslib/bin/darwin/x86_64/bin/$$fname; \
		lipo -info src/monodromy/vendor/lrslib/bin/darwin/bin/$$fname; \
	done
	rm -rf src/monodromy/vendor/lrslib/bin/darwin/aarch64 src/monodromy/vendor/lrslib/bin/darwin/x86_64


wheel: vendor_lrs
	uv build --wheel
wheel_devenv:
	nix develop --impure --command make wheel
.PHONY: vendor_lrs wheel wheel_devenv vendor_lrs_darwin

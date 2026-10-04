# Builds the X16Community ROM (the x16-rom submodule) with ld65 debug files, so BitMagic can debug it with full
# source. The ROM's own Makefile isn't changed: it is patched into build/ and run from there, so the submodule can
# be updated freely. If the patch no longer applies after an update, recreate it from the new Makefile.
#
# Needs make, patch and cc65, eg in WSL.

ROM_DIR      = x16-rom
PATCH        = patches/x16-rom-dbgfile.patch
ROM_MAKEFILE = build/Makefile.x16-rom

ROM_BUILD    = $(ROM_DIR)/build/x16

# a part linked before the patch (it has a .map) but without a .dbg is still up to date as far as make is concerned,
# so remove its .bin to make it link again, this time writing the debug file.
all: $(ROM_MAKEFILE)
	@for map in $(ROM_BUILD)/*.map; do \
		[ -f "$$map" ] || continue; \
		[ -f "$${map%.map}.dbg" ] || rm -f "$${map%.map}.bin"; \
	done
	$(MAKE) -C $(ROM_DIR) -f ../$(ROM_MAKEFILE)

# -o leaves the submodule's Makefile untouched. On failure remove the partial output so it is tried again.
$(ROM_MAKEFILE): $(ROM_DIR)/Makefile $(PATCH)
	@mkdir -p $(dir $@)
	patch --no-backup-if-mismatch -o $@ $(ROM_DIR)/Makefile $(PATCH) || (rm -f $@ $@.rej; exit 1)

clean: $(ROM_MAKEFILE)
	$(MAKE) -C $(ROM_DIR) -f ../$(ROM_MAKEFILE) clean
	rm -f $(ROM_MAKEFILE)

.PHONY: all clean

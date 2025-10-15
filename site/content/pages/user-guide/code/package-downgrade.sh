# shellcheck disable=SC2148,SC2102
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.
# SC2102: Ranges can only match single chars (mentioned due to duplicates).
$ pacman -U [package]
$ pacman -U /var/cache/pacman/pkg/linux-5.16.15.arch1-1-x86_64.pkg.tar.zst
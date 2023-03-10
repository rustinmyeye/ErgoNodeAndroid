DISTRO_NAME="alpine-ergo"

DISTRO_COMMENT="Alpine Linux setup for Ergo Node"

TARBALL_URL="https://github.com/termux/proot-distro/releases/download/v1.2-alpine-rootfs/alpine-minirootfs-3.13.1-aarch64.tar.gz"

TARBALL_SHA256="0e8258cc599a86be428228dd5ea9217959f2c77873790bec645c05899f252c5e"

distro_setup() {

        # Run command within proot'ed environment with
        # run_proot_cmd function.
        # Uncomment this to run 'apk upgrade' during installation.
        run_proot_cmd apk upgrade
        run_proot_cmd apk add openjdk11
        run_proot_cmd apk add wget
        run_proot_cmd apk add python3
        :
}

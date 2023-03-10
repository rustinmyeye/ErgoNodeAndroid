DISTRO_NAME="alpine-ergo"

DISTRO_COMMENT="Alpine Linux setup for Ergo Node"

get_download_url() {
        local rootfs
        local sha256

        case "$DISTRO_ARCH" in
                aarch64)
                        rootfs="https://github.com/termux/proot-distro/releases/download/v1.2-alpine-rootfs/alpine-minirootfs-3.13.1-aarch64.tar.gz"
                        sha256="0e8258cc599a86be428228dd5ea9217959f2c77873790bec645c05899f252c5e"
                        esac

        echo "${sha256}|${rootfs}"
}


distro_setup() {
        run_proot_cmd apk upgrade
        run_proot_cmd apk add openjdk11
        run_proot_cmd apk add wget
        run_proot_cmd apk add python3
}

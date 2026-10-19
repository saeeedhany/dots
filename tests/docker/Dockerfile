# A fresh Arch machine: only what the archlinux image ships, plus a sudo user.
FROM archlinux:latest
# the host's mirrors: the image default can stall
COPY mirrorlist /etc/pacman.d/mirrorlist
# one download at a time, no stall timeout: big parallel downloads stall here
RUN sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 1/; /^\[options\]/a DisableDownloadTimeout' /etc/pacman.conf
RUN pacman -Syu --noconfirm --needed sudo git base-devel && \
    useradd -m tester && \
    echo 'tester ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tester
COPY --chown=tester:tester dots /home/tester/dots
COPY --chown=tester:tester suckless /home/tester/suckless-src
USER tester
WORKDIR /home/tester

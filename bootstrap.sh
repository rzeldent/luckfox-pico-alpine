#!/bin/sh

# Install base
apk update
apk add openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add networking default
rc-update add local default

# Install TTY
apk add agetty

# Setting up shell
apk add shadow bash bash-completion --no-cache
chsh -s /bin/bash
echo -e "luckfox\nluckfox" | passwd
apk del -r shadow

# Setup time 
apk add openntpd tzdata --no-cache

# Add MTD utils for the UBI (Unsorted Block Images) filesystem
apk add mtd-utils-ubi --no-cache

# Add btop to monitor system resources
apk add btop --no-cache

# Install SSH (and SCP)
apk add openssh --no-cache
rc-update add sshd default

# Install cron, ntpd, tzdata
#apk add  cronie  --no-cache
#mkdir -p /etc/local.d && \
#     { \
#         echo '#!/bin/bash'; \
#         echo 'ntpd -s -d && crond'; \
#     } > /etc/local.d/crond.start && \
#     chmod +x /etc/local.d/crond.start && \
#     rc-update add local default

# Clear apk cache
rm -rf /var/cache/apk/*

# Packaging rootfs
for d in bin etc lib sbin usr; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys var oem userdata; do mkdir /extrootfs/${dir}; done

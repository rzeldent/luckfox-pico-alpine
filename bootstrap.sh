#!/bin/sh

const timezone = "UTC"

# Install base
apk update && \
    apk add openrc && \
    rc-update add devfs boot && \
    rc-update add procfs boot && \
    rc-update add sysfs boot && \
    rc-update add networking default && \
    rc-update add local default

# Install TTY
apk add agetty

# Setting up shell
apk add shadow bash bash-completion --no-cache && \
    chsh -s /bin/bash && \
    echo -e "luckfox\nluckfox" | passwd && \
    apk del -r shadow

# Local startup
mkdir -p /etc/local.d && \
    { \
        echo '#!/bin/bash'; \
        echo 'echo 0 > /sys/class/leds/work/brightness 2>/dev/null || true'; \
    } > /etc/local.d/crond.start && \
    chmod +x /etc/local.d/crond.start && \
    rc-update add local default

# Setup networking
echo "Luckfox-pico-plus" > /etc/hostname

# Setup time 
apk add chrony tzdata --no-cache && \
    rc-update add chronyd && \
    rc-service chronyd start && \
    cp /usr/share/zoneinfo/$timezone /etc/localtime && \
    echo "$timezone" > /etc/timezone && \
    apk del tzdata

# Add MTD utils for the UBI (Unsorted Block Images) filesystem
apk add mtd-utils-ubi --no-cache

# Add btop to monitor system resources
apk add btop --no-cache

# Install SSH (and SCP). For privilege separation; add /var/empty directory and set permissions

apk add openssh --no-cache && \
    mkdir -p /var/empty && \
    chmod 711 /var/empty && \
    rc-update add sshd default

# Clear apk cache
rm -rf /var/cache/apk/*

# Install .NET 10 runtime
mkdir -p /opt && \
    cd /opt && \
    mkdir -p dotnet && \
    cd dotnet && \
    wget https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.0/dotnet-runtime-10.0.0-linux-musl-arm.tar.gz && \
    tar -xzf dotnet-runtime-10.0.0-linux-musl-arm.tar.gz && \
    rm dotnet-runtime-10.0.0-linux-musl-arm.tar.gz && \
    ln -s /opt/dotnet/dotnet /usr/bin/dotnet

# Packaging rootfs
for d in bin etc lib sbin usr var opt; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys oem userdata; do mkdir /extrootfs/${dir}; done

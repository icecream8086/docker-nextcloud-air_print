# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NEXTCLOUD_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ffmpeg \
    gnu-libiconv \
    imagemagick \
    imagemagick-heic \
    imagemagick-pdf \
    imagemagick-svg \
    libxml2 \
    php83-apcu \
    php83-bcmath \
    php83-bz2 \
    php83-dom \
    php83-exif \
    php83-ftp \
    php83-gd \
    php83-gmp \
    php83-imap \
    php83-intl \
    php83-ldap \
    php83-opcache \
    php83-pcntl \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-pecl-imagick \
    php83-pecl-mcrypt \
    php83-pecl-memcached \
    php83-pecl-smbclient \
    php83-pgsql \
    php83-posix \
    php83-redis \
    php83-sodium \
    php83-sqlite3 \
    php83-sysvsem \
    php83-xmlreader \
    rsync \
    samba-client \
    util-linux \
    sudo \
    cups \
    cups-* && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf && \
  echo "**** configure php for nextcloud ****" && \
  { \
    echo 'apc.enable_cli=1'; \
  } >> /etc/php83/conf.d/apcu.ini && \
  { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=32'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.jit=1255'; \
    echo 'opcache.jit_buffer_size=128M'; \
  } >> "/etc/php83/conf.d/00_opcache.ini" && \
  { \
    echo 'memory_limit=-1'; \
    echo 'upload_max_filesize=100G'; \
    echo 'post_max_size=100G'; \
    echo 'max_input_time=3600'; \
    echo 'max_execution_time=3600'; \
    echo 'output_buffering=0'; \
    echo 'always_populate_raw_post_data=-1'; \
  } >> "/etc/php83/conf.d/nextcloud.ini" && \
  echo "**** install nextcloud ****" && \
  mkdir -p \
    /app/www/src/ && \
  if [ -z ${NEXTCLOUD_RELEASE+x} ]; then \
    NEXTCLOUD_RELEASE=$(curl -sX GET https://api.github.com/repos/nextcloud/server/releases \
      | jq -r '.[] | select(.prerelease != true) | .tag_name' \
      | sed 's|^v||g' | sort -rV | head -1); \
  fi && \
  curl -o \
    /tmp/nextcloud.tar.bz2 -L \
    https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_RELEASE}.tar.bz2 && \
  tar xf /tmp/nextcloud.tar.bz2 -C \
    /app/www/src --strip-components=1 && \
  rm -rf /app/www/src/updater && \
  mkdir -p /app/www/src/data && \
  chmod +x /app/www/src/occ && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf && \
  echo "**** configure php for nextcloud ****" && \
  { \
    echo 'apc.enable_cli=1'; \
  } >> /etc/php83/conf.d/apcu.ini && \
  { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=32'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.jit=1255'; \
    echo 'opcache.jit_buffer_size=128M'; \
  } >> "/etc/php83/conf.d/00_opcache.ini" && \
  { \
    echo 'memory_limit=-1'; \
    echo 'upload_max_filesize=100G'; \
    echo 'post_max_size=100G'; \
    echo 'max_input_time=3600'; \
    echo 'max_execution_time=3600'; \
    echo 'output_buffering=0'; \
    echo 'always_populate_raw_post_data=-1'; \
  } >> "/etc/php83/conf.d/nextcloud.ini" && \
  echo "**** install nextcloud ****" && \
  mkdir -p \
    /app/www/src/ && \
  if [ -z ${NEXTCLOUD_RELEASE+x} ]; then \
    NEXTCLOUD_RELEASE=$(curl -sX GET https://api.github.com/repos/nextcloud/server/releases \
      | jq -r '.[] | select(.prerelease != true) | .tag_name' \
      | sed 's|^v||g' | sort -rV | head -1); \
  fi && \
  curl -o \
    /tmp/nextcloud.tar.bz2 -L \
    https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_RELEASE}.tar.bz2 && \
  tar xf /tmp/nextcloud.tar.bz2 -C \
    /app/www/src --strip-components=1 && \
  rm -rf /app/www/src/updater && \
  mkdir -p /app/www/src/data && \
  chmod +x /app/www/src/occ && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# CUPS 权限处理核心逻辑
echo "**** 配置CUPS权限 ****" && \
mkdir -p \
    /var/run/cups \
    /etc/cups/ssl \
    /config/printers/ppd && \

# 权限继承处理
if [ -d /config/printers ]; then
    rsync -rtD --exclude '*.tmp' /config/printers/ /etc/cups/
fi && \

# 关键目录权限设置
chown -R root:lpadmin /etc/cups && \
chmod 0750 /var/run/cups && \
chmod 0700 /etc/cups/ssl && \
chmod 0644 /etc/cups/cupsd.conf* && \

# PPD文件特殊权限处理
find /etc/cups/ppd -name "*.ppd" -exec chmod 0664 {} \; && \
find /etc/cups/ppd -name "*.ppd" -exec chown root:lpadmin {} \; && \

# 运行时目录权限修复
( [ -d /var/spool/cups ] || mkdir -p /var/spool/cups ) && \
chown root:lp /var/spool/cups && \
chmod 1770 /var/spool/cups && \

# 容器用户权限兼容处理
if id -u abc >/dev/null 2>&1; then
    usermod -aG lpadmin abc && \
    find /config/printers -exec chown abc:abc {} \;
fi

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443 631
VOLUME /config
VOLUME /var/spool/cups
VOLUME /etc/cups
# end
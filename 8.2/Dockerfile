FROM php:8.2.12-fpm-bullseye


ARG TZ=Asia/Shanghai
ARG PHP_VERSION=php:8.2.12-fpm-bullseye
ARG PHP_EXTENSIONS=pdo_mysql,zip,pcntl,mysqli,mbstring,bcmath,sockets,gettext,shmop,sysvmsg,sysvsem,sysvshm,gd,intl,soap,xsl,curl,gmp,ldap,mcrypt,opcache,redis,xdebug,swoole,mongodb,apcu

# Replace Mirror Source
RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list && apt update


COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN apt update && chmod +x install.sh \
    && bash install.sh

# sync timezone
RUN apt install -y tzdata openssh-server git \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && mkdir /var/log/php



# Install composer and change it's cache home
RUN chmod +x install-composer.sh \
    && sh install-composer.sh \
    && rm -rf /tmp/extensions
ENV COMPOSER_HOME=/tmp/composer


EXPOSE 9000

# copy php config
COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

WORKDIR /www

# docker login harbor-st.2345.cn                              登陆harbor
# docker buildx create --name multi-platform-builder --use    创建docker driver并使用
# docker buildx inspect --bootstrap                           拉取镜像moby/buildkit:buildx-stable-1
# docker buildx build --platform linux/arm64,linux/amd64 -f Dockerfile -t harbor-st.2345.cn/server/devcontainer-php:8.2.12 . --push
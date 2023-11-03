#!/bin/bash
set -e

export MC="-j$(nproc)"

echo
echo "============================================"
echo "Install extensions from   : install.sh"
echo "PHP version               : ${PHP_VERSION}"
echo "Extra Extensions          : ${PHP_EXTENSIONS}"
echo "Multicore Compilation     : ${MC}"
echo "Container package url     : ${CONTAINER_PACKAGE_URL}"
echo "Work directory            : ${PWD}"
echo "============================================"
echo


if [ "${PHP_EXTENSIONS}" != "" ]; then
    apt install -y openssl libssl-dev libperl-dev
fi


export EXTENSIONS=",${PHP_EXTENSIONS},"


#
# Check if current php version is greater than or equal to
# specific version.
#
# For example, to check if current php is greater than or
# equal to PHP 7.0:
#
# isPhpVersionGreaterOrEqual 7 0
#
# Param 1: Specific PHP Major version
# Param 2: Specific PHP Minor version
# Return : 1 if greater than or equal to, 0 if less than
#
isPhpVersionGreaterOrEqual()
 {
    local PHP_MAJOR_VERSION=$(php -r "echo PHP_MAJOR_VERSION;")
    local PHP_MINOR_VERSION=$(php -r "echo PHP_MINOR_VERSION;")

    if [[ "$PHP_MAJOR_VERSION" -gt "$1" || "$PHP_MAJOR_VERSION" -eq "$1" && "$PHP_MINOR_VERSION" -ge "$2" ]]; then
        echo 1;
    else
        echo 0;
    fi
}


#
# Install extension from package file(.tgz),
# For example:
#
# installExtensionFromTgz redis-5.2.2
#
# Param 1: Package name with version
# Param 2: enable options
#
installExtensionFromTgz()
{
    tgzName=$1
    result=""
    extensionName="${tgzName%%-*}" 
    shift 1
    result=$@
    mkdir ${extensionName}
    tar -xf ${tgzName}.tgz -C ${extensionName} --strip-components=1
    ( cd ${extensionName} && phpize && ./configure ${result} && make ${MC} && make install )

    docker-php-ext-enable ${extensionName}
}


if [[ -z "${EXTENSIONS##*,pdo_mysql,*}" ]]; then
    echo "---------- Install pdo_mysql ----------"
    docker-php-ext-install ${MC} pdo_mysql
fi

if [[ -z "${EXTENSIONS##*,pcntl,*}" ]]; then
    echo "---------- Install pcntl ----------"
	docker-php-ext-install ${MC} pcntl
fi

if [[ -z "${EXTENSIONS##*,mysqli,*}" ]]; then
    echo "---------- Install mysqli ----------"
	docker-php-ext-install ${MC} mysqli
fi

if [[ -z "${EXTENSIONS##*,mbstring,*}" ]]; then
    echo "---------- mbstring is installed ----------"
fi


if [[ -z "${EXTENSIONS##*,bcmath,*}" ]]; then
    echo "---------- Install bcmath ----------"
	docker-php-ext-install ${MC} bcmath
fi

if [[ -z "${EXTENSIONS##*,calendar,*}" ]]; then
    echo "---------- Install calendar ----------"
	docker-php-ext-install ${MC} calendar
fi

if [[ -z "${EXTENSIONS##*,zend_test,*}" ]]; then
    echo "---------- Install zend_test ----------"
	docker-php-ext-install ${MC} zend_test
fi

if [[ -z "${EXTENSIONS##*,opcache,*}" ]]; then
    echo "---------- Install opcache ----------"
    docker-php-ext-install opcache
fi

if [[ -z "${EXTENSIONS##*,sockets,*}" ]]; then
    echo "---------- Install sockets ----------"
	docker-php-ext-install ${MC} sockets
fi

if [[ -z "${EXTENSIONS##*,gettext,*}" ]]; then
    echo "---------- Install gettext ----------"
    apt install -y gettext
    docker-php-ext-install ${MC} gettext

fi

if [[ -z "${EXTENSIONS##*,shmop,*}" ]]; then
    echo "---------- Install shmop ----------"
	docker-php-ext-install ${MC} shmop
fi

if [[ -z "${EXTENSIONS##*,sysvmsg,*}" ]]; then
    echo "---------- Install sysvmsg ----------"
	docker-php-ext-install ${MC} sysvmsg
fi

if [[ -z "${EXTENSIONS##*,sysvsem,*}" ]]; then
    echo "---------- Install sysvsem ----------"
	docker-php-ext-install ${MC} sysvsem
fi

if [[ -z "${EXTENSIONS##*,sysvshm,*}" ]]; then
    echo "---------- Install sysvshm ----------"
	docker-php-ext-install ${MC} sysvshm
fi


if [[ -z "${EXTENSIONS##*,pdo_odbc,*}" ]]; then
    echo "---------- Install pdo_odbc ----------"
	docker-php-ext-install ${MC} pdo_odbc
fi


if [[ -z "${EXTENSIONS##*,gd,*}" ]]; then
    if [[ $(isPhpVersionGreaterOrEqual 7 4) = "1" ]]; then
        options="--with-freetype --with-jpeg --with-webp"
    else
        options="--with-gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/"
    fi
    apt install -y \
        libfreetype6 \
        libfreetype6-dev \
        libpng16-16 \
        libpng-dev \
        libjpeg-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
	    libwebp-dev \
    && docker-php-ext-configure gd ${options} \
    && docker-php-ext-install ${MC} gd
fi


if [[ -z "${EXTENSIONS##*,bz2,*}" ]]; then
    echo "---------- Install bz2 ----------"
    apt install -y librust-bzip2-dev
    docker-php-ext-install ${MC} bz2
fi

if [[ -z "${EXTENSIONS##*,soap,*}" ]]; then
    echo "---------- Install soap ----------"
    apt install -y libxml2-dev
	docker-php-ext-install ${MC} soap
fi

if [[ -z "${EXTENSIONS##*,intl,*}" ]]; then
    echo "---------- Install intl ----------"
    apt install -y libicu-dev
    docker-php-ext-install ${MC} intl
fi

if [[ -z "${EXTENSIONS##*,xsl,*}" ]]; then
    echo "---------- Install xsl ----------"
	apt install -y libxml2-dev libxslt1-dev
	docker-php-ext-install ${MC} xsl
fi

if [[ -z "${EXTENSIONS##*,curl,*}" ]]; then
    echo "---------- curl is installed ----------"
fi

if [[ -z "${EXTENSIONS##*,gmp,*}" ]]; then
    echo "---------- Install gmp ----------"
	apt install -y libgmp-dev
	docker-php-ext-install ${MC} gmp
fi

if [[ -z "${EXTENSIONS##*,ldap,*}" ]]; then
    echo "---------- Install ldap ----------"
	apt install -y libldb-dev
	apt install -y golang-openldap-dev
	docker-php-ext-install ${MC} ldap
fi

if [[ -z "${EXTENSIONS##*,mcrypt,*}" ]]; then
    if [[ $(isPhpVersionGreaterOrEqual 7 0) = "1" ]]; then
        echo "---------- Install mcrypt ----------"
        apt install -y libmcrypt-dev libmcrypt4 re2c
        printf "\n" |pecl install mcrypt
        docker-php-ext-enable mcrypt
    else
        echo "---------- Install mcrypt ----------"
        apt install -y libmcrypt-dev \
        && docker-php-ext-install ${MC} mcrypt
    fi
fi


if [[ -z "${EXTENSIONS##*,mysql,*}" ]]; then
    if [[ $(isPhpVersionGreaterOrEqual 7 0) = "1" ]]; then
        echo "---------- mysql was REMOVED from PHP 7.0.0 ----------"
    else
        echo "---------- Install mysql ----------"
        docker-php-ext-install ${MC} mysql
    fi
fi

if [[ -z "${EXTENSIONS##*,redis,*}" ]]; then
    echo "---------- Install redis ----------"
    installExtensionFromTgz redis-5.3.7
fi

if [[ -z "${EXTENSIONS##*,apcu,*}" ]]; then
    echo "---------- Install apcu ----------"
    installExtensionFromTgz apcu-5.1.17
fi


if [[ -z "${EXTENSIONS##*,xdebug,*}" ]]; then
    echo "---------- Install xdebug ----------"
    if [[ $(isPhpVersionGreaterOrEqual 7 4) = "1" ]]; then
        installExtensionFromTgz xdebug-2.9.2
    fi
fi

if [[ -z "${EXTENSIONS##*,swoole,*}" ]]; then
    echo "---------- Install swoole ----------"
    if [[ $(isPhpVersionGreaterOrEqual 7 0) = "1" ]]; then
        installExtensionFromTgz swoole-4.8.11 --enable-openssl
    else
        installExtensionFromTgz swoole-2.0.11
    fi
fi


if [[ -z "${EXTENSIONS##*,mongodb,*}" ]]; then
    echo "---------- Install mongodb ----------"
    apt install -y openssl libssl-dev
    installExtensionFromTgz mongodb-1.7.4
fi




if [[ -z "${EXTENSIONS##*,zip,*}" ]]; then
    echo "---------- Install zip ----------"
    apt install -y libzip-dev libzip4
    if [[ $(isPhpVersionGreaterOrEqual 7 4) != "1" ]]; then
        docker-php-ext-configure zip --with-libzip=/usr/include
    fi

	docker-php-ext-install ${MC} zip
fi


if [ "${PHP_EXTENSIONS}" != "" ]; then
    docker-php-source delete
fi

echo "all extension install success"

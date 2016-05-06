#!/bin/bash
#优卖一点官网运行环境自动化安装脚本
#前端使用openresty
#php5.5
#php使用的memcache
#整套框架使用的是YAF
#作者：施罗伟
#修改日期：2016-5-6
#定义环境变量
#主安装环境目录
install_path='/usr/local/UMwebserver/'
soft_package='op_autoinstall.tar.gz'
phpize=${install_path}php/bin/phpize
tar xfz ${soft_package}
src_path=`pwd`/src
function check_status () {
	RETVAL=$?
	if [[ ${RETVAL}=0 ]]
		then
		echo "执行$1成功"
	else
		echo "执行$1失败，终止自动化安装过程"
		exit 20
	fi
}
function install_yum () {
	echo 'yum 开始安装需要一些时间请耐心等待................'
	yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel \
	freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel \
	glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel \
	e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel \
	openldap openldap-devel nss_ldap openldap-clients openldap-servers cmake \
	libmcrypt libmcrypt-devel mcrypt mhash pcre-devel > /dev/null 2>&1
	check_status "install_yum"
}

function install_openresty () {
	echo 'openresty开始安装'
	cd ${src_path}
	openresty='ngx_openresty-1.9.3.2.tar.gz'
	tar xfz ${openresty} 
	cd ${openresty%.tar.gz}
	./configure --prefix=/usr/local/UMwebserver \
	--with-luajit --with-http_iconv_module --with-http_stub_status_module > /dev/null 2>&1
	check_status "openresty configure"
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
	check_status "install_openresty"
	cd ${src_path}
}
function install_libmcrypt () {
	echo 'libmcrypt开始安装'
	libmcrypt='libmcrypt-2.5.7.tar.gz'
	tar xfz ${libmcrypt}
	cd ${libmcrypt%.tar.gz}
	./configure --prefix=/usr/local/libmcrypt > /dev/null 2>&1
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
	cd ${src_path}
	check_status "install_libmcrypt"
}
function install_php () {
	echo 'php开始编译安装'
	php='php-5.5.16.tar.gz'
	tar xfz  ${php}
	cd ${php%.tar.gz}
	./configure --prefix=/usr/local/UMwebserver/php \
	--with-config-file-path=/usr/local/UMwebserver/php/etc \
	--with-pdo-mysql=mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd \
	--with-mysql-sock=/tmp/mysql.sock --with-freetype-dir=/usr/local \
	--with-jpeg-dir=/usr/local --with-png-dir=/usr/local/ \
	--with-zlib-dir=/usr/local/ --with-zlib --with-curl=/usr/local \
	--enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt=/usr/local/libmcrypt \
	--with-mhash --enable-pcntl --enable-sockets --without-pear \
	--disable-ipv6 --disable-short-tags --with-gd --disable-gd-jis-conv \
	--with-openssl  --enable-inline-optimization --disable-debug > /dev/null 2>&1
	check_status "php configure"
	make > /dev/null 2>&1
	make install > /dev/null 2>&1 
	check_status "install_php"
	#mv /etc/init.d/php-fpm /tmp
	cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
	chmod 755 /etc/init.d/php-fpm
	cd ${src_path}
}
function install_memcache () {
	echo 'memcache开始编译安装'
	memcache='memcache-3.0.8.tgz'
	tar xfz $memcache
	cd ${memcache%.tgz} && ${phpize} && ./configure --with-php-config=${install_path}php/bin/php-config > /dev/null 2>&1 && check_status "install_memcache_configure"
	make > /dev/null 2>&1 && check_status "install_memcache_make"
	make install > /dev/null 2>&1 && check_status "install_memcache_make_install"
	cd ${src_path}
	cp php_memcache.ini ${install_path}php/etc/php.ini 
	check_status "install_memcache"
}
function install_redis () {
	echo 'redis开始编译安装'
	redis='phpredis-develop.zip'
	unzip $redis
	cd ${redis%.zip} && ${phpize} && ./configure --with-php-config=${install_path}php/bin/php-config > /dev/null 2>&1 && check_status "install_redis_configure"
	make > /dev/null 2>&1 && check_status "install_redis_make"
	make install > /dev/null 2>&1 && check_status "install_redis_make_install"
	cd ${src_path} 
	cp php_redis.ini ${install_path}php/etc/php.ini
	check_status "install_redis"	
}
function install_ZendOptimizerPlus () {
	echo 'zend开始编译安装'
	cd ZendOptimizerPlus && ${phpize} && ./configure --with-php-config=${install_path}php/bin/php-config > /dev/null 2>&1 && check_status "install_Zend_configure"
	make > /dev/null 2>&1 && check_status "install_zend_make"
	make install > /dev/null 2>&1 && check_status "install_zend_make_install"
	cd ${src_path} 
	check_status "install_Zend"
}
function install_msgpack_php () {
	echo 'msgpack开始编译安装'
	cd msgpack-php && ${phpize} && ./configure --with-php-config=${install_path}php/bin/php-config > /dev/null 2>&1 && check_status "install_msgpack_configure"
	make > /dev/null 2>&1 && check_status "install_msgpack_make" 
	make install > /dev/null 2>&1 && check_status "install_msgpack_make_install"  
	cd ${src_path} 
	check_status "install_msgpack_php"
}
function install_yar () {
	echo 'yar开始编译安装'
	cd yar && ${phpize} && ./configure --with-php-config=${install_path}php/bin/php-config --enable-msgpack > /dev/null 2>&1 && check_status "install_yar_configure"
	make > /dev/null 2>&1 && check_status "install_yar_make"
	make install > /dev/null 2>&1 && check_status "install_yar_make_install"
	cd ${src_path} 
	check_status "install_yar"
}
function install_yaf () {
	echo 'yaf开始编译安装'
	yaf='yaf-2.2.8.tgz'
	tar xfz ${yaf}
	cd ${yaf%.tgz}&& ${phpize}  && ./configure --with-php-config=${install_path}php/bin/php-config > /dev/null 2>&1 && check_status "install_yaf_configure"
	make > /dev/null 2>&1 && check_status "install_yaf_configure"
	make install > /dev/null 2>&1 && check_status "install_yaf_configure"
	check_status "install_yaf"
}
function install_end () {
	echo '处理收尾'
	cd ${src_path} 
	#cp php.ini ${install_path}php/etc/php.ini
	cp ${install_path}php/etc/php-fpm.conf.default ${install_path}php/etc/php-fpm.conf
	sed -i 's/pm = dynamic/pm = static/g' ${install_path}php/etc/php-fpm.conf
	sed -i 's/pm.max_children = 5/pm.max_children = 150/g' ${install_path}php/etc/php-fpm.conf
	sed -i 's/;pm.max_requests = 500/pm.max_requests = 10240/g' ${install_path}php/etc/php-fpm.conf
	sed -i 's/;php_flag\[display_errors\] = off/php_flag\[display_errors\] = off/g' ${install_path}php/etc/php-fpm.conf
	cp nginx /etc/init.d/nginx
	mkdir -p /data/www
	check_status "install_end"
}

case "$1" in
	base-memcache)
		start=$(date +%s)
		install_yum
		install_openresty
		install_libmcrypt
		install_php
		install_memcache
		install_ZendOptimizerPlus
		install_msgpack_php
		install_yar
		install_yaf
		install_end
		end=$(date +%s)
		echo "执行$0使用时间：$(( $end - $start ))S"
	;;
	base-redis)
		start=$(date +%s)
		install_yum
		install_openresty
		install_libmcrypt
		install_php
		install_redis
		install_ZendOptimizerPlus
		install_msgpack_php
		install_yar
		install_yaf
		install_end
		end=$(date +%s)
		echo "执行$0使用时间：$(( $end - $start ))S"	
	;;
	*)
		echo "本安装程序编译安装的是基于php的yaf框架，可以根据后端缓存的方式选择memcache或者redis"
		echo $"Usage: $0 {base-memcache|base-redis}"
esac
exit 0

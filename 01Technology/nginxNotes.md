# Nginx

[nginx documentation](https://nginx.org/en/docs )

正向代理代理的对象是客户端, 为客户端收发请求，使真实客户端对服务器不可见。
反向代理代理的对象是服务端, 为服务器收发请求，使真实服务器对客户端不可见。
反向代理: 隐藏了真实的服务端

正向代理和反向代理最关键的两点区别：
    是否指定目标服务器
    客户端是否要做设置

## Recent

[关于$upstream_response_time，$request_time以及nginx配置设置在应用中的问题](https://groups.google.com/forum/#!msg/openresty/sGVZbJRs4lU/5Nxgb_rITGYJ)
`$upstream_response_time` 格式会变成2部分 xxxx, xxxx ，可能是什么原因？被拆分的字段代表什么含义？
这是 `ngx_http_upstream` 的 fail-over 机制在起作用。当 nginx
尝试了第一个后端节点出现错误时（比如超时），它会自动尝试同一个 upstream {}
分组中的下一个节点。每个节点的访问时间会以逗号分隔。所以尝试了两个节点便是"xxxx, xxxx"。
使用$request_body即可打出post的数据
nginx的limit_conn模块，用来限制瞬时并发连接数

NAXSI means Nginx Anti Xss & Sql Injection.
WAF Web Application Firewall
waf rule
invalid POST format id:13
"msg:invalid POST boundary" id:14;
/data/softwares/nginx/conf/rule/uc_account_whitelist.rules

### timeout 配置

`proxy_connect_timeout` :后端服务器连接的超时时间_发起握手等候响应超时时间
`proxy_read_timeout`:连接成功后_等候后端服务器响应时间_其实已经进入后端的排队之中等候处理（也可以说是后端服务器处理请求的时间）
`proxy_send_timeout` :后端服务器数据回传时间_就是在规定时间之内后端服务器必须传完所有的数据

## Nginx offical

[nginx documentation](http://nginx.org/en/docs )

NGINX (发音为 "engine X")
cd /data/softwares/tengine-2.1/
`sudo /usr/local/nginx/sbin/nginx -c /path/to/nginx/conf/nginx.conf` start nginx
`./sbin/nginx -s <signal>`
Where signal may be one of the following:
    `stop` — fast shutdown
    `quit` — graceful shutdown
    `reload` — reloading the configuration file
    `reopen` — reopening the log files

`nginx -t` Test your configuration file for syntax errors
`sudo systemctl reload nginx` reload Nginx

## Location正则写法

### 规则[doc](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)

``` shell
location optional_modifier location_match {
    . . .
}
```

1. (none): If no modifiers are present, the location is interpreted as a prefix match. This means that the location given will be matched against the beginning of the request URI to determine a match.
2. =: If an equal sign is used, this block will be considered a match if the request URI exactly matches the location given.
3. ~: If a tilde modifier is present, this location will be interpreted as a case-sensitive regular expression match.
4. ~*: If a tilde and asterisk modifier is used, the location block will be interpreted as a case-insensitive regular expression match.
5. ^~: If a carat and tilde modifier is present, and if this block is selected as the best non-regular expression match, regular expression matching will not take place.

#### 规则

1. =    表示精确匹配 如 A 中只匹配根目录结尾的请求，后面不能带任何字符串。
2. ^~    表示uri以某个常规字符串开头，不是正则匹配
3. ~    表示区分大小写的正则匹配;
4. ~*    表示不区分大小写的正则匹配
5. /    通用匹配, 如果没有其它匹配,任何请求都会匹配到
顺序 no优先级：
(location =) > (location 完整路径) > (location ^~ 路径) > (location ~,~* 正则顺序) > (location 部分起始路径) > (/)

### 一个示例

``` shell
location /settlementWeb {
    proxy_pass   http://localhost:3000;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

``` shell
location  = / {
  # 精确匹配 / ，主机名后面不能带任何字符串
  [ configuration A ]
}

location  / {
  # 因为所有的地址都以 / 开头，所以这条规则将匹配到所有请求
  # 但是正则和最长字符串会优先匹配
  [ configuration B ]
}

location /documents/ {
  # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration C ]
}

location ~ /documents/Abc {
  # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration CC ]
}

location ^~ /images/ {
  # 匹配任何以 /images/ 开头的地址，匹配符合以后，停止往下搜索正则，采用这一条。
  [ configuration D ]
}

location ~* \.(gif|jpg|jpeg)$ {
  # 匹配所有以 gif,jpg或jpeg 结尾的请求
  # 然而，所有请求 /images/ 下的图片会被 config D 处理，因为 ^~ 到达不了这一条正则
  [ configuration E ]
}

location /images/ {
  # 字符匹配到 /images/，继续往下，会发现 ^~ 存在
  [ configuration F ]
}

location /images/abc {
  # 最长字符匹配到 /images/abc，继续往下，会发现 ^~ 存在
  # F与G的放置顺序是没有关系的
  [ configuration G ]
}

location ~ /images/abc/ {
  # 只有去掉 config D 才有效：先最长匹配 config G 开头的地址，继续往下搜索，匹配到这一条正则，采用
    [ configuration H ]
}

location ~* /js/.*/\.js
```

按照上面的location写法，以下的匹配示例成立：

- / -> config A
    精确完全匹配，即使/index.html也匹配不了
- /downloads/download.html -> config B
    匹配B以后，往下没有任何匹配，采用B
- /images/1.gif -> configuration D
    匹配到F，往下匹配到D，停止往下
- /images/abc/def -> config D
    最长匹配到G，往下匹配D，停止往下
    你可以看到 任何以/images/开头的都会匹配到D并停止，FG写在这里是没有任何意义的，H是永远轮不到的，这里只是为了说明匹配顺序
- /documents/document.html -> config C
    匹配到C，往下没有任何匹配，采用C
- /documents/1.jpg -> configuration E
    匹配到C，往下正则匹配到E
- /documents/Abc.jpg -> config CC
    最长匹配到C，往下正则顺序匹配到CC，不会往下到E

### 实际使用建议

``` shell
所以实际使用中，个人觉得至少有三个匹配规则定义，如下：
#直接匹配网站根，通过域名访问网站首页比较频繁，使用这个会加速处理，官网如是说。
#这里是直接转发给后端应用服务器了，也可以是一个静态首页
# 第一个必选规则
location = / {
    proxy_pass http://tomcat:8080/index
}
# 第二个必选规则是处理静态文件请求，这是nginx作为http服务器的强项
# 有两种配置模式，目录匹配或后缀匹配,任选其一或搭配使用
location ^~ /static/ {
    root /webroot/static/;
}
location ~* \.(gif|jpg|jpeg|png|css|js|ico)$ {
    root /webroot/res/;
}
#第三个规则就是通用规则，用来转发动态请求到后端应用服务器
#非静态文件请求就默认是动态请求，自己根据实际把握
#毕竟目前的一些框架的流行，带.php,.jsp后缀的情况很少了
location / {
    proxy_pass http://tomcat:8080/
}
```

### 重定向

``` shell
    rewrite  ^/test.php  /new  permanent;       //重写向带参数的地址
    rewrite  ^/test.php  /new?  permanent;      //重定向后不带参数
    rewrite  ^/test.php   /new?id=$arg_id?  permanent;    //重定向后带指定的参数
```

## 静态页面 root vs. alias

[Nginx -- static file serving confusion with root & alias - Stack Overflow](https://stackoverflow.com/questions/10631933/nginx-static-file-serving-confusion-with-root-alias)

1. `root` the location part is appended to root part, `final path = root + location`
2. `alias` the last location part is replaced by the alias part `final path = alias`

示例

```sh
# 最终路径是 /var/www/app/static/static
location /static/ {
    root /var/www/app/static/;
    autoindex off;
}

# 最终路径是 /var/www/app/static
# trailing slash in alias，末尾要加上 /
location /static/ {
    alias /var/www/app/static/;
    autoindex off;
}
```

## Sample

### SSL双向认证

``` shell
ssl_certificate  /path/to/server.crt;#server公钥
ssl_certificate_key  /path/to/server.key;#server私钥
ssl_client_certificate   /path/to/ca.crt;#根级证书公钥，用于验证各个二级client, 使用 CA 证书来验证请求带的客户端证书是否是该 CA 签发的
ssl_verify_client on;
```

curl 验证 `curl --insecure --key client.key --cert client.crt 'https://test'`

### Location ends with slash

#### location [doc](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)

If a location is defined by a prefix string that ends with the slash character, and requests are processed by one of `proxy_pass, fastcgi_pass, uwsgi_pass, scgi_pass, or memcached_pass`, then the special processing is performed. In response to a request with URI equal to this string, but without the trailing slash, a permanent redirect with the code 301 will be returned to the requested URI with the slash appended. If this is not desired, an exact match of the URI and location could be defined like this:

``` shell
    location /user/ {
        proxy_pass http://user.example.com;
    }
    location = /user {
        proxy_pass http://login.example.com;
    }
```

#### proxy_pass [doc](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)

``` shell
Syntax:     proxy_pass URL;
Default:     —
Context:     location, if in location, limit_except

```

Sets the protocol and address of a proxied server and an optional URI to which a location should be mapped. As a protocol, "http" or "https" can be specified. The address can be specified as a domain name or IP address, and an optional port:
    `proxy_pass http://localhost:8000/uri/;`

or as a UNIX-domain socket path specified after the word "unix" and enclosed in colons:
    `proxy_pass http://unix:/tmp/backend.socket:/uri/;`

If a domain name resolves to several addresses, all of them will be used in a round-robin fashion. In addition, an address can be specified as a server group.

A request URI is passed to the server as follows:

- If the proxy_pass directive is specified **with a URI**, then when a request is passed to the server, the part of a normalized request URI matching the location is replaced by a URI specified in the directive:

``` shell
location /name/ {
    proxy_pass http://127.0.0.1/remote/;
}
```

- If proxy_pass is specified **without a URI**, the request URI is passed to the server in the same form as sent by a client when the original request is processed, or the full normalized request URI is passed when processing the changed URI:

``` shell
location /some/path/ {
    proxy_pass http://127.0.0.1;
}
```

### Sample 1 NginX trailing slash in proxy pass url

[NginX trailing slash in proxy pass url](http://stackoverflow.com/questions/22759345/nginx-trailing-slash-in-proxy-pass-url)
Here is an example with trailing slash in location, but no trailig slash in proxy_pass.

``` shell
location /one/ {
    proxy_pass http://127.0.0.1:8080/two;
    ...
}
```

if one go to address [URL1](http://yourserver.com/one/path/here?param=1) nginx will proxy request to [URL1](http://127.0.0.1/twopath/here?param=1). See how two and path concatenates.

### Sample 2 practice nginx configuration

[URL](http://localhost/webProject)

#### Both of location and proxy_pass end with slash

``` shell
location /webProject/ {
    proxy_pass   http://localhost:3000/;
}
```

Nginx log of user request:

``` log
[16/Oct/2015:11:30:17 +0800] "GET /webProject/ HTTP/1.1" 302 114 "-"
[16/Oct/2015:11:30:17 +0800] "GET /webProject/login?rurl=%2F HTTP/1.1" 304 0 "-"
[16/Oct/2015:11:30:17 +0800] "GET /webProject/css/jquery-ui.min.css HTTP/1.1" 304 0 "http://localhost/webProject/login?rurl=%2F"
```

NodeJS log after nginx proxy request:

``` log
GET /
GET /login?rurl=%2F
GET /css/jquery-ui.min.css
```

#### location not and proxy_pass ends with slash

``` shell
location /webProject {
    proxy_pass   http://localhost:3000/;
}
```

Nginx log of user request:

``` log
[16/Oct/2015:11:42:07 +0800] "GET /webProject/ HTTP/1.1" 302 120 "-"
[16/Oct/2015:11:42:07 +0800] "GET /webProject/login?rurl=%2F%2F HTTP/1.1" 302 170 "-"
[16/Oct/2015:11:42:07 +0800] "GET /webProject/login?rurl=%2F%2Flogin%3Frurl%3D%252F%252F HTTP/1.1" 302 236 "-"
```

NodeJS log after nginx proxy request:

``` log
GET //
GET //login?rurl=%2F%2F
GET //login?rurl=%2F%2Flogin%3Frurl%3D%252F%252F
```

#### location ends with slash and proxy_pass not

``` shell
location /webProject/ {
    proxy_pass   http://localhost:3000;
}
```

Nginx log of user request:

```log
[16/Oct/2015:11:36:49 +0800] "GET /webProject/ HTTP/1.1" 302 146 "-"
[16/Oct/2015:11:36:49 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2F HTTP/1.1" 302 222 "-"
[16/Oct/2015:11:36:49 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F HTTP/1.1" 302 314 "-"
```

NodeJS log after nginx proxy request:

```log
GET /webProject/
GET /webProject/login?rurl=%2FsettlementWeb%2F
GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F
```

#### None of location and proxy_pass ends with slash

``` shell
location /webProject {
    proxy_pass   http://localhost:3000;
}
```

Nginx log of user request:

``` log
[16/Oct/2015:11:45:18 +0800] "GET /webProject/ HTTP/1.1" 302 146 "-"
[16/Oct/2015:11:45:18 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2F HTTP/1.1" 302 222 "-"
[16/Oct/2015:11:45:18 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F HTTP/1.1" 302 314 "-"
```

NodeJS log after nginx proxy request:

``` log
GET /webProject/
GET /webProject/login?rurl=%2FsettlementWeb%2F
GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F
```

### Adding cross-origin resource sharing (CORS) support

test with `curl`: `curl -I -X GET -H "Origin: http://www.example.com" "https://api2.example.com/v1/getIp`

[URL](https://gist.github.com/Stanback/7145487)

``` shell
#
# CORS header support
#
# One way to use this is by placing it into a file called "cors_support"
# under your Nginx configuration directory and placing the following
# statement inside your **location** block(s):
#
#   include cors_support;
#
# As of Nginx 1.7.5, add_header supports an "always" parameter which
# allows CORS to work if the backend returns 4xx or 5xx status code.
#
# For more information on CORS, please see: http://enable-cors.org/
# Forked from this Gist: https://gist.github.com/michiel/1064640
#

set $cors '';
#if ($http_origin ~ '^https?://(localhost|www\.yourdomain\.com|www\.yourotherdomain\.com)') {
# use wildcard for subdomain
if ($http_origin ~* https?://(localhost|[^/]*\.example\.com$)) {
    set $cors 'true';
}

if ($cors = 'true') {
    add_header 'Access-Control-Allow-Origin' "$http_origin" always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With' always;
    # required to be able to read Authorization header in frontend
    #add_header 'Access-Control-Expose-Headers' 'Authorization' always;
}

if ($request_method = 'OPTIONS') {
    # Tell client that this pre-flight info is valid for 20 days
    add_header 'Access-Control-Allow-Credentials' true;
    add_header 'Access-Control-Allow-Origin' "$http_origin";
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
    add_header 'Access-Control-Max-Age' 1728000;
    add_header 'Content-Type' 'text/plain; charset=utf-8';
    add_header 'Content-Length' 0;
    return 204;
}
```

### cros headers

```bash
# /etc/nginx/conf/module/crossdomainheader.conf

# include module/crossdomainheader.conf;
if ($http_origin ~* \w+.domain.(net|cn|com)) {
    add_header "Access-Control-Allow-Origin" $http_origin;
    add_header "Access-Control-Allow-Credentials" true;
    add_header "Access-Control-Allow-Methods" "GET,POST,OPTIONS";
    add_header "Access-Control-Max-Age" 86400;
}
```

### 启用长连接 proxy_pass http 1.1

[nginx keepalive](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive)

[nginx反向代理时保持长连接 - 流年的夏天 - 博客园](https://www.cnblogs.com/liufarui/p/11075630.html)

[nginx配置长连接 - 凌度 - 博客园](https://www.cnblogs.com/linn/p/4738820.html)

```bash
http {
    server {
        location / {
            proxy_pass http://backend;

            ##
            # 与上游服务器(Tomcat)建立keepalive长连接的配置，可参考上面的keepalive链接里的"For HTTP"部分
            ##
            # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_http_version
            # 设置代理的HTTP协议版本（默认是1.0版本）
            # 使用keepalive连接的话，建议使用1.1版本。
            proxy_http_version 1.1;                         # 设置http版本为1.1

            # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header
            # 允许重新定义或追加字段到传递给代理服务器的请求头信息（默认是close）
            # "Connection" header 被清理，这样即便是 Client 和 Nginx 之间是短连接，Nginx 和 upstream 之间也是可以开启长连接的。

            # 在nginx的配置文件中，如果当前模块中没有proxy_set_header的设置，则会从上级别继承配置。
            # 继承顺序为：http, server, location
            proxy_set_header Connection "";      # 设置Connection为长连接（默认为no）
        }
    }
}
```

### 请求路径重写 改写 rewrite

[Nginx的rewrite指令修改访问路径 - 腾讯云](https://cloud.tencent.com/developer/article/1531268)

[Module ngx_http_rewrite_module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite)

`Syntax: rewrite regex replacement [flag];`

```bash

location /api/ {
    proxy_set_header Host 'app-h5.dev.picooc.cn';

    # rewrite "^/api/(.*)$" /$1 break，路径重写：
    # "^/api/(.*)$"：匹配路径的正则表达式，用了分组语法，把/api/以后的所有部分当做1组
    # /$1：重写的目标路径，这里用$1引用前面正则表达式匹配到的分组（组编号从1开始），即/api/后面的所有。这样新的路径就是除去/api/以外的所有，就达到了去除/api前缀的目的
    # break：指令，常用的有2个，分别是：last、break
    # last：重写路径结束后，将得到的路径重新进行一次路径匹配
    # break：重写路径结束后，不再重新匹配路径。
    # 我们这里不能选择last，否则以新的路径/upload/image来匹配，就不会被正确的匹配到8082端口了
    rewrite ^/api/(.*)$ /$1 break;
    proxy_pass http://app-h5.dev.picooc.cn/;
}
```

## 安全配置

隐藏Nginx后端服务指定Header的状态

```sh
# 1、打开conf/nginx.conf配置文件（或主配置文件中的inlude文件）；
# 2、在http下配置proxy_hide_header项； 增加或修改为
proxy_hide_header X-Powered-By;
proxy_hide_header Server;
```

[TOC]

# Nginx
[nginx documentation](https://nginx.org/en/docs ) 

## Recent
https://groups.google.com/forum/#!msg/openresty/sGVZbJRs4lU/5Nxgb_rITGYJ
`$upstream_response_time` 格式会变成2部分 xxxx, xxxx ，可能是什么原因？被拆分的字段代表什么含义？
这是 `ngx_http_upstream` 的 fail-over 机制在起作用。当 nginx
尝试了第一个后端节点出现错误时（比如超时），它会自动尝试同一个 upstream {}
分组中的下一个节点。每个节点的访问时间会以逗号分隔。所以尝试了两个节点便是“xxxx, xxxx”。

### timeout 配置
`proxy_connect_timeout` :后端服务器连接的超时时间_发起握手等候响应超时时间  
`proxy_read_timeout`:连接成功后_等候后端服务器响应时间_其实已经进入后端的排队之中等候处理（也可以说是后端服务器处理请求的时间）  
`proxy_send_timeout` :后端服务器数据回传时间_就是在规定时间之内后端服务器必须传完所有的数据


## Nginx offical
[nginx documentation](http://nginx.org/en/docs )

NGINX (发音为 “engine X”)
cd /data/softwares/tengine-2.1/
`sudo /usr/local/nginx/sbin/nginx` start nginx
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

```
location optional_modifier location_match {
    . . .
}
```

1. (none): If no modifiers are present, the location is interpreted as a prefix match. This means that the location given will be matched against the beginning of the request URI to determine a match.
2. =: If an equal sign is used, this block will be considered a match if the request URI exactly matches the location given.
3. ~: If a tilde modifier is present, this location will be interpreted as a case-sensitive regular expression match.
4. ~*: If a tilde and asterisk modifier is used, the location block will be interpreted as a case-insensitive regular expression match.
5. ^~: If a carat and tilde modifier is present, and if this block is selected as the best non-regular expression match, regular expression matching will not take place.

1. =	表示精确匹配 如 A 中只匹配根目录结尾的请求，后面不能带任何字符串。
2. ^~	表示uri以某个常规字符串开头，不是正则匹配
3. ~	表示区分大小写的正则匹配;
4. ~*	表示不区分大小写的正则匹配
5. /	通用匹配, 如果没有其它匹配,任何请求都会匹配到
顺序 no优先级：
(location =) > (location 完整路径) > (location ^~ 路径) > (location ~,~* 正则顺序) > (location 部分起始路径) > (/)

###一个示例：

```
	
	location /settlementWeb {
             proxy_pass   http://localhost:3000;
             proxy_redirect off;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
```


```
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

###实际使用建议
```
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

## 
### SSL双向认证
```
	
	ssl_certificate  /path/to/server.crt;#server公钥
	ssl_certificate_key  /path/to/server.key;#server私钥
	ssl_client_certificate   /path/to/ca.crt;#根级证书公钥，用于验证各个二级client, 使用 CA 证书来验证请求带的客户端证书是否是该 CA 签发的
	ssl_verify_client on;
```
curl 验证 `curl --insecure --key client.key --cert client.crt 'https://test'`  

## Sample: Location ends with slash
### rule
#### location [doc](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)
If a location is defined by a prefix string that ends with the slash character, and requests are processed by one of `proxy_pass, fastcgi_pass, uwsgi_pass, scgi_pass, or memcached_pass`, then the special processing is performed. In response to a request with URI equal to this string, but without the trailing slash, a permanent redirect with the code 301 will be returned to the requested URI with the slash appended. If this is not desired, an exact match of the URI and location could be defined like this:

```
    location /user/ {
        proxy_pass http://user.example.com;
    }
    location = /user {
        proxy_pass http://login.example.com;
    }
```

#### proxy_pass [doc](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass)

```
Syntax: 	proxy_pass URL;
Default: 	—
Context: 	location, if in location, limit_except
```
Sets the protocol and address of a proxied server and an optional URI to which a location should be mapped. As a protocol, “http” or “https” can be specified. The address can be specified as a domain name or IP address, and an optional port:
	`proxy_pass http://localhost:8000/uri/;`

or as a UNIX-domain socket path specified after the word “unix” and enclosed in colons:
	`proxy_pass http://unix:/tmp/backend.socket:/uri/;`

If a domain name resolves to several addresses, all of them will be used in a round-robin fashion. In addition, an address can be specified as a server group.

A request URI is passed to the server as follows:

- If the proxy_pass directive is specified **with a URI**, then when a request is passed to the server, the part of a normalized request URI matching the location is replaced by a URI specified in the directive:
```
        location /name/ {
            proxy_pass http://127.0.0.1/remote/;
        }
```

- If proxy_pass is specified **without a URI**, the request URI is passed to the server in the same form as sent by a client when the original request is processed, or the full normalized request URI is passed when processing the changed URI:  
```
        location /some/path/ {
            proxy_pass http://127.0.0.1;
        }
```

### Sample 1 NginX trailing slash in proxy pass url
[NginX trailing slash in proxy pass url](http://stackoverflow.com/questions/22759345/nginx-trailing-slash-in-proxy-pass-url)
Here is an example with trailing slash in location, but no trailig slash in proxy_pass.
```
location /one/ {
    proxy_pass http://127.0.0.1:8080/two;
    ...
}
```
if one go to address http://yourserver.com/one/path/here?param=1 nginx will proxy request to http://127.0.0.1/twopath/here?param=1. See how two and path concatenates.

### Sample 2 practice nginx configuration
URL: http://localhost/webProject

#### Both of location and proxy_pass end with slash
```
        location /webProject/ {
 49              proxy_pass   http://localhost:3000/;
 54         }
```
Nginx log:
```
[16/Oct/2015:11:30:17 +0800] "GET /webProject/ HTTP/1.1" 302 114 "-"
[16/Oct/2015:11:30:17 +0800] "GET /webProject/login?rurl=%2F HTTP/1.1" 304 0 "-"
[16/Oct/2015:11:30:17 +0800] "GET /webProject/css/jquery-ui.min.css HTTP/1.1" 304 0 "http://localhost/webProject/login?rurl=%2F"
```
Node log:
```
GET /
GET /login?rurl=%2F
GET /css/jquery-ui.min.css
```

#### location ends with slash and proxy_pass not
```
		location /webProject/ {
 49              proxy_pass   http://localhost:3000;
 54         }
```
Nginx log:
```
[16/Oct/2015:11:36:49 +0800] "GET /webProject/ HTTP/1.1" 302 146 "-"
[16/Oct/2015:11:36:49 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2F HTTP/1.1" 302 222 "-"
[16/Oct/2015:11:36:49 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F HTTP/1.1" 302 314 "-"
```
Node log:
```
GET /webProject/
GET /webProject/login?rurl=%2FsettlementWeb%2F
GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F
```

#### proxy_pass ends with slash and location not
```
        location /webProject {
 49              proxy_pass   http://localhost:3000/;
 54         }
```
Nginx log:
```
[16/Oct/2015:11:42:07 +0800] "GET /webProject/ HTTP/1.1" 302 120 "-"
[16/Oct/2015:11:42:07 +0800] "GET /webProject/login?rurl=%2F%2F HTTP/1.1" 302 170 "-"
[16/Oct/2015:11:42:07 +0800] "GET /webProject/login?rurl=%2F%2Flogin%3Frurl%3D%252F%252F HTTP/1.1" 302 236 "-"
```
Node log:
```
GET //
GET //login?rurl=%2F%2F
GET //login?rurl=%2F%2Flogin%3Frurl%3D%252F%252F
```

#### None of location and proxy_pass ends with slash
```
         location /webProject {
 49              proxy_pass   http://localhost:3000;
 54         }
```
Nginx log:
```
[16/Oct/2015:11:45:18 +0800] "GET /webProject/ HTTP/1.1" 302 146 "-"
[16/Oct/2015:11:45:18 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2F HTTP/1.1" 302 222 "-"
[16/Oct/2015:11:45:18 +0800] "GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F HTTP/1.1" 302 314 "-"
```
Node log:
```
GET /webProject/
GET /webProject/login?rurl=%2FsettlementWeb%2F
GET /webProject/login?rurl=%2FsettlementWeb%2Flogin%3Frurl%3D%252FsettlementWeb%252F
```

# HTTPS Notes

## Introduction

### [阮一峰](http://www.ruanyifeng.com)

[SSL/TLS协议运行机制的概述](http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html)

[图解SSL/TLS协议](http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html)
CloudFlare宣布，开始提供Keyless服务，即你把网站放到它们的CDN上，不用提供自己的私钥，也能使用SSL加密链接.
CloudFlare的说明:

1. [Announcing Keyless SSL™: All the Benefits of CloudFlare Without Having to Turn Over Your Private SSL Keys](https://blog.cloudflare.com/announcing-keyless-ssl-all-the-benefits-of-cloudflare-without-having-to-turn-over-your-private-ssl-keys/)

2. [Keyless SSL: The Nitty Gritty Technical Details](https://blog.cloudflare.com/keyless-ssl-the-nitty-gritty-technical-details/)

[HTTPS 升级指南](http://www.ruanyifeng.com/blog/2016/08/migrate-from-http-to-https.html)

### JSSE

[Java Secure Socket Extension (JSSE) Reference Guide](https://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html)

## Nginx 配置 HTTPS 服务器

Author: Mihan 凹凸实验室 [Nginx 配置 HTTPS 服务器](https://mp.weixin.qq.com/s?__biz=MzIxMzExMjYwOQ==&mid=2651890628&idx=1&sn=ef48f59b49fede80813ac1f53dee22e2&scene=23&srcid=0823lFKQB1MdUfoGjf5h1cCk#rd)

### 配置 HTTPS

要开启 HTTPS 服务，在配置文件信息块(server block)，必须使用监听命令 listen 的 ssl 参数和定义服务器证书文件和私钥文件，如下所示

```bash
server {
    #ssl参数
    listen              443 ssl;
    server_name         example.com;
    #证书文件
    ssl_certificate     example.com.crt;
    #私钥文件
    ssl_certificate_key example.com.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    #...
}
```

证书文件会作为公用实体發送到每台连接到服务器的客戶端，私钥文件作为安全实体，**应该被存放在具有一定权限限制的目录文件，并保证 Nginx 主进程有存取权限。**
`ssl_protocols` 和 `ssl_ciphers` 可以用来限制连接只包含 SSL/TLS 的加強版本和算法

### HTTPS服务器优化

减少 CPU 运算量
SSL 的运行计算需要消耗额外的 CPU 资源，一般多核处理器系统会运行多个工作进程(worker processes )，进程的数量不会少于可用的 CPU 核数。SSL 通讯过程中『握手』阶段的运算最占用 CPU 资源，有两个方法可以减少每台客户端的运算量：

* 激活 keepalive 长连接，一个连接发送更多个请求
* 复用 SSL 会话参数，在并行并发的连接数中避免进行多次 SSL『握手』

这些会话会存储在一个 SSL 会话缓存里面，通过命令 ssl_session_cache 配置，可以使缓存在机器间共享，然后利用客戶端在『握手』阶段使用的 seesion id 去查询服务端的 session cathe(如果服务端设置有的话)，简化『握手』阶段。

### 使用 HSTS 策略强制浏览器使用 HTTPS 连接

HSTS -- HTTP Strict Transport Security，HTTP严格传输安全。它允许一个 HTTPS 网站要求浏览器总是通过 HTTPS 来访问，这使得攻击者在用戶与服务器通讯过程中拦截、篡改信息以及冒充身份变得更为困难. 只要在 Nginx 配置文件加上以下头信息就可以了

``` nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;preload" always;
```

* `max-age`: 设置单位时间内強制使用 HTTPS 连接
* `includeSubDomains`: 可选，所有子域同时生效
* `preload`: 可选，非规范值，用于定义使用『HSTS 预加载列表』
* `always`: 可选，保证所有响应都发送此响应头，包括各种內置错误响应

浏览器在获取该响应头后，在 max-age 的时间内，如果遇到 HTTP 连接，就会通过 307 跳转強制使用 HTTPS 进行连接，并忽略其它的跳转设置（如 301 重定向跳转）

## OpenSSL

### [Create CSR using OpenSSL Without Prompt (Non-Interactive)](https://www.shellhacks.com/create-csr-openssl-without-prompt-non-interactive/ )

CSR (Certificate Signing Request)

cer 格式 等价于 PEM 格式，使用 vi 打开 copy 到的内容是一样的

格式介绍：

* cer 格式
* PEM 格式

#### Create CSR and Key Without Prompt using OpenSSL

`openssl req -nodes -newkey rsa:2048 -keyout example.key -out example.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"`

#### Generate CSR From the Existing Key using OpenSSL

`openssl req -new -key example.key -out example.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"`

#### Convert private key version

Newer versions of OpenSSL say `BEGIN PRIVATE KEY` because they contain the private key + an OID that identifies the key type (this is known as PKCS8 format). Old versions of OpenSSL say `BEGIN RSA PRIVATE KEY`
To get the old-style key (known as either PKCS1 or traditional OpenSSL format) you can do this:
`openssl rsa -in server.key -out server_new.key`
Alternately, if you have a PKCS1 key and want PKCS8: `openssl pkcs8 -topk8 -nocrypt -in privkey.pem`

#### Checking Using OpenSSL

[The Most Common OpenSSL Commands](https://www.sslshopper.com/article-most-common-openssl-commands.html)

* Check a Certificate Signing Request (CSR) `openssl req -noout -text -in example.com.csr`
* Check a private key `openssl rsa -check -in privateKey.key`
* Check a certificate `openssl x509 -text -noout -in certificate.crt`
* Check a PKCS#12 file (.pfx or .p12) `openssl pkcs12 -info -in keyStore.p12`
* Connect to 443 `openssl s_client -connect www.example.com:443`
* Extract the certificate from the .p12 file to a .pem file `openssl pkcs12 -in certificate.p12 -out certificate.pem -nodes`
* Extract the certificate from the .cer file to a .pem file `openssl x509 -in certificate.cer -out certificate.pem -outform PEM`
* Get expired date from URL `openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates`
* Get expired date `openssl x509 -noout -enddate -in certificate.pem`
* Get expired date `openssl x509 -noout -dates -in nginx/05/ssl/example.com.crt`
* Get expired date `openssl pkcs12 -in certificate.p12 -nodes | openssl x509 -noout -enddate`

openssl s_client -connect -showcerts example.com:443 -servername example.com
openssl s_client -connect example.com:443 -servername example.com 2>/dev/null
openssl s_client -connect -debug example.com:443 -servername example.com

#### Options

openssl req certificate request generating utility
-nodes if a private key is created it will not be encrypted
-newkey creates a new certificate request and a new private key
rsa:2048 generates an RSA key 2048 bits in size
-key specifies the file to read the private key from
-keyout the filename to write the newly created private key to
-out specifies the output filename
-subj sets certificate subject
-new generates a new certificate request
-passout pass:"${pass}"
-passin pass:"${pass}"
-dates get start date and expired date

-subj arg Replaces subject field of input request with specified data and outputs modified request. The arg must be formatted as /type0=value0/type1=value1/type2=…, characters may be escaped by \ (backslash), no spaces are skipped.

The fields, required in CSR are listed below:

|Field  |Meaning             |Example
|:---   |:---                |
|/C=    |Country             |GB
|/ST=   |State               |London
|/L=    |Location            |London
|/O=    |Organization        |Global Security
|/OU=   |Organizational Unit |IT Department
|/CN=   |Common Name         |example.com (the domain name the Certificate will be issued for, e.g. *.example.com)

## [acme 生成证书](https://github.com/acmesh-official/acme.sh/wiki/说明)

```sh
# 下载生成脚本
curl  https://get.acme.sh | sh -s email=my@example.com

# 执行脚本生成证书
acme.sh --issue  -d www.example.com --webroot  /data/www/acme

# 脚本添加 crontab 自动更新证书
47 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null

# 获取过期时间
openssl x509 -noout -enddate -in www.example.com.cer
```

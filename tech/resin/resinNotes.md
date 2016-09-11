
resin access.log format configured in resin.xml
<access-log path='/data/log/resin/account/access.log' format='%h %l %u %t "%r" %s %b %T %D "%{Referer}i" "%{User-Agent}i"' rollover-period='1D' />
%h %l %u %t "%r"
%s %b %T %D "%{Referer}i
"%h: remote IP addr" %l "%u: remote user" "%t: request date with optional time format string." "%r: request URL"
"%s: status code" "%b: result content length" "%T: time taken to complete the request in seconds" "%D: time taken to complete the request in microseconds (since 3.0.16)" "%i: request header xxx"

192.168.3.58 - "null-user" [08/Sep/2016:17:35:22 +0800] "GET /account/rollPictures?esdfsd=140_499 HTTP/1.0" 200 40 0 0 "-" "Apache-HttpClient/4.5.2 (Java/1.8.0_101)"

# pub-sub 通知服务

方案 RSShub + miniflux+ Reeder feed43

## rss

rssbud  RSSHub 是一个给各种网站生成订阅源的开源工具，使用它能够解决90%订阅源的问题。

[rss服务](https://selfoss.aditu.de/docs/administration/requirements/)

[The Best Self-Hosted, Open Source RSS Feed Readers in 2022](https://safjan.com/the-best-self-hosted-rss-feed-readers-in-2022/)

miniflux 是一个使用GO语言编写的开源软件，它支持自己托管的RSS订阅服务，就是说你可以使用它来管理你的订阅源，比如给不同的订阅分类啊，标记已读、未读，是否把某些内容收藏等等一系列服务。

[rss-bridge](https://rss-bridge.github.io/rss-bridge/General/Project_goals.html)

有一些网站是RSShub 无法覆盖到的内容，于是可以通过 feed43 自己制作订阅源。我日常用它来订阅一些政务网站的内容。

## pub-sub tools

开源的 pub-sub 通知服务，你可以用它向手机和桌面电脑推送消息。类似的工具还有 Gotify。

[ntfy.sh | Send push notifications to your phone via PUT/POST](https://ntfy.sh/)

[Gotify · a simple server for sending and receiving messages](https://gotify.net/)

## Rss reader

ios阅读器  netnewswire 免费的unread reeder

Reeder是一个iOS和macOS下的RSS阅 读器，最后通过它来阅读你所订阅的内容，选 它的理由是足够简单且颜值在线。

## 爬虫

Crawlee 一个 Node.js 的网页抓取和浏览器自动化库，底层包装了无头浏览器 Playwright，功能比较多。

[Crawlee · Build reliable crawlers. Fast. | Crawlee](https://crawlee.dev/)

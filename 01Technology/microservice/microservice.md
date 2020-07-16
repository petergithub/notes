# 微服务

## 介绍文章

[这是我见过最通俗易懂的微服务架构改造解读 ](https://mp.weixin.qq.com/s?src=11&timestamp=1594546550&ver=2456&signature=7oC2KbYhIhehHVuXHop1pXWd6bphtH3mRsE1bP*1NNLkKMkQrNd83RKLoVcz6eZSAR9vE3kp09ZxmrqK7B8x2ceT3MThoDFv9JLlk2sG9GfAjUFHFsFTvaNUzVmkWMG7&new=1)
[一个小团队的微服务架构改造之路](https://mp.weixin.qq.com/s/VjBiUmQNQPpSHeSVjK1C2A)
[部署微服务的时候，Spring Cloud 和 Kubernetes 哪个更好？](http://dockone.io/article/2896)

## 常见的微服务技术框架

### [微服务架构深度解析与最佳实践](https://zhuanlan.zhihu.com/p/94976754)

服务框架：我们可以选择用 Spring Cloud 或者 Apache Dubbo，包括新兴的 Spring Cloud Alibaba，还有华为贡献的 Apache ServiceComb，蚂蚁金服的 SOFAStack ，Oracle 的 Helidon，Redhat 的 Quarkus，基于 Scala 语言和 Akka 的 Lagom，基于 Grails 语言的 Micronaut，基于 Python 语言的 Nameko，基于 Golang 语言的 go-micro，支持多语言混编的响应式微服务框架 Vert.X，腾讯开源的 Tars，百度开源的 Apache BRPC（孵化中），微博的简化版 Dubbo 框架 Motan 等等。
配置中心：Apollo，Nacos，disconf，Spring Cloud Config，或者 Etcd、ZK、Redis 自己封装
服务注册发现：Eureka，Consul，或者 Etcd、ZK、Redis 自己封装
服务网关：Zuul/Zuul2，Spring Cloud Gateway，nginx 系列的 Open Resty 和 Kong，基于 Golang 的 fagongzi Gateway 等
容错限流：Hystrix，Sentinel，Resilience4j，或者直接用 Kong 自带的插件
消息处理：Kafka、RabbitMQ、RocketMQ，以及 Pulsar，可以使用 Sping Messaging 或者 Spring Cloud Stream 来简化处理
链路监控与日志：开源的链路技术有 CAT、Pinpoint、Skywalking、Zipkin、Jaeger 等，也可以考虑用商业的 APM（比如听云 APM、OneAPM、App Dynamic 等），日志可以用 ELK
认证与授权：比如要支持 OAuth2、LDAP，传统的自定义 BRAC 等，可以选择 Spring Security 或者 Apache Shiro 等

### [一个可供中小团队参考的微服务架构技术栈](https://www.infoq.cn/article/china-microservice-technique)

核心支撑组件

    服务网关 Zuul
    服务注册发现 Eureka+Ribbon
    服务配置中心 Apollo
    认证授权中心 Spring Security OAuth2
    服务框架 Spring MVC/Boot

监控反馈组件

    数据总线 Kafka
    日志监控 ELK
    调用链监控 CAT
    Metrics 监控 KairosDB
    健康检查和告警 ZMon
    限流熔断和流聚合 Hystrix/Turbine

## 规划

### 代码未编工具先行；

    统一微服务工程结构；
    统一服务启动方式（jar war）；
    统一缓存调用方式（架构封装统一提供 jar 包和底层存储无关）；
    统一 MQ 调用方式（架构封装统一提供 jar，和具体 MQ 类型无关) ；
    统一日志格式；
    统一多服务依赖调用方式 (串行调用方式、并行调用方式）；
    统一熔断、降级处理流程；

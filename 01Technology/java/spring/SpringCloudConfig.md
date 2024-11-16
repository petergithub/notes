# Spring Cloud Config

[Getting Started | Centralized Configuration](https://spring.io/guides/gs/centralized-configuration)
[Spring Cloud Config](https://docs.spring.io/spring-cloud-config/docs/current/reference/html)
[配置中心系列一：SpringCloud Config的接入与使用](https://blog.csdn.net/qq_44625080/article/details/127141678)
[Spring Cloud Config实现配置中心-阿里云开发者社区](https://developer.aliyun.com/article/1216293)

[配置中心原理和选型：Disconf、Spring Cloud Config、Apollo 和 Nacos讲解4种常用的 - 掘金](https://juejin.cn/post/7072302179008610317)

## 接入 Quick Start

[Getting Started | Centralized Configuration](https://spring.io/guides/gs/centralized-configuration)

### 文件访问规则

Spring Cloud Config 规定了一套配置文件访问规则

| 访问规则                                   | 示例                      |
|-------------------------------------------|-------------------------|
| /{application}/{profile}[/{label}]        | /config/dev/master      |
| /{application}-{profile}.{suffix}         | /config-dev.yml         |
| /{label}/{application}-{profile}.{suffix} | /master/config-dev.yml  |

访问规则内各参数说明如下。

* {application}：应用名称，即配置文件的名称，例如 config-dev。
* {profile}：环境名，一个项目通常都有开发（dev）版本、测试（test）环境版本、生产（prod）环境版本，配置文件则以 application-{profile}.yml 的形式进行区分，例如 application-dev.yml、application-test.yml、application-prod.yml 等。
* {label}：Git 分支名，默认是 master 分支，当访问默认分支下的配置文件时，该参数可以省略，即第二种访问方式。
* {suffix}：配置文件的后缀，例如 config-dev.yml 的后缀为 yml

The HTTP service has resources in the following form:

```sh
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

For example:

```sh
curl localhost:8888/foo/development
curl localhost:8888/foo/development/master
curl localhost:8888/foo/development,db/master
curl localhost:8888/foo-development.yml
curl localhost:8888/foo-db.properties
curl localhost:8888/master/foo-db.properties
```

### Setup Config Server

```yml
server:
  port: 8888

spring:
  cloud:
    config:
      server:
        git:
#          uri: https://github.com/spring-cloud-samples/config-repo
#          uri: ${HOME}/config
        #   username: temp-ems
        #   password: t1emp-ems
#          search-paths: '{application}'
          search-paths:  #配置文件所在根目录
            - a-bootiful-client
            - '{application}'
#          default-label: test #配置文件分支
```

```java
@EnableConfigServer
@SpringBootApplication
public class ConfigurationServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigurationServiceApplication.class, args);
    }
}
```

### 客户端接入

```xml
    <properties>
        <spring-cloud.version>2023.0.2</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>${spring-cloud.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
            <version>4.1.3</version>
        </dependency>
    </dependencies>
```

```properties
spring.application.name=a-bootiful-client
spring.profiles.active=test,mysql

spring.config.import=optional:configserver:http://localhost:8888/?fail-fast=true&max-attempts=10&max-interval=1500&multiplier=1.2&initial-interval=1100
# Spring 激活的 profile
spring.cloud.config.profile=test
# 读取分支
spring.cloud.config.label=test

# 暴露管理接口，用于刷新属性更新
# curl -X POST localhost:8080/actuator/refresh -d {} -H "Content-Type: application/json"
management.endpoints.web.exposure.include=*
```

## Config Server 介绍

### Git Refresh Rate

You can control how often the config server will fetch updated configuration data from your Git backend by using `spring.cloud.config.server.git.refreshRate`. The value of this property is specified in seconds. By default the value is 0, meaning the config server will fetch updated configuration from the Git repo every time it is requested.

### JDBC Backend

Spring Cloud Config Server supports JDBC (relational database) as a backend for configuration properties. You can enable this feature by adding `spring-boot-starter-data-jdbc` to the classpath and using the jdbc profile or by adding a bean of type JdbcEnvironmentRepository

### Embedding the Config Server

内置 Config Server

### Push Notifications and Spring Cloud Bus

[Spring Cloud Config](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/#_push_notifications_and_spring_cloud_bus)

变更推送到 `/monitor`

If you add a dependency on the spring-cloud-config-monitor library and activate the Spring Cloud Bus in your Config Server, then a `/monitor` endpoint is enabled.

When the webhook is activated, the Config Server sends a `RefreshRemoteApplicationEvent` targeted at the applications it thinks might have changed.

The `RefreshRemoteApplicationEvent` is transmitted only if the `spring-cloud-bus` is activated in both the Config Server and in the client application.

## spring cloud config 优缺点

1.优点

1. 提供服务端和客户端支持(spring cloud config server和spring cloud config client)
2. 集中式管理分布式环境下的应用配置
3. 基于Spring环境，无缝与Spring应用集成
4. 可用于任何语言开发的程序
5. 默认实现基于git仓库，可以进行版本管理
6. 可替换自定义实现

2.缺点

1. 没有界面，管理麻烦
2. 没有权限管理
3. 依赖繁多，例如：
4. 如果使用Git作为后端存储，需要搭建GitLab或其他Git服务器集群
5. 如需实现配置批量刷新，需要借助Spring Cloud Bus，依赖Kafka或RabbitMQ
6. 由于依赖太多，集群搭建很麻烦——GitLab、MQ、Config Server本身都得做集群

## 源码解读

[github spring-cloud/spring-cloud-config: External configuration (server and client) for Spring Cloud](https://github.com/spring-cloud/spring-cloud-config)

[Spring Cloud Config源码解析-CSDN博客](https://blog.csdn.net/qq_45797138/article/details/139731039)

[Spring Cloud Config源码分析 流程图模板_ProcessOn思维导图、流程图](https://www.processon.com/view/5e95c9d0e401fd262e18ce94)

[spring-cloud-config 源码解析 - 吴振照 - 博客园](https://www.cnblogs.com/wuzhenzhao/p/13708308.html)

config 服务端负责响应请求，config 客户端在服务启动时会从服务端拉取配置信息

### 服务端 spring-cloud-config-server

服务端响应请求的过程比较简单，主要由`spring-cloud-config-server`包下 `EnvironmentController` 负责

`EnvironmentController` 通过 `EnvironmentRepository#findOne` 获取对应的 `Environment`。
`EnvironmentRepository` 是一个`Environment`仓库，可以从不同的配置中心获取配置内容，如JDBC、SVN、GIT等等。

真正的处理类是 `MultipleJGitEnvironmentRepository`，他可以管理多个git配置中心，实际通过 `JGitEnvironmentRepository` 获取某一个git配置中心上的配置内容。

`JGitEnvironmentRepository#findOne` -> `AbstractScmEnvironmentRepository#findOne`

```java

@RestController
@RequestMapping(
    method = {RequestMethod.GET},
    path = {"${spring.cloud.config.server.prefix:}"}
)
public class EnvironmentController {

    /**
     * 根据环境类型和文件名拉取信息
    **/
    @RequestMapping(
        path = {"/{name}/{profiles:.*[^-].*}"},
        produces = {"application/json"}
    )
    public Environment defaultLabel(@PathVariable String name, @PathVariable String profiles) {
        return this.getEnvironment(name, profiles, (String)null, false);
    }


    public Environment getEnvironment(String name, String profiles, String label, boolean includeOrigin) {
        name = this.normalize(name);
        label = this.normalize(label);
        Environment environment = this.repository.findOne(name, profiles, label, includeOrigin);
        if (this.acceptEmpty || environment != null && !environment.getPropertySources().isEmpty()) {
            return environment;
        } else {
            throw new EnvironmentNotFoundException("Profile Not found");
        }
    }

}
```

### 客户端 spring-cloud-config-client

springboot 在启动时会调用`applyInitializers`方法，这个方法会遍历`ApplicationContextInitializer`接口的实现类并调用它们的initialize方法。

config 客户端中的`PropertySourceBootstrapConfiguration`类实现了`ApplicationContextInitializer`接口，它的承担的任务是拉取远程的配置信息并与本地信息整合，他会读取`bootstrap.properties`，`bootstrap.yml`等配置文件中`Config Server`的配置信息。

`ConfigServicePropertySourceLocator`是`PropertySourceLocator`接口的实现类，它的locate方法发送具体的请求，拉取过来的远程信息会与本地整合(通过`RestTemplate`获取Config Server的`Environment`)，将结果 `PropertySource` 转化为对应的`OriginTrackedMapPropertySource`。

```java
@Retryable(
    interceptor = "configServerRetryInterceptor"
)
public PropertySource<?> locate(Environment environment) {
   ...
        for(int var11 = 0; var11 < var10; ++var11) {
            String label = var9[var11];
            ...
            // 发送请求
            org.springframework.cloud.config.environment.Environment result
                = this.getRemoteEnvironment(restTemplate, properties, label.trim(), state);
            ...
        }
}

private Environment getRemoteEnvironment(RestTemplate restTemplate, ConfigClientProperties properties, String label, String state) {
    String path = "/{name}/{profile}";
    String name = properties.getName();
    String profile = properties.getProfile();
    String token = properties.getToken();
    ...
    response = restTemplate.exchange(uri + path, HttpMethod.GET, entity, org.springframework.cloud.config.environment.Environment.class, args);
   ...
    }
}
```

### 源码运行

Activate the Spring Maven profile

```sh
mvn clean install -Pspring -DskipTests
```

IntelliJ IDEA

Open your project in IntelliJ IDEA.

1. In the Maven tool window, you will see your project's Maven projects and profiles.
2. Find the "Profiles" section where you can select the spring profile to activate it.
3. Click on the checkbox next to the spring profile to activate it.

IntelliJ IDEA will now use the spring profile for your Maven builds within the IDE.

错误日志

```sh
/d/workspace/workspace.me/spring-cloud-config/spring-cloud-config-server/src/main/java/org/springframework/cloud/config/server/environment/SearchPathCompositeEnvironmentRepository.java:50: error: pattern matching in instanceof is no
t supported in -source 8
                                if (repo instanceof SearchPathLocator searchPathLocator) {
                                                                      ^
  (use -source 16 or higher to enable pattern matching in instanceof)
2 errors
```

## 配置文件更新时机

1. 重启项目
2. 使用 Spring Boot Actuator 提供的 @RefreshScope 注解，通过 actuator/refresh 来刷新
3. 使用 Spring Cloud Bus 的推送机制。需要一个额外的中间件（如：KafKa, RabbitMQ）运行，依赖 Git 的 WebHook、Spring Cloud Bus和客户端/busrefresh端点。

### 重启项目更新

Config Client 启动项目

### Bean 上添加 @RefreshScope 更新

引入spring-boot-starter-actuator后，我们可以通过 `/actuator/refresh` 来刷新 `@RefreshScope` 标注的类。

处理该请求的是 RefreshEndpoint，调用链路

RefreshEndpoint#refresh -> ContextRefresher#refresh -> RefreshScope#refreshAll，

ContextRefresher#refresh 会刷新 Environment 的内容，并发布EnvironmentChangeEvent事件。
RefreshScope#refreshAll 会销毁 @RefreshScope 标注的 bean（还会发布RefreshScopeRefreshedEvent事件），这样先创建的bean就可以拿到最新的配置值了。

### Spring Cloud Bus 推送刷新

[Push Notifications and Spring Cloud Bus](https://docs.spring.io/spring-cloud-config/reference/server/push-notifications-and-bus.html)

[Refresh Configurations at Runtime with Spring Cloud Bus: A Practical Guide | by Amirhossein Khoshbin | Medium](https://medium.com/@uptoamir/refresh-configurations-at-runtime-with-spring-cloud-bus-a-practical-guide-38a7f739eca6)

[Spring Cloud Config Bus — Auto Refresh Properties for Clients | by Eresh Gorantla | The Startup | Medium](https://medium.com/swlh/spring-cloud-config-bus-auto-refresh-properties-for-clients-d18fa4c036cb)

If you add a dependency on the spring-cloud-config-monitor library and activate the Spring Cloud Bus in your Config Server, then a `/monitor` endpoint is enabled.

更新流程：

1. 推送新的配置到 Git
2. Git Hooks 调用 Spring Cloud Config Server 的 /monitor 接口，
3. Config Server 获取最新的配置，并且发送 refresh event 到 Spring Cloud Bus
4. 连到 Spring Cloud Bus 的 Config Client 会监听到 refresh event，然后 Config Client 调用 Config Server 更新配置

## 实现自动更新方案

不使用 GitLab webhook 的前提下，自动更新思路：

1. 改造 Config Server 监控 Git 代码的变化，通知 Client 拉取：需要注册中心
2. 改造 Config Client 定时拉取：每个项目接入后需要启动定时任务

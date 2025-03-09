# Spring Note

## Spring Cloud

[spring-cloud docs](https://docs.spring.io/spring-cloud/docs/)

[Spring Cloud](https://spring.io/projects/spring-cloud)

Release 2023.0.x aka Leyton Spring Boot Generation 3.3.x, 3.2.x [Spring Cloud 2023.0 Release Notes](https://github.com/spring-cloud/spring-cloud-release/wiki/Spring-Cloud-2023.0-Release-Notes#202303)

[Spring Cloud Kubernetes Doc 3.1.0-M1](https://docs.spring.io/spring-cloud-kubernetes/docs/3.1.0-M1/reference/html/)

[Supported Versions · spring-cloud/spring-cloud-release Wiki](https://github.com/spring-cloud/spring-cloud-release/wiki/Supported-Versions)

### 链路追踪

[OpenTelemetry](https://opentelemetry.io/zh/docs/what-is-opentelemetry/)
[Intro to OpenTelemetry Java | OpenTelemetry](https://opentelemetry.io/zh/docs/languages/java/intro/)

[OpenTelemetry - 骑牛上青山的专栏 - 掘金](https://juejin.cn/column/7174678064054583355)

[Spring Cloud Sleuth在Spring Boot应用程序中的集成-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2261788)

[9.1 什么是可观测性 | 深入高可用系统原理与设计](https://www.thebyte.com.cn/Observability/What-is-Observability.html)

## spring boot

### spring boot启动流程

1. 会先创建一个SpringApplication，其中包含了初始化器(ApplicationContextInitializer)与监听器(ApplicationListener)的实例化，并推导出主应用类.
2. 执行run方法,实例化SpringApplicationRunListener（spring boot中的监听器回调入口）
3. 解析命令行参数
4. 环境变量准备
5. 创建applicationContext
6. 初始化器回调
7. 加载javaconfig资源文件，准备applicationContext刷新
8. 执行applicationContext刷新, 刷新过程：
   1. 会添加工厂的postProcessor，bean的postProcessor到bean工厂中
   2. 执行工厂的postProcessor
   3. 实例化beanPostProcessor
   4. 启动内嵌的tomcat
   5. 注册实现了ApplicationListener接口的监听器
   6. 实例化bean，并且调用beanpostprocessor，应用其中的逻辑

### springboot自动配置

1. @SpringBootApplication中使用了@EnableAutoConfiguration
2. @EnableAutoConfiguration 使用了@Import导入了AutoConfigurationImportSelector类
3. AutoConfigurationImportSelector类中会返回所有自动配置类的类名，这些返回的类名都会被spring创建
4. AutoConfigurationImportSelector返回的自动配置的类都是使用@ConditionalXX进行并指定Condition进行条件匹配，符合条件的则会自动创建
5. 我们也可以实现自己的Condition，并在spring.factories中配置自己创建的自动配置类，并使用@Condition指定相关的创建条件，那么在符合条件时便会进行创建。

#### 0208Spring Boot技术难点源码深入剖析.mp4

Springboot 根据配置的 pom.xml 来判断使用 Tomcat，jetty，Undertow。通过使用 ASM 工具来扫描 class 文件实现，比如环境中是否存在 Undertow.class。
`@ConditionalOnClass({ Servlet.class, Undertow.class, SslClientAuthMode.class })`

### Spring Boot Actuator 的 Endpoints

[Spring Boot Actuator: Endpoints](https://docs.spring.io/spring-boot/docs/2.5.6/reference/html/actuator.html#actuator.endpoints)

以下是Spring Boot Actuator 常见的管理API端点，出于安全考虑，只有health和info端点是暴露的。通过配置 `management.endpoints.web.exposure.include=*`可以暴露所有端点，但请注意，这可能会带来安全风险

health：提供应用的健康状态信息。
info：提供应用的基本信息，如版本号等。
beans：列出应用中所有的Spring Beans。
caches：展示应用中的缓存信息。
conditions：列出所有的条件注解@Conditional。
configprops：展示所有@ConfigurationProperties注解的Bean的属性值。
env：展示环境变量和配置属性的值。
loggers：展示和修改日志级别。
heapdump：生成应用的堆转储文件。
threaddump：生成应用的线程转储文件。
metrics：提供应用的度量信息。
scheduledtasks：列出应用中所有的定时任务。
mappings：列出应用中所有的URL映射。

启用并暴露端点

访问http://localhost:8080/actuator，返回可用的端点列表

一旦我们引入了合适的starter到maven配置中，我们便可以通过 http://localhost:8080/actuator/health 和 http://localhost:8080/actuator/info来进行两个端点的访问

暴露所有端点

下面通过配置来暴露除了/shutdown之外的所有端点，在application.properties中进行如下配置：

management.endpoints.web.exposure.include=*

暴露指定端点

可以通过逗号分隔符来配置多个端点，比如我们暴露/beans和/loggers端点：

management.endpoints.web.exposure.include=beans, loggers

排除一些端点。比如暴露除了/threaddump之外的所有端点：

management.endpoints.web.exposure.include=*
management.endpoints.web.exposure.exclude=threaddump

开启指定端点
下面来看一下如何细粒度的开启指定的端点。首先，需要关闭默认开启的所有端点：

management.endpoints.enabled-by-default=false
开启并暴露/health端点：

management.endpoint.health.enabled=true
management.endpoints.web.exposure.include=health

开启Shutdown端点
因为/shutdown端点比较敏感的原因，该端点默认是不可用的。可在application.properties文件中通过如下配置进行启动：

management.endpoint.shutdown.enabled=true

## Spring 基础

### Bean 创建流程

1. 实例化 AbstractBeanFactory##getBean > doGetBean > AbstractAutowireCapableBeanFactory#createBean > doCreateBean > createBeanInstance
2. 初始化 自定义属性 设置Bean的属性 populateBean
3. 初始化 容器对象属性 Aware相关接口实现  BeanFactoryAware, ApplicationContextAware
4. BeanPostProcessor 接口 postProcessBeforeInitialization 方法，AOP 创建代理
5. init-method属性并自动调用其配置的初始化方法
6. BeanPostProcessor 接口 postProcessAfterInitialization 方法

### spring循环依赖

[Spring源码最难问题《当Spring AOP遇上循环依赖》](https://blog.csdn.net/chaitoudaren/article/details/105060882)

1. spring利用了3级缓存解决循环依赖
2. 在一个bean实例化的过程中，通过提前暴露自己的bean工厂存放在三级缓存中
3. 并在有循环依赖发生时，通过**三级缓存中存放的bean工厂**生产bean，并放置到二级缓存中，并返回引用的方式，来解决循环依赖的问题

为什么是三级缓存，而不是二级缓存？

简单来说，循环依赖的对象存在AOP代理的时候，代理时机会提前(正常是在初始化之后进行代理)，
为了避免循环依赖依赖到的是代理之后的对象，所以提前代理的对象存放在二级缓存，提前暴露的对象放在三级缓存

三级缓存：

1. singletonObject：一级缓存 成品对象，这里的 bean经历过实例化->属性填充->初始化以及各类的后置处理。
2. earlySingletonObjects：二级缓存 半成品对象，bean只能确保已经进行了实例化，但是属性填充跟初始化还没完成，仅能作为指针提前曝光，被其他bean所引用。
3. singletonFactories：三级缓存 lambda 表达式 ，在bean实例化完之后，属性填充以及初始化之前，bean转换成beanFactory并加入到三级缓存。

### aop的原理

1. spring的aop利用了jdk或者cglib的动态代理
2. 在代理目标类实现了接口的情况下，则会使用jdk动态代理，否则使用cglib基于目标类生成子类对象的方式生成动态代理对象（spring boot2中默认使用的cglib，aop自动配置类中指定的，为了防止impl类方式的注入不会生成代理对象）
3. 通过在生成spring bean的最后一步时候，通过aop的processor，生成jdk或者cglib的动态代理，会持有被代理对象，及相关的advisor
执行方法过程：
   1. 在执行代理方法的时候，会先获取所有的通知列表，并且在执行时会构建一个MethodInvocation，并传入通知列表。
   2. MethodInvocation的执行方法（proceed()）会利用此通知列表来构建一个责任链，维护一个增长的下标，每次在执行时获取一个通知方法（MethodInteceptor）
   3. 在每次执行methodInteceptor，会传入MethodInvocation进去，在执行proceed的前后可以执行增强的方法
   4. 另外在proceed的入口处会有下标超出通知列表的判断，如果达到最后一个会执行被代理的目标方法，并返回结果，以此来作为责任链的终点。
   5. 另外在执行MethodInteceptor的后置的一些方法是在finally中执行的，这样在保证return之前能够执行最终方法。

### spring mvc容器初始化与执行流程

boot启动阶段：
1.在执行applicationContext的刷新过程中，在执行到beanFactoryPostProcessor的时候会将所有的配置类解析出来，其中包括DispatcherServletAutoConfiguration，并注册到beanFactory中
2.在onRefresh中，启动内置tomcat时，会在启动回调时将dispatcherServlet注入到servletContext中（原理是是在tomcat启动时调用包括DispatcherServletRegistrationBean在内的ServletContextInitializer，而这些是通过beanFactory中获取的，在beanFactoryPostProcessor处理阶段添加bd到工厂中的）
3.在实例化bean工厂中单例bean的阶段中，会将HandlerMapping进行实例化，会先将注册的所有拦截器进行保存，然后会获取所有@Controller和@RequestMapping注解的类，接着解析里面的方法解析为路径对应method存放到内存中

请求流程：
1.根据请求路径找到对应的HandlerMapping
2.HandlerMapping中找到映射的方法，并根据请求路径匹配对应的拦截器
3.返回包含方法和拦截器在内的一个对象，用于执行拦截器的调用
4.根据执行方法获取HandlerAdapter（会使用adapter执行controller方法调用）
5.在方法调用前先调用拦截器preHandle前置方法
6.执行adapter.handle调用真实controller方法并获取返回值
7.执行拦截器后置调用postHandle
8.最后执行输出结果 并且 执行拦截器AfterCompletion调用

### spring事务原理

事务原理是基于spring aop的，方法上加@Transactional注解的，会在实例化bean阶段，生成代理对象，并且会匹配相关的advisor，其中包括TransactionInterceptor。
1.springboot启动的时候会有TransactionAutoConfiguration，符合条件的话，TransactionAutoConfiguration会开启EnableTransactionManagement注解
2.EnableTransactionManagement会导入TransactionInterceptor到bean工厂中。
3.在实例化bean阶段，生成代理类的时候会根据所有的advisor匹配符合规则的bean(主要方法上有加Transactional注解的)，会应用TransactionInterceptor，生成代理对象。
4.在执行代理对象的时候，会根据所有的advisors找到符合规则的methodInterceptor列表，并使用责任链的模式进行递归调用。

5.TransactionInterceptor会在调用方法前后开启事务和提交或者回滚事务。
6.具体开启提交事务使用TransactionManager开启和提交。
7.在开启事务的时候会根据不同的传播行为走不同的逻辑分支。
8.传播行为判断通过底层ThreadLocal进行存储同一个线程，不同的事务的状态及信息。
9.如果需要挂起事务的情况会将这些信息保存到当前事务的TransactionStatus中，以便在内部事务结束时进行外部事务恢复。

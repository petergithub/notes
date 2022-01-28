# Spring Note

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

## Spring 基础

### spring循环依赖

[Spring源码最难问题《当Spring AOP遇上循环依赖》](https://blog.csdn.net/chaitoudaren/article/details/105060882)

1.spring利用了3级缓存解决循环依赖
2.在一个bean实例化的过程中，通过提前暴露自己的bean工厂存放在三级缓存中
3.并在有循环依赖发生时，通过**三级缓存中存放的bean工厂**生产bean，并放置到二级缓存中，并返回引用的方式，来解决循环依赖的问题

为什么是三级缓存，而不是二级缓存？

简单来说，循环依赖的对象存在AOP代理的时候，代理时机会提前(正常是在初始化之后进行代理)，
为了避免循环依赖依赖到的是代理之后的对象，所以提前代理的对象存放在二级缓存，提前暴露的对象放在三级缓存

### aop的原理

1. spring的aop利用了jdk或者cglib的动态代理
2.在代理目标类实现了接口的情况下，则会使用jdk动态代理，否则使用cglib基于目标类生成子类对象的方式生成动态代理对象（spring boot2中默认使用的cglib，aop自动配置类中指定的，为了防止impl类方式的注入不会生成代理对象）
3.通过在生成spring bean的最后一步时候，通过aop的processor，生成jdk或者cglib的动态代理，会持有被代理对象，及相关的advisor
执行方法过程：
 1.在执行代理方法的时候，会先获取所有的通知列表，并且在执行时会构建一个MethodInvocation，并传入通知列表。
 2.MethodInvocation的执行方法（proceed()）会利用此通知列表来构建一个责任链，维护一个增长的下标，每次在执行时获取一个通知方法（MethodInteceptor）
 3.在每次执行methodInteceptor，会传入MethodInvocation进去，在执行proceed的前后可以执行增强的方法
 4.另外在proceed的入口处会有下标超出通知列表的判断，如果达到最后一个会执行被代理的目标方法，并返回结果，以此来作为责任链的终点。
 5.另外在执行MethodInteceptor的后置的一些方法是在finally中执行的，这样在保证return之前能够执行最终方法。

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

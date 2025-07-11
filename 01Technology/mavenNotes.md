# Maven常用命令

[TOC]

[Settings – Maven Settings](https://maven.apache.org/ref/3.9.10/maven-settings/settings.html)

## Basic

``` bash

# 查看当前使用的 settings.xml 文件路径
mvn help:effective-settings


# List all your Maven dependencies
# detect multiple versions of the same dependency
mvn -o dependency:list \
| grep ":.*:.*:.*" \
| cut -d] -f2- \
| sed 's/:[a-z]*$//g' \
| sort -u
```

pom.xml
`scope`：是用来指定当前包的依赖范围，maven的依赖范围
`compile`编译范围, `provided`已提供范围(在当JDK或者一个容器已提供该依赖之后才使用), `runtime`运行时范围(在运行和测试系统的时候需要，但在编译的时候不需要), `test`测试范围(编译和运行时都不需要，在测试编译和测试时使用), `system`系统范围(必须显式的提供一个对于本地系统中JAR文件的路径)
`optional`:设置指依赖是否可选，默认为false,即子项目默认都继承，为true,则子项目必需显示的引入，与dependencyManagement里定义的依赖类似 。

```sh
# -v 显示版本信息
# -e 显示详细错误信息
# -o Work offline Running in Offline Mode
mvn -v
# 运行任何检查, 验证包是否有效且达到质量标准
mvn verify
# 验证工程是否正确, 所有需要的资源是否可用
mvn validate
# 产生应用需要的任何额外的源代码, 如xdoclet
mvn generate-sources
# 在集成测试可以运行的环境中处理和发布包
mvn integration-test
# 输出完整的带有参数的目标列
mvn help:describe -Dfull
    # -Dplugin=help 使用help插件的describe目标来输出Maven Help插件的信息
    # -Dplugin=compiler -Dmojo=compile    列出了Compiler插件的compile目标的所有信息
    # -Dplugin=exec    列出所有Maven exec插件可用的目标

# see how all of the current project’s ancestor POMs are contributing to the effective POM.它暴露了 Maven的默认设置
mvn help:effective-pom
# 想要查看完整的依赖踪迹, 包含那些因为冲突或者其它原因而被拒绝引入的构件, 打开 Maven的调试标记运行
mvn install -X
# 给任何目标添加maven.test.skip 属性就能跳过测试
mvn install -Dmaven.test.skip=true
# 打印出已解决依赖的列表
mvn dependency:resolve
# 打印整个依赖树
mvn dependency:tree
#  -U  (aka  --update-snapshots ): force maven update local repository
mvn dependency:list -e -U -X

# 创建Maven的普通java项目
mvn archetype:create -DgroupId=packageName -DartifactId=projectName
# 清空生成的文件
mvn clean
# 编译
mvn compile
# 编译项目测试代码
mvn test-compile
# 编译并测试
mvn test
# 只测试而不编译, 也不测试编译(-skipping 的灵活运用, 当然也可以用于其他组合命令)
mvn test -skipping compile -skipping test-compile
# 执行指定测试类
mvn test -Dtest=TestChannelService
# 执行指定测试类里的方法testＭethodA
mvn test -Dtest=xxxxTest#testＭethodA
# run only single test in multi-module project
mvn test -Dtest=TestClass#testMethod -pl moduleName
mvn -Dmaven.test.skip
mvn -DskipTests

# 生成target目录, 编译、测试代码, 生成测试报告, 生成jar/war文件
mvn package
# 打jar包
mvn jar:jar
# 调用 Jetty插件的 Run目标在 Jetty Servlet容器中启动 web应用
mvn jetty:run
mvn tomcat:run
# 在本地Repository中安装jar
mvn install
# 删除再编译
mvn clean install
mvn install:install-file -DgroupId=com.lowagie -DartifactId=itextasian -Dversion=1.0 -Dpackaging=jar -Dfile=/path/to/itextasian.jar
# 生成项目相关信息的网站
mvn site
# 插件让我们能够在不往classpath载入适当的依赖的情况下, 运行这个程序
mvn exec:java -Dexec.mainClass=org.sonatype.mavenbook.weather.Main Exec
# 统一修改父子版本号
mvn versions:set -DnewVersion=xxx-SNAPSHOT/RELEASE

# 下载单个 jar
mvn dependency:get -Dartifact=org.riversun:random-forest-codegen:1.0.0 -Ddest=./

# 删掉当前 POM 文件中所有依赖文件. 解决依赖更新后但版本号不变,导致的依赖文件没有下载最新版本
mvn dependency:purge-local-repository -DreResolve=false
```

### Proxy

`export MAVEN_OPTS="-DsocksProxyHost=127.0.0.1 -DsocksProxyPort=1080"`
or `mvn -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=1080`

## Usage example

### Add a jar, source and Javadoc to the local/remote Maven repository

[deploy:deploy-file](http://maven.apache.org/plugins/maven-deploy-plugin/deploy-file-mojo.html)

if want to download the sources jar the 2nd time, search and remove all "sources.jar-not-available"
    DEFAULT_PARAMETER=-DgroupId=com.auxilii.msgparser -DartifactId=msgparser -Dversion=1.10 -Dpackaging=jar -Dfile=C:/msgparser-1.10.jar
        -DrepositoryId=maven-snapshots -Drepo.login=username -Drepo.pwd=pwd
    mvn install:install-file ${DEFAULT_PARAMETER}
    mvn deploy:deploy-file ${DEFAULT_PARAMETER} -Durl=file://path/to/your/repository
        options: -Dclassifier add jar is the default value. -Dclassifier=sources (add sources) -Dclassifier=javadoc (add Java doc)

install jar:    `mvn install:install-file -DgroupId=es.upct.girtel -DartifactId=jom -Dversion=0.4.0 -Dpackaging=jar -Dfile=jom-0.4.0.jar`
install sources:`mvn install:install-file -DgroupId=es.upct.girtel -DartifactId=jom -Dversion=0.4.0 -Dpackaging=jar -Dclassifier=sources -Dfile=jom-0.4.0-sources.jar`

deploy root-pom.pom to snapshots 库:
`mvn deploy:deploy-file -DgroupId=com -DartifactId=root-pom -Dversion=1.0.1-SNAPSHOT -Dpackaging=pom -DrepositoryId=maven-snapshots -Drepo.login=user -Drepo.pwd=password -Durl=http://maven.com/repository/maven-snapshots -Dfile=root-pom.pom`

### Password Encryption

[Password Encryption – Maven](https://maven.apache.org/guides/mini/guide-encryption.html)

加密密码

```sh
# create a master password
mvn --encrypt-master-password <password>
# {jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}
```

Store this password in the ${user.home}/.m2/settings-security.xml; it should look like

```xml
<settingsSecurity>
  <master>{jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}</master>
</settingsSecurity>
```

```sh
# encrypt server passwords
mvn --encrypt-password <password>
# {COQLCE6DU6GtcS5P=}
```

```xml
<settings>
...
  <servers>
...
    <server>
      <id>my.server</id>
      <username>foo</username>
      <password>Oleg reset this password on 2009-03-11, expires on 2009-04-11 {COQLCE6DU6GtcS5P=}</password>
    </server>
...
  </servers>
...
</settings>
```

### Specify the location for the testResource folder

adding this to your pom.xml build section

``` xml
<testResources>
    <testResource>
        <!-- include src/main/resources -->
        <directory>${basedir}/src/main/WEB-INF/resources</directory>
    </testResource>
    <testResource>
        <directory>${basedir}/src/main/WEB-INF/test/java</directory>
        <excludes>
            <exclude>**/*.java</exclude>
        </excludes>
    </testResource>
</testResources>
```

Rerfer:
[Maven - Override test resource folder](https://stackoverflow.com/questions/35369269/maven-override-test-resource-folder)
[testResources](https://maven.apache.org/plugins/maven-resources-plugin/testResources-mojo.html)

### Unit test disable in pom.xml

``` xml
<plugin>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>2.19.1</version>
    <configuration>
        <!-- skip test -->
        <skip>true</skip>
        <forkMode>none</forkMode>
        <includes>
            <include>**/*Test.java</include>
        </includes>
    </configuration>
</plugin>
```

### Maven 自动化部署

[Maven Release Plugin](http://maven.apache.org/maven-release/maven-release-plugin/index.html)
[Guide to using the release plugin](https://maven.apache.org/guides/mini/guide-releasing.html)
[极客学院 Maven - 自动化部署](https://wiki.jikexueyuan.com/project/maven/deployment-automation.html)
[Maven最佳实践：版本管理](https://blog.csdn.net/iteye_11035/article/details/81717447)

git connection `<connection>scm:git:git@gitlab.com:username/testMavenRelease.git</connection>`

`mvn release:prepare -Prelease -Darguments="-DskipTests" -DautoVersionSubmodules=true -Dusername=YOUR GITHUB ID -DdryRun=true`

[Performing a Non-interactive Release](http://maven.apache.org/maven-release/maven-release-plugin/examples/non-interactive-release.html)
release prepare without prompts: `mvn --batch-mode release:prepare` or `mvn -B release:prepare` This will assume defaults for anything that you would normally be prompted for.
`mvn --batch-mode -Dtag=v1.3 release:prepare -DreleaseVersion=1.2 -DdevelopmentVersion=2.0-SNAPSHOT release:perform`

``` shell
# for Jenkins
# release version to maven repository
releaseVersion=1.0-RELEASE
# next development version
developmentVersion=1.1-SNAPSHOT
mvn --batch-mode release:clean release:prepare release:perform -Dtag=v${releaseVersion} -DreleaseVersion=${releaseVersion} -DdevelopmentVersion=${developmentVersion}
```

#### maven-release-plugin pom.xml template

``` xml
<!-- template -->
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
   <modelVersion>4.0.0</modelVersion>
   <groupId>test</groupId>
   <artifactId>mavenRelease</artifactId>
   <version>1.0-SNAPSHOT</version>
   <packaging>jar</packaging>
   <scm>
      <url>https://gitlab.com/username/testMavenRelease</url>
      <connection>scm:git:git@gitlab.com:username/testMavenRelease.git</connection>
      <developerConnection>scm:git:git@gitlab.com:username/testMavenRelease.git</developerConnection>
     <tag>HEAD</tag>
  </scm>
  <build>
      <plugins>
         <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-release-plugin</artifactId>
            <version>2.5.3</version>
            <configuration>
               <useReleaseProfile>false</useReleaseProfile>
               <goals>deploy</goals>
               <scmCommentPrefix>[maven-release-checkin]-</scmCommentPrefix>
               <!--
                 <tagNameFormat>v@{project.version}</tagNameFormat>
                 -->
                 <autoVersionSubmodules>true</autoVersionSubmodules>
            </configuration>
         </plugin>
      </plugins>
   </build>
  <distributionManagement>
        <!-- use the following if you're not using a snapshot version. -->
        <repository>
            <id>maven-releases</id>
            <name>RepositoryProxy</name>
            <url>http://maven.com/repository/maven-releases/</url>
        </repository>
        <!-- use the following if you ARE using a snapshot version. -->
        <snapshotRepository>
            <id>maven-snapshots</id>
            <name>RepositoryProxySnap</name>
            <url>http://maven.com/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
```

## Introduction to the Standard Directory Layout

src/main/java Application/Library sources
src/main/resources Application/Library resources
src/main/filters Resource filter files
src/main/assembly Assembly descriptors
src/main/config Configuration files
src/main/scripts Application/Library scripts
src/main/webapp Web application sources
src/test/java Test sources
src/test/resources Test resources
src/test/filters Test resource filter files
src/site Site
LICENSE.txt Project's license
NOTICE.txt Notices and attributions required by libraries that the project depends on
README.txt Project's readme

### configuration

setting.xml change local reponsitory
  `<localRepository>$HOME/.m2/repository</localRepository>`

### pom.xml

``` xml
1. configure build options <project><build>...</build></project>
    <!-- change build target path -->
    <build>
       <outputDirectory>src/main/webapp/WEB-INF/classes</outputDirectory>
       <testOutputDirectory>${basedir}/${target.dir}/test-classes</testOutputDirectory>
    </build>
2. configure build plugins <project><build><plugins>...</plugins></build></project>
    2.1    <!-- Attach Library Sources and Javadocs -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-eclipse-plugin</artifactId>
            <version>2.9</version>
            <configuration>
                <downloadSources>true</downloadSources>
                <downloadJavadocs>true</downloadJavadocs>
            </configuration>
        </plugin>
    2.2    <!-- Fix compiler version -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>1.5</source>
                <target>1.5</target>
            </configuration>
        </plugin>
```

### Example springside

springside define version in parent/pom.xml `<dependencyManagement>`
那么经过验证，scope写在子项目中的`<dependencies>` 下的`<dependency>`中，或是写在父项目中的`<dependencyManagement>`中，都是可以的。
但有一点需要注意，dependencies 和 dependencyManagement 的区别在于：
前者，即使在子项目中不写该依赖项，那么子项目仍然会从父项目中继承该依赖项。
后者，如果在子项目中不写该依赖项，那么子项目中是不会从父项目继承该依赖项的；只有在子项目中写了该依赖项，才会从父项目中继承该项，并且version 和 scope 都读取自 父pom。

## Sonotype Nexus3

[sonatype/nexus3 docker image](https://hub.docker.com/r/sonatype/nexus3/)

`docker run -d -p 8081:8081 --name nexus2 -v /data/docker/sonatype-nexus2/sonatype-work:/sonatype-work sonatype/nexus`
`docker run -d -p 8081:8081 --name nexus3 -v /data/docker/sonatype-nexus3/nexus-data:/nexus-data sonatype/nexus3`
`docker logs -f nexus`

[localhost nexus3](http://localhost:8081) 用户名 admin 默认密码 admin123
To test: `curl -u admin:admin123 http://localhost:8081/service/metrics/ping`

[Maven Repositories](https://help.sonatype.com/en/maven-repositories.html)

[How do I deploy my jar in my remote repository? – Maven](https://maven.apache.org/guides/getting-started/#How_do_I_deploy_my_jar_in_my_remote_repository.3F)

For deploying jars to an external repository, you have to configure the repository url in the `pom.xml` and the authentication information for connecting to the repository in the `settings.xml`.

setting.xml

```xml
<settings>
  <servers>
    <server>
      <id>maven-server-id</id>
      <username>username</username>
      <password>pwd</password>
    </server>
  </servers>

  <mirrors>
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>https://maven.example.com/repository/maven-group/</url>
    </mirror>
  </mirrors>

  <profiles>
    <profile>
      <id>maven-profile-id</id>
      <repositories>
        <repository>
          <id>maven-repository-id</id>
          <url>https://maven.example.com</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>
</settings>
```

project pom.xml

``` xml
<parent>
    <groupId>com.company</groupId>
    <artifactId>company-root-pom</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</parent>

<distributionManagement>
    <!-- use the following if you're not using a snapshot version. -->
    <repository>
        <id>maven-releases</id>
        <name>RepositoryProxy</name>
        <url>https://maven.example.com/repository/maven-releases/</url>
    </repository>
    <!-- use the following if you ARE using a snapshot version. -->
    <snapshotRepository>
        <id>maven-snapshots</id>
        <name>RepositoryProxySnap</name>
        <url>https://maven.example.com/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

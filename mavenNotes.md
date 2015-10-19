Maven常用命令:
create variable M2_REPO for workspace
	mvn eclipse:configure-workspace -Declipse.workspace=C:\workspace
首先通过cvs或svn下载代码到本机, 然后执行mvn eclipse:eclipse生成eclipse项目文件, 然后导入到eclipse就行了, 修改代码后执行mvn compile或mvn test检验, 也可以下载eclipse的maven插件. 
mvn archetype:create -DgroupId=packageName -DartifactId=projectName 创建Maven的普通java项目
	options include: -DarchetypeArtifactId=maven-archetype-webapp(创建Maven的Web项目), maven-archetype-j2ee-simple
mvn eclipse:eclipse (eclipse:clean, idea:idea)		create (clear) configuration files of eclipse (idea) project
	options include:
		-Dwtpversion=2.0 生成Wtp插件的web2.0项目e.g. mvn eclipse:eclipse -Dwtpversion=2.0
		-Declipse.workspace=C:\workspace 指明了eclipse的workspace, 这样如果发现依赖包也在workspace里就会进行项目依赖而不是jar包依赖
		-DdownloadSources  -DdownloadJavadocs (default value:-DdownloadSources=true -DdownloadJavadocs=true)
mvn clean清空生成的文件
mvn compile编译	mvn test-compile编译项目测试代码		mvn test编译并测试
mvn test -skipping compile -skipping test-compile	只测试而不编译, 也不测试编译(-skipping 的灵活运用, 当然也可以用于其他组合命令) 
mvn package  生成target目录, 编译、测试代码, 生成测试报告, 生成jar/war文件	mvn jar:jar	打jar包
mvn jetty:run 调用 Jetty插件的 Run目标在 Jetty Servlet容器中启动 web应用 mvn tomcat:run
mvn install 在本地Repository中安装jar	mvn clean install 删除再编译
mvn install:install-file -DgroupId=com.lowagie -DartifactId=itextasian -Dversion=1.0 -Dpackaging=jar -Dfile=c:\sp\doing\itextasian.jar
mvn site  生成项目相关信息的网站
mvn exec:java -Dexec.mainClass=org.sonatype.mavenbook.weather.Main Exec 插件让我们能够在不往classpath载入适当的依赖的情况下, 运行这个程序
mvn -Dtest=TestInsertWrongManage#testInsert test -pl moduleName  :run only single test in multi-module project

add a jar, source and Javadoc to the local/remote Maven repository
if want to download the sources jar the 2nd time, search and remove all "sources.jar-not-available"
	DEFAULT_PARAMETER=-DgroupId=com.auxilii.msgparser -DartifactId=msgparser -Dversion=1.10 -Dpackaging=jar -Dfile=C:/msgparser-1.10.jar
	mvn install:install-file ${DEFAULT_PARAMETER}
	mvn deploy:deploy-file ${DEFAULT_PARAMETER} -Durl=file://path/to/your/repository
		options: -Dclassifier add jar is the default value.	-Dclassifier=sources (add sources)		-Dclassifier=javadoc (add Java doc)

mvn -v	显示版本信息		-e 显示详细错误信息	-o	Work offline Running in Offline Mode
mvn verify	运行任何检查, 验证包是否有效且达到质量标准
mvn validate	验证工程是否正确, 所有需要的资源是否可用
mvn generate-sources	产生应用需要的任何额外的源代码, 如xdoclet
mvn hibernate3:hbm2ddl	使用Hibernate3插件构造数据库
mvn integration-test	在集成测试可以运行的环境中处理和发布包
mvn help:describe -Dfull 输出完整的带有参数的目标列
	-Dplugin=help 使用help插件的describe目标来输出Maven Help插件的信息
	-Dplugin=compiler -Dmojo=compile	列出了Compiler插件的compile目标的所有信息
	-Dplugin=exec	列出所有Maven exec插件可用的目标
mvn help:effective-pom see how all of the current project’s ancestor POMs are contributing to the effective POM.它暴露了 Maven的默认设置
mvn install -X 想要查看完整的依赖踪迹, 包含那些因为冲突或者其它原因而被拒绝引入的构件, 打开 Maven的调试标记运行
mvn install -Dmaven.test.skip=true 给任何目标添加maven.test.skip 属性就能跳过测试
mvn dependency:resolve 打印出已解决依赖的列表
mvn dependency:tree 打印整个依赖树
mvn dependency:list -e -U -X


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

configuration:
setting.xml change local reponsitory
  <localRepository>c:/sp/.m2/repository</localRepository>
pom.xml
1. configure build options <project><build>...</build></project>
	<!-- change build target path -->
	<build>
	   <outputDirectory>src/main/webapp/WEB-INF/classes</outputDirectory>
	   <testOutputDirectory>${basedir}/${target.dir}/test-classes</testOutputDirectory>
	</build>
2. configure build plugins <project><build><plugins>...</plugins></build></project>
	2.1	<!-- Attach Library Sources and Javadocs -->
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-eclipse-plugin</artifactId>
			<version>2.9</version>
			<configuration>
				<downloadSources>true</downloadSources>
				<downloadJavadocs>true</downloadJavadocs>
			</configuration>
		</plugin>
	2.2	<!-- Fix compiler version -->
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-compiler-plugin</artifactId>
			<configuration>
				<source>1.5</source>
				<target>1.5</target>
			</configuration>
		</plugin>

springside define version in parent/pom.xml <dependencyManagement>
那么经过验证，scope写在子项目中的<dependencies> 下的<dependency>中，或是写在父项目中的<dependencyManagement>中，都是可以的。
但有一点需要注意，dependencies 和 dependencyManagement 的区别在于：
前者，即使在子项目中不写该依赖项，那么子项目仍然会从父项目中继承该依赖项。
后者，如果在子项目中不写该依赖项，那么子项目中是不会从父项目继承该依赖项的；只有在子项目中写了该依赖项，才会从父项目中继承该项，并且version 和 scope 都读取自 父pom。
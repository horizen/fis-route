什么鸟
========

fis-route 旨在解决前端[fis](http://fex-team.github.io/fis3/)和后端[velocity](http://velocity.apache.org/)模板引擎之间如下问题：

1. 前后端部署依赖
	
2. 后端服务依赖tomcat

3. 后端既处理业务又承担模板引擎的功能
	

fis-route利用一个单独的tomcat把模板引擎从后端服务中剥离，利用ngx_lua做一个简单的路由分发


长啥样
========

route：ngx_lua路由层

velocity：模板引擎

[fis-route ppt介绍](https://github.com/horizen/fis-route/tree/master/doc/fis-route.key)

![fis-router原理图](https://github.com/horizen/fis-route/tree/master/doc/fis-route.jpg)

怎么用
==========

安装openresty
-----
[openresty英文](https://openresty.org/en/)

[openresty中文](https://openresty.org/cn/)

route
------

route配置项以json组织，相当于接口说明

1. 写配置(json)，放在conf/route/下

    *example.json:*

    ```
    {
        "fis_addrs":["127.0.0.1:8081"], //模板引擎地址
        "resource_path":"/var/www/static", //静态资源目录

        "server_name":"sample.com", //域名
        "server_port":"8000", //端口
        "server_prefix":"/test", //项目uri前缀
        "intra_allow_ips":["127.0.0.1"], //内部请求允许访问的ip, 以/test/intra为前缀的地址代表是ip限制的

		"index_page": "/page/index", //默认首页
		"error_page": "/error.html", //错误页
		
        //所有页面
        "page":{
            "/page/index":true, //需要模板数据
            "/page/test":false  //不需要模板数据
        },

        "https_only":"true|false",

        "https": {
            "port":"8443",
            "certificate":"", //证书
            "certificate_key":"" //证书私钥
        },
        
        "conf_predefine": "" //自定义nginx配置，对应server这级
    }
    ```

    *enable*

    **在conf/route/enable下增加一行example.json**


2. 生成配置文件 ./bin/build.sh example.json [有多个配置文件依次接在后面], 如果不愿一个一个写就用./bin/build.sh all

3. 重启nginx ./bin/nginx.sh start


velocity
--------
1. 进入velocity目录，mvn clean package打包

2. 将生成的war包拷贝到tomcat目录下

3. 配置tomcat/server.xml

   ```
   <Engine name="Catalina" defaultHost="localhost">
	
	//在Engine节点下增加如下Host配置
	<Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="false">
		<Context path="" docBase="fis-velocity/" reloadable="true" />
		
		<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="localhost_access_log." suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />

	</Host>
   </Engine>
   ```

4. 启动tomcat ./bin/catalina.sh start



fis
--------
模板按照 {project}/page/{vm} 或者{project}/page/{vm}/{subvm} 组织

jello release -r {project} -cmopd dev 发布代码

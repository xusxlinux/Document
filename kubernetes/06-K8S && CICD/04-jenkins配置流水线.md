jenkins构建保留的的天数,保留构建几个数据  
参数化构建 一  
app_name  -->  项目的名称，例：dubbo-demo-service  
参数化构建 二  
image_name  -->  docker镜像的名称，例：app/dubbo-service  
参数化构建 三  
git_repo  -->  项目所在的git中央仓库地址，例：git@github.com  
参数化构建 四  
git_version  -->  项目在git中央仓库所对应的，项目的分支或版本号  
参数化构建 五  
add_tag  -->  docker镜像标签的一部分，日期时间戳，例L：20200104_2312  
参数化构建 六  
mvn_dir  -->  ./  -->  编译项目的目录，默认为项目的根目录  
参数化构建 七  
target_dir  -->  ./target  -->  项目编译完成后，产生的jar/war包目录  
参数化构建 八  
mvn_cmd  -->  mvn clean package -e -q -Dmaven.test.skip=true  -->  执行编译所用的命令  
选择构建 九  
base_image  -->  base/jre8:8u112 或者 base/jre7:7u80  -->  项目使用的docker底包镜像  
选择构建 十  
maven  -->  3.6.1-8u232 或者 3.2.5-7u045 或者 2.2.1-6u025 -->  执行编译使用的maven软件版本  
```
Jenkins的工作目录
$ ls /data/nfs-volume/jenkins_home/workspace/dubbo-demo/dubbo-demo-service/
10  2  3  4  5  6  8  9
```

```pipeline
pipeline {
  agent any 
    stages {
      stage('pull') { //get project code from repo 
        steps {
          sh "git clone ${params.git_repo} ${params.app_name}/${env.BUILD_NUMBER} && cd ${params.app_name}/${env.BUILD_NUMBER} && git checkout ${params.git_version}"
        }
      }
      stage('build') { //exec mvn cmd
        steps {
          sh "cd ${params.app_name}/${env.BUILD_NUMBER}  && /var/jenkins_home/maven-${params.maven}/bin/${params.mvn_cmd}"
        }
      }
      stage('package') { //move jar file into project_dir
        steps {
          sh "cd ${params.app_name}/${env.BUILD_NUMBER} && cd ${params.target_dir} && mkdir project_dir && mv *.jar ./project_dir"
        }
      }
      stage('image') { //build image and push to registry
        steps {
          writeFile file: "${params.app_name}/${env.BUILD_NUMBER}/Dockerfile", text: """FROM harbor.od.com/${params.base_image}
ADD ${params.target_dir}/project_dir /opt/project_dir"""
          sh "cd  ${params.app_name}/${env.BUILD_NUMBER} && docker build -t harbor.od.com/${params.image_name}:${params.git_version}_${params.add_tag} . && docker push harbor.od.com/${params.image_name}:${params.git_version}_${params.add_tag}"
        }
      }
    }
}
```

```bash
#!/usr/bin/env bash
#作者: xusx
#时间: 2019/08/05
time=`date +%Y%m%d%H%M%S`
localdir="/usr/local/src/chain-rent-deploy"
backupdir="/usr/local/src/backup"
RED_COLOR='\E[0;31m'
GREEN_COLOR='\E[0;32m'
RESET='\E[0m'
function checkprc(){
    process=`ps aux | grep $1 | grep -v grep | awk '{print $2}'`
}
function copypkg(){
  cd $2
  \cp $2/$pkg ${backupdir}/$pkg.$time
  \cp ${localdir}/$1 $2/
  echo -e "拷包 $1 完成"
}
function deployto(){
  checkprc $1
  copypkg $1 $2
  if [[ $1 == chain-bigdata-bi-0.0.1-SNAPSHOT.jar ]];then
    kill -9 $process
    nohup /usr/java/jdk1.8.0_201/bin/java -jar $1  --spring.profiles.active=pro >> /dev/null 2>&1 &
  elif [[ $1 == collect-service-1.0-SNAPSHOT.jar ]];then
    kill -9 $process
    nohup /usr/java/jdk1.8.0_201/bin/java -Denv=prd.yml -jar $1 --spring.profiles.active=prd >> /dev/null 2>&1 &
  else
    exit 0
  fi
  checklive $1
}
function checklive(){
# 该函数检测进程
  checkprc $1
  if [ $process != " " ];then
     sleep 5
     echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')][$$]: ${GREEN_COLOR}[info]${RESET} $process 程序启动成功" >&2
  else
     echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')][$$]: ${RED_COLOR}[error]${RESET} $process 程序启动失败" >&2
  fi
}
function selectact(){
# jar启动使用函数 deployto
# jar包拷包以及备份使用 copypkg
case $1 in 
	bigdata-bi)	        pkg="chain-bigdata-bi-0.0.1-SNAPSHOT.jar"
			        dir="/mnt/software/jars"
			        deployto "$pkg" "$dir";;
        bigdata-collect)        pkg="collect-service-1.0-SNAPSHOT.jar"
                                dir="/mnt/software/jars"
                                deployto "$pkg" "$dir";;
	phoenix-etl)	        pkg="phoenix-etl-1.0-SNAPSHOT.jar"
			        dir="/mnt/software/jars"
			        copypkg "$pkg" "$dir";;
	spark-etl)	        pkg="spark-etl-1.0-SNAPSHOT.jar"
			        dir="/mnt/software/jars"
			        copypkg "$pkg" "$dir";;
	es-etl)	                pkg="es-etl-1.0-SNAPSHOT.jar"
			        dir="/mnt/software/jars"
			        copypkg "$pkg" "$dir";;
esac
}
selectact $1
```

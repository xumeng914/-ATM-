#Copyright @Hangzhou Yatop Co.Ltd.
#All Right Reserved
#author:XM
#date:20170322



export HADOOP_CLIENT_OPTS="-Djline.terminal=jline.UnsupportedTerminal"
export ETCDIR=/etl/etldata/script/conf

function getDBPAR()
{
    IP=`grep -w "IP" ${ETCDIR}/dbup.ini|awk -F= '{print$2}'`
    PORT=`grep -w "PORT" ${ETCDIR}/dbup.ini|awk -F= '{print$2}'`
    DBNAME=`grep -w "DBNAME" ${ETCDIR}/dbup.ini|awk -F= '{print$2}'`
    DBUSER=`grep -w  "DBUSER" ${ETCDIR}/dbup.ini|awk -F= '{print$2}'`
    DBPASSWD=`grep -w "DBPASSWD" ${ETCDIR}/dbup.ini|awk -F= '{print$2}'`
    return 0
}

function connectDB()
{
    [ ! -f ${ETCDIR}/dbup.ini ] && echo "配置文件不存在" && exit -1
    getDBPAR
    [ "${IP}" == "" ] && echo "参数配置错误" && exit -1
    [ "${PORT}" == "" ] && echo "参数配置错误" && exit -1
    [ "${DBNAME}" == "" ] && echo "参数配置错误" && exit -1
    #[ "${DBUSER}" == "" ] && echo "参数配置错误" && exit -1
    #[ "${DBPASSWD}" == "" ] && echo "参数配置错误" && exit -1
    TDH="beeline -u \"jdbc:hive2://${IP}:${PORT}/${DBNAME}\" "
    return 0
}



[ $# -ne 1 ] && echo "输入参数个数错误 Usage:$0 today " && exit -1
today=$1

YY=`expr substr ${today} 1 4`
MM=`expr substr ${today} 5 2`
DD=`expr substr ${today} 7 2`

MM_END=`cal ${MM} ${YY}|xargs|awk '{print $NF}'`

if [ "${DD}" != "${MM_END}" ];then
  echo "当前批量日期 ${today} 不是月底,程序正常退出"
  exit 0
fi



connectDB
[ $? -ne 0 ] && echo "数据库连接错误" && exit -1



indir=/etl/etldata/script/R
outdir=/etl/etldata/output/${today}/ATM


[ -d ${outdir} ] && rm -rf ${outdir}
[ ! -d /etl/etldata/output/${today} ] && mkdir -p /etl/etldata/output/${today}
mkdir -p ${outdir}
 echo "#########  创建结果路径成功 ${outdir} #########"

 logdir=/etl/etldata/log/msg/${today}/R
[ ! -d ${logdir} ] && mkdir -p ${logdir}
echo "#########  创建日志路径成功 ${logdir} #########"


Rscript --slave ${indir}/ATM.R ${today} ${IP} ${PORT} ${DBNAME} ${DBUSER} ${DBPASSWD} >${logdir}/ATM.log



[ $? -ne 0 ] && echo "######### 聚类模型失败，请查看日志 ${logdir}/ATM.log#########" && exit -1



echo "######### 聚类模型成功，请在路径 ${outdir} 下查看生成的文件  #########"

exit 0

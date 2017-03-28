# -ATM-
瑞丰银行ATM机项目

*Copyright @Hangzhou Yatop Co.Ltd.*
*All Right Reserved*
*author:XM*
*date:20170327*

##说明

本压缩包包含5个文件：
1.crt_MODEL_ATM_BIZ_INFO.ddl ：ATM模型输出之一表MODEL_ATM_BIZ_INFO的表结构
2.宽表部分字段取数SQL.sql ：宽表部分字段取数SQL
3.crt_sp_model_atm_biz_info.ddl ：表MODEL_ATM_BIZ_INFO的存储过程
4.ATM.R ：生成聚类图，及聚类文件的R脚本
5.R_ATM_model.sh ：调起R脚本的shell语句


##操作说明

0.先用crt_MODEL_ATM_BIZ_INFO.ddl创建表MODEL_ATM_BIZ_INFO
1.上传 crt_SP_MODEL_ATM_BIZ_INFO.ddl 至路径 /etl/etldata/script/tdhproc
2.上传 ATM.R 至路径 /etl/etldata/script/R
3.上传 R_ATM_model.sh 至路径 /etl/etldata/script

>cd /etl/etldata/script
>chmod +x *.sh

>cd /etl/etldata/script/R
>chmod +x *.R

###创建存储过程

>beeline -u "jdbc:hive2://155.101.252.127:10000/bdpdb" -f /etl/etldata/script/tdhproc/crt_SP_MODEL_ATM_BIZ_INFO.ddl

###运行存储过程

>/etl/etldata/script/call_sp.sh 20161130 3999999 SP_MODEL_ATM_BIZ_INFO

###用shell调起R得到聚类结果

>/etl/etldata/script/R_ATM_model.sh 20161130

###查看生成结果

>cat /etl/etldata/output/20161130/ATM/atm.csv 
>cat /etl/etldata/output/20161130/ATM/atm_1.png
>cat /etl/etldata/output/20161130/ATM/atm_2.png

###查看日志文件

>cat /etl/etldata/log/msg/20161130/R/ATM.log



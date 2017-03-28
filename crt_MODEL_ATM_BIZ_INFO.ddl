CREATE DATABASE IF NOT EXISTS bdpdb;
USE bdpdb;
DROP TABLE MODEL_ATM_BIZ_INFO;
CREATE TABLE IF NOT EXISTS MODEL_ATM_BIZ_INFO (
            STAT_MTH VARCHAR(10) comment "统计月份",
            ATM_NO VARCHAR(10) comment "设备编号",
            ATM_NAME VARCHAR(32) comment "设备网点名称",
            ORG_NO VARCHAR(10) comment "归属网点号",
            ORG_NAME VARCHAR(32) comment "归属网点",
            BRANCH_NO VARCHAR(10) comment "归属支行号",
            BRANCH_NAME VARCHAR(32) comment "归属支行",
            ADDRESS VARCHAR(32) comment "设备地址",
            ATM_BRAND VARCHAR(33) comment "设备品牌",
            ATM_TYPE VARCHAR(1) comment "设备机型：1，一体机；2，取款机",
            PLACE_TYPE VARCHAR(1) comment "布放方式：1，附行式；2，离行式",
            RENT DECIMAL(15,2) comment "租金:元/台月,离行式按台数摊，附行式每台4平米",
            FEE_DEPRE_MTH DECIMAL(15,2) comment "折旧费：元/台月",
            FEE_REPAIR DECIMAL(15,2) comment "维保费：元/台月",
            FEE_TRAFFIC DECIMAL(15,2) comment "押运费：元/台月",
            CNT_TOTAL INTEGER comment "总笔数",
            AMT_QX DECIMAL(15,2) comment "月取现金额",
            CNT_QX INTEGER comment "月取现笔数",
            AMT_CX DECIMAL(15,2) comment "月存现金额",
            CNT_CX INTEGER comment "月存现笔数",
            AMT_ZZ DECIMAL(15,2) comment "月转账金额",
            CNT_ZZ INTEGER comment "月转账笔数",
            AMT_QX_BDT DECIMAL(15,2) comment "月本代他取现金额",
            CNT_QX_BDT INTEGER comment "月本代他取现笔数",
            AMT_ZZ_BDT DECIMAL(15,2) comment "月本代他转账金额",
            CNT_ZZ_BDT INTEGER comment "月本代他转账笔数",
            DAYS_TOTALAVG INTEGER comment "月运营天数:大于每种机型日均笔数的天数",
            DAYS_WORK INTEGER comment "月运营天数:交易天数",
            DAYS_SELFAVG INTEGER comment "月运营天数:大于自身日均笔数天数",
            UPDATE_DT DATE comment "更新日期"
) comment "ATM运营分析数据表"
CLUSTERED BY (ATM_NO) INTO 11 BUCKETS
STORED AS ORC
TBLPROPERTIES ("transactional"="true");




























































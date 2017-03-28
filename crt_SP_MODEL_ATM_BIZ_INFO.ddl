set plsql.client.dialect=oracle;
set plsql.server.dialect=oracle;
SET transaction.type = inceptor;
set plsql.show.sqlresults=true;
SET plsql.catch.hive.exception=true;
!set plsqlUseSlash true

create or replace procedure SP_MODEL_ATM_BIZ_INFO( v_today STRING,v_job_seq_id STRING,ret out int)
is
 dbname STRING
 v_code INT
 v_errm STRING
 NBR_1 INT
 NBR_0 INT
 mth_num INT
nextDat DATE;
dat STRING;
num1 int ;
num2 int ;
n1 int ;
n2 int ;
n3 int ;


 







begin
begin transaction 
 ret:=-1;
 		nextDat := date(v_today)  + INTERVAL '1' DAY;
        dat := substr(nextDat,9,2)
        IF dat != '01' THEN
              put_line("这个作业不需要在今天跑批 "||current_date())
   		ret:=0;
              RETURN
        END IF;
 v_code:=0;
 mth_num:= substr(v_today,7,2);
 


-- ------------------------------------------------------------------------------------------------------



    select count(1) into n1 from BDPDB.sdi_m_data_input_atm_base_info ;
        IF n1 = 0 THEN
              put_line(current_time()||"sdi_m_data_input_atm_base_info中没有数据")
              RETURN
        END IF ;
    select count(1) into n2 from BDPDB.SDI_F_CORE_BWFMATMD;
        IF n2 = 0 THEN
              put_line(current_time()||"SDI_F_CORE_BWFMATMD中没有数据")
              RETURN
        END IF ;
    
	select count(1) into n3 from BDPDB.model_atm_biz_info where stat_mth=substr(v_today,1,6);
        IF n3 > 0 THEN
		      DELETE FROM bdpdb.model_atm_biz_info WHERE stat_mth=substr(v_today,1,6)
              put_line(current_time()||" :delete bdpdb.model_atm_biz_info DATA  susseed")
              
        END IF ;
		
--------------------------------------------------------------------------------------------------------------------
 v_code:=1;

WITH idv_ATM_All AS (
 SELECT
  X.BJ36NO08,  --ATM机设备编号
  SUM(NBR_TOTAL_D) NBR_TOTAL, ----该ATM机交易总笔数，汇总到月
  SUM(AMT_QX_D) AMT_QX, --该ATM机取现交易总金额，汇总到月
  SUM(NBR_QX_D) NBR_QX, --该ATM机取现交易总笔数，汇总到月
  SUM(AMT_CX_D) AMT_CX, --该ATM机存现交易总金额，汇总到月
  SUM(NBR_CX_D) NBR_CX, --该ATM机存现交易总笔数，汇总到月
  SUM(AMT_ZZ_D) AMT_ZZ, --该ATM机转账交易总金额，汇总到月
  SUM(NBR_ZZ_D) NBR_ZZ, --该ATM机转账交易总笔数，汇总到月
  SUM(AMT_QX_BDT_D) AMT_QX_BDT, --该ATM机本代他取现交易总金额，汇总到月
  SUM(NBR_QX_BDT_D) NBR_QX_BDT, --该ATM机本代他取现交易总笔数，汇总到月
  SUM(AMT_ZZ_BDT_D) AMT_ZZ_BDT, --该ATM机本代他转账交易总金额，汇总到月
  SUM(NBR_ZZ_BDT_D) NBR_ZZ_BDT,--该ATM机本代他转账交易总笔数，汇总到月
  SUM(CASE WHEN NBR_TOTAL_D>NBR_TYPE THEN 1 ELSE 0 END) DAYS_TOTALAVG, --该ATM机交易笔数大于同机型当月每台每天交易笔数的天数，即大于同机型平均水平的天数
  COUNT(BJ01DATE) DAYS_WORK,--该ATM机当月有交易天数
  SUM(CASE WHEN NBR_TOTAL_D>NBR_AVG_SELF THEN 1 ELSE 0 END) DAYS_SELFAVG --该ATM机交易笔数大于自身当月每天交易笔数的天数

FROM
(
  SELECT
    A.BJ36NO08, --ATM机设备编号
	BJ01DATE, --交易日期
	ATM_TYPE, --ATM机设备机型，1一体机，2取款机
	COUNT(1) NBR_TOTAL_D,--该ATM机交易总笔数，汇总到天
    SUM(CASE WHEN B.TXTPINVT='3' THEN B.TAMTAMT END) AS AMT_QX_D, --该ATM机取现交易总金额，汇总到天
    COUNT(CASE WHEN B.TXTPINVT='3' THEN B.TAMTAMT END) AS NBR_QX_D,--该ATM机取现交易总笔数，汇总到天
    SUM(CASE WHEN B.TXTPINVT='4' THEN B.TAMTAMT END) AS AMT_CX_D,--该ATM机存现交易总金额，汇总到天
    COUNT(CASE WHEN B.TXTPINVT='4' THEN B.TAMTAMT END) AS NBR_CX_D,--该ATM机存现交易总笔数，汇总到天
    SUM(CASE WHEN A.BJ20FLAG='2' THEN A.BJ16AMT END) AS AMT_ZZ_D,--该ATM机转账交易总金额，汇总到天
    COUNT(CASE WHEN A.BJ20FLAG='2' THEN A.BJ16AMT END) AS NBR_ZZ_D,--该ATM机转账交易总笔数，汇总到天
    SUM(CASE WHEN (B.TXTPINVT='3' AND A.BJ17CDFG='2') THEN A.BJ16AMT END) AS AMT_QX_BDT_D, --该ATM机本代他取现交易总金额，汇总到天
    COUNT(CASE WHEN (B.TXTPINVT='3' AND A.BJ17CDFG='2') THEN A.BJ16AMT END) AS NBR_QX_BDT_D,--该ATM机本代他取现交易总笔数，汇总到天
    SUM(CASE WHEN (A.BJ20FLAG='2' AND A.BJ17CDFG='2') THEN A.BJ16AMT END) AS AMT_ZZ_BDT_D,--该ATM机本代他转账交易总金额，汇总到天
    COUNT(CASE WHEN (A.BJ20FLAG='2' AND A.BJ17CDFG='2') THEN A.BJ16AMT END) AS NBR_ZZ_BDT_D--该ATM机本代他转账交易总笔数，汇总到天
  FROM 
  (
    SELECT * FROM bdpdb.SDI_F_CORE_BDFMHQBJ
    WHERE SUBSTR(BJ01DATE,1,6)=substr(v_today,1,6)
      AND BJ19JYLX='1' --正常交易
      AND TRIM(RCSTRS1B)=''--记录状态未删除
      AND END_DATE='99990101'   
    AND BJ36NO08 IN 
    (
      SELECT DISTINCT ATMNNO08 FROM bdpdb.SDI_F_CORE_BWFMATMB
      WHERE TRIM(RCSTRS1B)='' AND END_DATE='99990101'
          )
  ) A
  LEFT JOIN 
  (
    SELECT * FROM bdpdb.SDI_F_CORE_BWFMATMD 
    WHERE SUBSTR(TXDTDATE,1,6)=substr(v_today,1,6)
      AND TRIM(RCSTRS1B)=''
      AND END_DATE='99990101'
   ) B ON A.BJ01DATE = B.TXDTDATE AND A.BJ06TXSN = B.LPTNTXSN --以交易日期和流水号关联
   LEFT JOIN bdpdb.SDI_M_DATA_INPUT_ATM_BASE_INFO C ON C.ATM_NO = A.BJ36NO08
  GROUP BY A.BJ36NO08, BJ01DATE, ATM_TYPE
) X
LEFT JOIN
(
  SELECT ATM_TYPE, COUNT(1)/COUNT(DISTINCT BJ36NO08)/mth_num NBR_TYPE --同一机型ATM机平均每台每天交易笔数
    FROM 
  (
    SELECT * FROM bdpdb.SDI_F_CORE_BDFMHQBJ
    WHERE SUBSTR(BJ01DATE,1,6)=substr(v_today,1,6)
      AND BJ19JYLX='1' 
      AND TRIM(RCSTRS1B)=''
      AND END_DATE='99990101'   
    AND BJ36NO08 IN 
    (
      SELECT DISTINCT ATMNNO08 FROM bdpdb.SDI_F_CORE_BWFMATMB
      WHERE TRIM(RCSTRS1B)='' AND END_DATE='99990101'
          )
  ) A
   LEFT JOIN bdpdb.SDI_M_DATA_INPUT_ATM_BASE_INFO B ON B.ATM_NO = A.BJ36NO08
   GROUP BY ATM_TYPE
 ) Y ON Y.ATM_TYPE = X.ATM_TYPE
 LEFT JOIN
 (
  SELECT BJ36NO08, COUNT(1)/mth_num NBR_AVG_SELF --同一ATM机平均每台每天交易笔数
    FROM 
  (
    SELECT * FROM bdpdb.SDI_F_CORE_BDFMHQBJ
    WHERE SUBSTR(BJ01DATE,1,6)=substr(v_today,1,6)
      AND BJ19JYLX='1' 
      AND TRIM(RCSTRS1B)=''
      AND END_DATE='99990101'   
    AND BJ36NO08 IN 
    (
      SELECT DISTINCT ATMNNO08 FROM bdpdb.SDI_F_CORE_BWFMATMB
      WHERE TRIM(RCSTRS1B)='' AND END_DATE='99990101'
          )
    )
    GROUP BY BJ36NO08
) Z ON Z.BJ36NO08 = X.BJ36NO08
GROUP BY X.BJ36NO08

),



idv_ATM_All_baseinfo AS (
select * from 
idv_ATM_All U
left join 
(select *, MONTHS_BETWEEN(substr(v_today,1,6),substr(buy_time,1,6))- depre_mth as mth_diff 
--(substr(v_today,1,4) - substr(buy_time,1,4))*12 + substr(v_today,5,2) - substr(buy_time,5,2) - depre_mth as mth_diff 
 from BDPDB.sdi_m_data_input_atm_base_info) V
on U.bj36no08=V.atm_no
) 


 
INSERT  into TABLE bdpdb.model_atm_biz_info
select 
substr(v_today,1,6) AS STAT_MTH,
ATM_NO,
ATM_NAME,
ORG_NO,
ORG_NAME,
BRANCH_NO,
BRANCH_NAME,
ADDRESS,
ATM_BRAND,
ATM_TYPE,
PLACE_TYPE,
RENT,
(case when mth_diff>=0 then '0' when mth_diff<0 then price/depre_mth end) AS FEE_DEPRE_MTH,
FEE_REPAIR,
FEE_TRAFFIC,
nbr_total as CNT_TOTAL,
AMT_QX,
nbr_qx as CNT_QX,
AMT_CX,
nbr_cx as CNT_CX,
AMT_ZZ,
nbr_zz as CNT_ZZ,
AMT_QX_BDT,
nbr_qx_bdt as CNT_QX_BDT,
AMT_ZZ_BDT,
nbr_zz_bdt as CNT_ZZ_BDT,
DAYS_TOTALAVG,
DAYS_WORK,
DAYS_SELFAVG,
v_today AS UPDATE_DT
from idv_ATM_All_baseinfo ;






put_line(current_time()||" : insert bdpdb.model_atm_biz_info succees;"); 
v_code:=2;
commit;
ret:=0;
put_line(current_time()||" :executed bdpdb.model_atm_biz_info procedure succeed ;");
exception
when others then 
  v_errm := case
  when v_code = 0 then " : prophase data prepare failed ;"
  when v_code = 1 then " : insert bdpdb.model_atm_biz_info failed ;"
  end;
  put_line(current_time()||" :v_errm");
  put_line(current_time()||" :executed bdpdb.model_atm_biz_info procedure failed ;");
  ret:=-1;
  rollback;
end;


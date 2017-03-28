#Copyright @Hangzhou Yatop Co.Ltd.
#All Right Reserved
#author:XM
#date:20170322
start_time <- Sys.time()
cat(paste(start_time,"开始执行程序：ATM.R",sep = "***"),"\n")


cat(paste(Sys.time(),"开始载入数据库配置所需参数...",sep = "***"),"\n")
kArgs <- commandArgs(TRUE)
ktoday <- kArgs[1]
kIP <- kArgs[2]
kport <- kArgs[3]
kdbname <- kArgs[4]
kdbuser <- kArgs[5]
kdbpasswd <- kArgs[6]
pathout <- paste("/etl/etldata/output/",ktoday,"/ATM",sep="")
cat(paste(Sys.time(),"成功载入数据库配置所需参数：",sep = "***"),kArgs,"\n")


cat(paste(Sys.time(),"开始建立数据库连接...预计耗时 80 seconds",sep = "***"),"\n")
sc<-discover.init() 
sqlCon <- txSqlConnect(host = paste(kIP,":",kport, sep = ""), user = kdbuser, 
                       passwd =kdbpasswd, dbName = kdbname)
cat(paste(Sys.time(),"成功建立数据库连接",sep = "***"),"\n")


cat(paste(Sys.time(),"开始载入模型所需数据...预计耗时 80 seconds",sep = "***"),"\n")
All_table <- txSqlQuery(sqlConnection = sqlCon, query = paste( "SELECT 
ATM_NO,
atm_type,
amt_qx,
cnt_qx,
amt_cx,
cnt_cx,
amt_zz,
cnt_zz,
amt_qx_bdt,
cnt_qx_bdt,
amt_zz_bdt,
cnt_zz_bdt,
days_totalavg,
rent,
fee_repair,
fee_traffic,
fee_depre_mth
FROM ",kdbname,".model_atm_biz_info where stat_mth=",substr(ktoday,1,6),
      sep="") )


All <- txCollect(All_table)
All[is.na(All)] <- 0
All <- subset(All, All$cnt_cx+All$cnt_qx+All$cnt_zz+All$cnt_qx_bdt+All$cnt_zz_bdt!=0)
cat(paste(Sys.time(),"模型所需数据载入成功",sep = "***"),"\n")
##########################一体机:人工定义权重+聚类##########################
cat(paste(Sys.time(),"开始对一体机进行聚类",sep = "***"),"\n")

atm_1 <- All[All$atm_type==1,]

atm_1$profit <- 0.10*scale(atm_1$amt_qx)+0.10*scale(atm_1$cnt_qx)+
  0.09*scale(atm_1$amt_cx)+0.09*scale(atm_1$cnt_cx)+
  0.08*scale(atm_1$amt_zz)+0.10*scale(atm_1$cnt_zz)+
  0.10*scale(atm_1$amt_qx_bdt)+0.10*scale(atm_1$cnt_qx_bdt)+
  0.05*scale(atm_1$amt_zz_bdt)+0.09*scale(atm_1$cnt_zz_bdt)+
  0.09*scale(atm_1$days_totalavg)
atm_1$cost<-0.20*scale(atm_1$rent)+0.29*scale(atm_1$fee_repair)+0.22*scale(atm_1$fee_traffic)+0.30*scale(atm_1$fee_depre_mth)


profit_min <- min(atm_1$profit)
profit_max <- max(atm_1$profit)
cost_min <- min(atm_1$cost)
cost_max <- max(atm_1$cost)
###聚类###

p_c_1 <- c(which(colnames(atm_1)=='profit'),which(colnames(atm_1)=='cost'))
k_1<-kmeans(atm_1[,p_c_1], 
            centers = matrix(c(profit_min,cost_min,profit_max,cost_min,profit_min,cost_max,profit_max,cost_max),nrow =4,byrow = T) , 
            iter.max = 1000)

png(paste(pathout,"/ATM_1.png",sep = ""))
plot(atm_1[,p_c_1],pch=18,col=k_1$cluster,xaxt="n",yaxt="n",xlab='效能',ylab = '成本',main = '存取款一体机聚类分布图')
text(k_1$centers[,1],k_1$centers[,2],paste('第',c(1:4),"类"))
dev.off()

atm_1$k <- k_1$cluster

cat(paste(Sys.time(),"***一体机聚类成功，图片输出至路径",pathout,"/ATM_1.png",sep = ""),"\n")

##########################取款机:人工定义权重+聚类##########################
cat(paste(Sys.time(),"开始对取款机进行聚类",sep = "***"),"\n")
atm_2 <- All[All$atm_type==2,]

atm_2$profit<-0.12*scale(atm_2$amt_qx)+0.12*scale(atm_2$cnt_qx)+
  0.10*scale(atm_2$amt_zz)+0.12*scale(atm_2$cnt_zz)+
  0.12*scale(atm_2$amt_qx_bdt)+0.12*scale(atm_2$cnt_qx_bdt)+
  0.08*scale(atm_2$amt_zz_bdt)+0.11*scale(atm_2$cnt_zz_bdt)+
  0.11*scale(atm_2$days_totalavg)
atm_2$cost<-0.09*scale(atm_2$rent)+0.36*scale(atm_2$fee_repair)+
  0.17*scale(atm_2$fee_traffic)+0.38*scale(atm_2$fee_depre_mth)


profit_min <- min(atm_2$profit)
profit_max <- max(atm_2$profit)
cost_min <- min(atm_2$cost)
cost_max <- max(atm_2$cost)


p_c_2 <-  c(which(colnames(atm_2)=='profit'),which(colnames(atm_2)=='cost'))
k_0<-kmeans(atm_2[,p_c_2], 
            centers = matrix(c(profit_min,cost_min,profit_max,cost_min,profit_min,cost_max,profit_max,cost_max),nrow =4,byrow = T) , 
            iter.max = 1000)

png(paste(pathout,"/ATM_2.png",sep = ""))
plot(atm_2[,p_c_2],pch=18,col=k_0$cluster,xaxt="n",yaxt="n",xlab='效能',ylab = '成本',main='取款机聚类分布图')
text(k_0$centers[,1],k_0$centers[,2],paste('第',c(1:4),"类"))
dev.off()

atm_2$k <- k_0$cluster
cat(paste(Sys.time(),"***取款机聚类成功，图片输出至路径",pathout,"/ATM_2.png",sep = ""),"\n")

####################################################################

atm_All <- rbind(atm_1[,c(1,2,18,19,20)],atm_2[,c(1,2,18,19,20)])
write.table(atm_All, paste( pathout,"/atm.csv",sep=""),
            row.names = FALSE,col.names = TRUE, quote = FALSE,sep=",")

cat(paste(Sys.time(),"***成功导出聚类标签，保存至路径",pathout,"/atm.csv",sep = ""),"\n")
### 第3类是最差的ATM机，效能低，成本高


sc$stop()
rm(list=ls())
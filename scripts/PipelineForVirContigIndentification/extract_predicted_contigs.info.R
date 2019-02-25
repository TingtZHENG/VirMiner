args<-commandArgs(TRUE)
library(randomForest)


test_set<-read.table(args[1],header=TRUE,sep='\t',quote="")

prefix=sub(".POG2016.contig.depth.length.mVC.KO.Pfam.viral_hallmark.summary.final.txt","",args[1])

set.seed(1234)

load("../../database/rf_model.used_for_webserver.Rdata")

pred=predict(rf,test_set[,2:12])

pred.matrix=as.matrix(pred)

pred.rowname=rownames(pred.matrix)

test_sample_add_predict_label=cbind(test_set[pred.rowname,],pred.matrix[pred.rowname,])

predicted_viral_contig=test_sample_add_predict_label[test_sample_add_predict_label[,13]=="Viral_contig",]

write.table(predicted_viral_contig,file=paste(prefix,"predicted_viral_contig_info.txt",sep="."),quote=FALSE,sep="\t",row.name=FALSE)


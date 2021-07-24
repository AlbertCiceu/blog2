require(spatstat)
require(reshape2)
require(dplyr)
# install.packages("spatstat.geom")
data("spruces")
data("waka")
data(longleaf)
if(require(spatstat.geom)) {
  plot(longleaf)
  plot(cut(longleaf, breaks=c(0,30,Inf), labels=c("Sapling","Adult")))
}

hist(longleaf[["marks"]])
sqrt(sum(longleaf[["marks"]]^2)/length(longleaf[["marks"]]))
x<-(sample(longleaf[["marks"]],10))
x[order(x)][6]
divide <-quadrats(longleaf,3,3)
plot(divide)


nndist(longleaf,k = 10)
q<-quadratresample(longleaf, 6, 3)
plot(q)


qmd<-function(x){sqrt(sum(x^2)/length(x))}


meanmarkstable <- as.data.frame(apply((markstat (longleaf, fun=print,N=10)),2,sort))
qmd_df<-melt(meanmarkstable[8,])
mean(qmd_df$value)

sqrt(sum(waka[["marks"]]^2)/length(waka[["marks"]]))
meanmarkstable <- as.data.frame(apply((markstat (waka, fun=print,N=10)),2,sort))
qmd_df<-melt(meanmarkstable[7,])
mean(qmd_df$value)
?waka
?spruces
spruces[["marks"]]<-spruces[["marks"]]*100


sqrt(sum(spruces[["marks"]]^2)/length(spruces[["marks"]]))
meanmarkstable <- as.data.frame(apply((markstat (spruces, fun=print,N=10)),2,sort))
qmd_df<-melt(meanmarkstable[6,])
mean(qmd_df$value)

require(lmfor)
data("spati")
?spati
unique(spati$Y)
spati$area<-spati$X*spati$Y
unique(spati$area)/10000
# spati<-spati %>% group_by(plot) %>% mutate(n=n()) %>% filter(n>=100)
set.seed(1)
hist(rnorm(100,25,5))
quantile(rnorm(100,25,5), 0.6)
sqrt((sum(rnorm(100,25,5)^2)/length(rnorm(100,25,5))))

quantile(spati$d[spati$plot==2], 0.55)
sqrt((sum(spati$d[spati$plot==2]^2)/length(spati$d[spati$plot==2])))

plot(spati$xk[spati$plot==1],spati$yk[spati$plot==1])
X <- ppp(spati$xk[spati$plot==1], spati$yk[spati$plot==1], window=owin(c(0,400),c(0,300)),marks = spati$d[spati$plot==1])
sqrt(sum(X[["marks"]]^2)/length(X[["marks"]]))
meanmarkstable <- as.data.frame(apply((markstat (X, fun=print,N=10)),2,sort))
qmd_df<-melt(meanmarkstable[6,])
mean(qmd_df$value)

length(unique(spati$plot))
i<-66
for (i in 1:length(unique(spati$plot))){
  pl<-unique(spati$plot)[i]
  X <- ppp(spati$xk[spati$plot==pl], spati$yk[spati$plot==pl], window=owin(c(0,spati$X[spati$plot==pl][1]),c(0,spati$X[spati$plot==pl][1])),marks = spati$d[spati$plot==pl])
  meanmarkstable <- as.data.frame(apply((markstat (X, fun=print,N=10)),2,sort))
  # meanmarkstable<-meanmarkstable[complete.cases(meanmarkstable)]
  meanmarkstable$n<-seq(1,10,1)
  meanmarkstable<-reshape2::melt(meanmarkstable, id=c("n"))
  meanmarkstable$plot<-pl
  assign(paste("plot_",pl, sep=""),meanmarkstable)
}

weisse_data<-do.call(rbind.data.frame,mget(ls(pattern = "plot")))
require(dplyr)

weisse_data<-weisse_data %>% group_by(plot,n) %>% summarise(dg=mean(value)) 
weisse_data60<-weisse_data %>% filter(n %in% c(3,9)) %>% group_by(plot) %>% summarise(n=9,dg=mean(dg)) 
weisse_data<-rbind.data.frame(weisse_data,weisse_data60)

spati_filt<-spati %>% group_by(plot) %>% summarise(Dg=sqrt(sum(d^2)/n()))

weisse<-left_join(weisse_data, spati_filt )
weisse$dif<-abs(weisse$dg-weisse$Dg)
weisse<-weisse %>% group_by(plot) %>% mutate(min= min(dif)) %>% filter(dif==min)
require(ggplot2)
ggplot(weisse, aes(n))+
  geom_histogram()

ggplot(weisse, aes(factor(n), dif, group=n,fill=factor(n)))+
  geom_boxplot()

spati[spati$plot %in% c(weisse$plot[weisse$n==9]),] %>%
  ggplot(aes(d))+
  geom_density()+
  # geom_smooth(method = "loess")+
  facet_wrap(~plot, scales="free")

spati[spati$plot %in% c(weisse$plot[weisse$n==6]),] %>%
  ggplot(aes(d))+
  geom_density()+
  facet_wrap(~plot, scales="free")

spati[spati$plot %in% c(weisse$plot[weisse$n==7]),] %>%
  ggplot(aes(d))+
  geom_density()+
  facet_wrap(~plot, scales="free")

spati[spati$plot %in% c(weisse$plot[weisse$n==8]),] %>%
  ggplot(aes(d))+
  geom_density()+
  facet_wrap(~plot, scales="free")

spati6<-spati[spati$plot %in% c(weisse$plot[weisse$n==8]),]

out<-data.frame(matrix(nrow = length(unique(spati6$plot)),ncol=2))
for (i in seq_along(unique(spati6$plot))){
  out$X1[i]<-unique(spati6$plot)[i]
  a<-(shapiro.test(spati$d[spati$plot %in% c(unique(spati6$plot)[i])]))
  out$X2[i]<-a[["p.value"]]
}
class(out$X2)
out$X2<-round(out$X2,4)
warnings()
class(a[["p.value"]])

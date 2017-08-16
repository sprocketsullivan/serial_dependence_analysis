######
#analysis serial dependence colour and luminosity
######
library(tidyverse)
library(nlstools)
library(openxlsx)
####
#read in data from raw data
####
cur.dir<-getwd()
raw.dir<-paste(cur.dir,"/rawdataluminosity/",sep="")
read.data<-NULL
files<-dir(raw.dir)
pp.id<-as.numeric(stringr::str_extract(files,pattern = "^\\d\\d"))
for ( i in 1:length(files)){
  helper<-read.xlsx(paste(raw.dir,files[i],sep=""),1)
  helper$id<-pp.id[i]
  read.data<-rbind(read.data,helper)
}
read.data<-read.data[-which(is.na(read.data$condition)),]
my.data<-data.frame(with(read.data,cbind(as.numeric(lower_end),as.numeric(trial_value),as.numeric(condition),as.numeric(Mouse2.x_raw),as.numeric(id))))
names(my.data)<-c("le","trial_value","condition","mouse.pos","id")
my.data$mouse.pos.new<-my.data$mouse.pos+13.33
my.data$choice<-(my.data$mouse.pos.new/26.66)*30+my.data$le
my.data$deviation<-my.data$choice-my.data$trial_value
my.data<-
  my.data %>% 
  group_by(condition,id) %>% 
  mutate(trial=seq(1,n()))
my.data$block<-ifelse(my.data$trial>63,2,1)
my.data<-
  my.data %>% 
  group_by(condition,id,block) %>% 
  mutate(stimdiff=-c(0,diff(trial_value)))
#####
#conditions verbatim
####
my.data$cond.verb<-factor(my.data$condition,labels=c("red","green","yellow","blue"))
######
#some basic plots
#####
names(my.data)
ggplot(aes(x=stimdiff,y=deviation),data=my.data)+geom_point()+theme_classic()+facet_grid(cond.verb~id,scales="free")+stat_smooth()
##########
#accuracy of players in each condition
#########
acc.ana<-
  my.data %>% 
  group_by(condition,id) %>%
  mutate(abs_acc=abs(deviation)) %>% 
  summarise(mean_acc=mean(abs_acc),
            sd_acc=sd(abs_acc),
            N_trials=n())




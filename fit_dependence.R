#fit nls to green condition with highest accuracy for pps 21 to 25

sub.data<-my.data#subset(my.data,id%in%selector&cond.verb=="red")
sub.data<-subset(my.data,cond.verb=="blue")
c<-sqrt(2)/exp(-.5)
m.serdep<-list()
k<-0
conf.int<-list()
sub.data$fitted<-0
for(i in sub.data$id){
  k<-k+1
  try(m.serdep[[k]]<-nls(deviation~a*b*c*stimdiff*exp(-((b*stimdiff)^2)),data=subset(sub.data,id==i),start=list(a=.1,b=.1)))
  try(sub.data$fitted[sub.data$id==i]<-fitted(m.serdep[[k]]))
  try(conf.int[[k]]<-confint2(m.serdep[[k]]))
}
ggplot(aes(x=stimdiff,y=deviation),data=sub.data)+geom_point()+geom_line(aes(y=fitted))+facet_wrap(~id)


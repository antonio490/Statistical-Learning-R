
## K-Nearest Neighbors

library(class)
?knn
attach(Smarket)

xlog=cbind(Lag1, Lag2)
train=Year<2005

knn.pred=knn(xlog[train,], xlog[!train,], Direction[train], k=1)

table(knn.pred, Direction[!train])

mean(knn.pred==Direction[!train])

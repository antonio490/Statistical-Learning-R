

Model Selection
================

This is an R markdown document.


```{r}
library(ISLR)
summary(Hitters)
```
There are some missing values here, so before we proceed we will remove them:


```{r}
Hitters=na.omit(Hitters)
with(Hitters, sum(is.na(Salary)))
```

Best subset regression
=======================

Best subset regression looks through all possible regression models
of all different subset sizes and looks for the best of each size.
And so produces a sequence of models which is the best subset for each particular size.

```{r}
library(leaps)
regfit.full=regsubsets(Salary~.,data=Hitters)
summary(regfit.full)
```
It gives by default best subsets up to size 8; lets increase that to 19

```{r}
regfit.full=regsubsets(Salary~., data=Hitters, nvmax=19)
reg.summary=summary(regfit.full)
names(reg.summary)
plot(reg.summary$cp, xlab="number of Variables", ylab="Cp")
which.min(reg.summary$cp)
points(10, reg.summary$cp[10], pch=20, col="red")
```

There is a plot method for the `regsubsets` object

```{r}
plot(regfit.full, scale="Cp")
coef(regfit.full, 10)
```

Forward Stepwise Selection
===========================

Here we use the `regsubsets` function but specify the method="forward" option:


```{r}
regfit.fwd=regsubsets(Salary~., data=Hitters, nvmax=19, method="forward")
summary(regfit.fwd)
plot(regfit.fwd, scale="Cp")
```
Model Selection using a Validation Set
======================================

Lets make a training and validation set, so that we can choose a good subset model. 
We wil do it using a slightly different apporach from what was done in the book.

```{r}
dim(Hitters)
set.seed(1)
train=sample(seq(263), 180, replace=FALSE)
train
regfit.fwd=regsubsets(Salary~., data=Hitters[train,], nvmax=19, method="forward")
```

Now we will make predictions on the observations nt used for training. We know there are 19 models, so we set up some vectors to record the errores we have to do a bit of worl here, because there is no predict method for `regsubsets`.


```{r}
val.errors=rep(NA, 19)
x.test=model.matrix(Salary~., data=Hitters[-train,])

for(i in 1:19){
  coefi=coef(regfit.fwd, id=i)
  pred=x.test[,names(coefi)]%*%coefi
  val.errors[i]=mean((Hitters$Salary[-train]-pred)^2)
}

plot(sqrt(val.errors), ylab="Root MSE", ylim=c(300,400), pch=19, type="b")

points(sqrt(regfit.fwd$rss[-1]/180), col="blue", pch=19, type="b")

legend("topright", legend=c("Training", "Validation"), col=c("blue", "black"), pch=19)
```

As we expect, the training error goes down monotonically as the model gets bigger, but not si for the validation error.

This was a little tedious - not having a predict method for `regsubsets`. So we will write one!


```{r}
predict.regsubsets=function(object, newdata, id, ...){
  form=as.formula(object$call[[2]])
  mat=model.matrix(form, newdata)
  coefi=coef(object, id=id)
  mat[,names(coefi)]%*%coefi
}
```

Model Selection by Cross validation
====================================

we will do a 10-fold cross-validation. It is really easy!

```{r}
set.seed(1)
folds=sample(rep(1:10, length=nrow(Hitters)))
folds
table(folds)
cv.errors=matrix(NA, 10, 19)

for(k in 1:10){
  best.fit=regsubsets(Salary~., data=Hitters[folds!=k,], nvmax=19, method="forward")

  for(i in 1:19){
    pred=predict(best.fit,Hitters[folds==k,], id=i)
    cv.errors[k,i]=mean(( Hitters$Salary[folds==k]-pred)^2)
  }

}

rmse.cv=sqrt(apply(cv.errors, 2, mean))
plot(rmse.cv, pch=19, type="b")

```

Ridge Regression and the Lasso
===============================

We will use the package `glmnet` which does not use the model formula language, so we will set up an `x` and `y`.

```{r}
library(glmnet)
x=model.matrix(Salary~., data=Hitters)
y=Hitters$Salary
```

First we will fit a ridge regression model. This is achieved calling `glmnet` with `alpha=0`. There is also a `cv.glmnet` function which will do the cross-validation for us.

```{r}
fit.ridge=glmnet(x, y, alpha=0)
plot(fit.ridge, xvar="lambda", label=TRUE)
cv.ridge=cv.glmnet(x,y,alpha=0)
plot(cv.ridge)
```

Now we will fit a Lasso model; for this use the default `àlpha=1`

```{r}
fit.lasso=glmnet(x,y)
plot(fit.lasso, xvar="lambda", label=TRUE)
cv.lasso=cv.glmnet(x,y)
plot(cv.lasso)
coef(cv.lasso)
```

Suppose we want to use our earlier train/validation division to select the `lambda` for the lasso

```{r}
lasso.tr=glmnet(x[train,], y[train])
lasso.tr
pred=predict(lasso.tr, x[-train,])
dim(pred)
rmse=sqrt(apply((y[-train]-pred)^2, 2, mean))

plot(log(lasso.tr$lambda), rmse, type="b", xlab="Log(lambda)")

lam.best=lasso.tr$lambda[order(rmse)[1]]
lam.best
coef(lasso.tr, s=lam.best)
```











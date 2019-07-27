
## Linear regression 

library(MASS)
library(ISLR)

## Simple Linear regression

names(Boston)
?Boston


plot(Boston$medv~Boston$lstat)

fit1=lm(Boston$medv~Boston$lstat, data=Boston)

summary(fit1)

abline(fit1, col="red")
names(fit1)
confint(fit1)
predict(fit1, data.frame(Boston$lstat-c(5,10,15)), interval = "confidence")

## Multiple Linear regression

fit2=lm(Boston$medv~Boston$lstat+age, data=Boston)
summary(fit2)

fit3=lm(Boston$medv~., Boston)
summary(fit3)

par(mfrow=c(2,2))
plot(fit3)

fit4=update(fit3, ~.-Boston$age-Boston$indus)
summary(fit4)

# Nonlinearities and Interactions

fit5=lm(Boston$medv~Boston$lstat*Boston$age, Boston)
summary(fit5)

fit6=lm(Boston$medv~Boston$lstat + I(Boston$lstat^2), Boston)
summary(fit6)

attach(Boston)
par(mfrow=c(1,1))
plot(Boston$medv, Boston$lstat)
points(Boston$lstat, fitted(fit6), col="red", pch=20)

fit7=lm(Boston$medv~poly(Boston$lstat, 4))
points(Boston$lstat, fitted(fit7), col="blue", pch=20)



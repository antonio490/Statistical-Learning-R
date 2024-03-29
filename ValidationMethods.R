
require(ISLR)
require(boot)

?cv.glm
plot(mpg~horsepower, data = Auto)

## Leave one out cross validation LOOCV

glm.fit=glm(mpg~horsepower, data=Auto)
cv.glm(Auto, glm.fit)$delta

## Let's write a simple fucntion to use formula 5.2

loocv=function(fit){
  h=lm.influence(fit)$h
  mean((residuals(fit)/(1-h))^2)
}

loocv(glm.fit)
cv.error=rep(0,5)

degree=1:5
for(d in degree){
  glm.fit=glm(mpg~poly(horsepower, d), data = Auto)
  cv.error[d]=loocv(glm.fit)
}

plot(degree, cv.error, type="b")


## 10 fold cross validation

cv.error10=rep(0,5)

for(d in degree){
  glm.fit=glm(mpg~poly(horsepower, d), data = Auto)
  cv.error10[d]=cv.glm(Auto, glm.fit, K=10)$delta[1]
}

lines(degree, cv.error10, type="b", col="red")


## Bootstrap

alpha=function(x,y){
  vx=var(x)
  vy=var(y)
  cxy=cov(x,y)
  (vy-cxy)/(vx+vy-2*cxy)
}


alpha(Portfolio$X, Portfolio$Y)

alpha.fn=function(data, index){
  with(data[index,], alpha(X, Y))
}
  
alpha.fn(Portfolio, 1:100)

set.seed(1)

alpha.fn(Portfolio, sample(1:100, 100, replace = TRUE))
boot.out=boot(Portfolio, alpha.fn, R=1000)

boot.out

plot(boot.out)

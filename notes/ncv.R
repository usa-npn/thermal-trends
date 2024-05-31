library(mgcv)
library(dplyr)
library(ggplot2)
library(gratia)
?NCV

nei.cor <- function(h,n) { ## construct nei structure
  nei <- list(mi=1:n,i=1:n)
  nei$m <- cumsum(c((h+1):(2*h+1),rep(2*h+1,n-2*h-2),(2*h+1):(h+1)))
  k0 <- rep(0,0); if (h>0) for (i in 1:h) k0 <- c(k0,1:(h+i))
  k1 <- n-k0[length(k0):1]+1
  nei$k <- c(k0,1:(2*h+1)+rep(0:(n-2*h-1),each=2*h+1),k1)
  nei
}
set.seed(1)
n <- 500;sig <- .6
x <- 0:(n-1)/(n-1)
f <- sin(4*pi*x)*exp(-x*2)*5/2
e <- rnorm(n,0,sig)
for (i in 2:n) e[i] <- 0.6*e[i-1] + e[i]
y <- f + e ## autocorrelated data

df |> slice <- tibble(x, y)
ggplot(df |> slice, aes(x, y))+ geom_point()

nei <- nei.cor(4,n) ## construct neighbourhoods to mitigate 
View(nei)
# in nei...
# k is a sliding window of 9 index values
head(nei$k, n = 20)
# m is the index of k that is the end of each neighborhood.  For the 5th neighborhood...
j = 5
nei$m[j] #index 35 of k is the end of the neighborhood
nei$k[nei$m[j]] # which is the 9th value
#so the whole neighborhood is
nei$k[(nei$m[j-1]+1):nei$m[j]]
# i is the index of points to predict, in this case it's just every point?
# mi is also just 1:500 in this example
# I think that means this is leave-one-out example? "If m=n and α(k)=δ(k)=k then ordinary leave-one-out cross validation is recovered"



b0 <- gam(y~s(x,k=40)) ## GCV based fit
draw(b0)

gc <- gam.control(ncv.threads=2)
b1 <- gam(y~s(x,k=40),method="NCV",nei=nei,control=gc)
draw(b1)

## use "QNCV", which is identical here...
b2 <- gam(y~s(x,k=40),method="QNCV",nei=nei,control=gc)
draw(b2)

## plot GCV and NCV based fits...
compare_smooths(b0, b1, b2) |> draw()



# spatial -----------------------------------------------------------------

# What would this look like for a spatial gam?

library(tidyr)
df <- tidyr::expand_grid(x = 1:20, y = 1:20) |> 
  mutate(z = rnorm(n()))

m_spatial <- gam(z ~ s(x,y), data = df)
draw(m_spatial)

# let's try neighborhoods of 9 units on all sides of each point

## We need a vector of indices to be dropped for each neighborhood.  Basically need a sliding window but in 2D space.

library(purrr)
#indices to be dropped
k_list <- 
  map2(df$x, df$y, \(x.i, y.i) {
    expand_grid(x = x.i + -3:3, y = y.i + -3:3) 
  }) |> 
  map(\(exclude) {
    which(df$x %in% exclude$x & df$y %in% exclude$y)
  })

k <- list_c(k_list)
head(k, 20)
df |> slice(head(k, 20))

#index of k that is the end of each neighborhood
m <-
  k_list |> map_dbl(length) |> cumsum()

# index of points to predict (not sure how to decide on this, but I think for leave-one-out NCV it's just all the points. i.e. the "one" in leave-one-out is the center of each neighborhood, which is each point)
i <- seq_len(nrow(df))

# mi is like m above, but for i.  Gives the end index of each i

mi <- i
  
#for jth neighborhood

j = 70

#the indices of the neighborhood:

k[(m[j-1]+1):m[j]]

#the indices to be predicted:
i[(mi[j-1]+1):mi[j]]


df |> 
  slice(k[(m[j-1]+1):m[j]]) |>
  ggplot(aes(x,y)) +
  geom_point() +
  geom_point(data = df |> slice(i[(mi[j-1]+1):mi[j]]), color = "red")


nei = list(k, m, i, mi)

m_spatial_ncv <- gam(z ~ s(x,y), data = df, method = "NCV", nei = nei)

draw(m_spatial_ncv)

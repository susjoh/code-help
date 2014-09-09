# The aim of this exercise is to apply a function across many values of a data
# frame. The data frame DF1 contains column "Pr", which gives a probability of
# that the integer 2 will be sampled from a vector c(1, 2). Each line has a
# unique identifier, "Index".

DF1 <- data.frame(Pr = runif(100, min = 0, max = 1), 
                  Index = 1:100)

head(DF1)

#            Pr Index
# 1 0.859005752     1
# 2 0.855189580     2
# 3 0.505795720     3
# 4 0.538751551     4
# 5 0.007354454     5
# 6 0.179826223     6

#~~ The function foo samples a vector of length 2, with probabilities of 1-x and x.

foo <- function(x) sample.int(2, size = 1, prob = c(1 - x, x))

#~~ This function can then be applied to all values of Pr using lapply:

DF1$Sample <- unlist(lapply(DF1$Pr, foo))
head(DF1)

#            Pr Index Sample
# 1 0.859005752     1      2
# 2 0.855189580     2      2
# 3 0.505795720     3      1
# 4 0.538751551     4      2
# 5 0.007354454     5      1
# 6 0.179826223     6      1

#~~ However, this is slow when run several thousand times:

library(rbenchmark)

benchmark(unlist(lapply(DF1$Pr, foo)), replications = 10000)

#                          test replications elapsed relative user.self sys.self user.child sys.child
# 1 unlist(lapply(DF1$Pr, foo))        10000    8.28        1      8.27        0         NA        NA


#~~ one alternative is to use the ddply package

library(ddply)

DF2 <- data.frame(Pr = runif(100, min = 0, max = 1),
                  Index = 1:100)

DF2gp <- group_by(DF2, Index)

DF2$Sample <- summarise(DF2gp, samp = foo(Pr))

#~~ but this is not faster than lapply

benchmark(unlist(lapply(DF1$Pr, foo)),
          summarise(DF2gp, samp = foo(Pr)), replications = 10000)

#                               test replications elapsed relative user.self sys.self user.child sys.child
# 2 summarise(DF2gp, samp = foo(Pr))        10000   12.77     1.55     12.76        0         NA        NA
# 1      unlist(lapply(DF1$Pr, foo))        10000    8.24     1.00      8.22        0         NA        NA

#~~ other possibilities:

# vapply

vapply(DF1$Pr, foo, 1)

# data.table

library(data.table)

DT <- data.table(Pr    = runif(100, min=0, max=1),
                 Index = 1:100)

setkey(DT, Index)


#~~ All are slow...

benchmark(unlist(lapply(DF1$Pr, foo)),
          summarise(DF2gp, samp = foo(Pr)),
          vapply(DF1$Pr, foo, 1),
          DT[,list(samp=foo(Pr)), by=key(DT)], replications = 10000)

#                                       test replications elapsed relative user.self sys.self user.child sys.child
# 4 DT[, list(samp = foo(Pr)), by = key(DT)]        10000   45.14    5.664     45.02        0         NA        NA
# 2         summarise(DF2gp, samp = foo(Pr))        10000   12.61    1.582     12.48        0         NA        NA
# 1              unlist(lapply(DF1$Pr, foo))        10000    7.97    1.000      7.97        0         NA        NA
# 3                   vapply(DF1$Pr, foo, 1)        10000    8.53    1.070      8.46        0         NA        NA




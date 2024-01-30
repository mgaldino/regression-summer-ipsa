# simulation to understadn the effect of sample size on the standard error of OLS slope estimator

# creating values for sigma and x sd
sigma <- 100
s <- 20

# fucntion to simulate
se_beta_hat <- function(n) {
  sigma/(n*s)
}

# simulation of the effect of sample size on the se of beta_hat
se_beta_hat_sim <- se_beta_hat(1:2000)

# creating data frame for the plot
df <- data.frame(n = 1:2000, se_beta_hat_sim = se_beta_hat_sim)

library(ggplot2)
library(tidyverse)
# plot with results of simulation

df %>%
  filter( n < 200) %>%
  ggplot(aes(x=n, y=se_beta_hat_sim)) + geom_line() + geom_point() # plot the points in the graph

### Regression

## Firstly, simulate data from DGP (Data Generating Process)

e <- rnorm(n=1000, mean=0, sd=sqrt(10))
z <- rnorm(n=1000, mean=2, sd=5)
x <- ifelse(z > 0, 1,0)
y <- 2*x -3*z + e
# descriptive stats
summary(e)
summary(z)
summary(x)
summary(y)
#

df_regression <- data.frame(y=y, x=x, z=z)

# regression
fit1 <- lm(y ~ x, data = df_regression)
summary(fit1)

# ploting the data
df_regression %>%
  ggplot(aes(x=x, y=y)) + geom_point()

df_regression %>%
  ggplot(aes(x=x, y=y)) +
  geom_dotplot(binaxis = "y", stackdir = "center")

df_regression %>%
  ggplot(aes(y= y, group = x)) + geom_boxplot()

df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point() + facet_grid(~x)

#
dput(head(df_regression))

# ggplot code
df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point() + facet_grid(~x)

df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point()
# sample data
structure(list(y = c(22.9850436894311, 12.0054800824713, -20.0308690158672, 
                     14.3397230813811, 2.30678683735291, -22.0071822651631), x = c(0, 
                                                                                   0, 1, 0, 0, 1), z = c(-8.47220566325498, -5.05421933497527, 6.81429656669519, 
                                                                                                         -5.00731893187604, -0.651995230175863, 7.60256070506032)), row.names = c(NA, 
                                                                                                                                                                                  6L), class = "data.frame")

##
summary_df <- df_regression %>%
  group_by(x) %>%
  summarize(mean_y = mean(y))

df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point() + facet_grid(~x) +
  geom_hline(data = summary_df, aes(yintercept = mean_y), color = "red", linewidth = 1)

fit2 <- lm(y ~ x + z, data=df_regression)
summary(fit2)

fit3 <- lm(y ~z, data=df_regression)
summary(fit3)
coef(fit3)
# plot with regression line
df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point() + 
  geom_abline(slope=coef(fit3)[2], intercept = coef(fit3)[1], color = "red", linewidth = 1)

df_regression %>%
  ggplot(aes(x=z, y=y)) + geom_point() + geom_smooth(method = "lm", color = "red")

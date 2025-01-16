# Compute theoretical standard error under normal errors
theoretical_se <- function(n, x) {
  x_var <- var(x) # Variance of x scaled by n
  sigma_squared <- 1 # Assuming variance of error is 1
  sqrt(sigma_squared / (n*x_var))
}

# Simulate data with normal errors
simulate_beta_with_se <- function(n, error_dist) {
  alpha <- 5
  beta <- 1
  x <- rnorm(n, mean = 2, sd = 2) # x ~ N(2, 4)
  if (error_dist == "normal") {
    epsilon <- rnorm(n)
  } else if (error_dist == "t") {
    epsilon <- rt(n, df = 5)
  } else if (error_dist == "beta") {
    epsilon <- rbeta(n, shape1 = 2, shape2 = 5) - 2/7
  } else if (error_dist == "mixture") {
    epsilon <- ifelse(runif(n) < 0.5, rnorm(n, mean = -1, sd = 1), rnorm(n, mean = 1, sd = 1))
  }
  x_sample <- rnorm(sample_size, mean = 2, sd = 2) # Fixed x for theoretical SE
  y <- alpha + beta * x + epsilon
  model <- lm(y ~ x)
  se <- summary(model)$coefficients[2, 2] # Extract standard error of beta
  beta <- coef(model)[2]
  return(beta)
}

# Run simulations
run_simulations <- function(n, error_dist, num_simulations = 1000) {
  betas <- replicate(num_simulations, simulate_beta_with_se(n, error_dist))
  empirical_beta_se <- sd(betas) 
  return(empirical_beta_se)
}

# Simulation parameters
sample_size <- 100
distributions <- c("normal", "t", "beta", "mixture")


# Paroximately true sigma
error_sd <- c(sd(rnorm(10000)), sd(rt(10000, df = 5)), sd(rbeta(10000, shape1 = 2, shape2 = 5) - 2/7),
              sd(ifelse(runif(10000) < 0.5, rnorm(10000, mean = -1, sd = 1), rnorm(10000, mean = 1, sd = 1))))

# Collect results
results <- data.frame(
  Distribution = character(),
  EmpiricalSE = numeric(),
  TheoreticalSE = numeric(),
  Estimate_True_Error_SD = numeric(),
  stringsAsFactors = FALSE
)

error_sd <- c(sd(rnorm(10000)), sd(rt(10000, df = 5)), sd(rbeta(10000, shape1 = 2, shape2 = 5) - 2/7),
              sd(ifelse(runif(10000) < 0.5, rnorm(10000, mean = -1, sd = 1), rnorm(10000, mean = 1, sd = 1))))

for (dist in distributions) {
  empirical_se <- run_simulations(sample_size, dist)
  theoretical_se_val <- theoretical_se(sample_size, x_sample)
 
  results <- rbind(
    results,
    data.frame(
      Distribution = dist,
      EmpiricalSE = round(empirical_se[[1]], 3),
      TheoreticalSE = theoretical_se_val,
      Estimate_True_Error_SD = round(error_sd[which(distributions == dist)],2)
    )
  )
  
}

results$correct <- round(results$Estimate_True_Error_SD*results$TheoreticalSE,3)
# Display results
print(results)






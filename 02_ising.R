library(Matrix)

mascaras_tablero <- function(M, N) {
  par <- as.vector(outer(1:M, 1:N, "+")) %% 2 == 0
  list(which(par), which(!par))
}

S_ising <- function(x, e) sum(x[e[, 1]] * x[e[, 2]])

# h = campo externo por píxel (0 para el prior puro; gamma*y para la posterior)
barrido_gibbs <- function(x, A, beta, h, mascaras) {
  for (m in mascaras) {
    s <- as.vector(A %*% x)[m]
    p <- plogis(2 * (beta * s + h[m]))
    x[m] <- ifelse(runif(length(m)) < p, 1, -1)
  }
  x
}

mcmc_ising <- function(y, g, n_iter = 2000, burn = 500,
                       a_b = 2, b_b = 2, a_r = 1, b_r = 1,
                       delta = 0.05, K = 10, beta0 = 0.8, seed = 1) {
  set.seed(seed)
  P <- g$P; A <- g$A; e <- g$aristas
  mk <- mascaras_tablero(g$M, g$N)
  h0 <- numeric(P)
  x <- y; beta <- beta0; rho <- 0.1
  beta_ch <- rho_ch <- numeric(n_iter)
  suma_x <- numeric(P); acept <- 0
  
  for (t in 1:n_iter) {
    # 1) X | resto (Gibbs)
    gam <- 0.5 * log((1 - rho) / rho)
    x <- barrido_gibbs(x, A, beta, gam * y, mk)
    
    # 2) rho | resto: Beta(a+m, b+P-m) truncada en (0, 1/2)
    m  <- sum(x != y)
    a1 <- a_r + m; b1 <- b_r + P - m
    rho <- qbeta(runif(1, 0, pbeta(0.5, a1, b1)), a1, b1)
    
    # 3) beta | x: exchange aproximado
    prop <- beta + rnorm(1, 0, delta)
    if (prop > 0) {
      xs <- x
      for (k in 1:K) xs <- barrido_gibbs(xs, A, prop, h0, mk)
      log_a <- dgamma(prop, a_b, b_b, log = TRUE) - dgamma(beta, a_b, b_b, log = TRUE) +
        (prop - beta) * (S_ising(x, e) - S_ising(xs, e))
      if (log(runif(1)) < log_a) { beta <- prop; acept <- acept + 1 }
    }
    
    beta_ch[t] <- beta; rho_ch[t] <- rho
    if (t > burn) suma_x <- suma_x + (x == 1)
  }
  list(beta = beta_ch, rho = rho_ch, pi = suma_x / (n_iter - burn),
       tasa_acept = acept / n_iter, burn = burn)
}
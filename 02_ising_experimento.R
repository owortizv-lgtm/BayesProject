source("R01_grafo.R")
source("02_ising.R")
library(coda)

horse <- readPNG("horse_binaria.png")
# horse <- horse[, , 1]    # solo si dim(horse) tiene 3 dimensiones
M <- 128; N <- 128
g <- construir_grafo(M, N)
x_bin <- ifelse(as.vector(horse) == 0, 1, -1)
set.seed(123)
rho0 <- 0.10
y <- x_bin * ifelse(runif(g$P) < rho0, -1, 1)     # contaminación

fit <- mcmc_ising(y, g)

fit$tasa_acept                                     # objetivo: ~20-40 %
post <- (fit$burn + 1):length(fit$beta)
mean(fit$beta[post]); mean(fit$rho[post])          # rho debería quedar cerca de 0.10

x_hat <- ifelse(fit$pi > 0.5, 1, -1)               # restauración
mean(x_hat == x_bin)                               # proporción recuperada
mean(y == x_bin)                                   # referencia: ~0.90 sin restaurar

# Diagnósticos
library(coda)
effectiveSize(fit$beta[post]); effectiveSize(fit$rho[post])
par(mfrow = c(1, 2)); plot(fit$beta, type = "l"); plot(fit$rho, type = "l")

# Mapa de probabilidades
plot(as.raster(1 - matrix(fit$pi, 128, 128)))
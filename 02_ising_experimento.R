source("R01_grafo.R")
source("02_ising.R")
library(coda)

horse <- readPNG("imagenes/horse_binaria.png")
# horse <- horse[, , 1]    # solo si dim(horse) tiene 3 dimensiones
M <- 128; N <- 128
g <- construir_grafo(M, N)
x_bin <- ifelse(as.vector(horse) == 0, 1, -1)
set.seed(123)
rho0 <- 0.10
y <- x_bin * ifelse(runif(g$P) < rho0, -1, 1)     # contaminación

fit <- mcmc_ising(y, g, n_iter = 5000, burn = 1000, delta = 0.03, K = 10)

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
plot(fit$beta, type = "l", main = "Traza de beta")
# Mapa de probabilidades
plot(as.raster(1 - matrix(fit$pi, 128, 128)))

# --- 1. Sensibilidad a K ---
fit30 <- mcmc_ising(y, g, n_iter = 5000, burn = 1000, delta = 0.03, K = 30)
c(K10 = mean(fit$beta[post]),  K30 = mean(fit30$beta[post]))
c(K10 = mean(fit$rho[post]),   K30 = mean(fit30$rho[post]))
c(K10 = fit$tasa_acept,        K30 = fit30$tasa_acept)

# --- 2. Tres cadenas y Rhat ---
inicios <- c(0.3, 0.8, 1.2)
cadenas <- lapply(1:3, function(s)
  mcmc_ising(y, g, n_iter = 5000, burn = 1000, delta = 0.03, K = 10,
             beta0 = inicios[s], seed = s))

lista <- mcmc.list(lapply(cadenas, function(f)
  mcmc(cbind(beta = f$beta[post], rho = f$rho[post]))))
gelman.diag(lista)

par(mfrow = c(1, 2))
matplot(sapply(cadenas, function(f) f$beta), type = "l", lty = 1,
        ylab = "beta", main = "Trazas de beta (3 cadenas)")
matplot(sapply(cadenas, function(f) f$rho), type = "l", lty = 1,
        ylab = "rho", main = "Trazas de rho (3 cadenas)")

# --- 3. Sensibilidad a K = 100 ---
fit100 <- mcmc_ising(y, g, n_iter = 5000, burn = 1000, delta = 0.03, K = 100)
c(K10 = mean(fit$beta[post]), K30 = mean(fit30$beta[post]), K100 = mean(fit100$beta[post]))
fit100$tasa_acept

mean(fit100$beta[post]); mean(fit100$rho[post])
mean(ifelse(fit100$pi > 0.5, 1, -1) == x_bin)
effectiveSize(fit100$beta[post])


dir.create("figuras", showWarnings = FALSE)
guardar <- function(archivo, img) {
  png(archivo, width = 384, height = 384); par(mar = c(0, 0, 0, 0))
  plot(as.raster(img)); dev.off()
}
bw <- function(x) matrix(ifelse(x == 1, 0, 1), 128, 128)   # +1 negro -> 0

guardar("figuras/ising_original.png",    bw(x_bin))
guardar("figuras/ising_contaminada.png", bw(y))
guardar("figuras/ising_restaurada.png",  bw(ifelse(fit100$pi > 0.5, 1, -1)))
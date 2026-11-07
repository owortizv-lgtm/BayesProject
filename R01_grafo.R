library(Matrix)
library(png)

# Grafo de vecindad de 4 vecinos para imagen M x N.
# Orden de píxeles: por columnas (igual que as.vector() en R).
construir_grafo <- function(M, N) {
  P   <- M * N
  idx <- matrix(seq_len(P), M, N)
  
  # aristas verticales (i,j)-(i+1,j) y horizontales (i,j)-(i,j+1)
  v <- cbind(as.vector(idx[-M, ]), as.vector(idx[-1, ]))
  h <- cbind(as.vector(idx[, -N]), as.vector(idx[, -1]))
  e <- rbind(v, h)
  
  A <- sparseMatrix(i = c(e[, 1], e[, 2]),
                    j = c(e[, 2], e[, 1]),
                    x = 1, dims = c(P, P))
  d <- rowSums(A)
  D <- Diagonal(P, d)
  L <- D - A
  list(A = A, D = D, L = L, d = d, aristas = e, M = M, N = N, P = P)
}

# imagen matricial -> vector (y de vuelta)
img_a_vec <- function(img) as.vector(img)
vec_a_img <- function(x, M, N) matrix(x, M, N)

# RGB: arreglo M x N x 3 -> matriz P x 3 (columnas R, G, B)
rgb_a_mat <- function(img) matrix(img, ncol = 3)
mat_a_rgb <- function(X, M, N) array(X, dim = c(M, N, 3))
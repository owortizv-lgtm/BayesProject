# Grafo de 4 vecinos para una imagen M x N --------------------------------------
# Orden de píxeles: por columnas (igual que as.vector() en R).
# L = D - A (caso.Rmd, sección "Representación como grafo").

library(Matrix)
library(png)

construir_grafo <- function(M, N) {
     P   <- M * N
     idx <- matrix(seq_len(P), M, N)

     # aristas verticales (i,j)-(i+1,j) y horizontales (i,j)-(i,j+1), cada una una vez
     v <- cbind(as.vector(idx[-M, ]), as.vector(idx[-1, ]))
     h <- cbind(as.vector(idx[, -N]), as.vector(idx[, -1]))
     e <- rbind(v, h)

     A <- Matrix::sparseMatrix(i = c(e[, 1], e[, 2]),
                               j = c(e[, 2], e[, 1]),
                               x = 1, dims = c(P, P))
     d  <- Matrix::rowSums(A)
     D  <- Matrix::Diagonal(P, d)
     L  <- D - A
     Ls <- Matrix::forceSymmetric(L)          # dsCMatrix: para Matrix::Cholesky en GMRF

     # tablero de ajedrez: píxeles del mismo color son condicionalmente independientes
     mk  <- mascaras_tablero(M = M, N = N)
     A_m <- lapply(mk, function(m) A[m, , drop = FALSE])   # filas de A por color

     # vecinos en formato CSR (base 0) para una futura versión en C++
     At  <- as(A, "CsparseMatrix")
     csr <- list(ptr = At@p, idx = At@i)       # A simétrica: CSC de A = CSR de A

     # chequeos: grados 2 (esquinas), 3 (bordes), 4 (interior) y filas de L suman 0
     stopifnot(sum(d == 2) == 4,
               sum(d == 3) == 2 * (M - 2) + 2 * (N - 2),
               sum(d == 4) == (M - 2) * (N - 2),
               all(Matrix::rowSums(L) == 0),
               nrow(e) == M * (N - 1) + N * (M - 1))

     list(A = A, D = D, L = L, Ls = Ls, d = d, aristas = e,
          mascaras = mk, A_m = A_m, csr = csr, M = M, N = N, P = P)
}

# Tablero de ajedrez ----------
mascaras_tablero <- function(M, N) {
     par <- as.vector(outer(1:M, 1:N, "+")) %% 2 == 0
     list(which(par), which(!par))
}

# Vectorización ----------
# imagen M x N -> vector de longitud P (por columnas) y de vuelta
img_a_vec <- function(img) as.vector(img)
vec_a_img <- function(x, M, N) matrix(x, M, N)

# RGB: arreglo M x N x 3 -> matriz P x 3; la fila i es x_i' = (R_i, G_i, B_i)
rgb_a_mat <- function(img) matrix(img, ncol = 3)
mat_a_rgb <- function(X, M, N) array(X, dim = c(M, N, 3))

# Vector 3P apilado por píxel, x = (x_1', ..., x_P')', como en teoria.tex (Imagen RGB):
# es el orden en que valen 1_P ⊗ mu y Q = (I_P + lambda L) ⊗ Omega.
# OJO: as.vector(X) apila por canal y correspondería a Omega ⊗ (I_P + lambda L).
rgb_a_vec <- function(X) as.vector(t(X))
vec_a_rgbmat <- function(x) matrix(x, ncol = 3, byrow = TRUE)

# Lectura y visualización de imágenes ----------
# Normaliza el PNG: quita el canal alfa o los canales repetidos según el tipo.
# tipo = "binaria" | "gris" -> matriz M x N;  "rgb" -> arreglo M x N x 3.
leer_imagen <- function(ruta, tipo = c("binaria", "gris", "rgb")) {
     tipo <- match.arg(tipo)
     img  <- png::readPNG(ruta)
     if (tipo == "rgb") {
          stopifnot(length(dim(img)) == 3, dim(img)[3] >= 3)
          return(img[, , 1:3])
     }
     if (length(dim(img)) == 3) img <- img[, , 1]
     img
}

# Dibuja una imagen en [0,1] (recorta solo para visualizar) con márgenes mínimos.
mostrar_img <- function(img, titulo = "") {
     op <- par(mar = c(0.2, 0.2, 1.5, 0.2)); on.exit(par(op))
     plot(as.raster(pmin(pmax(img, 0), 1)))
     title(titulo)
}

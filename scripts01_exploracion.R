source("R01_grafo.R")

# --- Cargar imágenes ---
horse     <- readPNG("imagenes/horse_binaria.png")
camera    <- readPNG("imagenes/camera_grises.png")
astronaut <- readPNG("imagenes/astronaut_rgb.png")

# Algunos PNG traen canal extra (gris+alfa o RGBA): verifica y ajusta
dim(horse); dim(camera); dim(astronaut)

# Aquí ajusta según lo que imprima dim():
# horse     <- horse[, , 1]
# camera    <- camera[, , 1]
# astronaut <- astronaut[, , 1:3]

M <- 128; N <- 128
g <- construir_grafo(M, N)

# --- Verificar grados: esquinas 2, bordes 3, interior 4 ---
table(g$d)                       # esperado: 4 esquinas (2), 4*(126) bordes (3), 126^2 interiores (4)
stopifnot(sum(g$d == 2) == 4,
          sum(g$d == 3) == 4 * (M - 2),
          sum(g$d == 4) == (M - 2)^2)
stopifnot(all(rowSums(g$L) == 0))   # propiedad de la Laplaciana

# --- Vectorización y reconstrucción ---
x_gris <- img_a_vec(camera)
stopifnot(identical(vec_a_img(x_gris, M, N), camera))

X_rgb <- rgb_a_mat(astronaut)    # P x 3
stopifnot(all.equal(mat_a_rgb(X_rgb, M, N), astronaut))

# --- Binaria: 0 (negro) y 1 (blanco) -> +1 (negro) y -1 (blanco) ---
x_bin <- ifelse(img_a_vec(horse) == 0, 1, -1)
table(x_bin) / length(x_bin)

# --- Exploración visual ---
par(mfrow = c(2, 3))
plot(as.raster(horse));     title("Binaria")
plot(as.raster(camera));    title("Grises")
plot(as.raster(astronaut)); title("RGB")
barplot(table(x_bin), main = "Frecuencias (±1)")
hist(x_gris, breaks = 50, main = "Intensidades grises", xlab = "")
cols <- c("red", "green", "blue")
plot(density(X_rgb[, 1]), col = cols[1], main = "Canales RGB", xlab = "")
lines(density(X_rgb[, 2]), col = cols[2])
lines(density(X_rgb[, 3]), col = cols[3])
# BayesProject — Restauración bayesiana de imágenes

Caso de estudio de Estadística Bayesiana (UNAL, prof. Juan Sosa). Autores: Melissa Chaves Beltrán y Owen Deybis Ortiz Velasquez.
Enunciado: `caso.Rmd`. Teoría ya derivada: `teoria.tex` (posteriores conjuntas y condicionales completas de los 3 modelos).

## Reglas críticas (aplican a Claude y a TODOS los subagentes)
1. **Git:** NUNCA ejecutar `git commit`, `git push`, `git add`, `git reset`, `git rebase` ni similares, ni añadir firmas `Co-Authored-By`. Los autores hacen todos los commits a mano. Un hook (`.claude/hooks/bloquear-git.sh`) bloquea commit/push.
2. **Verdad conocida:** las imágenes originales (`horse_binaria.png`, `camera_grises.png`, `astronaut_rgb.png`) solo se usan para (a) generar la contaminación y (b) calcular errores (proporción recuperada, MSE, SNR). **Nunca** para elegir hiperparámetros, valores iniciales, δ², K, iteraciones ni la realización del ruido.
3. **Ruido:** una sola realización por escenario con semilla fija declarada de antemano; prohibido probar varias semillas y quedarse con la mejor.
4. **No recortar** `y` a [0,1] durante la inferencia; recortar solo al visualizar.
5. **No re-derivar** lo que ya está en `teoria.tex`; citarlo por sección.
6. **Código eficiente y claro** comentado brevemente.
7. **Planear antes de ejecutar**, pedir aprobación antes de continuar.

## Ahorro de tokens
- No leer `teoria.tex` completo (~62 KB): usar `Grep` con el encabezado y leer solo ese bloque. Mapa de secciones:
  - Ising: `\section{Imagen binaria` → condicionales `X_i` (σ(η_i), η_i = 2βS_i + y_i log((1-ρ)/ρ)), `\rho` (Beta truncada), `\beta`.
  - GMRF grises: `\section{Escala de grises` → `X_i ~ N(m_i, v_i)`, `\sigma^2` (IG), `\mu` (N), `\tau`, `\lambda` (MH, usan log|Q|).
  - GMRF RGB: `\section{Imagen RGB` → `X_i ~ N_3(μ_i*, Σ_i*)`, `Σ` (IW_3), `μ` (N_3), `Ω` (W_3), `λ` (MH, usa log|I_P+λL|).
- `.refs/` es solo de consulta y está en `.gitignore`. En `.refs/the-bayesian-way` usar únicamente: `chap06/chap06_sec_6.6.R` (Gibbs + Wishart Inversa, `metricas_mcmc`, `calcular_rhat`), `chap10/chap10_ex_10.5.R` (MH), `chap14/dist_functions.cpp` y `chap14/cap14_seccion_14.5.R` (Rcpp, `tunning`, burn/thin).
- Leer `output/*.rds` con `readRDS` y resumir en consola; no volcar vectores de 16 384 elementos.

## Estructura objetivo
```
imagenes/            PNG originales (caso.Rmd los busca aquí)
R/01_grafo.R         grafo 4-vecinos, A, D, L=D-A (Matrix), tablero, CSR, vectorización por columnas, RGB P×3
02_ising.R           Ising: Gibbs (tablero de ajedrez) + exchange aproximado
03_gmrf_grises.R     GMRF univariado: Gibbs + MH(τ, λ) con Cholesky disperso
04_gmrf_rgb.R        GMRF multivariado: Gibbs + MH(λ), Wishart / Wishart Inversa
src/*.cpp            barridos de Gibbs en Rcpp (ising_barrido.cpp; requiere Rtools, si no 02_ising.R usa R)
99_ejecutar.R        corre los escenarios ρ0, σ0 ∈ {0.05, 0.10, 0.20}
output/*.rds         resultados (ignorados por git)
figuras/             PNG para informe y README
informe/             LaTeX final
```

## Convenciones de código (estilo de Juan Sosa)
- Encabezados `# Sección ----------`, sangría de 5 espacios, argumentos con nombre, `set.seed(seed)` dentro de cada función MCMC.
- Cadenas en mayúscula (`BETA`, `RHO`, `SIGMA`), contadores `acept`, MH en escala log: `log(runif(1)) <= min(0, log_r)`.
- Prefijo explícito `coda::`, `Matrix::`. Diagnósticos: `coda::effectiveSize`, EEMC, CVMC, `coda::gelman.diag` con ≥ 3 cadenas.
- Orden de píxeles: por columnas (`as.vector`), igual en R y en C++.

## Subagentes (`.claude/agents/`)
| Agente | Uso |
|:--|:--|
| `bayesian-theorist` | Respuestas conceptuales pendientes, revisión conceptual actual, y correspondencia ecuación ↔ código |
| `mcmc-coder` | Implementación R/Rcpp, escenarios y `output/*.rds` |
| `bayesian-auditor` | Auditoría de fugas, convergencia y métricas (solo lectura) |
| `latex-reporter` | Informe LaTeX APA final |

Flujo típico: theorist → coder → auditor → (correcciones) → reporter. Modificar un agente: `/ajustar-agente <nombre> <cambio>`.

// Barridos de Gibbs para el modelo de Ising (tablero de ajedrez) ---------------
// X_i | resto ~ +1 con prob. sigma(eta_i), eta_i = 2*(beta*S_i + h_i)
// (teoria.tex, sección "Imagen binaria"; h_i = 0.5*log((1-rho)/rho)*y_i en la posterior,
//  h_i = 0 para simular de la previa en el exchange).
// Los píxeles de un mismo color son condicionalmente independientes, así que
// actualizarlos en secuencia equivale a la versión vectorizada en R. Se usa el RNG de R
// (una uniforme por píxel, en el orden de la máscara) para que set.seed controle todo
// y C++ y R den exactamente la misma cadena.

#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector barrido_ising_cpp(IntegerVector x,
                                const IntegerVector& ptr,   // CSR base 0 (g$csr$ptr)
                                const IntegerVector& idx,   // CSR base 0 (g$csr$idx)
                                const List& mascaras,       // índices base 1 (g$mascaras)
                                double beta,
                                const NumericVector& h,
                                int K = 1) {
     IntegerVector z = clone(x);
     for (int k = 0; k < K; k++) {
          for (int c = 0; c < mascaras.size(); c++) {
               IntegerVector m = mascaras[c];
               for (int r = 0; r < m.size(); r++) {
                    int i = m[r] - 1;
                    double s = 0.0;                         // S_i = suma de vecinos
                    for (int p = ptr[i]; p < ptr[i + 1]; p++) s += z[idx[p]];
                    double prob = R::plogis(2.0 * (beta * s + h[i]), 0.0, 1.0, 1, 0);
                    z[i] = (R::runif(0.0, 1.0) < prob) ? 1 : -1;
               }
          }
     }
     return z;
}

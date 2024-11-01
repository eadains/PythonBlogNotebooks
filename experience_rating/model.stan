data {
    int N; // Number of teams
    int T; // Number of observations
    array[N] vector[T] L; // Observation vector for each team
}
parameters {
    real<lower=0> k;
    real<lower=0, upper=1> alpha;
    real<lower=0, upper=1> mu_zero;
}
transformed parameters {
    array[N] vector[T] mu;
    for (i in 1:N) {
        mu[i][1] = mu_zero;
    }
    for (t in 2:T) {
        for (i in 1:N) {
            mu[i][t] = alpha * L[i][t-1] + (1 - alpha) * mu[i][t-1];
        }
    }
}
model {
    k ~ exponential(1);
    alpha ~ beta(2, 2);
    mu_zero ~ beta(2, 2);
    for (t in 1:T) {
        for (i in 1:N) {
            L[i][t] ~ beta_proportion(mu[i][t], k);
        }
    }
}
generated quantities {
    array[N] vector[T] L_hat;
    for (t in 1:T) {
        for (i in 1:N) {
            L_hat[i][t] = beta_proportion_rng(mu[i][t], k);
        }
    }
}
data {
    int N; // # of observations
    int K; // # of teams
    array[K] int idx; // Ending index for each team's observations
    vector[N] ys; // Concatenated observation vector
}
parameters {
    real<lower=0> sigma;
    real<lower=0, upper=1> alpha;
    real<lower=0, upper=1> mu_zero;
}
transformed parameters {
    vector[N] mu;
    {
        int start_idx = 1;
        for (k in 1:K) {
            mu[start_idx] = mu_zero;
            for (t in 1:(idx[k] - start_idx)) {
                mu[start_idx + t] = alpha * ys[start_idx + t - 1] + (1 - alpha) * mu[start_idx + t - 1];
            }
            start_idx = idx[k] + 1;
        }
    }
}
model {
    sigma ~ exponential(1);
    alpha ~ beta(2, 2);
    mu_zero ~ beta(2, 2);
    ys ~ beta_proportion(mu, sigma);
}
generated quantities {
    array[N] real ys_hat;
    ys_hat = beta_proportion_rng(mu, sigma);
}
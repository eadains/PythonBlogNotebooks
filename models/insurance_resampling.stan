data {
    int N; // Number of policies
    vector[N] E; // Exposure
    array[N] int C; // Observed claim count
    array[N] real S; // Observed loss amount
}
parameters {
    real<lower=0> phi;
    real<lower=0> omega;
    vector<lower=0>[N] lambda;
    vector<lower=0>[N] mu;
}
model {
    phi ~ exponential(1);
    lambda ~ exponential(phi);

    omega ~ exponential(1);
    mu ~ exponential(omega);

    C ~ poisson(E .* lambda);
    for (i in 1:N) {
        if (S[i] > 0) {
            S[i] ~ exponential(1 / (mu[i] * C[i]));
        }
    }
}
generated quantities {
    array[N] int C_hat; // Simulated claim counts
    array[N] real S_hat; // Simulated loss amount
    
    C_hat = poisson_rng(E .* lambda);
    for (i in 1:N) {
        if (C_hat[i] > 0) {
            S_hat[i] = exponential_rng(1 / (mu[i] * C_hat[i]));
        }
        else {
            S_hat[i] = 0;
        }
    }
}

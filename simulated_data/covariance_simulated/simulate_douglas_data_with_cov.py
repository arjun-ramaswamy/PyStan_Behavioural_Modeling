import numpy as np
import pandas as pd

# Group-level means and standard deviations for the learning rates and beta
mu_pr_Apun = 0.5
mu_pr_Arew = 0.5
mu_pr_beta = 5
sigma_Apun = 0.2
sigma_Arew = 0.2
sigma_beta = 1

# Covariances (adjust these based on desired correlations)
covariance_Apun_Arew = 0.02
covariance_Apun_beta = 0.01
covariance_Arew_beta = 0.01

# Construct the covariance matrix
cov_matrix = [
    [sigma_Apun**2, covariance_Apun_Arew, covariance_Apun_beta], 
    [covariance_Apun_Arew, sigma_Arew**2, covariance_Arew_beta],
    [covariance_Apun_beta, covariance_Arew_beta, sigma_beta**2]
]

# Group-level means array
means = [mu_pr_Apun, mu_pr_Arew, mu_pr_beta]

# Initialize simulation parameters
num_subjects = 14
equal_num_trials = 100
np.random.seed(42)  # For reproducibility

# Sample from a multivariate normal distribution
individual_params = np.random.multivariate_normal(means, cov_matrix, num_subjects)

# Ensure the parameters are within bounds
individual_params[:, :2] = np.clip(individual_params[:, :2], 0, 1)  # For learning rates
individual_params[:, 2] = np.clip(individual_params[:, 2], 0, np.inf)  # For beta, ensuring it's positive

learning_rates_pun, learning_rates_rew, betas = individual_params.T

# Initialize a list to store the simulated data
simulated_trials = []

for subj in range(1, num_subjects + 1):
    Apun = learning_rates_pun[subj - 1]
    Arew = learning_rates_rew[subj - 1]
    beta = betas[subj - 1]
    ev = np.array([0.5, 0.5])  # Initial expected values for two options

    for trial in range(equal_num_trials):
        # Randomly decide which option has the 70% win probability for this trial
        high_win_prob_choice = np.random.choice([0, 1])
        win_probs = np.array([0.7, 0.3]) if high_win_prob_choice == 0 else np.array([0.3, 0.7])

        # Simulate decision making based on softmax rule
        odds = np.exp(ev * beta)
        probs = odds / np.sum(odds)
        decision = np.random.choice([0, 1], p=probs)

        # Determine outcome based on chosen option's win probability
        outcome = np.random.choice([1, 0], p=[win_probs[decision], 1 - win_probs[decision]])

        # Update expected values based on outcome
        pe = outcome - ev[decision]
        ev[decision] += Arew * pe if outcome > 0 else Apun * pe

        # Append the trial data to the list
        simulated_trials.append({
            'subjid': subj, 'cond': 1, 'decisions': decision+1, 'outcomes': outcome
        })

# Convert the list of trial data into a DataFrame
simulated_data_adjusted = pd.DataFrame(simulated_trials)

# Specify the file path for saving the simulated data
adjusted_simulated_file_path = 'simulated_data_adjusted.csv'
simulated_data_adjusted.to_csv(adjusted_simulated_file_path, index=False)

print(f"Simulated data saved to {adjusted_simulated_file_path}.")

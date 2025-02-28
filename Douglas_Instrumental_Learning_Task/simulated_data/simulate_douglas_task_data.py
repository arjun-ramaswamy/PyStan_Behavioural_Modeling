import numpy as np
import pandas as pd

# Hyperparameters for the group-level distributions
mu_pr_Apun = 0.5  # Mean for punishment learning rate
sigma_Apun = 0.1  # Standard deviation for punishment learning rate

mu_pr_Arew = 0.5  # Mean for reward learning rate
sigma_Arew = 0.1  # Standard deviation for reward learning rate

mu_pr_beta = 20    # Mean for beta (inverse temperature)
sigma_beta = 2    # Standard deviation for beta

# Initialize simulation parameters
num_subjects = 14
equal_num_trials = 100
np.random.seed(42)  # For reproducibility

# Simulating individual-level parameters from group-level distributions
learning_rates_pun = np.random.normal(mu_pr_Apun, sigma_Apun, num_subjects)
learning_rates_rew = np.random.normal(mu_pr_Arew, sigma_Arew, num_subjects)
betas = np.random.normal(mu_pr_beta, sigma_beta, num_subjects)

# Ensuring parameters remain within their logical bounds
learning_rates_pun = np.clip(learning_rates_pun, 0, 1)
learning_rates_rew = np.clip(learning_rates_rew, 0, 1)
betas = np.clip(betas, 0, np.inf)  # Assuming beta must be positivex

# Initialize a dataframe to store the simulated data
simulated_data_adjusted = pd.DataFrame(columns=['subjid', 'cond', 'decisions', 'outcomes'])

for subj in range(1, num_subjects + 1):
    Apun = learning_rates_pun[subj - 1]
    Arew = learning_rates_rew[subj - 1]
    beta = betas[subj - 1]
    ev = np.array([0.5, 0.5])  # Initial expected values for two options
    
    for trial in range(equal_num_trials):
        # Randomly decide which option has the 70% win probability for this trial
        high_win_prob_choice = np.random.choice([1, 2])
        
        # Assign win probabilities based on the high win probability choice
        win_probs = np.array([0.7, 0.3]) if high_win_prob_choice == 1 else np.array([0.3, 0.7])
        
        # Simulate decision making based on softmax rule
        odds = np.exp(ev * beta)
        probs = odds / np.sum(odds)
        decision = np.random.choice([1, 2], p=probs)
        
        # Determine the outcome based on the chosen option's win probability
        outcome = np.random.choice([1, 0], p=[win_probs[decision - 1], 1 - win_probs[decision - 1]])
        
        # Update expected values based on the outcome
        pe = outcome - ev[decision - 1]
        ev[decision - 1] += Arew * pe if outcome > 0 else Apun * pe
        
        # Append the trial data to the dataframe
        simulated_data_adjusted = simulated_data_adjusted.append({'subjid': subj, 'cond': 1, 'decisions': decision, 'outcomes': outcome}, ignore_index=True)

# Specify the file path for saving the simulated data
adjusted_simulated_file_path = 'simulated_data_adjusted.csv'
simulated_data_adjusted.to_csv(adjusted_simulated_file_path, index=False)

print(f"Simulated data saved to {adjusted_simulated_file_path}.")

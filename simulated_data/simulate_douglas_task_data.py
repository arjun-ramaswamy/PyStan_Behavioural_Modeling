import numpy as np
import pandas as pd

# Initialize parameters
num_subjects = 14
equal_num_trials = 100
np.random.seed(42)  # For reproducibility
learning_rates_pun = np.random.uniform(0, 1, num_subjects)
learning_rates_rew = np.random.uniform(0, 1, num_subjects)
betas = np.random.uniform(0, 10, num_subjects)

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

# Save the adjusted simulated data to a CSV file
adjusted_simulated_file_path = '/mnt/data/simulated_data_adjusted.csv'
simulated_data_adjusted.to_csv(adjusted_simulated_file_path, index=False)

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Loading the data
data = pd.read_csv("/mnt/data/final_merged_logs_with_high_loss_chosen_corrected.csv")

# Filtering the data for reward trials and replacing NaNs
reward_trials_data = data[data['Condition'] == 1].copy()
reward_trials_data['High_Reward_Chosen'].fillna(0, inplace=True)

# Function to compute rates using sliding window method
def compute_rates_for_subject(subject_data, window_size=10, step_size=5, column_name='High_Reward_Chosen'):
    rates = []
    start_idx = 0
    while start_idx + window_size <= len(subject_data):
        window_data = subject_data.iloc[start_idx:start_idx + window_size]
        rate = window_data[column_name].mean()
        rates.append(rate)
        start_idx += step_size
    return rates

# Computing high reward choice rates for each subject
min_reward_trials = reward_trials_data['Subject'].value_counts().min()
reward_rates_df = pd.DataFrame()
for subject in reward_trials_data['Subject'].unique():
    subject_data = reward_trials_data[reward_trials_data['Subject'] == subject].head(min_reward_trials)
    rates = compute_rates_for_subject(subject_data, window_size=10, step_size=5, column_name='High_Reward_Chosen')
    reward_rates_df[subject] = rates

# Extracting trial numbers for plotting
reward_trial_numbers = [10 + i*5 for i in range(len(reward_rates_df))]

# Using a Seaborn color palette for plotting
color_palette_updated = sns.color_palette("husl", len(reward_rates_df.columns))

# Plotting the high reward choice rates
plt.figure(figsize=(12, 6))
for idx, subject in enumerate(reward_rates_df.columns):
    plt.plot(reward_trial_numbers, reward_rates_df[subject], label=f'Subject {idx+1}', color=color_palette_updated[idx], linestyle='-', linewidth=0.8, alpha=0.5)

# Plotting the group average
reward_group_average = reward_rates_df.mean(axis=1)
plt.plot(reward_trial_numbers, reward_group_average, color='black', linewidth=2.5, linestyle='-', label='Group Average')

# Adjusting plot aesthetics
plt.ylim(0, 1)
plt.yticks(np.arange(0, 1.1, 0.1))
plt.xlabel('Trial Number')
plt.ylabel('High Reward Choice Rate')
plt.title('High Reward Choice Rate')
plt.legend(loc='center right', bbox_to_anchor=(1.15, 0.5))
plt.grid(False)
plt.tight_layout()
plt.show()

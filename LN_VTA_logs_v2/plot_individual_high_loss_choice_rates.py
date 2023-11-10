# Loading the data
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

data = pd.read_csv("/mnt/data/final_merged_logs_with_high_loss_chosen_corrected.csv")

# Filtering the data for loss trials and replacing NaNs
loss_trials_data = data[data['Condition'] == 2].copy()
loss_trials_data['High_Loss_Chosen'].fillna(0, inplace=True)

# Function to compute rates using sliding window method
def compute_rates_for_subject(subject_data, window_size=10, step_size=5):
    rates = []
    start_idx = 0
    while start_idx + window_size <= len(subject_data):
        window_data = subject_data.iloc[start_idx:start_idx + window_size]
        rate = window_data['High_Loss_Chosen'].mean()
        rates.append(rate)
        start_idx += step_size
    return rates

# Computing high loss choice rates for each subject
min_loss_trials = loss_trials_data['Subject'].value_counts().min()
rates_df_updated = pd.DataFrame()
for subject in loss_trials_data['Subject'].unique():
    subject_data = loss_trials_data[loss_trials_data['Subject'] == subject].head(min_loss_trials)
    rates = compute_rates_for_subject(subject_data)
    rates_df_updated[subject] = rates

# Extracting trial numbers for plotting
trial_numbers_updated = [10 + i*5 for i in range(len(rates_df_updated))]

# Using a Seaborn color palette for plotting
color_palette_updated = sns.color_palette("husl", len(rates_df_updated.columns))

# Plotting the high loss choice rates
plt.figure(figsize=(12, 6))

# Plotting individual subjects with the Seaborn color palette and adjusted aesthetics
for idx, subject in enumerate(rates_df_updated.columns):
    plt.plot(trial_numbers_updated, rates_df_updated[subject], label=f'Subject {idx+1}', color=color_palette_updated[idx], linestyle='-', linewidth=0.8, alpha=0.5)

# Plotting the group average with the "Group Average" annotation
group_average_updated = rates_df_updated.mean(axis=1)
plt.plot(trial_numbers_updated, group_average_updated, color='black', linewidth=2.5, linestyle='-', label='Group Average')

plt.ylim(0, 1)
plt.yticks(np.arange(0, 1.1, 0.1))
plt.xlabel('Trial Number')
plt.ylabel('High Loss Choice Rate')
plt.title('High Loss Choice Rate')
plt.legend(loc='center right', bbox_to_anchor=(1.15, 0.5))
plt.grid(False)
plt.tight_layout()
plt.show()

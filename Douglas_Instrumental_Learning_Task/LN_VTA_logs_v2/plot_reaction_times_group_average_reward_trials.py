import pandas as pd
import matplotlib.pyplot as plt

# Load the dataset from the CSV file
data = pd.read_csv('/path/to/your/csv/file.csv')

# Filter the dataset for reward trials (Condition == 1)
reward_trials = data[data['Condition'] == 1]

# Determine the minimum number of reward trials across all subjects
min_trials = reward_trials['Subject'].value_counts().min()

# Define the function to compute the average reaction time for a given number of trials
def compute_avg_reaction_time_for_n_trials(n, data):
    averages = []
    for subject, group in data.groupby('Subject'):
        # If there are fewer than n trials for a subject, we won't include that subject for that point
        if len(group) >= n:
            selected_trials = group.head(n)
            avg_reaction_time = selected_trials['Reaction Time'].mean()
            averages.append(avg_reaction_time)
    return sum(averages) / len(averages)

# Calculate the group average reaction time for each number of trials from 1 to min_trials
group_averages = [compute_avg_reaction_time_for_n_trials(i, reward_trials) for i in range(1, min_trials + 1)]

# Plot the results
plt.figure(figsize=(12, 6))
plt.plot(range(1, min_trials + 1), group_averages, marker='o', linestyle='-')
plt.title('Group Average Reaction Time as a Function of Number of Reward Trials')
plt.xlabel('Number of Reward Trials')
plt.ylabel('Average Reaction Time (s)')
plt.xticks(range(1, min_trials + 1))
plt.grid(True, which='both', linestyle='--', linewidth=0.5)
plt.tight_layout()
plt.show()

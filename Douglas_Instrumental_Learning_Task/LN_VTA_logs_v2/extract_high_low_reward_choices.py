import pandas as pd

# Load the data
df = pd.read_csv('/mnt/data/final_merged_logs.csv')

# Define the high probability win pairs
high_probability_win_pairs = ['f1', 'f3', 'f4']

# Extract the order of the stimuli from the 'Code' column
df['Stimuli_Order'] = df['Code'].str.extract(r'(f\d_f\d)')

# Extract the numeric value from the 'Decisions' column
df['Decisions'] = df['Decisions'].str.extract('(\d)').astype(int)

# Filter for reward trials
reward_trials = df[df['Condition'] == 1]

# Create a dictionary to store the counts for each subject
subject_counts = {}

# Loop through each unique subject
for subject in reward_trials['Subject'].unique():
    subject_data = reward_trials[reward_trials['Subject'] == subject]
    
    # Initialize counters for higher and lower reward choices
    higher_reward_choice_count = 0
    lower_reward_choice_count = 0
    
    # Loop through the reward trials and count the number of higher and lower reward choices
    for idx, row in subject_data.iterrows():
        order = row['Stimuli_Order']
        decision = row['Decisions']
        
        # Check the chosen stimulus based on the decision and the order of the stimuli
        if decision == 1:  # Left choice
            chosen_stimulus = order.split('_')[0]
        elif decision == 2:  # Right choice
            chosen_stimulus = order.split('_')[1]
        else:
            continue
        
        # Check if the chosen stimulus is a higher or lower reward choice
        if chosen_stimulus in high_probability_win_pairs:
            higher_reward_choice_count += 1
        else:
            lower_reward_choice_count += 1
    
    # Store the counts in the dictionary
    subject_counts[subject] = {
        'Higher Reward Choice Count': higher_reward_choice_count,
        'Lower Reward Choice Count': lower_reward_choice_count
    }

# Convert the dictionary to a DataFrame for easier viewing
results_df = pd.DataFrame.from_dict(subject_counts, orient='index')
print(results_df)

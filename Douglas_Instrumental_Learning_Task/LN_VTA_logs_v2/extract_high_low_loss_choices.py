import pandas as pd

# Load the CSV
data = pd.read_csv('/mnt/data/final_merged_logs_with_high_reward_chosen.csv')

# Function to determine if the high loss option was chosen
def high_loss_chosen(row):
    if row['Condition'] == 2:  # Only consider rows with loss condition
        if row['Stimuli_Order'] == "f1_f2" and row['Decisions'] == 1:
            return 1
        elif row['Stimuli_Order'] == "f2_f1" and row['Decisions'] == 2:
            return 1
        else:
            return 0
    else:
        return None  # For other conditions, we don't determine high loss choice

# Apply the function to populate the High_Loss_Chosen column
data['High_Loss_Chosen'] = data.apply(high_loss_chosen, axis=1)

# Extract the number of times each subject chose the high loss option and low loss option
summary = data[data['Condition'] == 2].groupby(['Subject', 'High_Loss_Chosen']).size().unstack().fillna(0)
summary.columns = ['Low Loss Option', 'High Loss Option']
summary = summary.sort_index()

# Save the modified data back to CSV
data.to_csv('/mnt/data/final_merged_logs_with_high_loss_chosen.csv', index=False)

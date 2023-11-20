import pandas as pd
import re

# Load the original dataset
df = pd.read_csv('/path/to/your/original_file.csv')

# Function to extract Stimuli_Order from the Code column
def extract_stimuli_order(Code):
    match = re.search(r'(f\d_f\d)', Code)
    return match.group(0) if match else None

# Function for calculating High_Reward_Chosen
def calculate_high_reward_chosen(row):
    if row['Condition'] == 1:  # Only for reward condition
        f1_position = row['Stimuli_Order'].split('_').index('f1') + 1  # +1 as decisions are 1 and 2
        return 1 if row['Decisions'] == f1_position else 0
    return None

# Function for calculating High_Loss_Chosen
def calculate_high_loss_chosen(row):
    if row['Condition'] == 2:  # Only for loss condition
        f1_position = row['Stimuli_Order'].split('_').index('f1') + 1
        return 1 if row['Decisions'] == f1_position else 0
    return None

# Applying the functions to the dataset
df['Stimuli_Order'] = df['Code'].apply(extract_stimuli_order)
df['High_Reward_Chosen'] = df.apply(calculate_high_reward_chosen, axis=1)
df['High_Loss_Chosen'] = df.apply(calculate_high_loss_chosen, axis=1)

# Save the processed dataset
df.to_csv('/path/to/your/output_file.csv', index=False)

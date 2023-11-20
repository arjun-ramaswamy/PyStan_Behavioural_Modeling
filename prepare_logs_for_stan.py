import pandas as pd
import re

# Load the original dataset
df = pd.read_csv('/path/to/your/final_cleaned_dataset.csv')

# Rescore 'Subject' from 'LN_VTA_x' to 'x' for the 'subjid' column
df['subjid'] = df['Subject'].str.extract(r'LN_VTA_(\d+)').astype(int)

# 'choice' column as the same as the 'Decisions' column
df['choice'] = df['Decisions']

# 'gain' column: 1 if 'Outcomes' is 1, otherwise 0
df['gain'] = df['Outcomes'].apply(lambda x: 1 if x == 1 else 0)

# 'loss' column: -1 if 'Outcomes' is -1, otherwise 0
df['loss'] = df['Outcomes'].apply(lambda x: -1 if x == -1 else 0)

# Retain the 'Outcomes' column
# Selecting only the required columns for the new file
df_new = df[['subjid', 'choice', 'gain', 'loss', 'Outcomes']]

# Save the new dataset
df_new.to_csv('/path/to/your/transformed_dataset_with_outcomes.csv', index=False)

import pandas as pd

# Define the function to populate the specified column
def populate_column(prediction_errors_file, vta_logs_and_regressors_file, output_file, column_name):
    # Load the CSV files
    prediction_errors_df = pd.read_csv(prediction_errors_file)
    vta_logs_and_regressors_df = pd.read_csv(vta_logs_and_regressors_file)

    # Extract unique SubjectIDs from prediction_errors.csv
    subject_ids = prediction_errors_df['SubjectID'].unique()

    # Creating a copy of the VTA logs and regressors DataFrame to modify
    vta_logs_and_regressors_df_copy = vta_logs_and_regressors_df.copy()

    # Reset the specified column to NaN
    vta_logs_and_regressors_df_copy[column_name] = pd.NA
    
    # Loop through each valid subject and populate the specified column
    for subject_id in subject_ids:
        subject_name = f"LN_VTA_{subject_id}"
        prediction_errors = prediction_errors_df[prediction_errors_df['SubjectID'] == subject_id].iloc[:, 1:].values.flatten()

        condition_1_indices = vta_logs_and_regressors_df_copy[
            (vta_logs_and_regressors_df_copy['Subject'] == subject_name) &
            (vta_logs_and_regressors_df_copy['Condition'] == 1)
        ].index

        for idx, condition_idx in enumerate(condition_1_indices):
            if idx < len(prediction_errors):
                vta_logs_and_regressors_df_copy.at[condition_idx, column_name] = prediction_errors[idx]

    # Save the updated dataframe to a new CSV file
    vta_logs_and_regressors_df_copy.to_csv(output_file, index=False)

# Define the file paths and column name
prediction_errors_file = '/mnt/data/prediction_errors.csv'
vta_logs_and_regressors_file = '/mnt/data/VTA_logs_and_regressors.csv'
output_file = '/mnt/data/updated_VTA_logs_and_regressors.csv'
column_name = 'm5'

# Call the function
populate_column(prediction_errors_file, vta_logs_and_regressors_file, output_file, column_name)

output_file

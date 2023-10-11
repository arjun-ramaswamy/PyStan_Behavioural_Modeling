def compute_choice_rate_with_padding(df, decision_val, max_trials):
    """Compute choice rate for given decision value up to max_trials, with padding."""
    choice_rates = [0.5]  # start with 0.5 choice rate
    
    for trial in range(1, max_trials + 1):
        if trial <= len(df):
            choice_rate = df['decisions'].iloc[:trial].eq(decision_val).sum() / trial
            choice_rates.append(choice_rate)
        else:
            choice_rates.append(np.nan)  # pad with nan
    
    return np.arange(max_trials + 1), choice_rates

# Determine the maximum number of trials across all subjects
max_trials = df.groupby('subjid').size().max()

# For each subject and condition, compute choice rate up to the maximum number of trials with padding
choice_rates_1_for_cond_1_padded = []
choice_rates_2_for_cond_1_padded = []
choice_rates_1_for_cond_2_padded = []
choice_rates_2_for_cond_2_padded = []

for subjid in df['subjid'].unique():
    for cond in [1, 2]:
        sub_cond_df = df[(df['subjid'] == subjid) & (df['cond'] == cond)]
        
        trials, rates_decision_1 = compute_choice_rate_with_padding(sub_cond_df, 1, max_trials)
        trials, rates_decision_2 = compute_choice_rate_with_padding(sub_cond_df, 2, max_trials)
        
        if cond == 1:
            choice_rates_1_for_cond_1_padded.append(rates_decision_1)
            choice_rates_2_for_cond_1_padded.append(rates_decision_2)
        else:
            choice_rates_1_for_cond_2_padded.append(rates_decision_1)
            choice_rates_2_for_cond_2_padded.append(rates_decision_2)

# Compute average and standard deviation across subjects for each trial, ignoring nans
avg_rate_1_for_cond_1_padded = np.nanmean(choice_rates_1_for_cond_1_padded, axis=0)
std_rate_1_for_cond_1_padded = np.nanstd(choice_rates_1_for_cond_1_padded, axis=0)

avg_rate_2_for_cond_1_padded = np.nanmean(choice_rates_2_for_cond_1_padded, axis=0)
std_rate_2_for_cond_1_padded = np.nanstd(choice_rates_2_for_cond_1_padded, axis=0)

avg_rate_1_for_cond_2_padded = np.nanmean(choice_rates_1_for_cond_2_padded, axis=0)
std_rate_1_for_cond_2_padded = np.nanstd(choice_rates_1_for_cond_2_padded, axis=0)

avg_rate_2_for_cond_2_padded = np.nanmean(choice_rates_2_for_cond_2_padded, axis=0)
std_rate_2_for_cond_2_padded = np.nanstd(choice_rates_2_for_cond_2_padded, axis=0)

# Plot with choice rates as a function of trial number with padding
plt.figure(figsize=(12, 6))
plt.plot(trials, avg_rate_1_for_cond_1_padded, label='Decision 1 (Cond 1)', color='blue')
plt.fill_between(trials, 
                 np.clip(avg_rate_1_for_cond_1_padded - std_rate_1_for_cond_1_padded, 0, 1), 
                 np.clip(avg_rate_1_for_cond_1_padded + std_rate_1_for_cond_1_padded, 0, 1), 
                 color='blue', alpha=0.2)

plt.plot(trials, avg_rate_2_for_cond_1_padded, label='Decision 2 (Cond 1)', color='red')
plt.fill_between(trials, 
                 np.clip(avg_rate_2_for_cond_1_padded - std_rate_2_for_cond_1_padded, 0, 1), 
                 np.clip(avg_rate_2_for_cond_1_padded + std_rate_2_for_cond_1_padded, 0, 1), 
                 color='red', alpha=0.2)

plt.plot(trials, avg_rate_1_for_cond_2_padded, label='Decision 1 (Cond 2)', color='green', linestyle='--')
plt.fill_between(trials, 
                 np.clip(avg_rate_1_for_cond_2_padded - std_rate_1_for_cond_2_padded, 0, 1), 
                 np.clip(avg_rate_1_for_cond_2_padded + std_rate_1_for_cond_2_padded, 0, 1), 
                 color='green', alpha=0.2)

plt.plot(trials, avg_rate_2_for_cond_2_padded, label='Decision 2 (Cond 2)', color='purple', linestyle='--')
plt.fill_between(trials, 
                 np.clip(avg_rate_2_for_cond_2_padded - std_rate_2_for_cond_2_padded, 0, 1), 
                 np.clip(avg_rate_2_for_cond_2_padded + std_rate_2_for_cond_2_padded, 0, 1), 
                 color='purple', alpha=0.2)

plt.xlabel('Trial Number')
plt.ylabel('Choice Rate')
plt.title('Choice Rate Across Trials (Padded)')
plt.legend()
plt.grid(True, which='both', linestyle='--', linewidth=0.5)
plt.tight_layout()
plt.show()

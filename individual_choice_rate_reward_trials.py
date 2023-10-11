# Create individual plots for each participant focusing on reward trials and choice rate of Decision 1
unique_subjects = df['subjid'].unique()

# For better visualization, let's plot them in a grid format
num_rows = len(unique_subjects) // 2 + len(unique_subjects) % 2  # Aim for roughly 2 columns
fig, axes = plt.subplots(num_rows, 2, figsize=(15, 4 * num_rows))

for idx, subjid in enumerate(unique_subjects):
    sub_df = df[(df['subjid'] == subjid) & (df['cond'] == 1)]
    trials, rates_decision_1 = compute_choice_rate_with_padding(sub_df, 1, len(sub_df))
    
    ax = axes[idx // 2, idx % 2]
    ax.plot(trials, rates_decision_1, label='Decision 1 (Cond 1)', color='blue')
    ax.set_xlabel('Trial Number')
    ax.set_ylabel('Choice Rate')
    ax.set_title(f'Choice Rate Across Trials for Subject {subjid}')
    ax.grid(True, which='both', linestyle='--', linewidth=0.5)
    ax.legend()

# Remove any unused subplots
if len(unique_subjects) % 2 != 0:
    axes[-1, -1].axis('off')

plt.tight_layout()
plt.show()

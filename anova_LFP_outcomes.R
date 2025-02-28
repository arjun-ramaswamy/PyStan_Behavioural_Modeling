# Load necessary libraries
library(tidyverse)
library(lme4)
library(broom)
library(broom.mixed)
library(emmeans)
library(kableExtra)

# ---- Step 1: Load and Reshape the Data ----
data <- read.csv("outcome_effects_lfp_mean.csv")

# Reshape the data to long format
data_long <- pivot_longer(data, cols = c("Rew", "Loss", "Neu"), 
                          names_to = "Trial_Type", values_to = "LFP")

# Ensure factors are correctly defined
data_long$Trial_Type <- factor(data_long$Trial_Type, levels = c("Rew", "Loss", "Neu"))
data_long$Model.fitting <- factor(data_long$Model.fitting)
data_long$Subj <- factor(data_long$Subj)

# ---- Step 2: Perform Repeated Measures ANOVA on Trial Type ----
anova_lfp_repeated <- aov(LFP ~ Trial_Type + Error(Subj/Trial_Type), data = data_long)
anova_repeated_summary <- summary(anova_lfp_repeated)
print("Repeated Measures ANOVA Results:")
print(anova_repeated_summary)

# ---- Step 3: Linear Mixed-Effects Model (LME) ----
lme_model <- lmer(LFP ~ Trial_Type + HAM.D + HIT.6 + Model.fitting + (1 | Subj), data = data_long)
lme_summary <- summary(lme_model)
print("Linear Mixed-Effects Model Results:")
print(lme_summary)

# ---- Step 4: ANCOVA with HAM-D and HIT-6 ----
ancova_hamd <- lm(LFP ~ Trial_Type + HAM.D + Model.fitting, data = data_long)
ancova_hamd_summary <- summary(ancova_hamd)
print("ANCOVA (HAM-D as Covariate) Results:")
print(ancova_hamd_summary)

ancova_hit6 <- lm(LFP ~ Trial_Type + HIT.6 + Model.fitting, data = data_long)
ancova_hit6_summary <- summary(ancova_hit6)
print("ANCOVA (HIT-6 as Covariate) Results:")
print(ancova_hit6_summary)

# ---- Step 5: Post-hoc Tukey Test for Trial Type ----
posthoc_test <- emmeans(lme_model, pairwise ~ Trial_Type, adjust = "tukey")
posthoc_summary <- summary(posthoc_test)
print("Post-hoc Tukey Test Results:")
print(posthoc_summary)

# ---- Step 6: Simplified Summary Table ----
# Tidy each model result separately

# 1. Tidy the ANOVA result manually by extracting the relevant terms
anova_tidy <- broom::tidy(anova_lfp_repeated$`Error: Subj:Trial_Type`)

# 2. Tidy the LME model
lme_tidy <- broom.mixed::tidy(lme_model)

# 3. Tidy the ANCOVA results
ancova_hamd_tidy <- broom::tidy(ancova_hamd)
ancova_hit6_tidy <- broom::tidy(ancova_hit6)

# 4. Tidy the Post-hoc Tukey test result
posthoc_tidy <- as.data.frame(summary(posthoc_test)$contrasts)

# ---- Step 7: Combine all the tidied results ----
# Combine into a single data frame with a new "Analysis" column
summary_df <- bind_rows(
  anova_tidy %>% mutate(Analysis = "Repeated Measures ANOVA"),
  lme_tidy %>% mutate(Analysis = "LME: Trial Type + Covariates"),
  ancova_hamd_tidy %>% mutate(Analysis = "ANCOVA: HAM-D as Covariate"),
  ancova_hit6_tidy %>% mutate(Analysis = "ANCOVA: HIT-6 as Covariate"),
  posthoc_tidy %>% mutate(Analysis = "Post-hoc Tukey Test")
)

# ---- Step 8: Select the necessary columns ----
summary_df <- summary_df %>%
  select(term, estimate, std.error, p.value, Analysis)

# ---- Step 9: Create a clean summary table using kableExtra ----
summary_df %>%
  kable("html", caption = "Summary of ANOVA, LME, ANCOVA, and Post-hoc Test Results") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
  column_spec(1:5, bold = TRUE) %>%
  row_spec(which(summary_df$p.value < 0.05), background = "lightblue") %>%
  add_footnote("P-values less than 0.05 are highlighted.", notation = "symbol")


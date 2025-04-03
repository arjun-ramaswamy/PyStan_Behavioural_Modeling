# ------------------------------------------------------
# 1️⃣ Load Required Libraries
# ------------------------------------------------------
library(lme4)
library(lmerTest)
library(ggplot2)
library(emmeans)
library(tidyr)
library(performance)
library(sjstats)
library(partR2)
library(car)


data <- read.csv("outcome_effects_lfp_win.csv")
print("✅ Initial Data Loaded")

colnames(data) <- c("Subj", "Rew", "Loss", "Neu", "Model_Fitting", "HAMD", "HIT6", "SHAPS", 
                    "Smoking", "Depression_Severity", "Rew_Trials_Behaviour",
                    "Loss_Trials_Behaviour", "Neutral_Trials_Behaviour")
print("✅ Column names renamed")

# Fix variable types
data$Smoking <- factor(trimws(data$Smoking))
data$Subj <- factor(data$Subj)
data$Model_Fitting <- factor(data$Model_Fitting)
data$Depression_Severity <- factor(data$Depression_Severity, ordered = TRUE)
data$Rew_Trials_Behaviour <- factor(data$Rew_Trials_Behaviour)
data$Loss_Trials_Behaviour <- factor(data$Loss_Trials_Behaviour)
data$Neutral_Trials_Behaviour <- factor(data$Neutral_Trials_Behaviour)
data$HAMD <- as.numeric(data$HAMD)
data$HIT6 <- as.numeric(data$HIT6)
data$SHAPS <- as.numeric(data$SHAPS)
print("✅ Data types converted")

# ------------------------------------------------------
# 3️⃣ Subset for SHAPS model
# ------------------------------------------------------
data_shaps <- data[!is.na(data$SHAPS), ]
print(paste("✅ Subjects included (Non-SHAPS):", length(unique(data$Subj))))
print(paste("✅ Subjects included (SHAPS):", length(unique(data_shaps$Subj))))

# ------------------------------------------------------
# 4️⃣ Reshape to Long Format
# ------------------------------------------------------
data_long <- pivot_longer(data, cols = c("Rew", "Loss", "Neu"),
                          names_to = "Trial_Type", values_to = "LFP")
data_long_shaps <- pivot_longer(data_shaps, cols = c("Rew", "Loss", "Neu"),
                                names_to = "Trial_Type", values_to = "LFP")
data_long$Trial_Type <- factor(data_long$Trial_Type, levels = c("Rew", "Loss", "Neu"))
data_long_shaps$Trial_Type <- factor(data_long_shaps$Trial_Type, levels = c("Rew", "Loss", "Neu"))
print("✅ Reshaped to long format")

# ------------------------------------------------------
# 5️⃣ Apply Sum-to-Zero Contrast Coding
# ------------------------------------------------------
contrasts(data_long$Trial_Type) <- contr.sum(3)
contrasts(data_long$Smoking) <- contr.sum(2)
contrasts(data_long$Model_Fitting) <- contr.sum(2)
contrasts(data_long_shaps$Trial_Type) <- contr.sum(3)
contrasts(data_long_shaps$Smoking) <- contr.sum(2)
contrasts(data_long_shaps$Model_Fitting) <- contr.sum(2)
print("✅ Contrast coding applied")

# ------------------------------------------------------
# 6️⃣ Fit Full LME Models
# ------------------------------------------------------
print("🔄 Fitting LME model (non-SHAPS)...")
lme_model <- lmer(LFP ~ Trial_Type * Smoking * Model_Fitting + HAMD + HIT6 + (1 | Subj),
                  data = data_long)
print("✅ LME model (non-SHAPS) complete.")
print(summary(lme_model))

print("🔄 Fitting LME model (SHAPS)...")
lme_model_shaps <- lmer(LFP ~ Trial_Type * Smoking * Model_Fitting + HAMD + HIT6 + SHAPS + (1 | Subj),
                        data = data_long_shaps)
print("✅ LME model (SHAPS) complete.")
print(summary(lme_model_shaps))
# ------------------------------------------------------
# 7️⃣ Type III ANOVA
# ------------------------------------------------------
print("🔄 Running Type III ANOVA (non-SHAPS)...")
print(Anova(lme_model, type = 3))

print("🔄 Running Type III ANOVA (SHAPS)...")
print(Anova(lme_model_shaps, type = 3))

# ------------------------------------------------------
# 8️⃣ Post-hoc Pairwise Comparisons
# ------------------------------------------------------
print("🔍 Post-hoc contrasts (non-SHAPS):")
print(emmeans(lme_model, pairwise ~ Trial_Type, adjust = "bonferroni"))
print(emmeans(lme_model, pairwise ~ Smoking, adjust = "bonferroni"))

print("🔍 Post-hoc contrasts (SHAPS):")
print(emmeans(lme_model_shaps, pairwise ~ Trial_Type, adjust = "bonferroni"))
print(emmeans(lme_model_shaps, pairwise ~ Smoking, adjust = "bonferroni"))

# ------------------------------------------------------
# 9️⃣ Behavioural Strategy Models
# ------------------------------------------------------
print("🔄 Running behavioural model for Reward trials...")
lm_rew <- lm(LFP ~ Smoking * Model_Fitting + Rew_Trials_Behaviour + HAMD + HIT6,
             data = subset(data_long, Trial_Type == "Rew"))
print(summary(lm_rew))

print("🔄 Running behavioural model for Loss trials...")
lm_loss <- lm(LFP ~ Smoking * Model_Fitting + Loss_Trials_Behaviour + HAMD + HIT6,
              data = subset(data_long, Trial_Type == "Loss"))
print(summary(lm_loss))

print("🔄 Running behavioural model for Neutral trials...")
lm_neu <- lm(LFP ~ Smoking * Model_Fitting + Neutral_Trials_Behaviour + HAMD + HIT6,
             data = subset(data_long, Trial_Type == "Neu"))
print(summary(lm_neu))

# ------------------------------------------------------
# 🔟 Compute Effect Sizes (SHAPS Model)
# ------------------------------------------------------
print("🔄 Computing part R² and Cohen's f² for SHAPS model...")
shaps_partR2 <- partR2(lme_model_shaps,
                       partvars = c("HAMD", "HIT6", "SHAPS"),
                       data = data_long_shaps,
                       nboot = 1000)

print("✅ partR2 results:")
print(shaps_partR2$R2)

r2_hamd <- shaps_partR2$R2[shaps_partR2$R2$term == "HAMD", "estimate"]
r2_hit6 <- shaps_partR2$R2[shaps_partR2$R2$term == "HIT6", "estimate"]
r2_shaps <- shaps_partR2$R2[shaps_partR2$R2$term == "SHAPS", "estimate"]

f2_hamd  <- r2_hamd / (1 - r2_hamd)
f2_hit6  <- r2_hit6 / (1 - r2_hit6)
f2_shaps <- r2_shaps / (1 - r2_shaps)

print(paste("🔹 Cohen's f² (HAMD):",  round(f2_hamd, 4)))
print(paste("🔹 Cohen's f² (HIT6):", round(f2_hit6, 4)))
print(paste("🔹 Cohen's f² (SHAPS):", round(f2_shaps, 4)))


# ------------------------------------------------------
# 1️⃣ Load Required Libraries
# ------------------------------------------------------
library(lme4)
library(lmerTest)
library(emmeans)

# ------------------------------------------------------
# 2️⃣ Load and Prepare Data
# ------------------------------------------------------
expectation_data <- read.csv("expectation.csv")
print("✅ Data Loaded")
print(head(expectation_data))
print(colnames(expectation_data))

# Convert to appropriate types
expectation_data$Patient <- as.factor(expectation_data$Patient)
expectation_data$Value <- as.factor(expectation_data$Value)
expectation_data$Outcome <- as.factor(expectation_data$Outcome)
print("✅ Variables converted to factor")

# ------------------------------------------------------
# 3️⃣ Full-Sample LME Analysis
# ------------------------------------------------------
print("🔄 Running LME model on all patients...")
lme_all <- lmer(LFP ~ Value * Outcome + (1 | Patient), data = expectation_data)
print("✅ LME model (all patients) complete.")
print(summary(lme_all))

# ------------------------------------------------------
# 4️⃣ Type III ANOVA on Full Model
# ------------------------------------------------------
library(car)
print("🔍 Type III ANOVA on all patients:")
print(Anova(lme_all, type = 3))

# ------------------------------------------------------
# 5️⃣ Post-hoc Comparisons for Interaction
# ------------------------------------------------------
print("🔍 Post-hoc pairwise comparisons (Value × Outcome):")
posthoc_all <- emmeans(lme_all, pairwise ~ Value * Outcome, adjust = "bonferroni")
print(posthoc_all)

# ------------------------------------------------------
# 6️⃣ Patient-Specific Model (Patient 3 = ID 2)
# ------------------------------------------------------
print("🔄 Running model for Patient 3 (ID 2 in file)...")
patient3_data <- subset(expectation_data, Patient == 2)
patient3_data$Value <- factor(patient3_data$Value)
patient3_data$Outcome <- factor(patient3_data$Outcome)

aov_patient3 <- aov(LFP ~ Value * Outcome, data = patient3_data)
print("✅ Two-way ANOVA for Patient 3 complete.")
print(summary(aov_patient3))

# ------------------------------------------------------
# 7️⃣ Post-hoc for Patient 3
# ------------------------------------------------------
print("🔍 Post-hoc pairwise comparisons (Patient 3):")
emm_patient3 <- emmeans(aov_patient3, pairwise ~ Value * Outcome, adjust = "bonferroni")
print(emm_patient3)

# ✅ End of Script

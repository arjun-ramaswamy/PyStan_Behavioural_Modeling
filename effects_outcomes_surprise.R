# ------------------------------------------------------
# 1️⃣ Load Required Libraries
# ------------------------------------------------------
library(lme4)
library(lmerTest)
library(emmeans)
library(car)

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
# 3️⃣ Set Contrasts Manually for Type III ANOVA
# ------------------------------------------------------
# Ensure valid Type III ANOVA by setting sum-to-zero contrasts manually
contrasts(expectation_data$Value) <- "contr.sum"
contrasts(expectation_data$Outcome) <- "contr.sum"
print("⚙️ Contrasts manually set to contr.sum for Value and Outcome")

# ------------------------------------------------------
# 4️⃣ Full-Sample LME Analysis
# ------------------------------------------------------
print("🔄 Running LME model on all patients...")
lme_all <- lmer(LFP ~ Value * Outcome + (1 | Patient), data = expectation_data)
print("✅ LME model (all patients) complete.")
print(summary(lme_all))

# ------------------------------------------------------
# 5️⃣ Type III ANOVA on Full Model
# ------------------------------------------------------
print("🔍 Type III ANOVA on all patients:")
print(Anova(lme_all, type = 3))

# ------------------------------------------------------
# 6️⃣ Post-hoc Comparisons for Interaction
# ------------------------------------------------------
print("🔍 Post-hoc pairwise comparisons (Value × Outcome):")
posthoc_all <- emmeans(lme_all, pairwise ~ Value * Outcome, adjust = "bonferroni")
print(posthoc_all)

# ------------------------------------------------------
# 7️⃣ Patient-Specific Model (Patient 3 = ID 2) — Corrected
# ------------------------------------------------------
print("🔄 Running model for Patient 3 (ID 2 in file) with Type III ANOVA...")

# Subset for Patient 3
patient3_data <- subset(expectation_data, Patient == 2)

# Re-factor and set contrasts for Type III
patient3_data$Value <- factor(patient3_data$Value)
patient3_data$Outcome <- factor(patient3_data$Outcome)
contrasts(patient3_data$Value) <- "contr.sum"
contrasts(patient3_data$Outcome) <- "contr.sum"

# Fit standard two-way ANOVA model
aov_patient3 <- aov(LFP ~ Value * Outcome, data = patient3_data)

# Run Type III ANOVA
library(car)
print("✅ Type III ANOVA for Patient 3 complete.")
print(Anova(aov_patient3, type = 3))

# ------------------------------------------------------
# 8️⃣ Post-hoc for Patient 3
# ------------------------------------------------------
print("🔍 Post-hoc pairwise comparisons (Patient 3):")
emm_patient3 <- emmeans(aov_patient3, pairwise ~ Value * Outcome, adjust = "tukey")
print(emm_patient3)

# ✅ End of Script

#Visualizing estimated marginal means (all subjects

library(ggplot2)

# Extract from existing emmeans
plot_data <- as.data.frame(posthoc_all$emmeans)
plot_data$Value <- factor(plot_data$Value, labels = c("Low", "High"))
plot_data$Outcome <- factor(plot_data$Outcome, labels = c("Nothing", "Win"))
plot_data$CondLabel <- interaction(plot_data$Value, plot_data$Outcome, sep = "\n")

p <- ggplot(plot_data, aes(x = CondLabel, y = emmean, fill = Outcome)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = emmean - SE, ymax = emmean + SE), 
                width = 0.15, size = 0.6) +
  scale_fill_manual(values = c("gray60", "skyblue")) +
  labs(
    title = "LFP by Value × Outcome (All Subjects)",
    y = "Estimated LFP",
    x = NULL,
    fill = "Outcome"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    axis.line = element_line(color = "black"),
    axis.title.x = element_blank()
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", linewidth = 0.6)

# Add brackets with standard asterisk thresholds
p +
  # Low Val + Win vs Low Val + Nothing (p = 0.0028 → **)
  geom_segment(aes(x = 1, xend = 1, y = 2.0, yend = 2.2)) +
  geom_segment(aes(x = 1, xend = 3, y = 2.2, yend = 2.2)) +
  geom_segment(aes(x = 3, xend = 3, y = 2.2, yend = 2.0)) +
  annotate("text", x = 2, y = 2.3, label = "**", size = 5) +
  
  # Low Val + Win vs High Val + Nothing (p = 0.0009 → ***)
  geom_segment(aes(x = 2, xend = 2, y = 2.8, yend = 3.0)) +
  geom_segment(aes(x = 2, xend = 3, y = 3.0, yend = 3.0)) +
  geom_segment(aes(x = 3, xend = 3, y = 3.0, yend = 2.8)) +
  annotate("text", x = 2.5, y = 3.1, label = "***", size = 5) +
  
  # High Val + Win vs High Val + Nothing (p < 0.0001 → ***)
  geom_segment(aes(x = 2, xend = 2, y = 1.6, yend = 1.8)) +
  geom_segment(aes(x = 2, xend = 4, y = 1.8, yend = 1.8)) +
  geom_segment(aes(x = 4, xend = 4, y = 1.8, yend = 1.6)) +
  annotate("text", x = 3, y = 1.9, label = "***", size = 5)

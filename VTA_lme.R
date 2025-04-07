# ------------------------------------------------------
# 📦 Load Libraries
# ------------------------------------------------------
library(lme4)
library(lmerTest)
library(emmeans)
library(ggplot2)
library(tidyverse)
library(performance)
library(car)

# ------------------------------------------------------
# 📂 Load and Prepare Data
# ------------------------------------------------------
data <- read.csv("trialwise_lfp_cleaned.csv")
colnames(data) <- make.names(colnames(data))

data$Subj <- factor(data$Subj)
data$Trial_Type <- factor(data$Trial_Type, levels = c("Rew", "Loss", "Neu"))
data$Smoking <- factor(trimws(data$Smoking))
data$Outcome_Label <- factor(data$Outcome_Label, levels = c(-1, 1))
data$HAMD <- as.numeric(data$HAMD)
data$HIT6 <- as.numeric(data$HIT6)
data$SHAPS <- as.numeric(data$SHAPS)
data$Age <- as.numeric(data$Age)

# Impute missing SHAPS for LN_VTA1
subj_to_impute <- "LN_VTA1"
group_mean_shaps <- round(mean(data$SHAPS[data$Smoking == "No" & !is.na(data$SHAPS)], na.rm = TRUE))
data$SHAPS[data$Subj == subj_to_impute] <- group_mean_shaps

# ------------------------------------------------------
# 🎯 Contrast Coding
# ------------------------------------------------------
contrasts(data$Trial_Type) <- contr.sum(3)
contrasts(data$Smoking) <- contr.sum(2)
contrasts(data$Outcome_Label) <- contr.sum(2)

# ------------------------------------------------------
# 🧠 Fit 6 Models (3 formulas × 2 random structures)
# ------------------------------------------------------
model1_int <- lmer(LFP ~ Trial_Type * Outcome_Label + (1 | Subj), data = data)
model2_int <- lmer(LFP ~ Trial_Type * (Smoking + Outcome_Label) + (1 | Subj), data = data)
model3_int <- lmer(LFP ~ Trial_Type * (HAMD + HIT6 + SHAPS + Smoking + Outcome_Label) + (1 | Subj), data = data)

model1_slope <- lmer(LFP ~ Trial_Type * Outcome_Label + (1 + Trial_Type | Subj), data = data)
model2_slope <- lmer(LFP ~ Trial_Type * (Smoking + Outcome_Label) + (1 + Trial_Type | Subj), data = data)
model3_slope <- lmer(LFP ~ Trial_Type * (HAMD + HIT6 + SHAPS + Smoking + Outcome_Label) + (1 + Trial_Type | Subj), data = data)

# ------------------------------------------------------
# 📉 BIC Comparison for All 6 Models
# ------------------------------------------------------
model_bic <- BIC(model1_int, model2_int, model3_int, model1_slope, model2_slope, model3_slope)
rownames(model_bic) <- c("Model1_Intercept", "Model2_Intercept", "Model3_Intercept",
                         "Model1_Slope", "Model2_Slope", "Model3_Slope")
bic_df <- as.data.frame(model_bic)
bic_df$Model <- rownames(bic_df)
bic_df$Delta_BIC <- round(bic_df$BIC - min(bic_df$BIC), 2)
bic_df$Label <- c("1: Outcome\\n(Intercept)", "2: Smoke+Outcome\\n(Intercept)",
                  "3: Clinical+Smoke+Outcome\\n(Intercept)",
                  "1: Outcome\\n(Slopes)", "2: Smoke+Outcome\\n(Slopes)",
                  "3: Clinical+Smoke+Outcome\\n(Slopes)")
print(bic_df[order(bic_df$Delta_BIC), c("Model", "BIC", "Delta_BIC")])

# 🖼️ Plot ΔBIC with proper line breaks on x-axis labels
ggplot(bic_df, aes(x = reorder(Label, Delta_BIC), y = Delta_BIC)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = Delta_BIC), vjust = -0.5, size = 3.5) +
  labs(title = "ΔBIC from Best Model (Lower = Better)", x = "Model", y = "ΔBIC") +
  scale_x_discrete(labels = function(x) gsub("\\\\n", "\n", x)) +  # render \n as newline
  theme_minimal() +
  theme(axis.text.x = element_text(size = 9, angle = 12, hjust = 1))


# ------------------------------------------------------
# 🔁 LRT: Random Effects (Slope vs Intercept)
# ------------------------------------------------------
cat("\\n🔍 LRT: Model 1 (Outcome only) — Intercept vs Slope\\n")
print(anova(model1_slope, model1_int, test = "LRT"))

cat("\\n🔍 LRT: Model 2 (Smoke + Outcome) — Intercept vs Slope\\n")
print(anova(model2_slope, model2_int, test = "LRT"))

cat("\\n🔍 LRT: Model 3 (Clinical + Smoke + Outcome) — Intercept vs Slope\\n")
print(anova(model3_slope, model3_int, test = "LRT"))

# ------------------------------------------------------
# 🧪 LRT: Clinical Interactions (Model 3 vs Model 2)
# ------------------------------------------------------
cat("\\n🔍 LRT: Clinical Interactions — Slope Models (Model 3 vs Model 2)\\n")
print(anova(model3_slope, model2_slope, test = "LRT"))

cat("\\n🔍 LRT: Clinical Interactions — Intercept-Only Models (Model 3 vs Model 2)\\n")
print(anova(model3_int, model2_int, test = "LRT"))

# ------------------------------------------------------
# 🧪 LRT: Smoking Interaction — Model 2 vs Model 1
# ------------------------------------------------------
cat("\\n🔍 LRT: Does Smoking Interaction Improve Fit?\\n")
cat("\\nIntercept-only Models (Model 2 vs Model 1)\\n")
print(anova(model2_int, model1_int, test = "LRT"))

cat("\\nSlope Models (Model 2 vs Model 1)\\n")
print(anova(model2_slope, model1_slope, test = "LRT"))

# ------------------------------------------------------
# 📈 Post Hoc for Trial_Type (Main Effect) — All Models
# ------------------------------------------------------
posthoc_trialtype <- function(model, label) {
  cat(paste0("\\n📈 EMMs + Pairwise for Trial_Type — ", label, "\\n"))
  em <- emmeans(model, ~ Trial_Type)
  print(summary(em))
  pw <- contrast(em, method = "pairwise", adjust = "tukey")
  print(summary(pw))
}
posthoc_trialtype(model1_int, "Model 1 (Intercept Only)")
posthoc_trialtype(model2_int, "Model 2 (Intercept Only)")
posthoc_trialtype(model3_int, "Model 3 (Intercept Only)")
posthoc_trialtype(model1_slope, "Model 1 (With Slopes)")
posthoc_trialtype(model2_slope, "Model 2 (With Slopes)")
posthoc_trialtype(model3_slope, "Model 3 (With Slopes)")

# ------------------------------------------------------
# 🎯 Post Hoc: Interaction Trial_Type × Outcome_Label (Model 1)
# ------------------------------------------------------
cat("\\n📊 Post Hoc: Trial_Type × Outcome_Label (Model 1 Intercept Only)\\n")
em_interact <- emmeans(model1_int, ~ Trial_Type | Outcome_Label)
print(summary(em_interact))
print(summary(contrast(em_interact, method = "pairwise", adjust = "tukey")))


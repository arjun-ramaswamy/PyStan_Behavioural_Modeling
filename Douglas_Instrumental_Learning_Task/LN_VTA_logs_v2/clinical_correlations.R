# Install and load necessary packages
install.packages(c("readxl", "ggplot2"))
library(readxl)
library(ggplot2)

# Read the Excel file
data <- read_excel("VTA_scores.xlsx")

# Compute Pearson correlation and p-value
cor_test1 <- cor.test(data$`HAM-D`, data$`HIT-6`, method="pearson")
cor_test2 <- cor.test(data$`HIT-6`, data$reward_cluster1_mean, method="pearson")
cor_test3 <- cor.test(data$`HIT-6`, data$loss_cluster1_mean, method="pearson")
cor_test4 <- cor.test(data$`HAM-D`, data$reward_cluster1_mean, method="pearson")
cor_test5 <- cor.test(data$`HAM-D`, data$loss_cluster1_mean, method="pearson")
cor_test6 <- cor.test(data$`HIT-6`, data$reward_cluster2_mean, method="pearson")
cor_test7 <- cor.test(data$`HIT-6`, data$loss_cluster2_mean, method="pearson")
cor_test8 <- cor.test(data$`HAM-D`, data$reward_cluster2_mean, method="pearson")
cor_test9 <- cor.test(data$`HAM-D`, data$loss_cluster2_mean, method="pearson")


# Print correlation coefficient and p-value
cat("Correlation Coefficient:", cor_test9$estimate, "\n")
cat("P-value:", cor_test9$p.value, "\n")

# Plot the scatter plot with a linear regression line
plot <- ggplot(data, aes(x=`HAM-D`, y=`HIT-6`)) +
  geom_point(aes(color="blue"), size=3) + 
  geom_smooth(method="lm", se=FALSE, color="red") +
  theme_minimal() +
  labs(title="Scatter Plot of HAM-D vs. HIT-6",
       x="HAM-D (Depression Scores)", y="HIT-6") +
  theme(legend.position="none")

print(plot)

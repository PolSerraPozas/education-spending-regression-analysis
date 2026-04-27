# Education Spending Regression Analysis
# Author: Pol Serra Pozas
# Objective: Analyze relationships between education spending variables using linear regression in R.

# 1. Load libraries --------------------------------------------------------

library(readr)
library(lattice)


# 2. Load data -------------------------------------------------------------

education_data <- read_csv("GastoHogaresEduc.csv")
education_data <- data.frame(education_data)


# 3. Create outputs folder -------------------------------------------------

dir.create("outputs", showWarnings = FALSE)


# 4. Data filtering --------------------------------------------------------

education_spending <- subset(
  education_data,
  GTT > 0 & !is.na(GTT)
)

other_studies_data <- subset(
  education_spending,
  !is.na(C34A)
)


# 5. Other studies vs total education spending -----------------------------

model_other_studies <- lm(C34A ~ GTT, data = other_studies_data)

png("outputs/other_studies_vs_total_spending.png", width = 1000, height = 700)

plot(
  C34A ~ GTT,
  data = other_studies_data,
  main = "Other Studies Spending vs Total Education Spending",
  xlab = "Total education spending (GTT)",
  ylab = "Other studies spending (C34A)"
)

abline(model_other_studies, col = "red", lwd = 2)

dev.off()

summary(model_other_studies)

r2_other_studies <- cor(
  other_studies_data$GTT,
  other_studies_data$C34A,
  use = "complete.obs"
)^2

print(r2_other_studies)


# 6. Regulated and non-regulated education services ------------------------

model_regulated <- lm(GTSR ~ MCL, data = education_data)
model_non_regulated <- lm(GTSNR ~ MCL, data = education_data)

png("outputs/regulated_vs_tuition.png", width = 1000, height = 700)

plot(
  GTSR ~ MCL,
  data = education_data,
  main = "Regulated Services vs Tuition",
  xlab = "Tuition and classes spending (MCL)",
  ylab = "Regulated education services (GTSR)"
)

abline(model_regulated, col = "red", lwd = 2)

dev.off()


png("outputs/non_regulated_vs_tuition.png", width = 1000, height = 700)

plot(
  GTSNR ~ MCL,
  data = education_data,
  main = "Non-Regulated Services vs Tuition",
  xlab = "Tuition and classes spending (MCL)",
  ylab = "Non-regulated education services (GTSNR)"
)

abline(model_non_regulated, col = "red", lwd = 2)

dev.off()


r2_regulated <- cor(
  education_data$GTSR,
  education_data$MCL,
  use = "complete.obs"
)^2

r2_non_regulated <- cor(
  education_data$GTSNR,
  education_data$MCL,
  use = "complete.obs"
)^2

print(r2_regulated)
print(r2_non_regulated)


# 7. Prediction of regulated education services ----------------------------

tuition_values <- data.frame(
  MCL = c(200, 525, 735, 995, 1350)
)

predicted_regulated_spending <- predict(
  model_regulated,
  newdata = tuition_values
)

print(predicted_regulated_spending)


# 8. Relationship by type of education -------------------------------------

png("outputs/regulated_by_education_type.png", width = 1000, height = 700)

print(
  xyplot(
    GTSR ~ MCL,
    groups = C01,
    data = education_data,
    main = "Regulated Education Services vs Tuition by Education Type",
    xlab = "Tuition and classes spending (MCL)",
    ylab = "Regulated education services (GTSR)",
    auto.key = TRUE,
    type = c("p", "r")
  )
)

dev.off()


# 9. Prediction for private education --------------------------------------

models_by_education_type <- by(
  other_studies_data,
  other_studies_data$C01,
  function(df) lm(GTSR ~ MCL, data = df)
)

private_model <- models_by_education_type[["3"]]

private_predictions <- predict(
  private_model,
  newdata = tuition_values
)

print(private_predictions)


# 10. Summary of main results ----------------------------------------------

cat("\nR2 - Other studies vs total spending:", round(r2_other_studies, 4))
cat("\nR2 - Regulated services vs tuition:", round(r2_regulated, 4))
cat("\nR2 - Non-regulated services vs tuition:", round(r2_non_regulated, 4))
cat("\n\nPredictions for regulated education services:\n")
print(predicted_regulated_spending)
cat("\nPredictions for private education:\n")
print(private_predictions)

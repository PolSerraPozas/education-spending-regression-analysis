# Education Spending Regression Analysis
# Author: Pol Serra Pozas
# Objective: Analyze relationships between education spending variables using linear regression in R.

# 1. Load libraries --------------------------------------------------------

library(readr)
library(lattice)


# 2. Load data -------------------------------------------------------------

education_data <- read_csv("GastoHogaresEduc.csv")
education_data <- data.frame(education_data)


# 3. Data filtering --------------------------------------------------------

# Keep households with positive total education spending
education_spending <- subset(
  education_data,
  GTT > 0 & !is.na(GTT)
)

# Keep valid observations for the relationship between C34A and GTT
other_studies_data <- subset(
  education_spending,
  !is.na(C34A)
)


# 4. Relationship between other studies and total education spending --------

model_other_studies <- lm(C34A ~ GTT, data = other_studies_data)

plot(
  C34A ~ GTT,
  data = other_studies_data,
  main = "Other Studies Spending vs Total Education Spending",
  xlab = "Total education spending (GTT)",
  ylab = "Other studies spending (C34A)"
)

abline(model_other_studies, col = "red", lwd = 2)

summary(model_other_studies)

r2_other_studies <- cor(
  other_studies_data$GTT,
  other_studies_data$C34A,
  use = "complete.obs"
)^2

print(r2_other_studies)


# 5. Regulated and non-regulated education services ------------------------

model_regulated <- lm(GTSR ~ MCL, data = education_data)
model_non_regulated <- lm(GTSNR ~ MCL, data = education_data)

par(mfrow = c(1, 2))

plot(
  GTSR ~ MCL,
  data = education_data,
  main = "Regulated Services vs Tuition",
  xlab = "Tuition and classes spending (MCL)",
  ylab = "Regulated education services (GTSR)"
)

abline(model_regulated, col = "red", lwd = 2)

plot(
  GTSNR ~ MCL,
  data = education_data,
  main = "Non-Regulated Services vs Tuition",
  xlab = "Tuition and classes spending (MCL)",
  ylab = "Non-regulated education services (GTSNR)"
)

abline(model_non_regulated, col = "red", lwd = 2)

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

# Interpretation:
# The relationship between GTSNR and MCL is very weak.
# The relationship between GTSR and MCL is much stronger, suggesting that
# tuition spending is a better predictor of regulated education services.


# 6. Prediction of regulated education services ----------------------------

tuition_values <- data.frame(
  MCL = c(200, 525, 735, 995, 1350)
)

predicted_regulated_spending <- predict(
  model_regulated,
  newdata = tuition_values
)

print(predicted_regulated_spending)


# 7. Relationship by type of education -------------------------------------

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


# 8. Prediction for private education --------------------------------------

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
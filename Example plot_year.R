library(dplyr)
library(magrittr)
library(SpaDES)

set.seed(1)

modulePath <- "~/Documents/GitHub/McIntire-lab/modulesPrivate/"

# Define simulation parameters
times <- list(start = 1, end = 1, timeunit = "year")
modules <- list("fireSense_FrequencyFit", "fireSense_FrequencyPredict")
paths <- list(
  modulePath = modulePath
)

# Create random weather and fire frequency dataset
dummyData <- data.frame(
  weather = rep(1:100, each = 10),
  fireFrequency = rpois(1000, lambda=rep(10:1, each = 100)),
  year = rep(1:10, each = 100)
)


# Define module parameters
parameters <- list(
  fireSense_FrequencyFit = list(
    formula = fireFrequency ~ weather,
    family = poisson(),
    data = "dummyData"
  ),
  fireSense_FrequencyPredict = list(
    modelName = "fireSense_FrequencyFitted",
    data = "dummyData"
  )
)

# Objects to pass from the global environment to the simList environment
objects <- "dummyData"

# Create the simList
sim <- simInit(
  times = times, 
  params = parameters, 
  modules = modules, 
  objects = objects, 
  paths = paths
)

sim <- spades(sim)

# Prepare data
data <- bind_cols(dummyData, list(predicted_ff = sim$fireSense_FrequencyPredicted[[1]])) 

# Plot predictions versus observations
data %>%
  group_by(year) %>%
  summarise(observed = sum(fireFrequency), predicted = sum(predicted_ff)) %>%
  with(., plot(predicted ~ .$observed, xlim = c(150, 1200), ylim = c(150, 1200)))

# Predictions function as a covariate
with(data, plot(sim$fireSense_FrequencyPredicted[[1]] ~ weather, ylab = expression(Predicted~number~of~fires~occurrences), type = "l"))




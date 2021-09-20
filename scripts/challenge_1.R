# Loading necessary libs
library(tidyverse)
library(readxl)



# Getting working directory, sourcing theme and data folder
wd <- getwd()
data_dir <- paste(wd, "/data", sep = "")
source(paste(wd, "/scripts/theme.R", sep = ""))

# Loading data (and fixing jobID column to padronize)
cat <- read.csv(paste(data_dir, "/category.csv", sep = ""))
customer <- read.csv(paste(data_dir, "/customer.csv", sep = ""))
job_cost <- read.csv(paste(data_dir, "/jobCost.csv", sep = ""))
jobs <- read_excel(paste(data_dir, "/jobs.xlsx", sep = ""))

names(job_cost)[1] <- "jobId"

# Calculating total costs for jobs
job_cost$totalCost <- job_cost$marketingCost + job_cost$platformCost

# Since is cost per day, one needs to calculate mean cost for each job
mean_cost_per_job <- aggregate(
    x = job_cost$totalCost, by = list(job_cost$jobId), FUN = mean
)

names(mean_cost_per_job)[1] <- "jobId"
names(mean_cost_per_job)[2] <- "meanTotalCost"

# Now let`s grab the job category from the jobs dataframe
mean_cost_by_type <- merge(mean_cost_per_job, jobs[, c("jobId", "jobType")], by = "jobId")

# Computing mean cost by job type
mean_cost_by_type <- aggregate(
    x = mean_cost_by_type$meanTotalCost, by = list(mean_cost_by_type$jobType), FUN = mean
)

names(mean_cost_by_type)[1] <- "jobType"
names(mean_cost_by_type)[2] <- "meanTotalCost"

# Now make it visual! Let's plot this
p_mean_cost_type <- ggplot(mean_cost_by_type, aes(reorder(jobType, -meanTotalCost), meanTotalCost)) +
                        geom_col(color = "black", fill = "#3F0097", alpha = .4) +
                        geom_text(aes(jobType, meanTotalCost, label = round(meanTotalCost, 0)), vjust = 1, hjust = - 0.5) + # nolint
                        scale_y_continuous(limits = c(0, 110), breaks = seq(0, 110, by = 10)) +
                        ggtitle("Custo médio por tipo de vaga") +
                        labs(x = "Tipo de vaga", y = "Custo médio (R$)") +
                        coord_flip() +
                        challenge_theme_bary
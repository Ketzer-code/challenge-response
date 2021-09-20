# Loading necessary libs
library(tidyverse)
library(readxl)
library(RColorBrewer)

# Getting working directory, sourcing theme and data folder
wd <- getwd()
data_dir <- paste(wd, "/data", sep = "")
source(paste(wd, "/scripts/theme.R", sep = ""))

# Loading data (and fixing jobID and customerId column to padronize)
cat <- read.csv(paste(data_dir, "/category.csv", sep = ""))
customer <- read.csv(paste(data_dir, "/customer.csv", sep = ""))
job_cost <- read.csv(paste(data_dir, "/jobCost.csv", sep = ""))
jobs <- read_excel(paste(data_dir, "/jobs.xlsx", sep = ""))

names(job_cost)[1] <- "jobId"
names(customer)[1] <- "customerId"

# Next challenge - let's grab mean total costs by category, considering mean total cost per job as proxy for job cost
job_cost$totalCost <- job_cost$marketingCost + job_cost$platformCost

mean_cost_by_cat <- aggregate(
    x = job_cost$totalCost, by = list(job_cost$jobId), FUN = mean
)

names(mean_cost_by_cat) <- c("jobId", "meanTotalCost")

mean_cost_by_cat <- merge(mean_cost_by_cat, jobs[, c("jobId", "categoryId")], by = "jobId")

mean_cost_by_cat <- aggregate(
    x = mean_cost_by_cat$meanTotalCost, by = list(mean_cost_by_cat$categoryId), FUN = mean
)

names(mean_cost_by_cat) <- c("categoryId", "meanTotalCost")

# Cool - we'll use that to calculate price by job, but we need first to get customer type ids and names
mon_rev_by_client <- merge(jobs, customer, by = "customerId")

mon_rev_by_client <- merge(mon_rev_by_client, mean_cost_by_cat, by = "categoryId")

# Nice - let's calculate price by multplying mean total cost of category by customerTypeId and n open positions
mon_rev_by_client$price <- mon_rev_by_client$customerTypeID * mon_rev_by_client$meanTotalCost * mon_rev_by_client$openPositionAmnt # nolint

# Now we need to aggregate by month and client - first let's extract month from these strings
mon_rev_by_client$createdAtMonth <- strftime(mon_rev_by_client$createdAt, "%m") # nolint

mon_rev_by_client <- aggregate(
    mon_rev_by_client$price ~ mon_rev_by_client$customerName + mon_rev_by_client$createdAtMonth, FUN = sum
)

names(mon_rev_by_client) <- c("customerName", "month", "revenue")

# And that's done - let's make it visual!
p_mon_rev_by_client <- ggplot(mon_rev_by_client) +
                        geom_linerange(aes(x = month, ymin = 0, ymax = revenue, colour = customerName),
                        position = position_dodge(width = 1)) +
                        geom_point(aes(x = month, y = revenue, colour = customerName),
                        position = position_dodge(width = 1)) +
                        geom_text(aes(x = month, y = revenue, label = round(revenue, 0),
                        colour = customerName), vjust = - 0.5) +
                        facet_wrap(~customerName) +
                        scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                        "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
                        scale_y_continuous(limits = c(0, 4500), breaks = seq(0, 4500, by = 500)) +
                        ggtitle("Receita mensal por cliente - 2020") +
                        labs(x = "Mês", y = "Receita total (R$)", colour = "Cliente") +
                        scale_color_brewer(palette = "Dark2") +
                        challenge_theme_bary

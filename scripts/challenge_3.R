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
names(customer)[1] <- "customerId"

# Hopping to next challenge - we can easily aggregate monthly total revenue by using the same method as before
job_cost$totalCost <- job_cost$marketingCost + job_cost$platformCost # nolint

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
mon_rev_total <- merge(jobs, customer, by = "customerId")

mon_rev_total <- merge(mon_rev_total, mean_cost_by_cat, by = "categoryId")

# Nice - let's calculate price by multplying mean total cost of category by customerTypeId and n open positions
mon_rev_total$price <- mon_rev_total$customerTypeID * mon_rev_total$meanTotalCost * mon_rev_total$openPositionAmnt # nolint

# Now we need to aggregate by month only - first let's extract month from these strings
mon_rev_total$createdAtMonth <- strftime(mon_rev_total$createdAt, "%m") # nolint

# We shall not agrregate just right now - it will make sense later
# On a important notice - do you realize some jobs don't have costs in the job_cost database? That's why we'll
# use mean total cost by category as a proxy for the cost when it does not exist
mon_cost_total <- aggregate(
    x = job_cost$totalCost, by = list(job_cost$jobId), FUN = mean
)

names(mon_cost_total) <- c("jobId", "meanCostPerJob")

mon_cost_total <- merge(jobs[, c("jobId", "categoryId", "openPositionAmnt", "createdAt")], mon_cost_total, by = "jobId", all.x = TRUE) # nolint

mon_cost_total <- merge(mon_cost_total, mean_cost_by_cat, by = "categoryId")

# We will need to loop through the dataframe. R doesn't accept returning a vector of results with if statments
# Create a function and then apply in the loop - return the vector with appended values.

est_cost <- function(i, df, col1, col2, col3) {

    if (is.na(df[[i, col1]] == TRUE)) {
        total_job_cost <- df[[i, col2]] * df[[i, col3]]
    } else {
        total_job_cost <- df[[i, col1]] * df[[i, col3]]
    }
    return(total_job_cost)
}

total_cost <- vector(mode = "numeric", length = length(mon_cost_total))

for (i in seq_len(nrow(mon_cost_total))) {

    total_job_cost <- est_cost(i, mon_cost_total, "meanCostPerJob", "meanTotalCost", "openPositionAmnt")
    total_cost[i] <- total_job_cost
}

mon_cost_total$totalCost <- total_cost # nolint

# And that is done! Let's drop other columns to avoid further confusion
mon_cost_total$createdAt <- NULL
mon_cost_total$meanCostPerJob <- NULL 
mon_cost_total$meanTotalCost <- NULL 

# Remember how we did not aggregate total revenue by month just yet? The next task requires mean profit by client cat
# and job cat: just merge that now and avoid further confusion with data later!

profits <- merge(mon_cost_total, mon_rev_total[, c("jobId", "customerTypeID", "price", "createdAtMonth")], by = "jobId")
profits$profit <- profits$price - profits$totalCost

# Save that to workingdir:
write.csv(profits, paste(data_dir, "/profits.csv", sep = ""))

# Now to the matter at hand - aggregate profit by month:

monthly_profit <- aggregate(
    x = profits$profit, by = list(profits$createdAtMonth), FUN = sum
)

names(monthly_profit) <- c("month", "profit")


# GG(plot) - let's make it visual then
p_mon_profit <- ggplot(monthly_profit, aes(month, profit, group = 1)) +
                    geom_line(color = "#3F0097", alpha = .4) +
                    geom_text(aes(month, profit, label = round(profit, 0)), vjust = - 1) +
                    scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                        "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
                    scale_y_continuous(limits = c(0, 5500), breaks = seq(0, 5500, by = 500)) +
                    geom_point() +
                    ggtitle("Lucro mensal - 2020") +
                    labs(x = "Mês", y = "Lucro (R$)") +
                    challenge_theme_line
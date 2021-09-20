# Loading necessary libs
library(tidyverse)
library(readxl)
library(data.table)


# Getting working directory, sourcing theme and data folder
wd <- getwd()
data_dir <- paste(wd, "/data", sep = "")
source(paste(wd, "/scripts/theme.R", sep = ""))

# Loading data (and fixing jobID column to padronize)
cat <- read.csv(paste(data_dir, "/category.csv", sep = ""))
customer <- read.csv(paste(data_dir, "/customer.csv", sep = ""))
job_cost <- read.csv(paste(data_dir, "/jobCost.csv", sep = ""))
jobs <- read_excel(paste(data_dir, "/jobs.xlsx", sep = ""))
profits <- read.csv(paste(data_dir, "/profits.csv", sep = ""))

names(job_cost)[1] <- "jobId"
names(cat)[1] <- "categoryId"
profits$X <- NULL

# Next challenge! We thankfully have profit per job - but why is that good?
# We'll have an 14% percent increase in cats sales and tech, 8% for the rest; plus 2
# type 10 clients, 4 type 12 and 1 type 14 more next year.

# We can't really know when these will come. What we can do is calculate total profit
# for these now, calculate the total resulting increase and distribute evenly through
# the year - neat right? Not exactly linear regression but works fine

# Firstly, shall we grab category name? This will make our lifes easier later
profits <- merge(profits, cat, by = "categoryId")

# Cool - now we need to know mean profit by category and how many jobs per cat we have
mean_profit_by_cat <- aggregate(
    profits$profit ~ profits$categoryName + profits$categoryId, FUN = mean
)

total_jobs_by_cat <- aggregate(
    profits$openPositionAmnt ~ profits$categoryName + profits$categoryId, FUN = sum
)

names(mean_profit_by_cat) <- c("categoryName", "categoryId", "meanProfit")
names(total_jobs_by_cat) <- c("categoryName", "categoryId", "totalJobs")

# And merge all that up:
cat_profit <- merge(
    mean_profit_by_cat, total_jobs_by_cat[, c("categoryId", "totalJobs")],
    by = "categoryId"
)

# We shall calculate the costs too - this will be important to answer some questions later
mean_cost_by_cat <- aggregate(
    profits$totalCost ~ profits$categoryName + profits$categoryId, FUN = mean
)

names(mean_cost_by_cat) <- c("categoryName", "categoryId", "meanTotalCost")

cat_profit_costs <- merge(cat_profit, mean_cost_by_cat, by = "categoryId")

names(cat_profit_costs)[2] <- "categoryId"
cat_profit_costs$categoryName.y <- NULL 

# Now to do the same for customer type, and also to collect total n customers
mean_profit_by_customer <- aggregate(
    profits$profit ~ profits$customerTypeID, FUN = mean
)

total_customers_by_type <- data.frame(table(customer$customerTypeID))

names(total_customers_by_type) <- c("customerTypeId", "totalCustomers")
names(mean_profit_by_customer) <- c("customerTypeId", "meanProfit")

# Merge it up:
cust_type_profit <- merge(mean_profit_by_customer, total_customers_by_type, by = "customerTypeId")

# Calculate the costs again
cost_by_client_type <- aggregate(
    profits$totalCost ~ profits$customerTypeID, FUN = mean
)

names(cost_by_client_type) <- c("customerTypeId", "meanTotalCost")

cust_type_profit_costs <- merge(cust_type_profit, cost_by_client_type, by = "customerTypeId")

# We'll approach it this way: an x increase in customerTypeID will imply an mean increase of y in
# profit, according to mean profit for each category, for both cases. For jobs, we shall compute
# how much jobs there would be with that % increase, and each + job will imply in one mean increase:
# for client types, is fairly straightforward - + 2 type 10 clients will imply in 2 * the mean increase
# in profit.

# First, let's do jobs - since it's a less than 10 lines dataframe, let's keep it simple and manual:

cat_profit$forecastTotalJobs <- NA # nolint

cat_profit$forecastTotalJobs[1] <- round(cat_profit$totalJobs[1] * 1.14, 0)
cat_profit$forecastTotalJobs[3] <- round(cat_profit$totalJobs[3] * 1.14, 0)
cat_profit$forecastTotalJobs[2] <- round(cat_profit$totalJobs[2] * 1.08, 0)
cat_profit$forecastTotalJobs[4] <- round(cat_profit$totalJobs[4] * 1.08, 0)

# Just compute the difference between actual and forecasted and multiply by mean profit to get profit increase
cat_profit$forecastedProfitIncrease <- (cat_profit$forecastTotalJobs - cat_profit$totalJobs) * cat_profit$meanProfit # nolint

# Now for customer types
cust_type_profit$forecastTotalCustomer <- NA # nolint 

cust_type_profit$forecastTotalCustomer[1] <- cust_type_profit$totalCustomers[1] + 2
cust_type_profit$forecastTotalCustomer[3] <- cust_type_profit$totalCustomers[3] + 4
cust_type_profit$forecastTotalCustomer[4] <- cust_type_profit$totalCustomer[4] + 1

cust_type_profit$forecastedProfitIncrease <- (cust_type_profit$forecastTotalCustomer - cust_type_profit$totalCustomers) * cust_type_profit$meanProfit # nolint

# Done and done - now all we need to do is calculate total forecasted profit increase
cust_total_profit_inc <- sum(cust_type_profit$forecastedProfitIncrease, na.rm = TRUE)
cat_total_profit_inc <- sum(cat_profit$forecastedProfitIncrease)

total_profit_inc <- cust_total_profit_inc + cat_total_profit_inc

# Get forecasted profit by summing 2020 profit with forecasted profit increase - we'll use that later
forecasted_profit <- sum(profits$profit) + total_profit_inc

# Aggregate 2020 profits by month:
monthly_profit <- aggregate(
    x = profits$profit, by = list(profits$createdAtMonth), FUN = sum
)

names(monthly_profit) <- c("month", "profit")

# Forecasted monthly profit will be profit + total_profit_inc/12: 

monthly_profit$forecastedProfit <- monthly_profit$profit + total_profit_inc / 12 # nolint


# The sum matches forecasted total profit! Before visualizing, melt it - it will be easier, trust me.
monthly_profit <- reshape2::melt(monthly_profit, measure.vars = c("profit", "forecastedProfit"),
                                    variable.name = "forecastOrCurrent", value.name = "profit")

# Done! Now, make it visual.
p_mon_profit <- ggplot(monthly_profit, aes(x = factor(month),
                y = profit, group = forecastOrCurrent, colour = forecastOrCurrent)) +
    geom_line(alpha = .4) +
    geom_point(alpha = .4) +
    geom_text(aes(factor(month), profit, label = round(profit, 0)), vjust = - 1) +
    scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                        "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
    scale_y_continuous(limits = c(0, 6000), breaks = seq(0, 6000, by = 500)) +
    scale_colour_manual(name = "2020 x 2021", breaks = c("profit", "forecastedProfit"),
    labels = c("2020", "2021"), values = c("#3F0097", "#006400")) +
    ggtitle("Lucro mensal 2020 e lucro mensal previsto 2021") +
    labs(x = "Mês", y = "Lucro (R$)") +
    challenge_theme_line

# And that's it for coding graphs and calculating things! Hope you enjoyed your journey & that code is properly
# clean!

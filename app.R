# Importing libs
library(shiny)
library(shinydashboard)
library(tidyverse)
library(RColorBrewer)
library(data.table)

# Getting working directory & sourcing theme script
wd <- getwd()
source(paste(wd, "/scripts/theme.R", sep = ""))

# Sourcing data
mean_cost_by_type <- read.csv(paste(wd, "/plot_data/mean_cost_by_type.csv", sep = ""))
mon_rev_by_client <- read.csv(paste(wd, "/plot_data/mon_rev_by_client.csv", sep = ""))
monthly_profit <- read.csv(paste(wd, "/plot_data/monthly_profit.csv", sep = ""))
monthly_profit_forecast <- read.csv(paste(wd, "/plot_data/monthly_profit_forecast.csv", sep = ""))

costs_profits_cust_type <- read.csv(paste(wd, "/plot_data/cust_type_profit_costs.csv", sep = ""))
costs_profits_cat <- read.csv(paste(wd, "/plot_data/cat_profit_costs.csv", sep = ""))

# Making some adjustments to costs and profits databases
costs_profits_cust_type$X <- NULL 
costs_profits_cat$X <- NULL

names(costs_profits_cat)[2] <- "categoryName"

mean_cost_by_type$jobType <- iconv(mean_cost_by_type$jobType, from = "latin1", to = "UTF-8")

costs_profits_cust_type <- reshape2::melt(costs_profits_cust_type, measure.vars = c("meanProfit", "meanTotalCost"),
                                            variable.name = "profitOrCost", value.name = "value")

costs_profits_cat <- reshape2::melt(costs_profits_cat, measure.vars = c("meanProfit", "meanTotalCost"),
                                        variable.name = "profitOrCost", value.name = "value")

# Plotting mean total profits and costs by client type id
p_costs_profits_cat <- ggplot(costs_profits_cat, aes(reorder(categoryName, -value), value, fill = profitOrCost)) +
                            geom_col(color = "black", alpha = .4, position = "dodge") +
                            geom_text(aes(categoryName, value, label = round(value, 0)), vjust = - 1, hjust = 0.5,
                            position = position_dodge(width = 1)) +
                            scale_y_continuous(limits = c(0, 2000), breaks = seq(0, 2000, by = 500)) +
                            scale_fill_manual(name = "Lucro x Gasto", values = c("#3F0097", "#006400"),
                            breaks = c("meanProfit", "meanTotalCost"), labels = c("Lucro", "Gasto")) +
                            ggtitle("Custos e lucros médios por categoria de vaga") +
                            labs(x = "Categoria de vaga", y = "Valor médio (R$)") +
                            challenge_theme_barx

p_costs_profits_cust_type <- ggplot(costs_profits_cust_type, aes(reorder(factor(customerTypeId), -value), value, fill = profitOrCost)) + # nolint
                                geom_col(color = "black", alpha = .4, position = "dodge") +
                                geom_text(aes(factor(customerTypeId), value, label = round(value, 0)), 
                                vjust = - 1, hjust = 0.5,
                                position = position_dodge(width = 1)) +
                                scale_y_continuous(limits = c(0, 1200), breaks = seq(0, 1200, by = 200)) +
                                scale_fill_manual(name = "Lucro x Gasto", values = c("#3F0097", "#006400"),
                                breaks = c("meanProfit", "meanTotalCost"), labels = c("Lucro", "Gasto")) +
                                ggtitle("Custos e lucros médios por tipo de cliente") +
                                labs(x = "Tipo de cliente", y = "Valor médio (R$)") +
                                challenge_theme_barx

# Making challenge plots locally to avoid problems with character encoding
p_mean_cost_type <- ggplot(mean_cost_by_type, aes(reorder(jobType, -meanTotalCost), meanTotalCost)) +
                        geom_col(color = "black", fill = "#3F0097", alpha = .4) +
                        geom_text(aes(jobType, meanTotalCost, label = round(meanTotalCost, 0)), vjust = 1, hjust = - 0.5) + # nolint
                        scale_y_continuous(limits = c(0, 110), breaks = seq(0, 110, by = 10)) +
                        ggtitle("Custo médio por tipo de vaga") +
                        labs(x = "Tipo de vaga", y = "Custo médio (R$)") +
                        coord_flip() +
                        challenge_theme_bary

p_mon_rev_by_client <- ggplot(mon_rev_by_client) +
                        geom_linerange(aes(x = factor(month), ymin = 0, ymax = revenue, colour = customerName),
                        position = position_dodge(width = 1)) +
                        geom_point(aes(x = factor(month), y = revenue, colour = customerName),
                        position = position_dodge(width = 1)) +
                        geom_text(aes(x = factor(month), y = revenue, label = round(revenue, 0),
                        colour = customerName), vjust = - 0.5) +
                        facet_wrap(~customerName) +
                        scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                        "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
                        scale_y_continuous(limits = c(0, 4500), breaks = seq(0, 4500, by = 500)) +
                        ggtitle("Receita mensal por cliente - 2020") +
                        labs(x = "Mês", y = "Receita total (R$)", colour = "Cliente") +
                        scale_color_brewer(palette = "Dark2") +
                        challenge_theme_bary

p_mon_profit <- ggplot(monthly_profit, aes(factor(month), profit, group = 1)) +
                    geom_line(color = "#3F0097", alpha = .4) +
                    geom_text(aes(factor(month), profit, label = round(profit, 0)), vjust = - 1) +
                    scale_x_discrete(labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                        "Jul", "Ago", "Set", "Out", "Nov", "Dez")) +
                    scale_y_continuous(limits = c(0, 5500), breaks = seq(0, 5500, by = 500)) +
                    geom_point() +
                    ggtitle("Lucro mensal - 2020") +
                    labs(x = "Mês", y = "Lucro (R$)") +
                    challenge_theme_line

p_mon_profit_forecast <- ggplot(monthly_profit_forecast, aes(x = factor(month),
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

# Creating UI
 ui <- dashboardPage(
    skin = "purple",
    dashboardHeader(title = "Empresa X", titleWidth = 250),
    dashboardSidebar(
        width = 250,
        sidebarMenu(
             menuItem("Lucro - 2020 e 2021", tabName = "profits", icon = icon("chart-line")),
             menuItem("Custos e receitas - 2020", tabName = "costsRevenue", icon = icon("hand-holding-usd")),
             menuItem("Lucro e custos médios - 2020", tabName = "profitCosts", icon = icon("search-dollar")),
             menuItem("Insights", tabName = "insights", icon = icon("lightbulb"))
         )),
    dashboardBody(
        tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "font.css")
        ),
        tabItems(
            # First tab content
            tabItem(
            tabName = "profits",
            h1("Séries mensais - lucro", style = "text-align: center;"),
            br(),
            fluidRow(
                column(12, box(plotOutput("plot3"), width = "100%", align = "center")),
                column(12, box(plotOutput("plot4"), width = "100%", align = "center"))
            )
            ),
            # Second tab content
            tabItem(
                tabName = "costsRevenue",
                h1("Custos e receitas", style = "text-align: center;"),
                br(),
                fluidRow(
                    column(12, box(plotOutput("plot1"), width = "100%", align = "center")),
                    column(12, box(plotOutput("plot2"), width = "100%", align = "center"))
                )
            ),
            # Third tab content
            tabItem(
                tabName = "profitCosts",
                h1("Lucro e custos médios", style = "text-align: center;"),
                h2("Segmentação por tipo de cliente e categoria de vaga", style = "text-align: center;"),
                br(),
                fluidRow(
                    column(12, box(plotOutput("plot5"), width = "100%", align = "center")),
                    column(12, box(plotOutput("plot6"), width = "100%", align = "center"))
                )
            ),
            # Fourth tab content
            tabItem(
                tabName = "insights",
                h1("Tomando posse dos dados:", style = "text-align: center;"),
                h2("O que podemos fazer com essas informações?", style = "text-align: center;"),
                br(),
                tags$ol(
                    tags$li("As categorias de vaga com maior lucro são tecnologia e atendimento"),
                    p("Embora o lucro previsto para 2021 seja consistentemente maior
                    do que o lucro previsto para 2020 - considerando um aumento de 14%
                    nas vagas de tecnologia e atendimento -, o plano de crescimento poderia
                    ser otimizado para aumentar mais vagas em atendimento e tecnologia,
                    ao invés de tecnologia e vendas.", style = "font-size: 15px;"),
                    br(),
                    tags$li("Os clientes com maior retorno são tipo 14 e 10"),
                    p("A empresa planejou sua expansão para adquirir mais clientes do
                    tipo 14 e 12, porém clientes do tipo 12 geram os menores retornos:
                    o plano de expansão poderia ser redirecionado para reduzir futuros
                    investimentos em clientes do tipo 12, focando em clientes do tipo
                    14 e 10.", style = "font-size: 15px;"),
                    br(),
                    tags$li("Vagas de administrativo e vendas geraram menor retorno, assim como clientes do tipo 11 e 12"), # nolint
                    p("Apesar destes clientes terem gerado os menores retornos,
                    um número de aquisições maior poderia ser possivelmente vantajoso,
                    desde que gastos em marketing não aumentassem consideravelmente,
                    e que clientes o suficiente fossem captados.", style = "font-size: 15px;"),
                    br(),
                    tags$li("Tomando decisões: investindo em lucro"),
                    p("Caso haja segurança quanto aos retornos futuros gerados por
                    clientes do tipo 14 e 10, bem como de vagas de tecnologia e atendimento,
                    recomenda-se que os investimentos sejam direcionados para estas áreas. É
                    importante destacar, entretanto, que elas também possuem custos consideráveis:
                    caso haja um aumento nos custos, ou uma queda na demanda nas áreas citadas,
                    essa pode não ser a melhor abordagem - atente-se à demanda por profissionais
                    destas áreas e estude cuidadosamente o potencial retorno destes clientes.",
                    style = "font-size: 15px;"),
                    br(),
                    tags$li("Tomando decisões: investido em custo"),
                    p("Outras categorias de vagas e tipos de clientes não geram tanto lucro,
                    porém se a demanda de mercado por tais categorias de vagas e a quantidade
                    de vagas demandada por estes tipos de cliente forem grandes o suficiente,
                    esta pode ser uma abordagem vantajosa. Cuidado, no entanto, com custos
                    de marketing: atrair um número de clientes o suficiente pode acabar saindo
                    pela culatra se os custos de atraí-los superar o lucro que teria sido obtido
                    com clientes que geram mais retornos.", style = "font-size: 15px;"),
                    br(),
                    style = "font-size: 20px;"
                )
            )
        )
    )
 )


server <- function(input, output) {

    output$plot1 <- renderPlot(
        {p_mean_cost_type}
    )

    output$plot2 <- renderPlot(
        {p_mon_rev_by_client}
    )

    output$plot3 <- renderPlot(
        {p_mon_profit}
    )

    output$plot4 <- renderPlot(
        {p_mon_profit_forecast}
    )

    output$plot5 <- renderPlot(
        {p_costs_profits_cat}
    )

    output$plot6 <- renderPlot(
        {p_costs_profits_cust_type}
    )

 }

shinyApp(ui = ui, server = server)

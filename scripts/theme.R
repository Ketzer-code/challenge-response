# Importing libs
library(ggplot2)
library(extrafont)

# Getting working directory for font import
wd <- getwd()

font_import(path = paste(wd, "/font", sep = ""))


challenge_theme_barx <- theme(panel.background = element_rect(fill = "#FFFFFF"),
                        plot.background = element_rect(fill = "#FFFFFF"),
                        plot.title = element_text(family = "Ubuntu", color = "#000000", size = 16, face = "bold", hjust = 0.5), # nolint
                        axis.title.x = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = -0.5), # nolint
                        axis.title.y = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = 2), # nolint
                        panel.grid = element_line(color = "#F9F9F9"),
                        panel.grid.major.x = element_line(color = "#E6E6E6"),
                        panel.grid.minor.x = element_line(color = "#E6E6E6"),
                        axis.text = element_text(family = "Ubuntu", color = "#808080"))

challenge_theme_bary <- theme(panel.background = element_rect(fill = "#FFFFFF"),
                        plot.background = element_rect(fill = "#FFFFFF"),
                        plot.title = element_text(family = "Ubuntu", color = "#000000", size = 16, face = "bold", hjust = 0.5), # nolint
                        axis.title.x = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = -0.5), # nolint
                        axis.title.y = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = 2), # nolint
                        legend.title = element_text(family = "Ubuntu", color = "#808080", size = 14),
                        legend.text = element_text(family = "Ubuntu", size = 12),
                        panel.grid = element_line(color = "#F9F9F9"),
                        panel.grid.major.y = element_line(color = "#E6E6E6"),
                        panel.grid.minor.y = element_line(color = "#E6E6E6"),
                        axis.text = element_text(family = "Ubuntu", color = "#808080", size = 12))

challenge_theme_line <- theme(panel.background = element_rect(fill = "#FFFFFF"),
                plot.background = element_rect(fill = "#FFFFFF"),
                plot.title = element_text(family = "Ubuntu", color = "#000000", size = 16, face = "bold", hjust = 0.5),
                axis.title.x = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = -0.5),
                axis.title.y = element_text(family = "Ubuntu", color = "#808080", size = 14, face = "bold", vjust = 2),
                panel.grid.major.y = element_line(color = "#E6E6E6"),
                panel.grid.minor.y = element_line(color = "#E6E6E6"),
                legend.title = element_text(color = "#000000", family = "Ubuntu"),
                legend.text = element_text(color = "#000000", family = "Ubuntu"),
                panel.border = element_rect(fill = NA))
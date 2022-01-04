
library("ggplot2")

p2 <- ggplot(data = my.df2, aes(x = vaccinated_population, y = max_infected_time, 
                          group = vaccinated_population )) + 
        geom_boxplot() + facet_wrap ( ~ average_immune_time)

p2

p2 + labs(title = "Peak Time of Outbreak with 
         \nVaccinated Population proportion and Immunity Duration",
         x = "Initial Vaccinated Population",
         y = "Peak Time of Outbreak (days)")





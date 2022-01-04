
my.df2<-read.csv('/Users/heekim/Ass1-ori_results.csv', 
                      header = T,    # set columns names true
                      sep = ",",     # define the separator between columns
                      skip = 6,      # skip first 6 rows
                      quote = "\"",  # correct the column separator
                      fill = TRUE
)

# view (myrm(.df)
boxplot(total_infected~average_immune_time,
        data = my.df.new ,
        col = "grey",
        main = "Total number of infected cases - Initial Vaccination",
        xlab = "Initial Vaccination (%)",
        ylab = "Total number of infected (cases)"
        
        #        total_infected~average_immune_time,
        #        data = my.df.new ,
        #        col = "grey",
        #        main = "Total number of infected cases - Initial Vaccination",
        #        xlab = "Initial Vaccination (%)",
        #        ylab = "Total number of infected (cases)"
)

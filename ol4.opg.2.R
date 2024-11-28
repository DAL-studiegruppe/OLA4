library(DBI)
library(RMariaDB)
library(dplyr)
library(lubridate)

# Først sæt miljøvariablen
readRenviron(".Renviron")

# Derefter brug den i forbindelsen
bil_con <- dbConnect(MariaDB(),
                  dbname = "bilbasen",
                  host = "localhost",
                  port = 3306,
                  user = "root",
                  password = Sys.getenv("password")
)

dbWriteTable(bil_con,"merged_df",merged_df_final)
dbWriteTable(bil_con,"sim_df",sim_df)
dbWriteTable(bil_con,"first_scrape",adf)
dbWriteTable(bil_con,"nyebiler",nyebiler)

saveRDS(merged_df_final,"merged_df_final.rds")
saveRDS(sim_df,"sim_df.rds")
saveRDS(adf,"all_cars.rds")
saveRDS(nyebiler,"car_database.rds")



library(dplyr)
library(ggplot2)
#Dowloading data and organizing it
datadir <- './data'
neidataurl<-'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
neidatazip  <- './data/neidata.zip'
neidatadir <- './data/neidata'

if(!dir.exists(datadir)){
        dir.create(datadir)
}

if(!file.exists(neidatazip)){
        download.file(url = neidataurl,destfile = neidatazip,method = 'curl')
}else if(!dir.exists(paths = neidatadir)){
        dir.create(path = neidatadir)
        unzip(zipfile = neidatazip,exdir = neidatadir)
}


#Reading the data into R
datafilenames <- dir(neidatadir)
filepaths<- list()
for(fl in datafilenames){
        column <- sub(pattern = '[.]rds$',replacement = '',x = fl)
        filepaths[column] <- paste0(neidatadir,'/',fl)
}

neismry <- readRDS(filepaths[[2]])
neisrc <- readRDS(filepaths[[1]])

#Joining source and summary data 
nei <- left_join(x = neismry,y = neisrc,"SCC")

#looking for rows of interest with reg ex
ofinterest <- grepl('[vV]ehicle',nei$Short.Name)
 
totalyear <- nei %>% 
        filter(SCC.Level.One == 'Mobile Sources' & ofinterest) %>%
        filter(fips == '24510' | fips=='06037') %>%
        group_by(fips,year) %>% summarise(total = sum(Emissions)) %>%
        select(fips,year,total) %>% 
        mutate(city = ifelse(fips == '24510','Baltimore','Los Angeles'))

#plotting
png('./plot6.png',width = 480,height = 480)  

g<-ggplot(data = totalyear, aes(x = year,y = total)) + 
        geom_point() +
        geom_line() +
        facet_wrap(. ~ city,nrow = 2,ncol = 1)
        theme_bw() + 
        labs(title = 'Motor vehicle total emissions from 1999 to 2008') +
        labs(y = 'Total PM2.5 emission (ton)')  
print(g)

dev.off()

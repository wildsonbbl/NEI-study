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

totalyear <- neismry %>% filter(fips == '24510') %>%
        group_by(type,year) %>% summarise(total = sum(Emissions)) %>%
        select(type,year,total)

png('./plot3.png',width = 480,height = 480)  

g<-ggplot(data = totalyear, aes(x = year,y = total)) + 
        geom_point() +
        geom_line() +
        facet_wrap(. ~ type,nrow = 2,ncol = 2) +
        theme_bw() + 
        labs(title = 'Total emissions from 1999 to 2008 in Baltimore/MA') +
        labs(y = 'Total PM2.5 emission (ton)')  
print(g)

dev.off()

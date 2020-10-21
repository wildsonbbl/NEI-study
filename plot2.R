library(dplyr)
#Dowloading data and organizing it
datadir <- './data'
neidataurl <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
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

neisrc <- readRDS(filepaths[[1]])
neismry <- readRDS(filepaths[[2]])

totalyear <- neismry %>% filter(fips == '24510') %>%
        group_by(year) %>% summarise(total = sum(Emissions)) %>%
        select(year,total)

png('./plot2.png',width = 480,height = 480)
with(totalyear, plot(x = year,y = total,type = 'b',
                     main = 'Total emissions from 1999 to 2008 in Baltimore, Maryland',
                     ylab = 'Total PM2.5 emission (ton)',pch = 19))
dev.off()

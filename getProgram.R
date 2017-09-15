cat("#####################", '\n',
    "# Step: get PROGRAM #", '\n',
    "#####################", '\n', sep = "")

# create data directory
dir.create("data/program/", showWarnings = FALSE, recursive = TRUE)

# load libraries
library(seleniumPipes)
library(RSelenium)
library(xml2)
library(rvest)
library(stringr)
library(dplyr)

# self-defined functions to control the fake web browser

# log-in function
myLogin = function(remDr, account, password){
    
    # xpath holder
    sign_in_button1 = '//*[@id="status"]/li[2]/a'
    account_text    = '/html/body/div[5]/div/div/form/div[2]/div[1]/input'
    password_text   = '/html/body/div[5]/div/div/form/div[2]/div[2]/input'
    sign_in_button2 = '/html/body/div[5]/div/div/form/div[3]/button[2]'
    
    # go to main page
    remDr %>% go(url = "https://www.applysquare.com")
    
    # click [Sign in] button
    remDr %>% 
        findElement(using = 'xpath', value = sign_in_button1) %>%
        elementClick()
    
    Sys.sleep(3)
    
    # send [accont]
    remDr %>%
        findElement(using = 'xpath', value = account_text) %>%
        elementSendKeys(account)
    
    # send [password]
    remDr %>%
        findElement(using = 'xpath', value = password_text) %>%
        elementSendKeys(password)
    
    # click [Sign in]
    remDr %>%
        findElement(using = 'xpath', value = sign_in_button2) %>%
        elementClick()
    
    Sys.sleep(6)
    
    return(NULL)
    
}

# open url function
myDriver = function(url, remDr){
    
    cat("WAIT\n")
    
    # navigate to url
    remDr %>% go(url)
    xml = remDr %>% getPageSource()
    
    # return html
    return(xml)
    
}

########################################################

# load necessary data file
load("data/PROGRAM.LINK.RData")

# run Selenium Server
rD = rsDriver()
# connect to a running server
remDr = remoteDr(port = "YOUR_PORT", browserName = "chrome")

# your account and password for applysquare.com
account = "YOUR_EMAIL"
password = "YOUR_PASSWORD"
myLogin(remDr, account, password)

tmp_N = length(PROGRAM.LINK$prog.link)

for(tmp_i in 1:tmp_N){

    if(mod(tmp_i, 500) == 0){
        cat("[RESTART CHROME]\n")
        # restart the fake web browser
        # close all windows
        remDr %>% closeWindow()
        # close the server
        rD$server$stop()
        # have a rest
        Sys.sleep(6)
        # run Selenium Server
        rD = rsDriver()
        # connect to a running server
        remDr = remoteDr(port = 4567L, browserName = "chrome")
        # log-in
        myLogin(remDr, account, password)
    }

    cat("[NEW]\n")

    tmp_link = PROGRAM.LINK$prog.link[tmp_i]
    tmp_page = myDriver(tmp_link, remDr)

    cat("LOAD PAGE SUCCESS\n")

    tmp_file = tmp_link %>%
        str_extract("program-en/.+/$") %>%
        str_replace("program-en/", "") %>%
        str_replace_all("/", "")
    write_html(tmp_page, file = paste0("data/program/",
                                       tmp_file, ".html"))

    cat("WRITE FILE SUCCESS\n")

    cat(sprintf("%d/%d = %4.3f%%", tmp_i, tmp_N, 100*tmp_i/tmp_N), '\n')

}

rm(list = ls(pattern = "tmp|d_"))

# close all windows
remDr %>% closeWindow()
# close the server
rD$server$stop()

cat("#######################", '\n',
    "# Finish: get PROGRAM #", '\n',
    "#######################", '\n', sep = "")

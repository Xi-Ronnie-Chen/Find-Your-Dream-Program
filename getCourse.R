cat("##########################", '\n',
    "# Step: get COURSE HTMLs #", '\n',
    "##########################", '\n', sep = "")

# create data directory
dir.create("data/course/", showWarnings = FALSE, recursive = TRUE)

# load libraries
library(rvest)
library(stringr)
library(dplyr)

url_base  = "https://www.applysquare.com"
url_major = "https://www.applysquare.com/fos-en/"

page = read_html(url_major)

res_major = page %>%
    html_nodes("#content a") %>%
    html_text() %>%
    .[. != ""]

links_major = page %>%
    html_nodes("#content a") %>%
    html_attr("href") %>%
    .[. != ""] %>% .[!is.na(.)]

for(tmp_i in seq_along(links_major)){
    tmp_link = links_major[tmp_i]
    tmp_major = tmp_link %>%
        str_replace("fos-en", "") %>%
        str_replace_all("/", "") %>%
        str_c(".html")
    # start to learn
    tmp_link %>% 
        str_replace("/$", "-learn/") %>%
        paste0(url_base, .) %>%
        download.file(destfile = paste0("data/course/", tmp_major), quiet = TRUE)
    cat(tmp_major, '\n')
}

rm(list = ls(pattern = "tmp|d_"))

cat("############################", '\n',
    "# Finish: get COURSE HTMLs #", '\n',
    "############################", '\n', sep = "")
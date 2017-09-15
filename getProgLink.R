cat("###########################", '\n',
    "# Step: get PROGRAM links #", '\n',
    "###########################", '\n', sep = "")

# create data directory
dir.create("data/", showWarnings = FALSE, recursive = TRUE)

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

RES_PROG_LINK = data_frame()

for(tmp_i in seq_along(links_major)){
    
    tmp_link = links_major[tmp_i]
    tmp_major = tmp_link %>%
        str_replace("fos-en", "") %>%
        str_replace_all("/", "")
    
    cat(tmp_major, '\n')
    
    # study abroad
    tmp_study = tmp_link %>%
        str_replace("/$", "-abroad-programs/") %>%
        paste0(url_base, .) %>%
        read_html()
    
    n = tmp_study %>%
        html_nodes("#pagination") %>%
        html_attr("data-total-pages") %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        as.numeric()
    
    # construct field
    if(length(n) == 0 || n < 2){
        # single or empty page
        d_university = tmp_study %>%
            html_nodes(".institute-school-name") %>%
            html_text() %>% 
            .[. != ""] %>% .[!is.na(.)]
        if(length(d_university) == 0){
            cat("JUMP EMPTY MAJOR", '\n')
            next
        }
        d_ranking = tmp_study %>%
            html_nodes(".institute-lite-ranking-apply") %>%
            html_text() %>% 
            .[. != ""] %>% .[!is.na(.)] %>%
            str_replace_all("\\s|\\n", "") %>%
            as.numeric()
        d_link = tmp_study %>%
            html_nodes(".institute-lite-apply") %>%
            html_attr("href") %>% 
            .[. != ""] %>% .[!is.na(.)]
    } else {
        # multiple pages
        d_university = c()
        d_ranking    = c()
        d_link       = c()
        for(tmp_p in 1:2){
            tmp_study = tmp_link %>%
                str_replace("/$", "-abroad-programs/") %>%
                str_c("?page=", tmp_p) %>%
                paste0(url_base, .) %>%
                read_html()
            d_university = tmp_study %>%
                html_nodes(".institute-school-name") %>%
                html_text() %>% 
                .[. != ""] %>% .[!is.na(.)] %>%
                c(d_university, .)
            d_ranking = tmp_study %>%
                html_nodes(".institute-lite-ranking-apply") %>%
                html_text() %>% 
                .[. != ""] %>% .[!is.na(.)] %>%
                str_replace_all("\\s|\\n", "") %>%
                as.numeric() %>%
                c(d_ranking, .)
            d_link = tmp_study %>%
                html_nodes(".institute-lite-apply") %>%
                html_attr("href") %>% 
                .[. != ""] %>% .[!is.na(.)] %>%
                c(d_link, .)
            cat("page:", tmp_p, '\n')
        }
    }
    d_major = res_major[tmp_i]
    
    # construct data frame
    RES_PROG_LINK = data_frame(
        univ          = d_university,
        major         = d_major,
        major.ranking = d_ranking,
        link          = d_link
    ) %>% rbind(RES_PROG_LINK, .)
    
}

RES_PROG_LINK = RES_PROG_LINK %>%
    mutate(link = str_c(url_base, link))

rm(list = ls(pattern = "tmp|d_"))

RES_LINK = data_frame()
for(tmp_link in RES_PROG_LINK$link){
    
    cat(tmp_link, '\n')
    
    # load page
    tmp_page = tmp_link %>%
        read_html()
    
    # get page number
    n = tmp_page %>%
        html_nodes("#pagination") %>%
        html_attr("data-total-pages") %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        as.numeric()
    
    # construct field
    if(length(n) == 0){
        # single or empty page
        d_prog = tmp_link %>%
            read_html() %>%
            html_nodes("[class=basic-name]") %>%
            html_attr("href") %>% 
            .[. != ""] %>% .[!is.na(.)]
    } else {
        # multiple pages
        d_prog = c()
        for(tmp_p in 1:n){
            d_prog = tmp_link %>%
                str_c("&page=", tmp_p) %>%
                read_html() %>%
                html_nodes("[class=basic-name]") %>%
                html_attr("href") %>% 
                .[. != ""] %>% .[!is.na(.)] %>%
                c(d_prog, .)
            cat("page:", tmp_p, '\n')
        }
    }
    
    # construct data frame
    if(length(d_prog) == 0){
        cat("JUMP EMPTY PROGRAM", '\n')
        next
    }
    RES_LINK = data_frame(
        link      = tmp_link,
        prog.link = d_prog
    ) %>% rbind(RES_LINK, .)
    
}

rm(list = ls(pattern = "tmp|d_"))

RES_LINK = RES_LINK %>%
    mutate(prog.link = str_c(url_base, prog.link))

extractUID = function(link){
    r = link %>%
        str_extract("/[a-z\\.]+,programs/") %>%
        str_replace(",programs/", "") %>%
        str_replace("/", "") %>%
        str_to_upper()
    return(r)
}

PROGRAM.LINK = inner_join(RES_PROG_LINK, RES_LINK, by = "link") %>%
    mutate(uid = extractUID(link)) %>%
    .[c(1, 6, 2, 3, 5)]

rm("RES_LINK", "RES_PROG_LINK")
save(PROGRAM.LINK, file = "data/PROGRAM.LINK.RData")

cat("#############################", '\n',
    "# Finish: get PROGRAM links #", '\n',
    "#############################", '\n', sep = "")
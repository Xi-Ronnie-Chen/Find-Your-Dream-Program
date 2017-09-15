cat("######################", '\n',
    "# Step: parse COURSE #", '\n',
    "######################", '\n', sep = "")

# load libraries
library(rvest)
library(stringr)
library(dplyr)

# Relation 2 [Course(cid, major, name)]
dir_course = "data/course"
tmp_htmls  = dir(dir_course, pattern = "*.html", full.names = TRUE)
COURSE = data_frame()

for(tmp_html in tmp_htmls){
    tmp_page = read_html(tmp_html)
    d_major = tmp_page %>%
        html_nodes(".ellipsis .sp-right") %>% 
        html_text() %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        str_replace_all("\\n", "") %>%
        str_replace_all("^\\s+", "") %>%
        str_replace_all("\\s+\\s$", "")
    d_courses = tmp_page %>%
        html_nodes("#tabshow-course a") %>%
        html_text() %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        str_replace_all("\\n", "") %>%
        str_replace_all("^\\s+", "") %>%
        str_replace_all("\\s+\\s$", "") %>%
        str_to_title()
    if(length(d_courses) == 0) { next }
    COURSE = data_frame(
        major = d_major,
        name  = d_courses
    ) %>% rbind(COURSE, .)
    
    cat(tmp_html, '\n')
}

rm(list = ls(pattern = "tmp|d_"))

save(COURSE, file = "data/COURSE.RData")

cat("########################", '\n',
    "# Finish: parse COURSE #", '\n',
    "########################", '\n', sep = "")
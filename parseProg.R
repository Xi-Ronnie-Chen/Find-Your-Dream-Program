cat("#######################", '\n',
    "# Step: parse PROGRAM #", '\n',
    "#######################", '\n', sep = "")

# load libraries
library(stringr)
library(dplyr)
library(rvest)

# Relation 3: [PROGRAM(name, department, degree, deadline, fee, toefl, gpa, work, link)]
dir_prog  = "data/program"
tmp_htmls = dir(dir_prog, pattern = "*.html", full.names = TRUE)
PROGRAMS  = data_frame()
base_url  = "https://www.applysquare.com/program-en/"

for(tmp_html in tmp_htmls){
    
    tmp_page = read_html(tmp_html)
    
    d_prog_link = tmp_html %>%
        str_replace("^data/program/", "") %>%
        str_replace(".html$", "/") %>%
        str_c(base_url, .)
    
    d_name = tmp_page %>%
        html_nodes(".js-program-einfo") %>%
        html_text() %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        .[1]
    if(length(d_name) == 0) {d_name = NA}
    
    tmp_prog_info = tmp_page %>%
        html_nodes("#program > div.program-view > div.col-md-3 > div:nth-child(2)") %>%
        html_text() %>%
        str_replace_all("\\s{2,}", " ")
    
    d_school = tmp_prog_info %>%
        str_extract("School[\\w|\\s|\\.]*?(Degree|Department)") %>%
        str_replace("^School", "") %>%
        str_replace("(Degree|Department)$", "") %>%
        str_trim()
    if(length(d_school) == 0) {d_school = NA}
    
    d_degree = tmp_prog_info %>%
        str_extract("Degree[\\w|\\s|\\.]*Link") %>%
        str_replace("^Degree", "") %>%
        str_replace("Link$", "") %>%
        str_trim()
    if(length(d_degree) == 0) {d_degree = NA}
    
    d_link = tmp_prog_info %>%
        str_extract("Link.*Online") %>%
        str_replace("^Link", "") %>%
        str_replace("Online$", "") %>%
        str_trim()
    if(length(d_link) == 0) {d_link = NA}
    
    d_deadline = tmp_page %>%
        html_nodes(".pull-right") %>%
        html_text() %>%
        str_replace_all("\n|\\s", "") %>%
        str_extract("[0-9]{4}-[0-9]{2}-[0-9]{2}") %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        .[length(.)]
    if(length(d_deadline) == 0) {d_deadline = NA}
    
    tmp_req = tmp_page %>%
        html_nodes("#program > div.program-view > div:nth-child(1) > div:nth-child(2) > div:nth-child(4)") %>%
        html_text() %>%
        str_replace_all("[\\s|\\n]", "") %>% 
        str_to_lower()
    
    d_fee = tmp_req %>%
        str_extract("applicationfee:\\d+") %>%
        str_extract("\\d+") %>%
        as.numeric()
    if(length(d_fee) == 0) {d_fee = NA}
    
    d_toefl = tmp_req %>%
        str_extract("toeflibttotalminimum:\\d+") %>%
        str_extract("\\d+") %>%
        as.numeric()
    if(length(d_toefl) == 0) {d_toefl = NA}
    if(!is.na(d_toefl) && (d_toefl > 120 || d_toefl < 60)) {d_toefl = NA}
    
    d_gpa = tmp_req %>%
        str_extract("gparequirementminimumscore:[\\d|\\.]+") %>%
        str_extract("[\\d|\\.]+") %>%
        as.numeric()
    if(length(d_gpa) == 0) {d_gpa = NA}
    
    d_work = tmp_req %>%
        str_extract("workexperience") %>%
        (function(x) !is.na(x))(.)
    if(length(d_work) == 0) {d_work = NA}
    
    PROGRAMS = data_frame(
        prog.link     = d_prog_link,
        prog.name     = d_name,
        department    = d_school,
        degree        = d_degree,
        deadline      = d_deadline,
        fee           = d_fee,
        toefl         = d_toefl,
        gpa           = d_gpa,
        work          = d_work,
        official.link = d_link
    ) %>% rbind(PROGRAMS, .)
    
    cat(d_name, '\n')
    
}

load("data/PROGRAM.LINK.RData")

PROGRAMS = PROGRAMS %>%
    filter((deadline >= as_date("2016-09-01") && 
            deadline < as_date("2017-09-01")) ||
            is.na(deadline)) %>%
    inner_join(PROGRAM.LINK, .) %>%
    select(-prog.link) %>%
    distinct()

save(PROGRAMS, file = "data/PROGRAMS.RData")

rm(list = ls(pattern = "tmp|d_"))

cat("#########################", '\n',
    "# Finish: parse PROGRAM #", '\n',
    "#########################", '\n', sep = "")
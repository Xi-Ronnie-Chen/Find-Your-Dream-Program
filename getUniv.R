cat("#################################", '\n',
    "# Step: get UNIVERSITY rankings #", '\n',
    "#################################", '\n', sep = "")

# load libraries
library(rvest)
library(stringr)
library(dplyr)

# ranking revelant url
url_base  = "https://www.applysquare.com"

# Relation 1 [University(uid, name, ranking, state)]
tmp_url1 = "https://www.applysquare.com/ranking-en/?ranking_key=usnews&country=us&page=1"
tmp_url2 = "https://www.applysquare.com/ranking-en/?ranking_key=usnews&country=us&page=2"
tmp_url3 = "https://www.applysquare.com/ranking-en/?ranking_key=usnews&country=us&page=3"
links_rank = c(tmp_url1, tmp_url2, tmp_url3)
UNIVERSITY = data_frame()
for(tmp_link in links_rank){
    tmp_page = tmp_link %>% 
        read_html()
    d_name = tmp_page %>%
        html_nodes(".institute-school-name") %>%
        html_text() %>% 
        .[. != ""] %>% .[!is.na(.)]
    d_ranking = tmp_page %>%
        html_nodes(".institute-lite-ranking") %>%
        html_text() %>% 
        .[. != ""] %>% .[!is.na(.)] %>%
        str_replace_all("\\n|\\s", "") %>%
        as.numeric()
    d_link = tmp_page %>%
        html_nodes(".ellipsis a") %>%
        html_attr("href")
    UNIVERSITY = data_frame(
        univ.name    = d_name,
        univ.ranking = d_ranking,
        univ.link    = d_link
    ) %>% rbind(UNIVERSITY, .)
    
    cat(tmp_link, '\n')
}

UNIVERSITY = UNIVERSITY %>%
    mutate(univ.link = str_c(url_base, univ.link))

d_state = c()
for(tmp_link in UNIVERSITY$univ.link){
    d_state = tmp_link %>%
        read_html() %>%
        html_nodes("p span") %>%
        html_text() %>%
        .[. != ""] %>% .[!is.na(.)] %>%
        c(d_state, .)
    cat(tmp_link, '\n')
}

UNIVERSITY$univ.state = d_state

rm(list = ls(pattern = "tmp|d_"))

# translate states

# load necessary data file
load("data/PROGRAM.LINK.RData")

UNIVERSITY = PROGRAM.LINK %>%
    select(univ, uid) %>%
    rename(univ.name = univ) %>%
    distinct() %>%
    inner_join(UNIVERSITY, ., by = "univ.name") %>%
    .[c(5, 4, 1:3)] %>%
    filter(univ.ranking <= 50)

CHN = c("新泽西州", "马萨诸塞州", "康涅狄格州", "加利福尼亚州", "伊利诺斯州", "纽约州",
        "北卡罗来纳州", "宾夕法尼亚州",  "马里兰州", "新罕布什尔州", "罗得岛州", "田纳西州",
        "密苏里州", "印第安纳州", "得克萨斯州", "乔治亚州", "华盛顿特区", "弗吉尼亚州", 
        "密歇根州", "俄亥俄州", "威斯康辛州", "路易斯安那州", "佛罗里达州")
ENG = c("NJ", "MA", "CT", "CA", "IL", "NY",
        "NC", "PA", "MD", "NH", "RI", "TN",
        "MO", "IN", "TX", "GA", "WA", "VA",
        "MI", "OH", "WI", "LA", "FL")

state.translation = data_frame(
    univ.state = CHN,
    eng = ENG
)

UNIVERSITY = UNIVERSITY %>%
    inner_join(., state.translation, by = "univ.state") %>%
    select(-univ.state) %>%
    rename(univ.state = eng) %>%
    .[c(1, 5, 2:4)]

save(UNIVERSITY, file = "data/UNIVERSITY.RData")

cat("###################################", '\n',
    "# Finish: get UNIVERSITY rankings #", '\n',
    "###################################", '\n', sep = "")
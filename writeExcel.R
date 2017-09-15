cat("#####################", '\n',
    "# Step: write EXCEL #", '\n',
    "#####################", '\n', sep = "")

# create data directory
dir.create("data/csv/", showWarnings = FALSE, recursive = TRUE)

# load necessary libraries
library(dplyr)
library(stringr)

# Course
load("data/COURSE.RData")
tmp_c = COURSE %>%
    select(name) %>%
    distinct() %>%
    mutate(cid = row_number()) %>%
    select(cid, name)
write.csv(tmp_c, file = "data/csv/Course.csv", row.names = FALSE)

# HasCourses
COURSE %>%
    left_join(., tmp_c) %>%
    select(major, cid) %>%
    write.csv(file = "data/csv/HasCourses.csv", row.names = FALSE)

# University
load("data/UNIVERSITY.RData")
UNIVERSITY %>%
    select(univ.name, univ.ranking, univ.state, univ.link) %>%
    rename(name = univ.name, ranking = univ.ranking,
           state = univ.state, link = univ.link) %>%
    write.csv(file = "data/csv/University.csv", row.names = FALSE)

# Program
load("data/PROGRAMS.RData")
tmp_u = UNIVERSITY %>%
    select(uid)
tmp_p = PROGRAMS %>%
    mutate(degree = ifelse(str_detect(degree, "(Master|MS)"), 
                           "Master", degree)) %>%
    mutate(degree = ifelse(str_detect(degree, "(Doctor|PhD|Ph.D.)"), 
                           "PhD", degree)) %>%
    mutate(degree = ifelse(str_detect(degree, "(Master|PhD)"), 
                           degree, "")) %>%
    filter(!is.na(degree) & degree != "") %>%
    inner_join(tmp_u) %>%
    select(-uid) %>%
    rename(university = univ, ranking = prog.ranking,
           name = prog.name, GPA = gpa, link = official.link) %>%
    mutate(pid = row_number()) %>%
    select(pid, name, university, department, ranking, major, 
           degree, deadline, fee, toefl, GPA, work, link)

write.csv(tmp_p, file = "data/csv/Program.csv", row.names = FALSE, na = "")

# PotentialProgram (fake)
tmp_pp = data_frame(
    sid = floor(runif(600, 1, 300.9)),
    pid = floor(runif(600, 1, max(tmp_p$pid)))
)
tmp_count = tmp_pp %>%
    group_by(sid) %>%
    summarise(num = n()) %>%
    ungroup() %>%
    filter(num <= 5)
inner_join(tmp_pp, tmp_count) %>%
    select(sid, pid) %>%
    distinct(sid, pid) %>%
    arrange(sid, pid) %>%
    write.csv(file = "data/csv/PotentialProgram.csv", 
              row.names = FALSE, na = "")

cat("#######################", '\n',
    "# Finish: write EXCEL #", '\n',
    "#######################", '\n', sep = "")
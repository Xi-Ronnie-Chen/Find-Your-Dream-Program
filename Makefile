all: data/csv/*.csv

data/csv/*.csv: writeExcel.R data/PROGRAMS.RData data/COURSE.RData data/UNIVERSITY.RData 
	Rscript writeExcel.R

data/PROGRAMS.RData: parseProg.R data/program/*.html
	Rscript parseProg.R

data/program/*.html: getProgram.R data/PROGRAM.LINK.RData
	Rscript getProgram.R

data/COURSE.RData: parseCourse.R data/course/*.html
	Rscript parseCourse.R

data/course/*.html: getCourse.R
	Rscript getCourse.R

data/UNIVERSITY.RData: getUniv.R data/PROGRAM.LINK.RData
	Rscript getUniv.R

data/PROGRAM.LINK.RData: getProgLink.R
	Rscript getProgLink.R

clean:
	rm -rf data/

.phony: all clean
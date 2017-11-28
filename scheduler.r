library(lpSolveAPI)
library(lpSolve)

number_of_people = 8
number_of_projects = 4 
f_i_j <- c(matrix(t(read.csv(file="Documents/Alocacao/F(i,j).csv", header=TRUE, sep=",", colClasses = c(rep("NULL", 1), rep("integer", number_of_projects))))))
f.obj <- f_i_j
one_project_per_person_constraint <- c(rep(0,number_of_people*number_of_people*number_of_projects))
for (i in 0:(number_of_people-1)) {
  for (j in 1:number_of_projects) {
    one_project_per_person_constraint[j+i*4+i*number_of_people*number_of_projects] = 1 
  }
}

senior_constraint <- c(rep(0,number_of_projects*number_of_people*number_of_projects))
qi <- c(matrix(t(read.csv(file="Documents/Alocacao/qi.csv", header=TRUE, sep=",", colClasses = c(rep("NULL", 1), rep("integer", 1))))))
for (i in 0:(number_of_projects-1)) {
  for(j in 0:(number_of_people-1)){
    senior_constraint[(1+3*j)+j+i+i*number_of_people*number_of_projects] = qi[j+1]
  }
}

number_of_people_per_project_contraint <- c(rep(0,number_of_projects*number_of_people*number_of_projects))
for (i in 0:(number_of_projects-1)) {
  for(j in 0:(number_of_people-1)){
    number_of_people_per_project_contraint[(1+3*j)+j+i+i*number_of_people*number_of_projects] = 1
  }
}


f.con <- matrix(
                c(one_project_per_person_constraint, 
                  senior_constraint, 
                  number_of_people_per_project_contraint),
                nrow=16, byrow=TRUE)

symbols <- c(rep("=", number_of_people), 
             rep(">=", number_of_projects), 
             rep("=", number_of_projects))
f.dir <- symbols

Qj <- c(matrix(t(read.csv(file="Documents/Alocacao/Qj.csv", header=FALSE, sep=",", colClasses = c(rep("NULL", 1), rep("integer", 1))))))
Nj <- c(matrix(t(read.csv(file="Documents/Alocacao/Nj.csv", header=FALSE, sep=",", colClasses = c(rep("NULL", 1), rep("integer", 1))))))
rhs <- c(rep(1, number_of_people),
         Qj,
         Nj)
f.rhs <- rhs

number_of_solutions = 5
result <- lp("max", f.obj, f.con, f.dir, f.rhs,all.bin=TRUE,num.bin.solns=number_of_solutions)$solution
write.csv(t(matrix(result[1:(number_of_people*number_of_projects*number_of_solutions)],nrow = number_of_projects,ncol = number_of_people*number_of_solutions)),file="Documents/Alocacao/solution.csv")

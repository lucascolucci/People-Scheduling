my_packages = c("devtools", "routr", "lpSolveAPI", "lpSolve", "reqres", "fiery")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))
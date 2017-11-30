library(fiery)
library(routr)
library(lpSolveAPI)
library(lpSolve)

app <- Fire$new(host = '0.0.0.0', port = as.integer(Sys.getenv('PORT')))
app$set_logger(logger_console())

# Now comes the biggest deviation. We'll use routr to define our request
# logic, as this is much nicer
router <- RouteStack$new()
route <- Route$new()
router$add_route(route, 'main')

# We start with a catch-all route that provides a welcoming html page
route$add_handler('get', '*', function(request, response, keys, ...) {
  response$type <- 'html'
  response$status <- 200L
  response$body <- '<h1>All your AI are belong to us</h1>'
  TRUE
})

#add the /schedulev1 route
route$add_handler('get', '/schedulev1', function(request, response, keys, ...) {
  dir <- as.numeric(unlist(strsplit(request$query$dir, "\\,")))
  dir <- replace( dir, dir==0, "=")
  dir <- replace( dir, dir==1, ">")
  dir <- replace( dir, dir==2, "<")
  dir <- replace( dir, dir==3, ">=")
  dir <- replace( dir, dir==4, "<=")

  obj <- as.numeric(unlist(strsplit(request$query$obj, "\\,")))
  rhs <- as.numeric(unlist(strsplit(request$query$rhs, "\\,")))
  number_of_solutions <- as.numeric(request$query$number_of_solutions, "\\,")
  con <- as.numeric(unlist(strsplit(request$query$con, "\\,")))
  con <- matrix(con, nrow=length(dir), byrow=TRUE)
    
  response$body <-lp("max",
             obj,
             con,
             dir,
             rhs,
             all.bin=TRUE,
             num.bin.solns=number_of_solutions)$solution
  response$status <- 200L
  response$format(json = reqres::format_json())
  TRUE
})

# add the /schedulev2 route
route$add_handler('get', '/schedulev2', function(request, response, keys, ...) {
  dir <- as.numeric(unlist(strsplit(toString(Sys.getenv("DIR")), "\\,")))
  dir <- replace( dir, dir==0, "=")
  dir <- replace( dir, dir==1, ">")
  dir <- replace( dir, dir==2, "<")
  dir <- replace( dir, dir==3, ">=")
  dir <- replace( dir, dir==4, "<=")
  
  obj <- as.numeric(unlist(strsplit(toString(Sys.getenv("OBJ")), "\\,")))
  rhs <- as.numeric(unlist(strsplit(toString(Sys.getenv("RHS")), "\\,")))
  number_of_solutions <- as.numeric(toString(Sys.getenv("NOS")), "\\,")
  con <- as.numeric(unlist(strsplit(toString(Sys.getenv("CON")), "\\,")))
  con <- matrix(con, nrow=length(dir), byrow=TRUE)
  
  response$body <-lp("max",
                     obj,
                     con,
                     dir,
                     rhs,
                     all.bin=TRUE,
                     num.bin.solns=number_of_solutions)$solution
  response$status <- 200L
  response$format(json = reqres::format_json())
  TRUE
})

# Finally we attach the router to the fiery server
app$attach(router)

app$ignite()
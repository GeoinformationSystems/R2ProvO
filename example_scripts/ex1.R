# library(r2provo)
# ------------------------------------------------------------------
init_prov_store()


add_two_numbers <- function(a, b) {
    return(a + b)
}
add_three_numbers <- function(a, b, c) {
    return(a + b + c)
}

a <- 3
b <- 4
eval(prov(quote(
    c <- add_two_numbers(a, b)
)))
d <- 9
eval(prov(quote(
    e <- add_two_numbers(c, d)
)))
f <- 1
g <- 2
eval(prov(quote(
    h <- add_three_numbers(e, f, g)
)))

store_prov("ex1.ttl")
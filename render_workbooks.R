library(rmarkdown)

notebooks <- dir(".", pattern = '\\.Rmd')

for(i in seq_along(notebooks)) {
    use_book <- sort(notebooks)[i]

    cat(paste("Rendering", use_book, "notebook\n"))

    render(use_book)
})

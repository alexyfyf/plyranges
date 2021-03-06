# test-overlaps.R
context("overlap joins")

test_that("intersect join returns correct results",{

  # empty intersect returns empty GRanges()
  x <- GRanges()
  expect_identical(join_overlap_intersect(x, x), x)

  x <- IRanges()
  expect_identical(join_overlap_intersect(x, x), x)

  a <- GRanges(seqnames = "chr1",
               ranges = IRanges(c(11,101), c(21, 200)),
               name = c("a1", "a2"),
               strand = c("+", "-"),
               score = c(1,2))
  b <- GRanges(seqnames = "chr1",
               strand = c("+", "-", "+", "-"),
               ranges = IRanges(c(21,91,101,201), c(30,101,110,210)),
               name = paste0("b", 1:4),
               score = 1:4)

  exp <- GRanges("chr1", IRanges(c(21, 101,101), c(21, 101, 110)),
                 strand=c("+", "-", "-"),
                 name.x=c("a1", "a2", "a2"),
                 score.x=c(1, 2, 2),
                 name.y = c("b1", "b2", "b3"),
                 score.y = 1:3)

  target <- join_overlap_intersect(a,b)
  expect_identical(target, exp)

  # with IRanges
  target <- join_overlap_intersect(ranges(a), ranges(b))
  expect_identical(target, ranges(exp))

  # modifying minoverlap and maxgap
  exp <- GRanges("chr1", IRanges(101, 110), strand = "-",
                 name.x = "a2", score.x = 2, name.y = "b3", score.y = 3L)

  target <- join_overlap_intersect(a,b, minoverlap = 2L)
  expect_identical(target, exp)

  target <- join_overlap_intersect(ranges(a), ranges(b), minoverlap = 2L)
  expect_identical(target, ranges(exp))

  exp <- GRanges("chr1", IRanges(c(21, 101, 101, 201), c(21, 101, 110, 200)),
                 strand = c("+", "-", "-", "-"),
                 name.x = c("a1", "a2", "a2", "a2"),
                 score.x = c(1,2,2,2),
                 name.y = c("b1", "b2", "b3", "b4"),
                 score.y = 1:4)
  target <- join_overlap_intersect(a, b, maxgap = 10)
  expect_identical(target, exp)

  # within
  b_with <- b[3]
  exp <- GRanges("chr1", IRanges(101, 110), strand = c("+"),
                 name.x = "b3", score.x = 3L, name.y = "a2", score.y = 2)

  target <- join_overlap_intersect_within(b_with, a)
  expect_identical(target, exp)

  exp <- GRanges() %>%
    mutate(name.x = character(),
           score.x = numeric(),
           name.y = character(),
           score.y = integer())
  seqinfo(exp) <- Seqinfo(seqnames = "chr1")

  target <- join_overlap_intersect_within(a, b)
  expect_identical(target, exp)

  # directed
  exp <- GRanges(seqnames = "chr1",
                 strand = c("+", "-"),
                 IRanges(c(21, 101), c(21, 101)),
                 name.x = c("a1", "a2"),
                 score.x = c(1,2),
                 name.y = c("b1", "b2"),
                 score.y = c(1L,2L))
  target <- join_overlap_intersect_directed(a,b)
  expect_identical(target, exp)

})

test_that("inner join/find overlaps returns correct results", {

  #a# .....
  #b#    ....
  #c#         ..
  #A#  x
  #B#  xx
  #C#          xxx
  a <- IRanges(c(1, 4, 9), c(5, 7, 10)) %>%
    mutate(key = letters[1:3])
  b <- IRanges(c(2, 2, 10), c(2, 3, 12)) %>%
    mutate(key = LETTERS[1:3])

  exp <- IRanges(c(1,1,9), c(5,5,10)) %>%
    mutate(key.a = c("a", "a", "c"),
           key.b = c("B", "A", "C"))

  target <- join_overlap_inner(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a, b, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  # with maxgap = 1
  exp <- IRanges(c(1,1,4,4,9), c(5,5,7,7,10)) %>%
    mutate(key.a = c("a", "a", "b", "b", "c"),
           key.b = c("B", "A", "B", "A","C"))
  target <- join_overlap_inner(a,b, maxgap = 1, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a,b, maxgap = 1, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  # minoverlap
  exp <- IRanges() %>%
    mutate(key.a = character(), key.b = character())

  target <- join_overlap_inner(a,b, minoverlap = 3L, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a,b, minoverlap = 3L, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  exp <- IRanges(1,5) %>%
    mutate(key.a = "a", key.b = "B")
  target <- join_overlap_inner(a,b, minoverlap = 2L, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a,b, minoverlap = 2L, suffix = c(".a", ".b"))

  #a# ..
  #b#     ..
  #c#   ....
  #d#    ......
  #A# xxxx
  #B#   xxxx
  #C#     xxxxx
  #D#      xxxx

  a <- IRanges(c(1, 5, 3, 4), width=c(2, 2, 4, 6)) %>%
    mutate(key.a = letters[1:4])
  b <- IRanges(c(1, 3, 5, 6), width=c(4, 4, 5, 4)) %>%
    mutate(key.b = LETTERS[1:4])

  exp <- IRanges(c(1,5,5,3,3,3,4,4,4), c(2, rep(6, 5), 9,9,9)) %>%
    mutate(key.a = c("a", rep("b", 2), rep("c", 3), rep("d", 3)),
           key.b = c("A", "B", "C", "A", "B", "C", "B", "C", "D"))

  target <- join_overlap_inner(a,b, minoverlap = 2L, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a,b, minoverlap = 2L, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  # within
  exp <- IRanges(c(1,5,5,3), c(2,6,6,6)) %>%
    mutate(key.a = c("a", "b", "b", "c"), key.b = c("A", "B", "C", "B"))
  target <- join_overlap_inner_within(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps_within(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  # GRanges

  #+# .....
  #-#    ....
  #+#         ..
  #-#  xxxx
  #+#  xxx
  #-#     xx
  #+#      xxxx
  a <- GRanges(seqnames = "chr1",
               strand = c("+", "-", "+"),
               ranges = IRanges(c(1, 4, 9), c(5, 7, 10)),
               key.a = letters[1:3])
  b <- GRanges(seqnames = "chr1",
               strand = c("-", "+", "-", "+"),
               ranges = IRanges(c(2, 2,5, 6), c(5, 4,6, 9)),
               key.b = LETTERS[1:4])
  exp <- GRanges(seqnames = "chr1",
                 strand = c(rep("+", 3), rep("-", 4), "+"),
                 ranges = IRanges(c(rep(1, 3), rep(4, 4), 9),
                                  c(rep(5,3), rep(7, 4), 10)),
                 key.a = c(rep("a", 3), rep("b", 4), "c"),
                 key.b = c(LETTERS[1:3], LETTERS[1:4], "D"))



  target <- join_overlap_inner(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  target <- find_overlaps(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  expect_identical(exp, join_overlap_left(a,b,suffix = c(".a", ".b")))

  # directed
  exp <- GRanges(seqnames = "chr1",
                 strand = c("+", "-", "-", "+"),
                 ranges = IRanges(c(1,4,4,9), c(5, 7,7,10)),
                 key.a = c("a", "b", "b", "c"),
                 key.b = c("B", "A", "C", "D"))
  target <- join_overlap_inner_directed(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)

  target <- find_overlaps_directed(a,b, suffix = c(".a", ".b"))
  expect_identical(target, exp)
  
  expect_identical(exp, 
                   join_overlap_left_directed(a,b,suffix = c(".a", ".b")))

})

test_that("outer join returns correct results", {
  # left overlap join, returns expected result
  a <- GRanges(seqnames = "chr1",
               strand = c("+", "-"),
               ranges = IRanges(c(1, 9), c(7, 10)),
               key = letters[1:2])
  b <- GRanges(seqnames = "chr1",
               strand = c("-", "+"),
               ranges = IRanges(c(2, 6), c(4, 8)),
               key = LETTERS[1:2])
  exp <- a[c(1,1,2)]
  exp <- select(exp, key.a = key)
  mcols(exp)$key.b <- c("A", "B", NA)
  target <- join_overlap_left(a,b, suffix = c(".a", ".b"))
  
  expect_identical(exp, target)
  
  # if IRanges
  ir0 <- ranges(a)
  
  ir1 <- ranges(b)
  mcols(ir1) <- DataFrame(key = c("A", "B"))
  
  exp <- ir0[c(1,1,2)]
  mcols(exp) <- DataFrame(key = c("A", "B", NA))
  target <- join_overlap_left(ir0, ir1)
  expect_identical(exp, target)
  
  mcols(exp) <- NULL
  mcols(ir1) <- NULL
  expect_identical(join_overlap_left(ir0, ir1), exp)
  
  
  # no overlaps
  expect_identical(join_overlap_left(a, GRanges()), a)
  expect_identical(join_overlap_left(ir0, IRanges()), ir0)
  
  b <- GRanges(seqnames = "chr1",
               strand = c("-", "+"),
               ranges = IRanges(c(20, 11), width = 5),
               key = LETTERS[1:2])
  exp <- select(a, key.a = key)
  mcols(exp)$key.b <- NA_character_
  
  target <- join_overlap_left(a,b, suffix = c(".a", ".b"))
  expect_identical(rep(NA_character_, 2), mcols(target)$key.b)
  expect_identical(exp, target)
  
  # issue 70, no mcols returns result
  # https://github.com/sa-lee/plyranges/issues/70
  gr0 <- GRanges(Rle(c("chr2", "chr5", "chr1", "chr3"), c(1, 3, 2, 4)),
                 IRanges(1:10, width=10:1))
  
  gr1 <- GRanges(Rle(c("chr2", "chr3", "chr1", "chr3"), c(1, 3, 2, 4)),
                 IRanges(1:10, width=10:1))
  
  gr2 <- gr1
  gr2$AAA <- 1L
  
  exp <- join_overlap_left(gr0, gr1)
  target <- granges(join_overlap_left(gr0, gr1))
  
  expect_identical(exp, target)
  

  
  
})

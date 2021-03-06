% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/io-gff.R
\name{read_gff}
\alias{read_gff}
\alias{read_gff1}
\alias{read_gff2}
\alias{read_gff3}
\title{Read a GFF/GTF/GVT file}
\usage{
read_gff(file, col_names = NULL, genome_info = NULL, overlap_ranges = NULL)

read_gff1(file, col_names = NULL, genome_info = NULL, overlap_ranges = NULL)

read_gff2(file, col_names = NULL, genome_info = NULL, overlap_ranges = NULL)

read_gff3(file, col_names = NULL, genome_info = NULL, overlap_ranges = NULL)
}
\arguments{
\item{file}{A path to a file or a connection.}

\item{col_names}{An optional character vector for parsing specific
columns in \code{file} that are part of the GFF specification. These should
name either fixed fields, like source or type, or, for GFF2 and GFF3,
any attribute.}

\item{genome_info}{An optional character string or a Ranges object
that contains information about the genome build. For example the UCSC identifier
"hg19" will add build information to the returned GRanges.}

\item{overlap_ranges}{An optional Ranges object. Only the intervals in the file
that overlap the Ranges will be returned.}
}
\value{
A GRanges object

a GRanges object
}
\description{
This is a lightweight wrapper to the import family
of functions defined in \pkg{rtracklayer}.
}
\examples{
test_path <- system.file("tests", package = "rtracklayer")
# gff3
test_gff3 <- file.path(test_path, "genes.gff3")
gr <- read_gff3(test_gff3)
gr
# alternatively with read_gff
gr <- read_gff(test_gff3, genome_info = "hg19")
gr
}
\seealso{
\code{\link[rtracklayer:GFFFile]{rtracklayer::GFFFile()}}
}

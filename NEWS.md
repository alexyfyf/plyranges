# plyranges 1.7.16

* refactoring of select internals, improved speed when casting a GRanges -> 
DataFrame

# plyranges 1.7.15

* further fixes to reduce/disjoin internals

# plyranges 1.7.14

* fixes reduce/disjoin internals cleans up disjoin cases when
an expansion occurs

# plyranges 1.7.13

* set tidyselect version to be v 1.0
* set coverage method for delegating ranges
* fix docs for bam reading

# plyranges 1.7.11

* move from `tidyselect::vars_select()` to `tidyselect::eval_select()`

# plyranges 1.7.7

* update handling of list columns, `expand_ranges()` no longer takes
cartesian product if lists are parallel. `summarize()` properly handles list
column output without blowing out number of columns. 

# plyranges 1.7.6 

* adds method for `dplyr::sample_n()`

# plyranges 1.7.5

* fixed issue #62 for Ranges construction, the `as_granges()` and `as_iranges()`
functions now handle List columns  correctly
* added in helper functions for dealing with names in Ranges. 
See `?ranges-names` for details.

# plyranges 1.7.4

* added `slice()` for Ranges, and GroupedRanges
* internals of grouping have been overhauled, but there
shouldn't be any user facing changes. It is now much faster
to generate groupings. 
* group information can be interrogated with `dplyr::group_keys()`
* a GRangesList can be obtained automatically from a GroupedGenomicRanges with `dplyr::group_split()`
* group indices can be generated with `dplyr::group_indices()`

# plyranges 1.7.3

* `shift_downstream()` and `shift_upstream()` now properly
handle vector amounts of `shift`. Fixes issue [#73](https://github.com/sa-lee/plyranges/issues/73)

# plyranges 1.7.2

* Left outer join overlap operations now work if either `x` or `y` have
no metadata columns see [#70](https://github.com/sa-lee/plyranges/issues/70) 
* Left outer join overlap operations will also correctly
behave in situations when there are no non-overlapping ranges.
* Left outer join overlaps no longer modify seqinfo (see here)[https://support.bioconductor.org/p/125623/]
* patch left outer join when `x` or `y` are IRanges, flesh out overlaps documentation.

# plyranges 1.7.1

* Reformatting `NEWS.md` so no longer softlinks to inst/NEWS

# plyranges 1.5.13  

* plyranges release and devel have removed `unnest()` and replaced it
with `expand_ranges()` due to changes in the tidyr API. Please replace
all uses of this function with `expand_ranges()`

# plyranges 1.3.4 

* fixed bind_ranges so it preserves rownames

# plyranges 1.1.5 

* enable right generics to be called upon invoking plyranges functions
without loading plyranges

# plyranges 1.1.4 

* added tile/window methods
* fixed up documentation

# plyranges 1.1.3 

* doc updates

# plyranges 1.1.2 

* speed up of `group_by` methods
* refactor of BAM reading utilities

# plyranges 0.99.10 

* refactored `set_width` out so it's called internally by mutate
* along with `set_width` there are other internal `set_` methods
* add `_within_directed` variants for overlaps methods
* modified `overscope_ranges` to be an S3 method, should enable more refactoring in the future

# plyranges 0.99.9

https://bioconductor.org/packages/devel/bioc/html/plyranges.html

- package passed review and is now on Bioconductor devel branch!
- I've been pretty slack with updating the NEWS file but will be more
diligent in the future.
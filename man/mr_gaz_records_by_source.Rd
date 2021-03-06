% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mr_gaz_records.R
\name{mr_gaz_records_by_source}
\alias{mr_gaz_records_by_source}
\title{Retrieve Gazetteer Records by Source}
\usage{
mr_gaz_records_by_source(source)
}
\arguments{
\item{source}{The source of which records are retrieved. Must be one of the types in `mr_gaz_info("placetypes")` and class `character`. Case insensitive.}
}
\value{
A tibble with all Gazetteer records of the specified placetype.
}
\description{
Every record in the [Marine Gazetteer](https://marineregions.org/gazetteer.php) has a placetype, e.g. `Sandbank` or `Marine Protected Area`.
All placetypes currently available in the gazetteer can be retrieved via `mr_gaz_info("placetypes")`.
}
\examples{
ecoregions <- mr_gaz_records_by_source("ICES Ecoregions")
ecoregions$preferredGazetteerName[4]
}

# nethoser

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

Networks for [webhoser](https://webhoser.john-coene.com/)

## Installation

``` r
# install.packages(remotes)
remotes::install_github("JohnCoene/nethoser")
```

## Example

``` r
library(nethoser)

data("webhoser")

webhoser %>%
  connect(           # make graph
    thread.site, 
    entities.persons
  ) %>% 
  visualise()        # visualise
```

![](https://github.com/JohnCoene/nethoser/blob/master/netohoser.png)

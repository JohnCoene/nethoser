globalVariables(
    c(
        "name",
        "target",
        "weight",
        "label",
        "size",
        "uuid",
        "doc",
        "."
    )
)

#' Connect
#'
#' Create network from webhoser data.
#'
#' @param data The data, as returned by \link[webhoser]{wh_collect}.
#' @param from,to Columns to build network.
#' @param callback Callback to apply to edges, a data.frame with columns 
#' \code{source}, \code{target}, \code{n} (number of occurences).
#'
#' @details The returned nodes and edges form an \emph{undirected} graph.
#'
#' @examples
#' data("webhoser")
#' 
#' # co-mentions
#' graph <- webhoser %>%
#'   net_con(entities.persons)
#'
#' # unpack
#' c(nodes, edges) %<-% graph
#' 
#' # visualise
#' webhoser %>%
#'   net_con(entities.persons, entities.locations) %>% 
#'   net_vis()
#'   
#' # callback
#' cb <- function(x){
#'   dplyr::filter(x, n > 3)
#' }
#' 
#' webhoser %>%
#'   net_con(
#'     entities.persons, 
#'     entities.locations, 
#'     callback = cb
#'   ) %>% 
#'   net_vis()
#'
#' @return A \code{list} of length 2 containing \code{data.frame}s:
#' \itemize{
#'   \item{\code{nodes}: Name of \code{entity} and \code{n}umber of occurences.}
#'   \item{\code{edges}: The \code{source}, \code{target}, and \code{n}umber of edges.}
#' }
#'
#' @export
net_con <- function(data, from, to = NULL, callback = NULL){

    if(missing(data) || missing(from))
        stop("Missing data or from", call. = FALSE)

    from_enquo <- rlang::enquo(from)
    to_enquo <- rlang::enquo(to)
    has_to <- rlang::quo_is_null(to_enquo)
    
    if(has_to) message("Building co-mention graph")

    edges <- data %>%
        {
            if(has_to)
                select(., doc = uuid, from = !!from_enquo) %>% mutate(to = from)
            else
                select(., doc = uuid, from = !!from_enquo, to = !!to_enquo) 
        } %>% 
        distinct() %>% 
        filter(from != "", to != "") %>%
        tidyr::separate_rows(from, sep = ",") %>%
        tidyr::separate_rows(to, sep = ",") %>%
        distinct() %>% 
        filter(!is.na(from), !is.na(to)) %>%
        split(.$doc) %>%
        purrr::map_df(function(x){
            tidyr::crossing(
                source = x$to,
                target = x$from
            )
        }) %>%
        filter(target > source) %>%
        mutate(
            source = trimws(source),
            target = trimws(target)
        ) %>% 
        count(source, target) 
    
    if(!is.null(callback))
        edges <- callback(x = edges)

    nodes <- bind_rows(
        edges %>% select(name = source, n),
        edges %>% select(name = target, n)
    ) %>%
        group_by(name) %>%
        summarise(n = sum(n)) %>%
        ungroup()

    list(
        nodes = nodes,
        edges = edges
    )

}

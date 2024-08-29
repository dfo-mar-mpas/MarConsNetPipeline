tar_visnetwork_summary <- function(keyDescriptions=c("bin","indicator","pillar"),keyname=c("data")){
  # get basic targets info
  network_data <- tar_network()
  meta <- tar_meta()
  manifest <- tar_manifest()

  # identidy targets to keep
  keep_targets <- unique(c(
    manifest$name[grepl(paste(keyDescriptions,collapse="|"),manifest$description)],
    meta$name[grepl(paste(keyname,collapse="|"),meta$name)]
  ))

  # create new edge list
  adjusted_edges <- network_data$edges |>
    filter(from %in% keep_targets)

  # remove unnecessary targets and link keepers with new edges
  while(any(!adjusted_edges$to %in% keep_targets)){

    new_edges <- adjusted_edges |>
      filter(!to %in% keep_targets)|>
      left_join(network_data$edges,
                by = c("to" = "from"),
                relationship = "many-to-many",
                keep=TRUE,
                suffix = c(".old", ".new"))

    names(new_edges) <- c("from","to.old","from.new","to")

    for(i in 1:nrow(new_edges)){
      adjusted_edges <- adjusted_edges[ !(adjusted_edges$to==new_edges$to.old[i] &
                                            adjusted_edges$from==new_edges$from[i]),]
    }
    adjusted_edges <- rbind(adjusted_edges,
                            new_edges[c("from","to")])
  }






  # Filter nodes to keep only start and end targets
  filtered_nodes <- network_data$vertices  |>
    filter(name %in% keep_targets) |>
    mutate(id=1:n(),
           label=name)

  filtered_nodes$id <- 1:nrow(filtered_nodes)
  id_edges <- as.data.frame(adjusted_edges)
  id_edges[] <- filtered_nodes$id[match(unlist(adjusted_edges),filtered_nodes$name)]

  graph <- graph_from_data_frame(d = adjusted_edges, vertices = filtered_nodes, directed = TRUE)
  # Perform topological sorting
  topo_order <- topo_sort(graph, mode = "out")

  # Initialize a vector to store levels
  filtered_nodes$level <- NA
  # Perform topological sorting of the graph
  sorted_nodes <- topo_sort(graph, mode = "in")

  # Iterate over each node in topological order
  for (node in sorted_nodes$name) {
    # Identify the predecessors (incoming edges) of the current node
    predecessors <- neighbors(graph, node, mode = "out")

    if (length(predecessors) == 0) {
      # If there are no predecessors, this is a root node, set level to 1
      filtered_nodes$level[filtered_nodes$name == node] <- 1
    } else {
      # Set level as one more than the maximum level of its predecessors
      max_level <- max(filtered_nodes$level[filtered_nodes$name %in% predecessors$name], na.rm = TRUE)
      filtered_nodes$level[filtered_nodes$name == node] <- max_level + 1
    }
  }


  # Create the network visualization with visNetwork
  visNetwork(nodes = filtered_nodes, edges = id_edges) |>
    visEdges(arrows = 'to',
             physics = FALSE,
             # color = "black",
             smooth = list(enabled = TRUE,type="cubicBezier",forceDirection="horizontal")) |>
    visNodes(color = list(highlight = "yellow"),
             physics = FALSE) |>
    visOptions(highlightNearest = list(enabled = TRUE,
                                       algorithm = "hierarchical",
                                       degree = list(from = 6, to = 0)
                                       )) |>
    visHierarchicalLayout(direction = "RL",
                          levelSeparation = 200)

}

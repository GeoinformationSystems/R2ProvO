
# ------------------------------------------------------------------
pkg.env <- new.env()


init_prov <- function() {
    pkg.env$rdf <- rdflib::rdf()

    pkg.env$namespaces <- c(
        rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        rdfs = "http://www.w3.org/2000/01/rdf-schema#",
        prov = "http://www.w3.org/ns/prov#",
        rscript = "http://www.r.rscript#"
    )
}

store_prov <- function(name) {
    rdflib::rdf_serialize(pkg.env$rdf, name, namespace = pkg.env$namespaces, format = "turtle")
}

prov <- function(expression) {
    output_string <- (toString(expression[[2]]))
    output_iri <- URLencode(output_string, reserved = TRUE)
    pkg.env$rdf %>% rdflib::rdf_add(
        subject = paste0(pkg.env$namespaces["rscript"], output_iri),
        predicate = paste0(pkg.env$namespaces["rdf"], "type"),
        object = paste0(pkg.env$namespaces["prov"], "Entity")
    )
    pkg.env$rdf %>% rdflib::rdf_add(
        subject = paste0(pkg.env$namespaces["rscript"], output_iri),
        predicate = paste0(pkg.env$namespaces["rdfs"], "label"),
        object = output_string
    )

    right_side <- expression[[3]]

    # each fuction call should be modeled as a new actvity,
    # therefore append uuids
    process_string <- toString(right_side[[1]])
    process_iri <- URLencode(process_string, reserved = TRUE)
    process_instance <- paste(process_iri, uuid::UUIDgenerate(), sep = "_")
    pkg.env$rdf %>% rdflib::rdf_add(
        subject = paste0(pkg.env$namespaces["rscript"], process_instance),
        predicate = paste0(pkg.env$namespaces["rdf"], "type"),
        object = paste0(pkg.env$namespaces["prov"], "Activity")
    )
    pkg.env$rdf %>% rdflib::rdf_add(
        subject = paste0(pkg.env$namespaces["rscript"], process_instance),
        predicate = paste0(pkg.env$namespaces["rdfs"], "label"),
        object = process_string
    )
    pkg.env$rdf %>% rdflib::rdf_add(
        subject = paste0(pkg.env$namespaces["rscript"], output_iri),
        predicate = paste0(pkg.env$namespaces["prov"], "wasGeneratedBy"),
        object = paste0(pkg.env$namespaces["rscript"], process_instance)
    )

    for (i in 2:length(right_side)) {
        current_input_string <- toString(right_side[[i]])
        current_input_iri <- URLencode(current_input_string, reserved = TRUE)
        pkg.env$rdf %>% rdflib::rdf_add(
            subject = paste0(pkg.env$namespaces["rscript"], current_input_iri),
            predicate = paste0(pkg.env$namespaces["rdf"], "type"),
            object = paste0(pkg.env$namespaces["prov"], "Entity")
        )
        pkg.env$rdf %>% rdflib::rdf_add(
            subject = paste0(pkg.env$namespaces["rscript"], current_input_iri),
            predicate = paste0(pkg.env$namespaces["rdfs"], "label"),
            object = current_input_string
        )
        pkg.env$rdf %>% rdflib::rdf_add(
            subject = paste0(pkg.env$namespaces["rscript"], process_instance),
            predicate = paste0(pkg.env$namespaces["prov"], "used"),
            object = paste0(pkg.env$namespaces["rscript"], current_input_iri)
        )
        pkg.env$rdf %>% rdflib::rdf_add(
            subject = paste0(pkg.env$namespaces["rscript"], output_iri),
            predicate = paste0(pkg.env$namespaces["prov"], "wasDerivedFrom"),
            object = paste0(pkg.env$namespaces["rscript"], current_input_iri)
        )
    }

    return(expression)
}
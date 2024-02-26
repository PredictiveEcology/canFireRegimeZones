defineModule(sim, list(
  name = "canFireRegimeZones",
  description = paste("Download and create fire regime polygons for a study area,",
                      "based on fire regime types or units in Erni et al. (2020)."),
  keywords = "",
  authors = c(
    person(c("Alex", "M"), "Chubaty", role = c("aut", "cre"), email = "achubaty@for-cast.ca")
  ),
  childModules = character(0),
  version = list(canFireRegimeZones = "0.0.0.9000"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list("citation.bib"),
  documentation = list("README.md", "canFireRegimeZones.Rmd"), ## same file
  reqdPkgs = list("cowplot", "dplyr", "geodata", "ggplot2", "ggspatial", "sf", "sp",
                  "PredictiveEcology/SpaDES.core@development (>= 1.1.1)"),
  parameters = bindrows(
    defineParameter("subsetType", "character", "intersects", NA, NA,
                    paste("GIS operation to derive `fireRegimeTypes` and `fireRegimeUnits` objects",
                          "based on `studyArea`. One of 'intersects' or 'contains',",
                          "where 'intersect' is the spatial intersection of the fire regime zones and `studyArea`,",
                          "and 'contains' includes all fire regime polygons contained within `studyArea`.")),
    defineParameter(".plots", "character", "screen", NA, NA,
                    "Used by Plots function, which can be optionally used here"),
    defineParameter(".plotInitialTime", "numeric", start(sim), NA, NA,
                    "Describes the simulation time at which the first plot event should occur."),
    defineParameter(".plotInterval", "numeric", NA, NA, NA,
                    "Describes the simulation time interval between plot events."),
    defineParameter(".saveInitialTime", "numeric", NA, NA, NA,
                    "Describes the simulation time at which the first save event should occur."),
    defineParameter(".saveInterval", "numeric", NA, NA, NA,
                    "This describes the simulation time interval between save events."),
    defineParameter(".studyAreaName", "character", NA, NA, NA,
                    "Human-readable name for the study area used - e.g., a hash of the study",
                          "area obtained using `reproducible::studyAreaName()`"),
    ## .seed is optional: `list('init' = 123)` will `set.seed(123)` for the `init` event only.
    defineParameter(".seed", "list", list(), NA, NA,
                    "Named list of seeds to use for each event (names)."),
    defineParameter(".useCache", "logical", FALSE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    expectsInput("studyArea", "sf", desc = "study area boundary", sourceURL = NA)
  ),
  outputObjects = bindrows(
    createsOutput("fireRegimeTypes", "sf", desc = "Fire Regime Types based on `studyArea`."),
    createsOutput("fireRegimeUnits", "sf", desc = "Fire Regime Units based on `studyArea`.")
  )
))

## event types
#   - type `init` is required for initialization

doEvent.canFireRegimeZones = function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {
      ### check for more detailed object dependencies:
      ### (use `checkObject` or similar)

      # do stuff for this event
      sim <- Init(sim)

      # schedule future event(s)
      sim <- scheduleEvent(sim, P(sim)$.plotInitialTime, "canFireRegimeZones", "plot")
    },
    plot = {
      # ! ----- EDIT BELOW ----- ! #

      plotFun(sim) # example of a plotting function

      # ! ----- STOP EDITING ----- ! #
    },
    warning(paste("Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
                  "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""))
  )
  return(invisible(sim))
}

## event functions
#   - keep event functions short and clean, modularize by calling subroutines from section below.

### template initialization
Init <- function(sim) {
  # # ! ----- EDIT BELOW ----- ! #

  useS2 <- sf::sf_use_s2(FALSE)

  ## Canada provincial/territorial boumndaries
  canProvs <- geodata::gadm(country = "CAN", level = 1, path = mod$dPath) |>
    st_as_sf() |>
    st_transform(crs = st_crs(sim$studyArea))
  mod$canProvsInSA <- canProvs[which(sapply(st_intersects(canProvs, sim$studyArea), length) > 0), ]

  ## FIRE REGIME TYPES - Erni et al. (2020) doi:10.1139/cjfr-2019-0191
  FRT <- prepInputs(
    url = "https://zenodo.org/record/4458156/files/FRT.zip",
    targetFile = "FRT_Canada.shp",
    alsoExtract = "similar",
    fun = "sf::st_read",
    destinationPath = mod$dPath
  ) |>
    st_transform(crs = st_crs(sim$studyArea))

  ## FIRE REGIME UNITS - Erni et al. (2020) doi:10.1139/cjfr-2019-0191
  FRU <- prepInputs(
    url =  "https://zenodo.org/record/4458156/files/FRU.zip",
    targetFile = "CanSZ_20180228_dissolve.shp",
    alsoExtract = "similar",
    fun = "sf::st_read",
    destinationPath = mod$dPath
  ) |>
    st_transform(crs = st_crs(sim$studyArea))

  if (P(sim)$subsetType == "intersects") {
    sim$fireRegimeTypes <- st_intersection(FRT, sim$studyArea) |>
      rename(FRT = Cluster) |>
      mutate(FRT = as.factor(FRT))
    sim$fireRegimeUnits <- st_intersection(FRU, sim$studyArea) |>
      rename(FRU = GRIDCODE) |>
      mutate(FRU = as.factor(FRU))
  } else if (P(sim)$subsetType == "contains") {
    sim$fireRegimeTypes <- FRT[which(sapply(st_intersects(FRT, sim$studyArea), length) > 0), ] |>
      rename(FRT = Cluster) |>
      mutate(FRT = as.factor(FRT))
    sim$fireRegimeUnits <- FRU[which(sapply(st_intersects(FRU, sim$studyArea), length) > 0), ] |>
      rename(FRU = GRIDCODE) |>
      mutate(FRU = as.factor(FRU))
  }

  sf::sf_use_s2(useS2)

  # ! ----- STOP EDITING ----- ! #

  return(invisible(sim))
}

### template for plot events
plotFun <- function(sim) {
  # ! ----- EDIT BELOW ----- ! #

  Plots(sim$studyArea, fn = ggplotFRZ, provs = mod$canProvsInSA, frt = sim$fireRegimeTypes, fru = sim$fireRegimeUnits)

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

.inputObjects <- function(sim) {
  cacheTags <- c(currentModule(sim), "function:.inputObjects")
  mod$dPath <- asPath(getOption("reproducible.destinationPath", dataPath(sim)), 1)
  message(currentModule(sim), ": using dataPath '", mod$dPath, "'.")

  # ! ----- EDIT BELOW ----- ! #
  if (!suppliedElsewhere("studyArea", sim)) {
    sim$studyArea <- SpatialPoints(data.frame(lon = -115, lat = 55), proj4string = CRS("EPSG:4326")) |>
      st_as_sf() |>
      st_transform(paste("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
                         "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")) |>
      as_Spatial() |>
      SpaDES.tools::randomStudyArea(center = _, seed = 60, size = 1e10) |>
      st_as_sf()
  }

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

ggplotFRZ <- function(studyArea, provs, frt, fru) {
  gg_provs <- ggplot(provs) +
    geom_sf(fill = "white", colour = "black", alpha = 0.5)

  gg_frt <- gg_provs +
    geom_sf(data = frt, aes(fill = FRT), alpha = 0.5) +
    scale_fill_brewer(palette = "Dark2") +
    ggtitle("Fire Regime Types in study area") +
    geom_sf(data = studyArea, col = "black", fill = NA) +
    annotation_north_arrow(location = "bl", which_north = "true",
                           pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"),
                           style = north_arrow_fancy_orienteering) +
    xlab("Longitude") + ylab("Latitude") +
    theme_bw()

  gg_fru <- gg_provs +
    geom_sf(data = fru, aes(fill = FRU), alpha = 0.5) +
    scale_fill_brewer(palette = "Accent") +
    ggtitle("Fire Regime Units in study area") +
    geom_sf(data = studyArea, col = "black", fill = NA) +
    annotation_north_arrow(location = "bl", which_north = "true",
                           pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"),
                           style = north_arrow_fancy_orienteering) +
    xlab("Longitude") + ylab("Latitude") +
    theme_bw()

  plot_grid(gg_frt, gg_fru)
}

---
title: "canFireRegimeZones Manual"
subtitle: "v.0.0.0.9000"
date: "Last updated: 2023-02-13"
output:
  bookdown::html_document2:
    toc: true
    toc_float: true
    theme: sandstone
    number_sections: false
    df_print: paged
    keep_md: yes
editor_options:
  chunk_output_type: console
  bibliography: citations/references_canFireRegimeZones.bib
link-citations: true
always_allow_html: true
---

# canFireRegimeZones Module

<!-- the following are text references used in captions for LaTeX compatibility -->
(ref:canFireRegimeZones) *canFireRegimeZones*



[![made-with-Markdown](figures/markdownBadge.png)](https://commonmark.org)

<!-- if knitting to pdf remember to add the pandoc_args: ["--extract-media", "."] option to yml in order to get the badge images -->

#### Authors:

Alex M Chubaty <achubaty@for-cast.ca> [aut, cre]
<!-- ideally separate authors with new lines, '\n' not working -->

## Module Overview

### Module summary

Create fire regime polygons based on Canadian Fire Regime Type (FRT) or Fire Regime Unit (FRU) [@Erni:2020].

### Module inputs and parameters

Describe input data required by the module and how to obtain it (e.g., directly from online sources or supplied by other modules)
If `sourceURL` is specified, `downloadData("canFireRegimeZones", "..")` may be sufficient.
Table \@ref(tab:moduleInputs-canFireRegimeZones) shows the full list of module inputs.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleInputs-canFireRegimeZones)List of (ref:canFireRegimeZones) input objects and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
   <th style="text-align:left;"> sourceURL </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> studyArea </td>
   <td style="text-align:left;"> sf </td>
   <td style="text-align:left;"> study area boundary </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

Provide a summary of user-visible parameters (Table \@ref(tab:moduleParams-canFireRegimeZones))


<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleParams-canFireRegimeZones)List of (ref:canFireRegimeZones) parameters and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> paramName </th>
   <th style="text-align:left;"> paramClass </th>
   <th style="text-align:left;"> default </th>
   <th style="text-align:left;"> min </th>
   <th style="text-align:left;"> max </th>
   <th style="text-align:left;"> paramDesc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> subsetType </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> intersects </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> GIS operation to derive `fireRegimeTypes` and `fireRegimeUnits` objects based on `studyArea`. One of 'intersects' or 'contains', where 'intersect' is the spatial intersection of the fire regime zones and `studyArea`, and 'contains' includes all fire regime polygons contained within `studyArea`. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plots </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> screen </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Used by Plots function, which can be optionally used here </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time at which the first plot event should occur. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time interval between plot events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time at which the first save event should occur. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> This describes the simulation time interval between save events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .studyAreaName </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Human-readable name for the study area used - e.g., a hash of the studyarea obtained using `reproducible::studyAreaName()` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .seed </td>
   <td style="text-align:left;"> list </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Named list of seeds to use for each event (names). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .useCache </td>
   <td style="text-align:left;"> logical </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Should caching of events or module be used? </td>
  </tr>
</tbody>
</table>

### Events

- `init` downloads the Fire Regime Types and Fire Regime Units polygons, and subsets these for the study area, base on `subsetType`.

- `plot` produces maps of the resulting `fireRegimeTypes` and `fireRegimeUnits`.

### Plotting

Maps of the resulting `fireRegimeTypes` and `fireRegimeUnits`.

### Module outputs

Description of the module outputs (Table \@ref(tab:moduleOutputs-canFireRegimeZones)).

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleOutputs-canFireRegimeZones)List of (ref:canFireRegimeZones) outputs and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> fireRegimeTypes </td>
   <td style="text-align:left;"> sf </td>
   <td style="text-align:left;"> Fire Regime Types based on `studyArea`. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fireRegimeUnits </td>
   <td style="text-align:left;"> sf </td>
   <td style="text-align:left;"> Fire Regime Types based on `studyArea`. </td>
  </tr>
</tbody>
</table>

### Example


```r
## select fire regime zones that intersect with study area
mySimOut1 <- SpaDES.core::simInitAndSpades(
  params = list(
    canFireRegimeZones = list(subsetType = "intersects")
  ),
  modules = "canFireRegimeZones",
  paths = list(modulePath = "..")
)
```

![](canFireRegimeZones_files/figure-html/example_intersects-1.png)<!-- -->

```
## Reading layer `FRT_Canada' from data source 
##   `/home/achubaty/Documents/GitHub/FOR-CAST/Ontario_AOU_ROF/modules/canFireRegimeZones/data/FRT_Canada.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 16 features and 1 field
## Geometry type: MULTIPOLYGON
## Dimension:     XY
## Bounding box:  xmin: -2309000 ymin: 703000 xmax: 3090000 ymax: 3851250
## Projected CRS: Canada_Lambert_Conformal_Conic
## Reading layer `CanSZ_20180228_dissolve' from data source 
##   `/home/achubaty/Documents/GitHub/FOR-CAST/Ontario_AOU_ROF/modules/canFireRegimeZones/data/CanSZ_20180228_dissolve.shp' 
##   using driver `ESRI Shapefile'
## Simple feature collection with 60 features and 4 fields
## Geometry type: MULTIPOLYGON
## Dimension:     XY
## Bounding box:  xmin: -2309000 ymin: 703000 xmax: 3090000 ymax: 3851250
## Projected CRS: Canada_Lambert_Conformal_Conic
```


```r
## select fire regime zones that intersect with study area
mySimOut1 <- SpaDES.core::simInitAndSpades(
  params = list(
    canFireRegimeZones = list(subsetType = "contains")
  ),
  modules = "canFireRegimeZones",
  paths = list(modulePath = "..")
)
```

![](canFireRegimeZones_files/figure-html/example_contains-1.png)<!-- -->

### Links to other modules

Can be used to provide fire regime polygons to fire simulation model (e.g., `scfm`, `fireSense`).

### Getting help

-  <https://github.com/PredictiveEcology/canFireRegimeZones/issues>

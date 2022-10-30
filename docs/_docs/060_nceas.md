---
title: NCEAS data
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---
The default parameters of Maxent were determined by modeling 225 species in a total of six regions of the world [(Phillips & Dudík, 2008)]( https://doi.org/10.1111/j.0906-7590.2008.5203.x). This NCEAS (National Center for Ecological Analysis and Synthesis) data has recently been published as an open benchmark dataset that was explicitly assembled to compare SDM methods [(Elith et al., 2020)]( https://doi.org/10.17161/bi.v15i2.13384). 
It contains six regions of the world: Australian Wet Tropics (AWT), Ontario Canada (CAN), New South Wales (NSW), New Zealand (NZ), South American countries (SA) and Switzerland (SWI).  The species themselves are anonymized and only assigned to a biological group. The data consists of presence-only (PO) records, presence-absence (PA) records, background points (BP) and environmental predictors in the form of environmental layers for each of the species. The PO and BP data are intended to train the SDM models, and the PA data to evaluate them. For a detailed description of the NCEAS dataset see [Elith et al. (2020)]( https://doi.org/10.17161/bi.v15i2.13384).

In this tutorial we will use the data for the region Ontario in Canada (see map below). The data species records needed for this exercises can be downloaded via the [disdat r-package]( https://cran.r-project.org/web/packages/disdat/index.html) or over [osf]( https://osf.io/kwc4v/). The environmental grids can only be downloaded via osf. 

{% include media4 url="assets/web_pages/study_area_can.html" %} [Full screen version of the map]({{ site.baseurl }}assets/web_pages/study_area_can.html){:target="_blank"}



* maps pa and po and explain we we dont want this but what we want to achieve instead map with spatial cv



## Get presence records from Presence-Only (PO) and Presence-Absence (PA) data

First of all, we will prepare the presence records for this region. Here we use the package [disdat]( https://cran.r-project.org/web/packages/disdat/index.html) to get the species records. The function `disdat::disPo()` can be used to derive all PO species records for one region. From this dataframe we can get a total of 20 individual species. As we are not using the (PA) data to evaluate the models we will also use the presence records from the PA data for modeling. The script below downloads the data and saves all presence only records for each species individually as geopackage.


<script src="https://gist.github.com/Baldl/1988b47add66c6b7029d7d42f6fb7f75.js"></script>


* explain function get pa
* explain environmental function
* map of species records one species

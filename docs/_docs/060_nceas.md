---
title: NCEAS data
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---
The default parameters of Maxent were determined by modeling 225 species in a total of six regions of the world (Phillips & Dudík, 2008). This NCEAS (National Center for Ecological Analysis and Synthesis) data has recently been published as an open benchmark dataset that was explicitly assembled to compare SDM methods (Elith et al., 2020). 
It contains six regions of the world: Australian Wet Tropics (AWT), Ontario Canada (CAN), New South Wales (NSW), New Zealand (NZ), South American countries (SA) and Switzerland (SWI).  The species themselves are anonymized and only assigned to a biological group. The data consists of presence-only (PO) records, presence-absence (PA) records, background points (BP) and environmental predictors in the form of raster layers for each of the species. The PO and BP data are intended to train the SDM models, and the PA data to evaluate them. For a detailed description of the NCEAS dataset see Elith et al. (2020).

In this tutorial we will use the data for the region Ontario in Canada. The data species records can be downloaded via the disdat r-package or over the here. The environmental grids can only be downloaded here. 

{% include media4 url="assets/web_pages/study_area_can.html" %} [Full screen version of the map]({{ site.baseurl }}"/assets/web_pages/study_area_can.html"){:target="_blank"}


## Presence only (PO) data

First of all we will prepare the presence only records for this region. Here we use the packages disdat to get the species records. The function disdat::disPo() can be used to derive all species for one region. From this dataframe we can get a total of 20 individual species. As we are not using the presence absence (PA) data to evaluate the models we will also use the presence records from the PA data for modeling. The script below downloads the data and saves all presence only records for each species as geopackage.


<script src="https://gist.github.com/Baldl/1988b47add66c6b7029d7d42f6fb7f75.js"></script>



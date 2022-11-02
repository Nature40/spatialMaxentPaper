---
title: Default vs. spatial
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---


To assess which method performs best we will use four different evaluation criteria. First we will create plots of the AUC (area under the receiver operating characteristic curve) together with the MAE (mean absolute error) as proposed by  [Konowalik & Nosol (2021)]( 10.1038/s41598-020-80062-1). We will calculate both metrics on the independent test data from the presence records and the background points using the [R package Metrics]( https://cran.r-project.org/web/packages/Metrics/index.html). As a third metric independent from the background points we will also calculate the Boyce-Index [(Boyce et al., 2002)]( 10.1016/S0304-3800(02)00200-4) using the [R package ecospat]( https://cran.r-project.org/web/packages/ecospat/index.html)  with the prediction raster and spatial test folds. To assess how complex the models are we will furthermore have a look at the number of parameters of each model. We will determine all four metrics for each fold of the FFME and an calculate the median of all these values to get a comprehensive picture of the performance of each method. 

We will start by calculating the metrics for each fold: 

<script src="https://gist.github.com/Baldl/73afe43f676f6dc7be89d1b52b42b156.js"></script>


### Forward Fold Metric Estimation
Once we have the metrics for all folds we will calculate the median for each species using the script below. These are our final results:

<script src="https://gist.github.com/Baldl/50297403717267d81cedadf26af1c56e.js"></script>

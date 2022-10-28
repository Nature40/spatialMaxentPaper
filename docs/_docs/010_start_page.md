---
title: Getting started
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---

Species Distribution Models (SDMs) and Habitat Suitability Models (HSMs, SDMs for both hereafter) have become an indispensable tool in conservation research and practice (Villero et al. 2017). They have the potential to forecast the distribution of invasive or endangered species under climate change scenarios or to identify areas of high value for the protection of endangered species (Frabs et al 2021). Government authorities are increasingly relying on these techniques as a basis for conservation management decisions (CITE). 
Among modelling approaches the SDM-software Maxent (Phillips et al., 2006) is probably the most popular, not least because it is readily available as an easy to operate graphical user interface (GUI).
In this study we implemented parameterization functionalities that account for spatial autocorrelation in a maxent extension (spatialMaxent) with the same GUI as the original Maxent-software, which is made available to the public together with this study. Explicitly, we implemented forward variable-selcetion and feature-class-selection algorithms together with regularization-multiplier tuning based on spatial cross-validation to enable the accounting for spatial auto-correlation already during model tuning. To reduce computation time for these extensive tuning schemes all these functionalities are parallelized.
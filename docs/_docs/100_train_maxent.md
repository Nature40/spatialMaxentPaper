---
title: ???????
header:
  image: "/assets/images/title_image.jpg"
  caption: "Photo credit: Herr Olsen [CC BY-NC 2.0] via [flickr.com](https://www.flickr.com/photos/herrolsen/26966727587/)"
---


We will now train two model for each species in the Canada dataset. One with a random 5-fold cross-validation and the maxent default settings (default model) and one with spatial cross-validation and forward-variable-selection, forward-feature-selection and regularization multiplier tuning (spatial model). Both models are trained and evaluated on the exact same data and we will compare their performance in the next section. 

As we are doing a Forward Fold Metric Estimation as described here, we will need to create 21 models for each species. 

## spatialMaxent GUI
If we are training with the spatialMaxent Graphical User Interface (GUI) 

## spatialMaxent from the command line
As we are training quite a few models here 21 models per species for 20 species for 2 different methods we have a total of 840 models to train, therefore we will use  



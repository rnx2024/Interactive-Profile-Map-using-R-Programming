![Image](https://github.com/rnx2024/Interactive-Profile-Map/blob/main/Mapped-Profiles-Pres-Candidates.png)

This is an interactive Mapped Profiles of Philippine Presidential Candidates and Presidents. Each Presidential candidate is mapped to their city location. Green locators are Presidential Winners. Each mapped Presidential candidate has a tooltip profile. The map needs to be zoomed in order to access all profiles. 

The dataset used is from Abe Caesar Perez of Kaggle.com [![Button2](https://img.shields.io/badge/Download-KaggleDataset-blue)](https://www.kaggle.com/datasets/abeperez/ph-presidential-elections)

I have only extracted Presidential Candidates with complete information from this dataset. I have not included 42 candidates because of essential missing information such as city, province and others. 
I have also added two columns for the dataset, lat and lng to map city locations. 

I have used dplyr to clean the dataset and used leaflet and htmltools packages in creating this interactive map. I have chosen to use the OpenStreetMap.Mapnik as against any other tile providers because of its simpler design that allows faster loading. 

I have created this project to aid History students in their lessons and History teachers to have a more interactive tool in teaching History to their students. This can be useful as the Philippine Midterm Elections is upcoming this May 2025.

Anyone can use the code and make changes as long as this original repository is referenced. 

The interactive mapped profile is published at: [![Button2](https://img.shields.io/badge/RPubs-Click%20to%20View%20Mapped%20Profile-purple)](https://rpubs.com/rnx2024/philippine-presidential-candidates-and-presidents-mapped-profiles)

![Button2](https://img.shields.io/badge/NOTE:-UPDATE-red) Changes were made to the code to handle similar lat and lng locations for some Presidents and Candidates, like Manila. 
All 17 Presidents are now displayed with green markers, 3 of which are located in Manila. For multiple location markers such as Manila, some are may not be immediately visible. You have to zoom in to locate other location markers shwoing candidate profiles. 


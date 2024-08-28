library(targets)

tar_option_set(format = "feather",
               packages = c("dplyr"))


sapply(c(list.files("../MarConsNetAnalysis/R/","ind_",full.names = TRUE),
         "../MarConsNetAnalysis/R/aggregate_groups.R",
         "../MarConsNetAnalysis/R/plot_flowerplot.R",
         "../MarConsNetAnalysis/R/calc_letter_grade.R"),source,.GlobalEnv)



# End this file with a list of target objects.
list(

  ##### Indicators #####
  tar_target(ind_placeholder_1_df,ind_placeholder()),
  tar_target(ind_placeholder_2_df,ind_placeholder()),
  tar_target(ind_placeholder_3_df,ind_placeholder()),
  tar_target(ind_placeholder_4_df,ind_placeholder()),
  tar_target(ind_placeholder_5_df,ind_placeholder()),
  tar_target(ind_placeholder_6_df,ind_placeholder()),
  tar_target(ind_placeholder_7_df,ind_placeholder()),
  tar_target(ind_placeholder_8_df,ind_placeholder()),
  tar_target(ind_placeholder_9_df,ind_placeholder()),
  tar_target(ind_placeholder_10_df,ind_placeholder()),
  tar_target(ind_placeholder_11_df,ind_placeholder()),

  ##### Indicator Bins #####
  tar_target(bin_biodiversity_FunctionalDiversity_df,
             aggregate_groups("bin",
               "Functional Diversity",
               weights=1,
               ind_placeholder_1_df
             )),
  tar_target(bin_biodiversity_GeneticDiversity_df,
             aggregate_groups("bin",
               "Genetic Diversity",
               weights=c(1,1),
               ind_placeholder_1_df,
               ind_placeholder_2_df
             )),
  tar_target(bin_biodiversity_SpeciesDiversity_df,
             aggregate_groups("bin",
               "Species Diversity",
               weights=1,
               ind_placeholder_3_df
             )),
  tar_target(bin_habitat_Connectivity_df,
             aggregate_groups("bin",
               "Connectivity",
               weights=1,
               ind_placeholder_4_df
             )),
  tar_target(bin_habitat_EnvironmentalRepresentativity_df,
             aggregate_groups("bin",
               "Environmental Representativity",
               weights=1,
               ind_placeholder_5_df
             )),
  tar_target(bin_habitat_KeyFishHabitat_df,
             aggregate_groups("bin",
               "Key Fish Habitat",
               weights=1,
               ind_placeholder_6_df
             )),
  tar_target(bin_habitat_ThreatstoHabitat_df,
             aggregate_groups("bin",
               "Threats to Habitat",
               weights=1,
               ind_placeholder_7_df
             )),
  tar_target(bin_habitat_Uniqueness_df,
             aggregate_groups("bin",
               "Uniqueness",
               weights=1,
               ind_placeholder_8_df
             )),
  tar_target(bin_productivity_BiomassMetrics_df,
             aggregate_groups("bin",
               "Biomass Metrics",
               weights=1,
               ind_placeholder_9_df
             )),
  tar_target(bin_productivity_StructureandFunction_df,
             aggregate_groups("bin",
               "Structure and Function",
               weights=1,
               ind_placeholder_10_df
             )),
  tar_target(bin_productivity_ThreatstoProductivity_df,
             aggregate_groups("bin",
               "Threats to Productivity",
               weights=1,
               ind_placeholder_11_df
             )),


  ##### Ecological Objectives #####
  tar_target(ecol_obj_biodiversity_df,
             aggregate_groups("objective",
                              "Biodiversity",
                              weights = NA,
                              bin_biodiversity_FunctionalDiversity_df,
                                   bin_biodiversity_GeneticDiversity_df,
                                   bin_biodiversity_SpeciesDiversity_df)),
  tar_target(ecol_obj_habitat_df,
             aggregate_groups("objective",
                              "Habitat",
                              weights = NA,
                              bin_habitat_Connectivity_df,
                              bin_habitat_EnvironmentalRepresentativity_df,
                              bin_habitat_KeyFishHabitat_df,
                              bin_habitat_ThreatstoHabitat_df,
                              bin_habitat_Uniqueness_df)),
  tar_target(ecol_obj_productivity_df,
             aggregate_groups("objective",
                              "Productivity",
                              weights = NA,
                              bin_productivity_BiomassMetrics_df,
                                   bin_productivity_StructureandFunction_df,
                                   bin_productivity_ThreatstoProductivity_df)),



  ##### Pillar #####
  tar_target(pillar_ecol_df,aggregate_groups("pillar",
                                             "Ecological",
                                             weights = NA,
                                             ecol_obj_biodiversity_df,
                                        ecol_obj_habitat_df,
                                        ecol_obj_productivity_df)),


  ##### Flower Plot #####
  tar_target(flowerplot,
             plot_flowerplot(pillar_ecol_df,
                  grouping = "objective",
                  labels = "bin",
                  score = "ind_value"),
             packages = "ggplot2",
             format = "qs")
)


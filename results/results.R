library(ggplot2)
library(here)
library(janitor)
library(dplyr)
library(conflicted)
library(magrittr)
library(tidyverse)
library(hrbrthemes)

data <- read.csv(here("results","2019_test_results.csv")) %>% clean_names()
data %<>% pivot_longer(cols = r_10:rr_rel_2_10)

data %>% dplyr::filter(fusion_function=="CC",!name%in%c("r_10","ap_10")) %>% 
  ggplot(aes(x=alpha,y=value,group=name))+
  geom_line(aes(color=name))+
  scale_y_continuous(limits=c(0.5,1))+
  theme_ipsum_rc()


data %>% dplyr::filter(fusion_function=="RRF",!name%in%c("r_10","ap_10")) %>% 
  ggplot(aes(x=alpha,y=value,group=name))+
  geom_line(aes(color=name))+
  scale_y_continuous(limits=c(0.5,1))+
  theme_ipsum_rc()

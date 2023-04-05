library(ggplot2)
library(here)
library(janitor)
library(dplyr)
library(conflicted)
library(magrittr)
library(tidyverse)
library(hrbrthemes)
library(cowplot)

data <- read.csv(here("results","2019_test_results.csv")) %>% clean_names()
data %<>% pivot_longer(cols = ap_10:n_dcg_100)

a <- data %>% dplyr::filter(fusion_function=="CC") %>% 
  ggplot(aes(x=alpha,y=value,group=name))+
  geom_line(aes(color=name),size=1)+
  scale_y_continuous(limits=c(0.1,0.8))+
  labs(title="CC",x="\u03b1",y="",color="Metric")+
  guides(color="none")+
  theme_ipsum_rc()+
  theme(axis.title.x = element_text(size=12))+
  theme(plot.title = element_text(size=12,face="plain"))



b <- data %>% dplyr::filter(fusion_function=="RRF") %>% 
  ggplot(aes(x=alpha,y=value,group=name))+
  geom_line(aes(color=name),size=1)+
  scale_y_continuous(limits=c(0.1,0.8))+
  labs(title="RRF",x="\u03b7",y="",color="Metric")+
  scale_color_discrete(labels = c("AP@10(rel=3)", "AP100", "NDCG@10", "NDCG@100"))+
  theme_ipsum_rc()+
  theme(axis.title.x = element_text(size=12))+
  theme(plot.title = element_text(size=12,face="plain"))



plot_grid(a, NULL, b, nrow = 1,rel_widths = c(0.85,-0.05,1))



data_2020 <- read.csv(here("results","2020_test_results.csv"),header = TRUE) %>% clean_names()
data_2020 %>% mutate(across(where(is.numeric), ~ round(., 3)))

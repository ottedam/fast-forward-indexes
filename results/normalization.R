library(ggplot2)
library(here)
library(janitor)
library(dplyr)
library(conflicted)
library(magrittr)
library(tidyverse)
library(hrbrthemes)
library(cowplot)
library(ggsci)
alpha = 0.85

vanilla <- read.csv(here("results","2020_test_results.csv"),header = TRUE) %>% mutate(method="vanilla") %>% mutate_at(c(3:7),as.numeric)
mm <- read.csv(here("results","2020_test_results_MM.csv"),header = TRUE) %>% mutate(method="MM")
tmm <- read.csv(here("results","2020_test_results_TMM.csv"),header = TRUE) %>% mutate(method="TMM")
z <- read.csv(here("results","2020_test_results_Z.csv"),header = TRUE) %>% mutate(method="z")


all <- vanilla %>% bind_rows(mm) %>% bind_rows(tmm) %>% bind_rows(z)
all %<>% dplyr::filter(alpha==0.85)
all %>% mutate(across(where(is.numeric), ~ round(., 3)))




data <- read.csv(here("index","dev","testing","2020qrels-pass.txt"),header = FALSE)
data %<>% separate(V1, into=c("q_id","Q0","doc_id","rating")) %>% select(q_id,doc_id,rating)
data %<>% mutate_all( ~ as.numeric(.))

sparse_2020 <- read.csv(here("index","dev","testing","msmarco-passage-test2020-sparse10000.txt"),sep=" ",header = FALSE)
colnames(sparse_2020) <- c("q_id","Q0","doc_id","rank","sparse_score","name")
sparse_2020 %<>% select(q_id,doc_id,sparse_score)

dense_2020 <- read.csv("C:/Users/Revi/Desktop/dense_scores.csv",sep=",",header = TRUE)
dense_2020 %<>% distinct()
dense_2020 %<>% mutate_all( ~ as.numeric(.)) %>% rename(dense_score=score)

data %<>% left_join(sparse_2020,by=c("q_id","doc_id"))
data %<>% left_join(dense_2020,by=c("q_id","doc_id"))
data %<>% drop_na()


data %<>% group_by(q_id) %>% mutate(min_sparse=min(sparse_score),max_sparse=max(sparse_score),mean_sparse=mean(sparse_score),std_sparse=sd(sparse_score))
data %<>% group_by(q_id) %>% mutate(min_dense=min(dense_score),max_dense=max(dense_score),mean_dense=mean(dense_score),std_dense=sd(dense_score))

data %<>% mutate(mm_sparse=(sparse_score - min_sparse)/(max_sparse - min_sparse))
data %<>% mutate(tmm_sparse=(sparse_score)/(max_sparse))
data %<>% mutate(z_sparse=(sparse_score - mean_sparse)/(std_sparse))
data %<>% mutate(mm_dense=(dense_score - min_dense)/(max_dense - min_dense))
data %<>% mutate(tmm_dense=(dense_score)/(max_dense))
data %<>% mutate(z_dense=(dense_score - mean_dense)/(std_dense))

data %<>% mutate(hybrid_vanilla = alpha * dense_score + (1-alpha) * sparse_score) 
data %<>% mutate(hybrid_mm = alpha * mm_dense + (1-alpha) * mm_sparse)
data %<>% mutate(hybrid_tmm = alpha * tmm_dense + (1-alpha) * tmm_sparse)
data %<>% mutate(hybrid_z = alpha * z_dense + (1-alpha) * z_sparse)

data %>% select(q_id,doc_id,sparse_score,tmm_sparse,dense_score,tmm_dense) %>% group_by() %>% summarise_at(c('dense_score','tmm_dense','sparse_score','tmm_sparse'),min)
data %>% select(q_id,doc_id,sparse_score,tmm_sparse,dense_score,tmm_dense) %>% group_by() %>% summarise_at(c('dense_score','tmm_dense','sparse_score','tmm_sparse'),max)


data %<>% select(q_id,doc_id,hybrid_vanilla,hybrid_mm,hybrid_tmm,hybrid_z) 
data %<>% pivot_longer(cols=c(hybrid_mm:hybrid_z)) 

names <- c(
  `hybrid_mm` = "Min-Max Scaling",
  `hybrid_tmm` = "Theoretical Min-Max Scaling",
  `hybrid_z` = "Z-Score")

data %>% dplyr::filter(q_id == 673670) %>% 
  ggplot(aes(y=hybrid_vanilla,x=value))+
  facet_wrap(vars(name),scales = "free", labeller =  as_labeller(names))+
  geom_point(aes(color=name))+
  guides(color="none")+
  scale_color_nejm()+
  theme_bw()+
  labs(y = "CC score - w/o normalization",x = "Normalized CC score")+
  theme(strip.background =element_rect(fill="#00A6D6"))+
  theme(strip.text = element_text(colour = 'white'))

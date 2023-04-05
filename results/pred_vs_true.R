library(ggplot2)
library(here)
library(janitor)
library(dplyr)
library(conflicted)
library(magrittr)
library(tidyverse)
library(hrbrthemes)
library(cowplot)

data <- read.csv(here("index","dev","testing","2020qrels-pass.txt"),header = FALSE)
data %<>% separate(V1, into=c("q_id","Q0","doc_id","rating")) %>% select(q_id,doc_id,rating)
data %<>% mutate_all( ~ as.numeric(.))


sparse_2020 <- read.csv(here("index","dev","testing","msmarco-passage-test2020-sparse10000.txt"),sep=" ",header = FALSE)
colnames(sparse_2020) <- c("q_id","Q0","doc_id","rank","sparse_score","name")
sparse_2020 %<>% select(q_id,doc_id,sparse_score)


dense_2020 <- read.csv("C:/Users/Revi/Desktop/dense_scores.csv",sep=",",header = TRUE)
dense_2020 %<>% distinct()
dense_2020 %<>% mutate_all( ~ as.numeric(.))




data %<>% left_join(sparse_2020,by=c("q_id","doc_id"))
data %<>% left_join(dense_2020,by=c("q_id","doc_id"))
alpha = 0.85
data %<>% mutate(hybrid_score = alpha * score + (1-alpha)*sparse_score) 


b <- data %>% arrange(rating) %>% 
  ggplot(aes(x=sparse_score,y=score))+
  geom_point(aes(color=hybrid_score))+
  #geom_point(aes(color=rating))+
  labs(x="Sparse score", y="Dense Score", color="Hybrid Score")+
  #labs(x="Sparse score", y="Dense Score", color="True relevance")+
  scale_color_continuous(type = "viridis")+
  theme_ipsum_rc()+
  theme(axis.title.y = element_text(size=12),axis.title.x = element_text(size=12))+
  theme(plot.margin = unit(c(0, 0, 5, 0), "pt"))


plot_grid(a, NULL, b, nrow = 1,rel_widths = c(1,0,1))



ranks <- read.csv("C:/Users/Revi/Desktop/ranks.csv",sep=",",header = FALSE)
colnames(ranks) <- c("q_id","doc_id","sparse_rank","dense_rank")

data %<>% left_join(ranks,by=c("q_id","doc_id"))
data %<>% mutate(hybrid_score_rrf=(1/(60+dense_rank))+(1/(60+sparse_rank)))

b <- data %>% arrange(rating) %>% 
  ggplot(aes(x=sparse_rank,y=dense_rank))+
  geom_point(aes(color=hybrid_score_rrf))+
  #geom_point(aes(color=rating))+
  labs(x="Sparse rank", y="Dense rank", color="Hybrid Score")+
  #labs(x="Sparse rank", y="Dense rank", color="True relevance")+
  scale_color_continuous(type = "viridis")+
  theme_ipsum_rc()+
  scale_x_continuous(limits = c(0,1000))+
  scale_y_continuous(limits = c(0,1000))+
  theme(axis.title.y = element_text(size=12),axis.title.x = element_text(size=12))+
  theme(plot.margin = unit(c(0, 0, 5, 0), "pt"))

plot_grid(a, NULL, b, nrow = 1,rel_widths = c(1,0,1))


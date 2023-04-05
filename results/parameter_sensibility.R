library(dplyr)


sem <- seq(0,1,0.05)
lex <- seq(0,1,0.05)

fusion_df <- expand.grid(sem,lex)
colnames(fusion_df) <- c("sem","lex")

alpha = 0.0
base <- fusion_df %>% mutate(alpha=alpha, hybrid=alpha*sem + (1-alpha)*lex) 

for (alpha in seq(1/5,1,1/5)) {
  base %<>% bind_rows(fusion_df %<>% mutate(alpha=alpha, hybrid=alpha*sem + (1-alpha)*lex) )
}


base %>% mutate(alpha=paste0("\u03b1 = ",alpha)) %>% ggplot(aes(x=sem,y=lex))+
  geom_raster(aes(fill=hybrid),interpolate = TRUE)+
  scale_fill_gradient(low="aliceblue", high="dodgerblue4")+
  coord_fixed()+
  labs(x="Semantic score", y="Lexical score", fill="Hybrid score")+
  facet_wrap(~alpha, nrow = 2)+
  theme_ipsum_rc()+
  theme(axis.text.x = element_text(angle=90),axis.title.y = element_text(size=12),axis.title.x = element_text(size=12))+
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)))+
  theme(axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0)))+
  theme(panel.spacing = unit(0.5, "lines"))


library(cowplot)

sem <- seq(0,20,1)
lex <- seq(0,20,1)

rrf_df <- expand.grid(sem,lex)
colnames(rrf_df) <- c("sem","lex")


eta = 600
base <- rrf_df %>% mutate(eta=eta, hybrid=(1/(eta+lex))+(1/(eta+sem))) 


c<- base %>% mutate(eta=paste0("\u03b7 = ",eta)) %>% ggplot(aes(x=sem,y=lex))+
  geom_tile(aes(fill=hybrid))+
  scale_fill_gradient(low="aliceblue", high="dodgerblue4")+
  coord_fixed()+
  labs(title=paste0("\u03b7 = ",eta),x="Semantic rank", y="Lexical rank", fill="Hybrid score")+
  theme_ipsum_rc()+
  theme(axis.title.y = element_text(size=12),axis.title.x = element_text(size=12))+
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)))+
  theme(axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0)))+
  theme(panel.spacing = unit(0.5, "lines"))+
  theme(plot.title = element_text(size=12,face="plain"))

plot_grid(a,NULL,b,NULL,c,nrow = 1,rel_widths = c(1,-0.15,1,-0.15,1))





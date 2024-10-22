setwd('/mnt/mibi_ngs/keerthi/berenike_substrates/assembly_allsubstrates_bin_substrate/all_samples_bins/CAZy_fam_new/')
cazyme_data<-read.delim(file='CAZyabundances.txt',sep = '\t', header = F)
cazyme_data<-cazyme_data[,-4]

colnames(cazyme_data)<-c('sample','CAZyfam','counts')

##
library(ggplot2)
library(dplyr)
library(gridExtra)
library(RColorBrewer)

colors_palette <- brewer.pal(5, "Set2")

gg<-ggplot(cazyme_data, aes(x = sample, y = counts, fill = CAZyfam)) +
  geom_bar(position="stack", stat="identity",width=0.7) + scale_fill_manual(values = colors_palette) + 
  labs(x="Sample",y="Absolute abundances")

p_abs<-gg + theme(axis.text.x = element_text(angle=45,hjust=1))
ggsave('cazy_absolabundances.pdf',plot=p_abs,height=7,width=7)


##calculate proportions
cazyme_data <- cazyme_data %>%
  group_by(sample) %>%
  mutate(proportion = counts / sum(counts))

# Plotting
gg<-ggplot(cazyme_data, aes(x = sample, y = proportion, fill = CAZyfam)) +
  geom_bar(position="stack", stat="identity", width = 0.7) + scale_fill_manual(values = colors_palette) +
  labs(x="Sample",y="Relative abundances")

p_rel<-gg + theme(axis.text.x = element_text(angle=45,hjust=1))  
ggsave('cazy_relabundances.pdf',plot=p_rel,height=7,width=7)


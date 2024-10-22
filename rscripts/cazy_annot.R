#install.packages('tidyr')
#install.packages('tidyverse')
#install.packages('pheatmap')

library(ggplot2)
library(tidyr)
library(tidyverse)
library(pheatmap)
library(rcartocolor)

phylum_list <- c('Firmicutes_A', 'Firmicutes', 'Fusobacteriota', 'Firmicutes_C', 'Bacteroidota')
color_list <- c('#FFFF00', '#FFA500', '#00FF00', '#FFDAB9', '#0000FF')

color_map <- setNames(color_list, phylum_list)
fam_list <- c('GH','GT','CE','CBM','PL')


# Heatmap
file_list <- list.files("/mnt/mibi_ngs/keerthi/CAZyme_ann/heatmap_Gemmiger", full.names = T, pattern = "counts.txt")
dfs <- lapply(file_list, function(x){read.delim(x, header = F)})

GH_sub_df <- NULL
for (seq_num in 1:length(dfs)){
  df <- dfs[[seq_num]]
  GH_sub <- df[grep("GH", df$V2),]
  GH_sub_df <- rbind(GH_sub_df, GH_sub)
}

## Sort to figure out the top GHs 
abund_df <- GH_sub_df %>% group_by(V2) %>% summarise(sum = sum(V3, na.rm = T))
abund_df <- abund_df %>% arrange(desc(sum))
top_list <- abund_df$V2[1:30]

genera_sel <- unique(GH_sub_df$V1)
df_heatmap <- NULL
for (i in genera_sel){
  sub_table <- GH_sub_df[GH_sub_df$V1 == i, ]
  single_list <- NULL
  for (j in top_list){
    if (j %in% sub_table$V2){
      single_list <- c(single_list, sub_table$V3[sub_table$V2==j]) # Assume the heatmap is about the read counts rather than existence being 1
    } else {
      single_list <- c(single_list, 0)
    }
  }
  df_heatmap <- rbind(df_heatmap, single_list)
}

row.names(df_heatmap) <- genera_sel
colnames(df_heatmap) <- top_list


pheatmap(df_heatmap, cluster_rows = F, cluster_cols =  F, main = 'g__Gemmiger')
dev.copy(pdf,'Gemmiger_GH.pdf')
dev.off()

##bar plot
family_map <- read.delim('/mnt/mibi_ngs/keerthi/butyrate_ann/greaterthan5MAGS/all_lineage.txt',sep=';', header = F)
family_map_rp <- read.delim('/mnt/mibi_ngs/keerthi/butyrate_ann/greaterthan5MAGS/all_lineage.txt',sep='\t', header = F)
family_map$genome <- family_map_rp$V1
family_map_trim <- family_map[,c('genome', 'V5')]

top_families <- read.delim('/mnt/mibi_ngs/keerthi/butyrate_ann/greaterthan5MAGS/top15_cp.txt',header = F)

genome_list <- NULL
for (fam_name in top_families$V1){
  tem_sub <- family_map_trim[family_map_trim$V5 == fam_name,]
  genome_list <- rbind(genome_list, tem_sub)
}

file_path <- '/mnt/mibi_ngs/keerthi/CAZyme_ann/'

merged_df <- NULL
for (fam_name in unique(genome_list$V5)){
  sub_table <- genome_list[genome_list$V5 == fam_name, ]
  #sub_table <- sub_table[sub_table$genome != 'MGYG000004866', ]
  sub_table$genome <- sub("\\.1$", "", sub_table$genome)
  file_list <- paste0(file_path, sub_table$genome, '_CAZycounts.txt')
  dfs_tem <- lapply(file_list, function(x){read.delim(x, header = F)})
  
  
  for (i in 1:length(dfs_tem)){
    df_tem <- dfs_tem[[i]]
    df_tem <- df_tem[!is.na(df_tem$V1),]
    mean_save <- NULL
    for (j in fam_list){
      tem_sub <- df_tem[grep(j,df_tem$V2),]
      mean_save <- c(mean_save, sum(tem_sub$V3, na.rm = T)) 
    }
    single_genome <- data.frame(fam_name = fam_name, genome_name = sub_table$genome[i], mean_value = mean_save, cluster = fam_list )
    merged_df <- rbind(merged_df, single_genome)
  }
}

merged_df$mean_value[is.na(merged_df$mean_value)] <- 0
#merged_df_new <- merge(merged_df, family_map[,c(2,5)], by.x = 'fam_name', by.y = 'V5')
#merged_df_new <-merged_df_new[!duplicated(merged_df_new), ]

res_final <- merged_df %>% group_by(fam_name, cluster) %>% summarise(mean_val = mean(mean_value, na.rm = T), sd_val = sd(mean_value, na.rm = T))

res_final$fam_name <- substr(res_final$fam_name, 4, nchar(res_final$fam_name))

res_final$min_val <- res_final$mean_val - res_final$sd_val
res_final$min_val <- ifelse(res_final$min_val < 0, 0, res_final$min_val)
res_final$max_val <- res_final$mean_val + res_final$sd_val

res_final$fam_name_origin <- paste0('f__', res_final$fam_name)
res_final_tem <- merge(res_final, family_map[,c(2,5)], by.x = 'fam_name_origin', by.y = 'V5')
res_final_tem <- res_final_tem[!duplicated(res_final_tem),]
res_final_tem$Phylum <- substr(res_final_tem$V2, 4, nchar(res_final_tem$V2))

p<-ggplot(res_final_tem, aes(x = fam_name, y = mean_val, fill = Phylum)) + geom_bar(stat= 'identity') + geom_errorbar(aes(ymin = min_val, ymax = max_val, x = fam_name), width = 0.5) + 
  facet_wrap(~cluster, scales = 'free_y') + theme(axis.text.x = element_text(hjust = 1, angle = 90)) + xlab("") + ylab("Mean across genomes") + scale_fill_manual(values =color_map) + labs(fill = 'Phylum') + 
  theme(legend.position = 'bottom', legend.justification = c(0.5,1), legend.box.just = 'right')

table(genome_list$V5)

ggsave(p, file='CAZymeabundaces_barplot_2.pdf')


## A combined heatmap
dir_list <- list.dirs('.')
dir_list <- dir_list[grep('heatmap', dir_list)]
matrix_all <- NULL

for (dir_name in dir_list){
  df_genomes <- list.files(dir_name, pattern = '.counts.txt')
  for (df_genome in df_genomes){
    file_list <- read.delim(paste0(dir_name, '/', df_genome), header = F)
    colnames(file_list)[2] <- 'Gene'
    colnames(file_list)[3] <- file_list$V1[1]
    if (is.null(matrix_all)){
      matrix_all <- file_list[,c(2,3)]
    } else{
      matrix_all <- merge(matrix_all, file_list[,c(2,3)], by = 'Gene', all= T)
    }
  }
  
}

total_counts <- rowSums(matrix_all[,2:ncol(matrix_all)], na.rm = T)
matrix_all_arrange <- matrix_all %>% mutate(total_counts = total_counts)

matrix_top <- matrix_all_arrange %>% arrange(desc(total_counts))
matrix_top_filter <- matrix_top[grep('GH', matrix_top$Gene),]
matrix_top_sub <- matrix_top_filter[1:30, ]


all_genome <- as.data.frame(colnames(matrix_top_sub)[2:(ncol(matrix_top_sub)-1)])
colnames(all_genome) <- 'Genome'
all_genome_anno <- merge(all_genome, family_map[,2:8], by.x = 'Genome', by.y = 'genome', all.x = T)
colnames(all_genome_anno) <- c('Genome', 'Phylum',	'Class', 'Order', 'Family', 'Genus', 'Species')
row.names(all_genome_anno) <- all_genome_anno$Genome

heatmap <- t(matrix_top_sub[,2:(ncol(matrix_top_sub)-1)])
colnames(heatmap) <- matrix_top_sub$Gene

heatmap[is.na(heatmap)] <- 0

for (i in 2:7){
  anno_tem_copy <- all_genome_anno[,i, drop=F]
  anno_tem <- anno_tem_copy
  heatmap_copy <- heatmap
  heatmap_new <- merge(heatmap_copy, all_genome_anno[,c(1,7)], by.x = 0, by.y = 1) 
  row.names(heatmap_new) <- heatmap_new$Species
  heatmap_new <- heatmap_new[,c(-1, -ncol(heatmap_new))]
  row.names(anno_tem) <- all_genome_anno$Species
  heatmap_plot <- as.matrix(heatmap_new)
  pheatmap(heatmap_plot, annotation_row = anno_tem,  cluster_rows = T, cluster_cols = F, show_rownames = T,fontsize_row = 10, fontsize_col = 10)
  dev.copy(pdf,paste0('./adapted_heat_maps_GH_2/', colnames(all_genome_anno)[i], '_rownames.pdf'),height=10,width=10)
  dev.off()
}

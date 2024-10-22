library(tidyverse)

folder_list <- c('S10w', 'S11w', 'S13', 'S9', 'S8', 'S6', 'S5', 'S4')
substrate_list <- c('Apple', 'Hylo', 'Inulin', 'Mucin' , 'NC', 'Nov', 'Protein')
info_substrate_all <- list()
substrate_df_list <- list()


for (num in 1:length(substrate_list)){
  for (folder_num in 1:length(folder_list)){
    folder_info <- folder_list[folder_num]
    current_path <- paste0('./', folder_info, '_mapping/')
    tem <- read_tsv(paste0('./', folder_info, '_mapping/' , substrate_list[num], '_' , folder_info, '_bin_abundances_metadata.tsv'))
   
    bin_cazy_anno_files <- list.files(current_path, pattern = '.dbCAN4.final.txt', full.names = T)
    bin_cazy_annotation_dfs <- lapply(bin_cazy_anno_files, function(x){read.delim(x,header = T)}) 
    bin_cazy_total <- NULL
    for (i in 1:length(bin_cazy_anno_files)){
      bin_cazy_total <- rbind(bin_cazy_total, bin_cazy_annotation_dfs[[i]])
    }
    
    bin_cazy_total$BinID <- unlist(lapply(bin_cazy_total$geneID, function(x){unlist(strsplit(x, '_'))[[1]]}))
    
    cazy_abundance_sub<-merge(tem,bin_cazy_total,by.x = "BinID", by.y = "BinID", all.y = TRUE)
    cazy_abundance_sub_new<-cazy_abundance_sub %>% group_by(CAZyID) %>% summarise(Total = sum(Proportion, na.rm = TRUE))
    
    substrate_df_list[[folder_num]] <-cazy_abundance_sub_new
  }
  info_substrate_all[[num]] <- substrate_df_list
}

overall_df <- NULL

for (i in 1:length(info_substrate_all)){
  substrate_sg_list <- info_substrate_all[[i]]
  for (j in 1:length(substrate_sg_list)){
    tem_list <- substrate_sg_list[[j]]
    tem <- tem_list[,c('CAZyID', 'Total')]
    tem_name <- paste0(substrate_list[i], '_',j)
    colnames(tem) <- c('CAZyID', tem_name)
    if (is.null(overall_df)){
      overall_df <- tem
    } else{
      overall_df <- merge(overall_df, tem, by='CAZyID', all.x = T, all.y = T)
    }
  }
}

overall_df[is.na(overall_df)] <- 0
overall_df_gh <- overall_df[grep('GH', overall_df$CAZyID),]

result_list <- c()
for (substrate in substrate_list) {
  for (folder in folder_list) {
    result_list <- c(result_list, paste(substrate, folder, sep = "_"))
  }
}
print(result_list)

row.names(overall_df_gh) <- overall_df_gh$CAZyID
overall_df_gh <- overall_df_gh[,-1]
colnames(overall_df_gh)<-result_list
#overall_df_gh <- as.matrix(overall_df_gh)


library(pheatmap)

colors_pal <- colorRampPalette(c('lightblue', 'blue', 'purple', 'red'))(240)
max_val <- max(overall_df_gh, na.rm = TRUE)

# Create breaks for heatmap
breaks <- c(seq(0, 100, length.out = 100), seq(100.01, 200, length.out = 100), seq(200.01, max_val, length.out = 40))

# Annotate columns
anno_heatmap <- data.frame(Substrate = sub("_.*", "", colnames(overall_df_gh)))
row.names(anno_heatmap) <- colnames(overall_df_gh)
anno_heatmap$Substrate <- factor(anno_heatmap$Substrate, levels = c("Hylo", "Nov", "Apple", "Mucin", "Inulin", "NC", "Protein"))

# Arrange data by substrate
arranged_df <- NULL
for (level_res in levels(anno_heatmap$Substrate)) {
  tem_df <- overall_df_gh[, grep(level_res, colnames(overall_df_gh))]
  if (is.null(arranged_df)) {
    arranged_df <- tem_df
  } else {
    arranged_df <- cbind(arranged_df, tem_df)
  }
}

total_counts <- rowSums(arranged_df, na.rm = T)
#arranged_df <-as.data.frame(arranged_df)
arranged_df_counts <- arranged_df %>% mutate(total_counts = total_counts)

arranged_df_top <- arranged_df_counts %>% arrange(desc(total_counts))
arranged_df_sub <- arranged_df_top[1:30, ]
arranged_df_sub <- arranged_df_sub[,-ncol(arranged_df_sub)]

arranged_df_sub_log <- log10(arranged_df_sub + 1)
arranged_df_sub_scaled <- scale(arranged_df_sub)

pdf('heatmap_cazyme_abundances_scaled.pdf',width = 14,height=8)
# Generate heatmap
#pheatmap(arranged_df_sub, cexCol = 0.7, angle_col = 90, cluster_cols = FALSE,cluster_rows = TRUE,color = colors_pal, breaks = breaks, annotation_col = anno_heatmap, show_colnames = TRUE, fontsize_row = 10, cellwidth =10 ,cellheight =10)
pheatmap(arranged_df_sub_scaled, cexCol = 0.7, angle_col = 90, cluster_cols = FALSE,cluster_rows = TRUE, annotation_col = anno_heatmap, show_colnames = TRUE, fontsize_row = 10, cellwidth =10 ,cellheight =10)
dev.off()

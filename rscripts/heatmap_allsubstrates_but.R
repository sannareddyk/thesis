library(tidyverse)
folder_list <- c('S10w', 'S11w', 'S13', 'S9', 'S8', 'S6', 'S5', 'S4')

for (folder_info in folder_list){
  current_path <- paste0('./', folder_info, '_mapping/')
  file_list <- list.files(current_path, pattern = '.bin.abundances.txt', full.names = T)
  file_list_short <- list.files(current_path, pattern = '.bin.abundances.txt', full.names = F)
  file_list_short_name <- substr(file_list_short, 1, nchar(file_list_short)-nchar('.bin.abundances.txt'))
  dfs <- lapply(file_list, function(x){read.delim(x, header = F)})
  
  meta_data <- read.delim(paste0(current_path, 'bins_metadata.tsv'), header = T, sep = '\t')
  meta_data_cp <- read.delim(paste0(current_path, 'bins_metadata.tsv'), header = F, sep = ';')
  meta_data_cp <- meta_data_cp[2:nrow(meta_data_cp),]
  meta_data_sum <- cbind(meta_data[1], meta_data_cp[2:ncol(meta_data_cp)])
  colnames(meta_data_sum) <- c('BinID', 'Phylum',	'Class', 'Order', 'Family', 'Genus', 'Species')
  
  anno <- read.delim(paste0(current_path,'metawrap_80_10_bins.contigs'), header = F)
  
  dfs_anno <- list()
  
  for (i in 1:length(dfs)){
    df <- dfs[[i]]
    df_tem <- merge(df, anno, by= 'V1')
    df_tem_bin <- df_tem %>% group_by(V2.y) %>% summarise(total_counts = sum(V3)) %>% arrange(desc(total_counts))
    df_tem_bin_new <- merge(df_tem_bin, meta_data_sum, by.x = 1, by.y = 1)
    df_tem_bin_new <- df_tem_bin_new %>% arrange(desc(total_counts))
    df_tem_bin_new$proportion <- df_tem_bin_new$total_counts/sum(df_tem_bin_new$total_counts) * 100
    colnames(df_tem_bin_new) <- c('BinID', 'Total_counts' , 'Phylum',	'Class', 'Order', 'Family', 'Genus', 'Species', 'Proportion')
    dfs_anno[[i]] <- df_tem_bin_new
    write_tsv(df_tem_bin_new, paste0(current_path, file_list_short_name[i], '_bin_abundances_metadata.tsv'))
  }              
  
}

folder_list <- c('S10w', 'S11w', 'S13', 'S9', 'S8', 'S6', 'S5', 'S4')
substrate_list <- c('Apple', 'Hylo', 'Inulin', 'Mucin' , 'NC', 'Nov', 'Protein')
info_substrate_all <- list()
substrate_df_list <- list()

for (num in 1:length(substrate_list)){
  for (folder_num in 1:length(folder_list)){
    folder_info <- folder_list[folder_num]
    current_path <- paste0('./', folder_info, '_mapping/')
    tem <- read_tsv(paste0('./', folder_info, '_mapping/' , substrate_list[num], '_' , folder_info, '_bin_abundances_metadata.tsv'))
    
    but_bins <- read.delim(paste0(current_path,'all_acoa_bins_sorted.txt'), header = F)
    colnames(but_bins) <- c('BinID')
    meta_data <- read.delim(paste0(current_path, 'bins_metadata.tsv'), header = T, sep = '\t')
    meta_data_cp <- read.delim(paste0(current_path, 'bins_metadata.tsv'), header = F, sep = ';')
    meta_data_cp <- meta_data_cp[2:nrow(meta_data_cp),]
    meta_data_sum <- cbind(meta_data[1], meta_data_cp[2:ncol(meta_data_cp)])
    colnames(meta_data_sum) <- c('BinID', 'Phylum',	'Class', 'Order', 'Family', 'Genus', 'Species')
    but_bins_annotated <- merge(but_bins, meta_data_sum, by.x = "BinID", by.y = "BinID", all.x = TRUE)
    write_tsv(but_bins_annotated, paste0(current_path, 'all_acoa_bins_sorted_annotated.tsv'))
    
    tem <- tem %>% filter(Species %in% but_bins_annotated$Species)
    substrate_df_list[[folder_num]] <- tem
  }
  info_substrate_all[[num]] <- substrate_df_list
}

overall_df <- NULL
  

for (i in 1:length(info_substrate_all)){
  substrate_sg_list <- info_substrate_all[[i]]
  for (j in 1:length(substrate_sg_list)){
        tem_list <- substrate_sg_list[[j]]
        tem <- tem_list[,c('Species', 'Proportion')]
        tem <- tem[tem$Species != 's__',]
        tem_name <- paste0(substrate_list[i], '_',j)
        colnames(tem) <- c('Species', tem_name)
        if (is.null(overall_df)){
          overall_df <- tem
        } else{
          overall_df <- merge(overall_df, tem, by='Species', all.x = T, all.y = T)
        }
  }
}

overall_df[is.na(overall_df)] <- 0

result_list <- c()
for (substrate in substrate_list) {
  for (folder in folder_list) {
    result_list <- c(result_list, paste(substrate, folder, sep = "_"))
  }
}
print(result_list)

row.names(overall_df) <- overall_df$Species
overall_df <- overall_df[,-1]
overall_df <- as.matrix(overall_df)
colnames(overall_df) <- result_list

##generate heatmap
library(pheatmap)

colors_pal <- colorRampPalette(c('lightblue', 'blue', 'purple', 'red'))(240)
max_val <- max(overall_df, na.rm = TRUE)

# Create breaks for heatmap
breaks <- c(seq(0, 2, length.out = 80), seq(2.01, 8, length.out = 80), seq(8.01, max_val, length.out = 80))

# Annotate columns
#anno_heatmap <- data.frame(Substrate = substr(colnames(overall_df), 1, nchar(colnames(overall_df)) - 2))
anno_heatmap <- data.frame(Substrate = sub("_.*", "", colnames(overall_df)))
row.names(anno_heatmap) <- colnames(overall_df)
anno_heatmap$Substrate <- factor(anno_heatmap$Substrate, levels = c("Hylo", "Nov", "Apple", "Mucin", "Inulin", "NC", "Protein"))

# Arrange data by substrate
arranged_df <- NULL
for (level_res in levels(anno_heatmap$Substrate)) {
  tem_df <- overall_df[, grep(level_res, colnames(overall_df))]
  if (is.null(arranged_df)) {
    arranged_df <- tem_df
  } else {
    arranged_df <- cbind(arranged_df, tem_df)
  }
}

# Calculate row-wise average abundance
row_avg_abundance <- apply(arranged_df, 1, mean, na.rm = TRUE)

# Filter rows with greater than 5% average abundance
filtered_indices <- row_avg_abundance > 0.05
filtered_df <- arranged_df[filtered_indices, ]
library(reshape2)
filtered_df_long <- melt(filtered_df)
filtered_df_long$Var2 <- as.character(filtered_df_long$Var2)
filtered_df_long$substrate_level <- unlist(lapply(filtered_df_long$Var2, function(x){unlist(strsplit(x, '_'))[[1]]}))
filtered_df_long_sum <- filtered_df_long %>% group_by(substrate_level, Var1) %>% summarise(average = mean(value), sd_val = sd(value))

pdf('heatmap_but_producers.pdf',width = 14,height=8)
# Generate heatmap
pheatmap(filtered_df, show_colnames = FALSE, cluster_cols = FALSE, cluster_rows = FALSE, color = colors_pal, breaks = breaks, annotation_col = anno_heatmap, fontsize_row = 10, cellwidth =10 ,cellheight =10)
dev.off()

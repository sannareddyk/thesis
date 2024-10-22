library(tidyverse)

rel_abundance_files <- list.files(pattern = '_lineage_20hkg_final_relabundance.txt')

rel_abundance_dfs <- lapply(rel_abundance_files, function(x) {
  df <- read.delim(x, header = TRUE)
  sample_name <- gsub('_lineage_20hkg_final_relabundance.txt', '', x)  # Extract sample name
  colnames(df)[4] <- sample_name # Rename the column
  return(df)
})

merged_abundance_data <- rel_abundance_dfs[[1]]
merged_abundance_data <- merged_abundance_data[,c(1,4)]

for (i in 2:length(rel_abundance_files)){
  tem <- rel_abundance_dfs[[i]]
  merged_abundance_data <- merge(merged_abundance_data, tem[,c(1,4)],by='lineage', all = T)
}

#split lineage column based on a delimiter, groupby phylum, family, genus and sum rel abundances
#plot rel abundance at each level and rearrange based on substrates

#split lineage column
split_df <-merged_abundance_data %>%
  separate(lineage, into = c("kingdom", "phylum", "class", "order", "family", "genus", "species"), sep = ";")

sample_col_indices <- 8:ncol(split_df)

##
split_df <- split_df %>%
  rowwise() %>%
  mutate(avg_abundance = mean(c_across(all_of(sample_col_indices)), na.rm = TRUE))

# Filter rows with greater than 1% average abundance
filtered_df <- split_df %>%
  filter(avg_abundance > 0.01)


# Summarize by genus
genus_data <- filtered_df %>%
  select(genus, sample_col_indices)

summarized_df_genus <- genus_data %>%
  group_by(genus) %>%
  summarise(across(everything(), ~ sum(.x, na.rm = TRUE)))

# Summarize by family
family_data <- filtered_df %>%
  select(family, sample_col_indices)

summarized_df_family <- family_data %>%
  group_by(family) %>%
  summarise(across(everything(), ~ sum(.x, na.rm = TRUE)))

# Summarize by phylum
phylum_data <- filtered_df %>%
  select(phylum, sample_col_indices)

summarized_df_phylum <- phylum_data %>%
  group_by(phylum) %>%
  summarise(across(everything(), ~ sum(.x, na.rm = TRUE)))

###

substrate_list <- c("Hylo", "Nov", "Apple", "Mucin", "Inulin", "NC", "Protein")
sample_list <- c('S10w','S11w', 'S13', 'S9', 'S8', 'S6', 'S5', 'S4')

combined_list <- vector("list", length = length(substrate_list) * length(sample_list))

idx <- 1
for (sub in substrate_list) {
  for (sample in sample_list) {
    combined_list[[idx]] <- paste0(sub, "_", sample)
    idx <- idx + 1
  }
}

combined_list

##long format, reorder by substrate and plot at genus level

# long_df_genus <- summarized_df_genus %>%
#   pivot_longer(cols = -genus, names_to = "sample", values_to = "abundance")
# 
# long_df_genus_filtered<-long_df_genus %>%
#   group_by(sample) %>%
#   arrange(sample,desc(abundance)) %>%
#   slice_head(n =10)

#group_col_g1 <- c('Hylo','Nov','Inulin')
#group_col_g2 <- c('Apple','Mucin')
#group_col_g3 <- c('NC','Protein')


#tem_gr1 <- summarized_df_genus[,c(1, grep(group_col_g1[1], colnames(summarized_df_genus)), 
#                                 grep(group_col_g1[2], colnames(summarized_df_genus)), 
#                                 grep(group_col_g1[3], colnames(summarized_df_genus)))]

#tem_gr2 <- summarized_df_genus[,c(1, grep(group_col_g2[1], colnames(summarized_df_genus)), 
#                                   grep(group_col_g2[2], colnames(summarized_df_genus)))]
 
#tem_gr3 <- summarized_df_genus[,c(1, grep(group_col_g3[1], colnames(summarized_df_genus)), 
#                                   grep(group_col_g3[2], colnames(summarized_df_genus)))]
 
#summarized_info_groups <- data.frame(genus = tem_gr1$genus,
#                                     group1_abundance = rowMeans(tem_gr1[,2:ncol(tem_gr1)]),
#                                      group2_abundance = rowMeans(tem_gr2[,2:ncol(tem_gr2)]),
#                                      group3_abundance = rowMeans(tem_gr3[,2:ncol(tem_gr3)]))

#summarized_info_groups_sorted <- summarized_info_groups %>% rowwise() %>% 
#  mutate(variance = var(c_across(where(is.numeric))), average = mean(c(group1_abundance, group2_abundance, group3_abundance))) %>%
#  arrange(desc(variance))

#summarized_info_all_sample <- summarized_df_genus %>% rowwise() %>% 
#  mutate(variance = var(c_across(where(is.numeric)), na.rm = T)) %>% 
#  arrange(desc(variance)) %>% select(c(genus, variance)) %>%  select(genus) 
#summarized_top_genus <- summarized_info_all_sample[1:25,]

summarized_info_all_sample <- summarized_df_genus %>%
  rowwise() %>%
  mutate(sum_values = sum(c_across(where(is.numeric)), na.rm = TRUE)) %>%
  arrange(desc(sum_values)) %>%
  select(genus, sum_values)

summarized_top_genus <- summarized_info_all_sample[1:25,]

long_df_genus_new <- summarized_df_genus %>%
  pivot_longer(cols = -genus, names_to = "sample", values_to = "abundance")

long_df_genus_filtered_new <-long_df_genus_new %>%
  group_by(sample) %>%
  filter(genus %in% summarized_top_genus$genus)

# Reorder sample names based on the order in the list of strings
long_df_genus_filtered_reordered_new <- long_df_genus_filtered_new %>%
  mutate(sample = factor(sample, levels = combined_list)) 

library(RColorBrewer)
library(viridis)

palette1 <- brewer.pal(12, "Paired")  # First 12 colors
palette2 <- brewer.pal(12, "Set3")[1:13]  # Next 13 colors
combined_palette <- c(palette1, palette2)



##ggplot
p_new <-ggplot(data=long_df_genus_filtered_reordered_new, aes(fill=genus, y=abundance, x=sample)) +
  geom_bar(position="stack", stat="identity") + theme(axis.text.x=element_text(angle=90)) + scale_fill_manual(values=combined_palette) +
  xlab("") + ylab("Relative abundance")

p_new



# # Reorder sample names based on the order in the list of strings
# long_df_genus_filtered_reordered <- long_df_genus_filtered %>%
#   mutate(sample = factor(sample, levels = combined_list)) 
# 
# ##ggplot
# p<-ggplot(data=long_df_genus_filtered_reordered, aes(fill=genus, y=abundance, x=sample)) +
#   geom_bar(position="stack", stat="identity") + theme(axis.text.x=element_text(angle=90)) +
#   xlab("") + ylab("Relative abundance")

ggsave('top25genus_relabundances.pdf',p_new,width=10,height=8)


##family level


#summarized_info_all_sample <- summarized_df_family %>% rowwise() %>% 
#  mutate(variance = var(c_across(where(is.numeric)), na.rm = T)) %>% 
#  arrange(desc(variance)) %>% select(c(family, variance)) %>%  select(family) 
#summarized_top_family <- summarized_info_all_sample[1:20,]

summarized_info_all_sample <- summarized_df_family %>%
  rowwise() %>%
  mutate(sum_values = sum(c_across(where(is.numeric)), na.rm = TRUE)) %>%
  arrange(desc(sum_values)) %>%
  select(family, sum_values)

summarized_top_family <- summarized_info_all_sample[1:20,]


long_df_family_new <- summarized_df_family %>%
  pivot_longer(cols = -family, names_to = "sample", values_to = "abundance")

long_df_family_filtered_new <-long_df_family_new %>%
  group_by(sample) %>%
  filter(family %in% summarized_top_family$family)

# Reorder sample names based on the order in the list of strings
long_df_family_filtered_reordered_new <- long_df_family_filtered_new %>%
  mutate(sample = factor(sample, levels = combined_list)) 

library(RColorBrewer)
library(viridis)

palette1 <- brewer.pal(12, "Paired")  # First 12 colors
palette2 <- brewer.pal(12, "Set2")[2:14]  # Next 13 colors
combined_palette <- c(palette1, palette2)



##ggplot
q_new <-ggplot(data=long_df_family_filtered_reordered_new, aes(fill=family, y=abundance, x=sample)) +
  geom_bar(position="stack", stat="identity") + theme(axis.text.x=element_text(angle=90)) + scale_fill_manual(values=combined_palette) +
  xlab("") + ylab("Relative abundance")

q_new

ggsave('family_relabundances.pdf',q_new,width=10,height=8)


##phylum level
long_df_phylum <- summarized_df_phylum %>%
  pivot_longer(cols = -phylum, names_to = "sample", values_to = "abundance")

# Reorder sample names based on the order in the list of strings
long_df_phylum_reordered <- long_df_phylum %>%
  mutate(sample = factor(sample, levels = combined_list))

palette2 <- brewer.pal(12, "Set3")[1:10]

##ggplot
r<-ggplot(data=long_df_phylum_reordered, aes(fill=phylum, y=abundance, x=sample)) +
  geom_bar(position="stack", stat="identity") + theme(axis.text.x=element_text(angle=90)) + scale_fill_manual(values=palette2) + 
  xlab("") + ylab("Relative abundance")

ggsave('phylum_relabundances.pdf',r,width=10,height=8)



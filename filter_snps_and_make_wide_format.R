# Load the data.table package
library(data.table)

# Read in the data, give column names, and remove a unnecessary/empty column
fread("200429_normalize.tsv") -> x
setnames(x, c("scaffold", "position", "ref", "alt", "quality", "sample", "GT", "V8", "DP", "DV"))
x[, V8 := NULL]

# Clean up sample names by stripping the "relative path" style, leaving only the sample name.
# The sample names will be turned into column names for part of the analysis, so this will make it cleaner.
x[, sample := sub("/.+$", "", sample)]

# Do the same for the scaffold column.
x[, scaffold := sub(";.+$", "", scaffold)]

# Name scaffolds of interest
scaffolds_of_interest = c("Scaffold_1", "Scaffold_3", "Scaffold_7", "Scaffold_9", "Scaffold_13", "Scaffold_18", "Scaffold_48", "Scaffold_51", "Scaffold_70", "Scaffold_93", "Scaffold_415", "Scaffold_693", "Scaffold_1062", "Scaffold_1063", "Scaffold_1064", "Scaffold_1065")

# Retain only scaffolds of interest
x[scaffold %in% scaffolds_of_interest] -> y

# Filter for low quality scores (minimum=40)
y[quality > 40] -> y
# Filter for a minimum depth of 6 reads
y[DP > 6] -> yy

# Filter based on genotype. Keep all homozygous calls but filter out heterozygotes with less than 3 ALT alleles
yy[GT==0 | GT == 2 | (GT==1 & DV >= 3)] -> z

# Convert from long format to wide format
dcast(z, scaffold + position + ref + alt ~ sample, value.var="GT") -> zz
zz <- as.data.table(zz)
# Count number of NA values (missing individuals) per SNP
zz[, sum := apply(zz, MARGIN=1, function(x) sum(is.na(x)))]
# Filter based on the number of NA values
zz[sum <= 30] -> a

# Save today's date as an object for use in filenames. This will prevent overwriting previous files by mistake
date <- Sys.Date()
today <- format(date, format="%y%m%d")

# Write the filtered SNP table to a file
write.csv(a, file=paste0(today, "_JohnsonDora_snps_filtered.csv"), row.names=FALSE, col.names=TRUE)
# Save data
save(a, y, scaffolds_of_interest, file=paste(today, "_JohnsonDora_snps_filtered.Rdata"))

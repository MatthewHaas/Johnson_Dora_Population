# 1 November 2019
# WD: /home/jkimball/haasx092/main_GBS/JohnsonDora_samtools

# Load required packages
library(data.table)
library(reshape2)

# Read in data
fread("191101_JohnsonDora_snps.tsv") -> x

# Remove unnecessary column
x[, V8 := NULL]

# Give columns informative names
setnames(x, c("scaffold", "pos", "ref", "alt", "qual", "sample", "GT", "DP", "DV"))

# Remove extraneous/redundant part of sample name
x[, sample := sub("/.+$", "", sample)]

# Remove extraneous part of scaffold name
x[, scaffold := sub(";.+$", "", scaffold)]

# Filter for depth greater than 5 reads per position
x[DP > 5] -> x

# Convert from long to wide format
dcast(x, scaffold + pos ~ sample, value.var="GT") -> y

# Convert back to data.table format
y <- as.data.table(y)

# Find the sum of "NA" values across all individuals and then filter (this level -25- allows for about 21% missing data)
y[, sum := apply(y, MARGIN=1, function(x) sum(is.na(x)))]
y[sum < 25] -> z

# Make a CSV file of the JohnsonDora SNPs
write.csv(z, file="191101_JohnsonDora_snps.csv", col.names=TRUE, row.names=FALSE)

# Save the data
save(x, y, z, file="191101_JohnsonDora_snps.Rdata")
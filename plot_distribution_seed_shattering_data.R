# 16 July 2019
# Plot distribution of seed shattering data

# On command line, load R
module load R/3.6.0

# Load data.table package and read in data
library(data.table)
fread("seed_shattering_data.csv") -> x

# Sort data into categories and set order 
x[, .N, by="shattering_numerical"] -> y
y[order(shattering_numerical)] -> y

# Make the plot
pdf("190716_JohnsonDora_shattering_distribution.pdf")
# Save midpoint values from barplot in "z"
z <- y[, barplot(N, xlab="Shattering score", ylab="Frequency", ylim=c(0,100), names.arg=c("S-", "S", "N", "N+"), main=paste0("Shattering Distribution", "\n", "Johnson×Dora population"), yaxt='n', col="blue")]
axis(2, las=2) # Makes values of y-axis easier to read
# Add value of each bar to the barplot (messy, but works)
text(z[1,1], y[1,N]+2, y[1,N])
text(z[2,1], y[2,N]+2, y[2,N])
text(z[3,1], y[3,N]+2, y[3,N])
text(z[4,1], y[4,N]+2, y[4,N])
dev.off()

# Save data
save(x,y,z, file="190716_JohnsonDora_shattering_distribution.Rdata")

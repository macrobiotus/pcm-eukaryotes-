#!/usr/local/bin/gnuplot

# Output W3C Scalable Vector Graphics
set terminal svg size 1250, 350

# Set plot size
set size 1,1

# Set graph title
set title 'DADA2 Processing Results (Qiime2 Implementation)'

# Set label of x-axis
set xlabel 'FastQ file'

# Set label of y-axis
set ylabel 'Reads at Stage'

# Use a histogram
set style data histogram

# Use clustered histogram (gap size of 1 makes xtics position better)
set style histogram clustered gap 1

# Use a solid fill style for histogram bars
set style fill solid 1 noborder

# Rotate x-axis labels by 60 degrees
set xtics rotate by 45 right

# define output path
set output "../Zenodo/Qiime/050_16S_ridge-stat.svg"

# Plot data from a file, with extra notes below:
#
# for [i=2:5]         Loop for values of i between 2 and 5 (inclusive)
# using i:xtic(1)     Plot column i using tick labels from column 1
# title columnheader  Use the column headers (first row) as titles
# linewidth 4         Use a wideplotr line width

# plot
plot for [i=2:5] "../Zenodo/Qiime/050_16S_ridge-stat.tsv" using i:xtic(1) title columnheader linewidth 4



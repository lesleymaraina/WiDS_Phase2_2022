#!/bin/bash

while read line
do
Rscript generate_df_multivariate_analysis.R $line
done < $1
The data directory contains the code necessary to prepare the feature and target matrices for the Spring Dawley rats. 

The data originally comes in vcf format and is converted into tabular format with these scripts. Preprocessing essentially consisted of
1. Loading the vcf data
2. Integer encoding the features and targets
3. Saving the data in tabular form 

Since there were two laboratories that the rats were raised at, it made sense to analyze the datasets grouped by laboratory in addition to the combined dataset in order to see if there was a large difference between the samples. 

TODO 
- [ ] Move and clean up the VCF parsing code to this directory.
- [ ] Verify that X_common_C and X_common_H have the same number of rows. If they differ, investigate the reason this happens. This may involve debugging the common_indices code. 
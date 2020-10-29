reference allele - most common allele at that spot in your data
alt allele (list) - 

indel - can have multiple insertions or deletions

- SNPs are the columns
- Mice are the rows (samples)

A "record" contains a single SNP. "sample" is a property of the record that tells us about a specific mouse. 


Use integer encoding to capture the base at a given position. You can use something like (0, 1, 2, 3) = (A, T, G, C) or even have the integers reflect how common an allele is. 
You should probably track the reference allele. 

Additive assumption of GWAS




## what is the target?

There should be phenotype of information.
There's another file in the github that gives a description. It's an Excel vile called SV...xls*. It has sample and phenotype info. 

THere should be some sort of sample ID that has 0 or 1. You just need to match that sample ID to your matrix.


## Notes

The neural netowrk paper took random subsets of the SNPs available rather than using all of them each time. 
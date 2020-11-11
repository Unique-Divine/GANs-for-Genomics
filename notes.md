# 



### PyVCF background info

reference allele - most common allele at that spot in your data
alt allele (list) - 

indel - can have multiple insertions or deletions

- SNPs are the columns
- Mice are the rows (samples)

A "record" contains a single SNP. "sample" is a property of the record that tells us about a specific mouse. 


Use integer encoding to capture the base at a given position. You can use something like (0, 1, 2, 3) = (A, T, G, C) or even have the integers reflect how common an allele is. 
You should probably track the reference allele. 

Additive assumption of GWAS


### Target Variable

**Targets**: Phenotype information for the mice.

There's another file in the github that gives a description. It's an Excel vile called SV...xls*. It has sample and phenotype info. 



### Notes, Brainstorming, and Planning

The neural netowrk paper took random subsets of the SNPs available rather than using all of them each time. 

#### Sun, Nov. 8

I need to narrow down relevant SNPs. In last meeting, we discussed a few methods to accomplish this goal. 
- p-values from logit
- [statistical tests / SelectKBest](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.SelectKBest.html)
- [variance threshold](https://scikit-learn.org/stable/modules/feature_selection.html#:~:text=1.-,Removing%20features%20with%20low%20variance,same%20value%20in%20all%20samples.)

**Blockers**: 
1. I don't understand the p value threshold concept well enough to explain it. From the paper, it seems that higher $p \implies$ better feature.
2. Which tests can be used to find variance explained? And, is the variance of a column vector all I need? This seems like a computationally inexpensive approach to shrinking down my set of features.
3. SelectKBest: This method is most likely best to use after a faster or more naive approach narrows the dataset. My hunch is that SelectKBest will take too long to run. Of course, I should try it out first. Also, exposing the target information to inform my feature selection could jeopardize the legitimacy of the predictive model. 

**MVP** (SNP feature selection): Make a small feature matrix that uses approximately the same  number of SNPs as the reference paper.

## TODO
- [ ] Make a small feature matrix that uses approximately the same  number of SNPs as the reference paper
  - [ ] Find out what that number is by reading the paper.
  - [ ] Record the number of SNPs used for each test in the paper as well.
  - [ ] Reduce the number of features down to the maximum number from the paper using variance threshold. 
- [ ] m




# Feature Selection: Lowering the SNP count


# Research Notes <!-- omit in toc -->


- [Parsing and loading the data](#parsing-and-loading-the-data)
  - [PyVCF background info](#pyvcf-background-info)
  - [Target Variable](#target-variable)
- [TODO](#todo)
- [Google Colab](#google-colab)
  - [Pytorch in Colab?](#pytorch-in-colab)
  - [`requirements.txt` in virtual environment](#requirementstxt-in-virtual-environment)
  - [How to enter multiple shell commands in one line](#how-to-enter-multiple-shell-commands-in-one-line)
- [Chronological Research Notes](#chronological-research-notes)

## Parsing and loading the data

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

## TODO

1. [ ] Recover the X_common for the C and H datasets.
2. [ ] Perform feature selection to get X_r
3. [ ] Train GANs on X_r & Y
4. [ ] Evaluate each model while the GANs train 
- Neural Networks 
  - [ ] Implement data loader
  - [ ] Implement network architecture
  - [ ] Write a NN training method
4. [ ] Generate new samples to improve dataset quality
5. [ ] Evaluate models again

---

## Google Colab

- [ ] finish mining [this](https://www.tutorialspoint.com/google_colab/google_colab_executing_external_python_files.htm) 
- [ ] mine [this](https://zerowithdot.com/colab-workspace/)

### Pytorch in Colab?

Simply `import torch` in one of the cells. PyTorch is pre-installed.

### `requirements.txt` in virtual environment

To install from a `requirements.txt` file (with pip):
1. `cd` to the directory `requirements.txt` is located.
2. Make sure your virtual environment is activated if you're using one.
3. Run: `pip install -r requirements.txt` in the shell.


Create a `requirements.txt`:
1. At the shell, run: `pip freeze > requirements.txt`. If pip installation conflicts are causing problems, try `conda install -r requirements`. 

### How to enter multiple shell commands in one line

- Use `&&` to execute successive commands. In `[command 1] && [command 2]`, the 2nd command only executes if the previous one succeeds.
- To pipe the outputs (stdout) of one comand into the input of another, use `|`. Use `|&` to pipe both the `stdout` and `stderr` into the standard input
- `[LHS] || [RHS]` executes RHS of only if the LHS fails. 
- `;` executes RHS regardless of whether LHS succeeds. Note, if `set -e` was previously invoked, `bash` will raise an error. 

[Maxim Egorushkin (reference)](https://stackoverflow.com/questions/5130847/running-multiple-commands-in-one-line-in-shell)

[bash docs](https://www.gnu.org/software/bash/manual/bash.html#Lists)


---

## Chronological Research Notes

The neural netowrk paper took random subsets of the SNPs available rather than using all of them each time. 

#### Nov. 8

I need to narrow down relevant SNPs. In last meeting, we discussed a few methods to accomplish this goal. 
- p-values from logit
- [statistical tests / SelectKBest](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.SelectKBest.html)
- [variance threshold](https://scikit-learn.org/stable/modules/feature_selection.html#:~:text=1.-,Removing%20features%20with%20low%20variance,same%20value%20in%20all%20samples.)

**Blockers**: 
1. I don't understand the p value threshold concept well enough to explain it. From the paper, it seems that higher $p \implies$ better feature.
2. Which tests can be used to find variance explained? And, is the variance of a column vector all I need? This seems like a computationally inexpensive approach to shrinking down my set of features.
3. SelectKBest: This method is most likely best to use after a faster or more naive approach narrows the dataset. My hunch is that SelectKBest will take too long to run. Of course, I should try it out first. Also, exposing the target information to inform my feature selection could jeopardize the legitimacy of the predictive model. 

**MVP** (SNP feature selection): Make a small feature matrix that uses approximately the same  number of SNPs as the reference paper. Done. 

#### Nov. 26 - 30

There are different numbers of SNPs between the two groups of samples. 


#### 

motivation fo GWAS - finding associations in genome
visualizations - manhattan plot
metrics 

intro to GANs
motivation for using them

dataset Dawley Rats

rough summary of project ^^^



Importance of undergrad research:

- seems intimidating at first
- more latitude to make mistakes and waste your time
- gives you a head start: longer you do it, better you get

look for statistics / sources to bolster claims:


----

Jie Yuan 8:24 PM

https://www.cs.columbia.edu/calendar/


Jie Yuan 8:32 PM

https://www.tandfonline.com/doi/abs/10.1080/00220612.1982.10671594
https://journals.sagepub.com/doi/abs/10.3102/0002831213482038


Jie Yuan 8:38 PM

map/ped
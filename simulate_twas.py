#!/usr/bin/env python
__author__ = "Jie Yuan"
__github__ = "https://github.com/jyuan1322"

import numpy as np
from scipy.stats import norm

def generate_liability(n_indivs, ps, \
                       beta1, beta2, beta3, \
                       beta1_h2, beta2_h2, beta3_h2):
    """[summary]

    Args:
        n_indivs (int): number of individuals
        ps ([type]): [description]
        beta2 ([type]): [description]
        beta3 ([type]): [description]
        beta2_h2 ([type]): [description]
        beta3_h2 ([type]): [description]

    Returns:
        [type]: [description]
    """
    n_snps = beta1.shape[0]
    n_genes = beta1.shape[1]
    genos = np.empty((n_indivs,n_snps)) # genotypes
    for i in range(n_snps):
        # sample genotypes from a binomial distribution
        genos[:,i] = np.random.binomial(2, ps[i], size=n_indivs)
        # rescale genotypes to have mean 0 and std 1
        genos[:,i] = (genos[:,i] - 2*ps[i]) / np.sqrt(2*ps[i]*(1-ps[i]))

    exprs = np.empty((n_indivs,n_genes))
    expr_prs = np.dot(genos, beta1)
    for i in range(n_genes):
        # gene expression is standard normally distributed with mean==PRS
        exprs[:,i] = expr_prs[:,i] + \
                          np.random.normal(loc=0, 
                                           scale=np.sqrt(1-beta1_h2),
                                           size=n_indivs)
    # the liability is thresholded to generate cases and controls
    liability = np.dot(exprs, beta2) + np.dot(genos, beta3) + \
                     np.random.normal(loc=0,
                                      scale=np.sqrt(1-beta2_h2-beta3_h2),
                                      size=n_indivs)
    return genos, exprs, liability

def generate_case_control(n_indivs, ps,
                          beta1, beta2, beta3,
                          beta1_h2, beta2_h2, beta3_h2,
                          thresh, status="control"):
    """[summary]

    Args:
        n_indivs ([type]): [description]
        ps ([type]): p-values? 
        beta1 ([type]): [description]
        beta2 ([type]): [description]
        beta3 ([type]): [description]
        beta1_h2 ([type]): [description]
        beta2_h2 ([type]): [description]
        beta3_h2 ([type]): [description]
        thresh ([type]): [description]
        status (str, optional): [description]. Defaults to "control".

    Returns:
        [type]: [description]
    """
    assert status=="case" or status=="control"
    n_snps = beta1.shape[0]
    n_genes = beta1.shape[1]
    genos = np.empty((n_indivs, n_snps))
    exprs = np.empty((n_indivs, n_genes))
    batch = 10000
    n_counted = 0

    while n_counted < n_indivs:
        """
        Generate a batch of random individuals.
        Depending on whether cases or controls are desired, select
        those whose liability falls on the right side of the threshold
        """

        genos_batch, exprs_batch, liab_batch = generate_liability(
            batch,ps,beta1,beta2,beta3,
            beta1_h2,beta2_h2,beta3_h2)
        if status=="control":
            keep_idxs = np.where(liab_batch < thresh)[0]
        elif status=="case":
            keep_idxs = np.where(liab_batch >= thresh)[0]
        keep_num = min(len(keep_idxs), n_indivs - n_counted)
        keep_idxs = keep_idxs[:keep_num]
        genos_batch = genos_batch[keep_idxs,:]
        exprs_batch = exprs_batch[keep_idxs,:]
        genos[n_counted:n_counted+keep_num,:] = genos_batch
        exprs[n_counted:n_counted+keep_num,:] = exprs_batch
        n_counted += keep_num
        # print(f"generating {status:s}: {n_counted:s}/{n_indivs:s}")
    return genos, exprs

def simulate(n_snps, n_genes, n_geno_samples, n_expr_samples, \
             beta1_h2, beta2_h2, beta3_h2, prevalence=0.01):
    """Simulate genotype, gene expression, and case/control status according to 
    a 2-layer linear model.

    SNPs --> Genes --> Trait
    SNP-Gene effects follow an OLS
    Gene-Trait effects follow a liability threshold model
    
    Args:
        n_snps: number of SNPs (genotype variants)
        n_genes: number of genes
        n_geno_samples: number of individuals with only genotype info available
        n_expr_samples: number of individuals with both genotype and 
            expression available
        beta1_h2: variance explained (R^2) of SNP-Gene linear model
        beta2_h2: variance explained of Gene-Trait liability model
        beta3_h2: variance explained of direct SNP-Trait liability model
            (not mediated by genes); Typically, we set this to 0.
        prevalence (float, optional): Proportion or percentage reflecting how 
            common the disease is in the population. Between 0.0 and 1.0. 
            Defaults to 0.1.
    
    Returns:
        genotype, expression, and labels; 'genos_plus' is the subset which has 
            gene expression data available. 'genos_only' has only genotype data.
        genos_only ():
        phenos_only ():
        genos_plus ():
        exprs_plus ():
        phenos_plus ():
        (beta1, beta2, beta3)
    """
    thresh = norm.ppf(1-0.01)
    ps = np.array([0.5]*n_snps)

    # randomly sample effect sizes
    beta1 = np.random.normal(loc=0.0, scale=1.0, size=(n_snps, n_genes))
    beta2 = np.random.normal(loc=0.0, scale=1.0, size=n_genes)
    beta3 = np.random.normal(loc=0.0, scale=1.0, size=n_snps)

    # re-scale effect sizes to set appropriate variance explained
    # NOTE: genotypes are scaled to have mean 0 and std 1, so ps_var should be 1
    # ps_var = 2.0*np.multiply(ps, 1-ps)
    ps_var = np.array([1]*n_snps)
    # beta1
    for i in range(n_genes):
        unscaled_varexp = np.sum(np.multiply(np.square(beta1[:,i]), ps_var))
        scale_factor = np.sqrt(unscaled_varexp / beta1_h2)
        beta1[:,i] /= scale_factor

    # beta2
    unscaled_varexp = np.sum(np.square(beta2))
    scale_factor = np.sqrt(unscaled_varexp / beta2_h2)
    beta2 /= scale_factor

    # beta3
    if beta3_h2 == 0:
        beta3 = np.zeros(n_snps)
    else:
        unscaled_varexp = np.sum(np.multiply(np.square(beta3), ps_var))
        scale_factor = np.sqrt(unscaled_varexp / beta3_h2)
        beta3 /= scale_factor

    # simulate all indivs
    genos_only_cont, exprs_only_cont = (
        generate_case_control(int(n_geno_samples/2), ps,
                              beta1, beta2, beta3,
                              beta1_h2, beta2_h2, beta3_h2,
                              thresh, status="control"))
    genos_only_case, exprs_only_case = (
        generate_case_control(int(n_geno_samples/2), ps,
                              beta1, beta2, beta3,
                              beta1_h2, beta2_h2, beta3_h2,
                              thresh, status="case"))
    genos_plus_cont, exprs_plus_cont = (
        generate_case_control(int(n_expr_samples/2), ps,
                              beta1, beta2, beta3,
                              beta1_h2, beta2_h2, beta3_h2,
                              thresh, status="control"))
    genos_plus_case, exprs_plus_case = (
        generate_case_control(int(n_expr_samples/2), ps,
                              beta1, beta2, beta3,
                              beta1_h2, beta2_h2, beta3_h2,
                              thresh, status="case"))
    genos_only = np.concatenate((genos_only_cont, genos_only_case), axis=0)
    phenos_only = np.array([0]*genos_only_cont.shape[0] 
                            + [1]*genos_only_case.shape[0])
    genos_plus = np.concatenate((genos_plus_cont, genos_plus_case), axis=0)
    exprs_plus = np.concatenate((exprs_plus_cont, exprs_plus_case), axis=0)
    phenos_plus = np.array([0]*exprs_plus_cont.shape[0]
                            + [1]*exprs_plus_case.shape[0])
    return genos_only, phenos_only, genos_plus, exprs_plus, phenos_plus, \
        (beta1, beta2, beta3)

n_snps = 100
n_genes = 10
n_geno_samples = 5000
n_expr_samples = 500
beta1_h2 = 0.1 # layer 1 weights
beta2_h2 = 0.01 # layer 2 weights
beta3_h2 = 0.0

genos_only, phenos_only, genos_plus, exprs_plus, phenos_plus, betas = \
    simulate(n_snps, n_genes, n_geno_samples, n_expr_samples, 
             beta1_h2, beta2_h2, beta3_h2, prevalence=0.01)


def namestr(obj, namespace):
    """
    
    Examples:
        >>> path = "some variable"
        >>> namestr(path, globals())
        ['path']
    """
    return [name for name in namespace if namespace[name] is obj]

def print_shapes():
    for A in [genos_only, phenos_only, genos_plus, exprs_plus, phenos_plus]:
        print(f"{namestr(A, globals())[0]}.shape: {A.shape}")

    for i, beta in enumerate(betas):
        print(f"beta{i}.shape {beta.shape}")

print_shapes()
# genos_only, genos_plus -> input 
# exprs_plus -> hidden 
# phenos_only, phenos_plus -> ouput layer

# The weights of the layers should correspond the to the betas. 
# sigmoid instead of ReLu: Try both?
# Linear layers

# To start, use genos_only and phenos_only 

# hidden nodes imagined as expression
# What if the value of the hidden for the plus_set is equal to the expression 
# variable?
# 
# Conisider penalty to loss

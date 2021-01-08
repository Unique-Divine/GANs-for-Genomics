# GANs for Genomics 
<!-- Overview -->



<!-- Motivation -->
## Motivation

While the central aim of this project is to investigate the viability of neural networks to identify predictive variants in the genome, I place a specific focus on comparing neural networks with linear predictors such as the polygenic risk score. 

Multiple papers have shown that neural networks are generally less effective for prediction of complex genetic disorders than polygenic risk scores (PRSs) even though PRSs are linear predictors [[Pinto et al., 2019]](ref) [[Mamani, 2020]](ref) [[Badré et al., 2020]](ref).

[ref]: #References-&-Acknowledgements

I found this pretty surprising at first, but it actually makes sense when we consider a few challenges of working with genomics datasets for predictive modeling with deep learning.
1. High-dimensionality feature sets: Input vectors can have on the order of 100,000+ features.  
2. Low number of training samples: Deep neural nets need plenty of data, and in the case of genomics, we probably won't have plenty of relevant samples.
3. Often imbalanced: The phenotypes tend not to have an even spread. This is especially true for case-control predictions. Usually, you'll have a small number of cases and lots of controls. 

So, I figured that it would be worth looking into the effectiveness of generative adversarial networks (GANs) to simulate synthetic samples, create more plentiful training data, and achieve higher performance. 

## Dataset 

[[Data source]]()<!-- insert link -->

**Samples**: Sprague Dawley rats from GWAS
  - sample size: 4106 rats
  - Between two laboratories, there were high-quality genotypes at approximately 220,000 SNPs, of which $\approx$ 90,000 were common between the labs.

**Features**: Integer-encoded allele frequencies. For example, if A was the reference (most common) allele at some locus, it was represented as 0 and the next most common allele would be represented by 1. 

**Targets**: Groupings from PavCA, or Pavlovian conditioned approach. The targets were also integer-encoded but were based on whether the rats were goal trackers (0), intermediate responders (1), or sign trackers(2).

**PavCA**: PavCA is a behavior that develops after response-independent presentation of a conditioned stimulus that predicts deliver of an unconditioned stimulus. In layman's terms, this would be something like giving a rat food or drugs (unconditioned stimulus) when it interacts with a lever or bell (conditioned stimulus) and observing what various responses. In general, 3 patterns of conditioned responses develop:
- GT (goal-tracking): Unconditioned stimulus-directed
  - Behavior directed by the goal
  - If the reward stops, the behavior stops
- IR (intermediate response): In between
- ST (sign-tracking): Persistent
  - Persisten motivation by reward-related cues, sometimes despite non-reinforcement
  - Susceptible to addiction-related behaviors

<!-- Image from paper -->




<!-- Experiments  -->

<!-- Results -->

<!-- Next Steps 
    PRS comparison
    Image transformation
-->

## References & Acknowledgements

This was a one-semester research project I worked on in the computer science department at Columbia University.
- PhD Student Mentor: Jie Yuan 
- Advisor: Dr. Itsik Pe'er

Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of Columbia University.


- Pinto, C., Gill, M., & Heron, E. A. (2019). Can artificial neural networks supplant the polygene risk score for risk prediction of complex disorders given very large sample sizes?. *arXiv preprint arXiv:1911.08996*.
- Mamani, N. M. (2020). Machine Learning techniques and Polygenic Risk Score application to prediction genetic diseases. *ADCAIJ: Advances in Distributed Computing and Artificial Intelligence Journal*, 9(1), 5-14.
- Badré, A., Zhang, L., Muchero, W., Reynolds, J. C., & Pan, C. (2020). Deep neural network improves the estimation of polygenic risk scores for breast cancer. *Journal of Human Genetics*, 1-11.

<!-- TODO 
    description of project
    installation instructions
    usage instructions for project 
    -->
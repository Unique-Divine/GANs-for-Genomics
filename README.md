# GANs for Genomics 
<!-- Overview -->

<!-- Motivation -->
## Motivation

TODO

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

<!-- TODO 
    description of project
    installation instructions
    usage instructions for project 
    -->
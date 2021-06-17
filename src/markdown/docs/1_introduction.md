



# Introduction

## Preface

The past couple of decades have seen the development of powerful computer systems that have become pervasive 
in every human endeavour. Scientists have long regarded computation as a helpful tool for tackling difficult problems, 
and leaps in computational power have opened up research opportunities that simply did not exist before. 
Such is the case with forward-genetics simulation. Although such simulations have existed since the mid-2000s[^fn1], 
their use was limited due to the computational requirements of forward-time simulations being unmatched by the hardware 
of the time. SLiM changes that, taking advantage of modern computers and an easy-to-learn scripting language that makes 
forward-genetic simulations relatively straightforward. Combined with a close integration with the `msprime` coalescent
package for python, SLiM is an extremely powerful tool for investigating populations with genetic architectures that are 
too costly or difficult to analyse numerically. While thorough documentation on introducing biologists to SLiM 
already exists in the form of the [SLiM manual](http://benhaller.com/slim/SLiM_Manual.pdf), for those studying complex, 
polygenic traits, there is a fair amount of trial and error. But fear not, dear reader, for you have stumbled across
a shortcut in the form of this document, in which I provide a plethora of templates, tutorials, and tips that I have 
learned through my time experimenting with SLiM, as well as where to find additional help.


## Overview

In this book, I'll cover:

- Installation of a Linux environment for Windows 10,
- Installing SLiM and other useful software (with some fixes for errors I have come across),
- Using the terminal, basic shortcuts (with hyperlinked video tutorials),
- Polygenic adaptation resources - a repository of helpful papers to get a feel for quantitative and population genetics
    What is polygenic adaptation?
        How is it studied? Population genetics vs quantitative genetics
    Quantitative genetics models
        Infinitesimal model
        Geometrical model
    Population Genetics theories
        Neutral theory of molecular evolution
        Nearly-neutral theory
    Combining population and quantitative genetics models
        Extreme value theory
    Background selection
    Directional selection vs stabilising selection + balancing selection
    Hard vs soft sweeps
    Neutral evolution: Brownian motion and Uhrbeck-Ornstein
    Linkage
    Adaptability vs Adaptedness: Effect sizes and mutation rates (HoC vs Gaussian)
- Modelling polygenic adaptation in SLiM, 
    Template 4: Stabilising selection model of two traits with the above parameters, and a level of pleiotropy between them, and configurable fitness impacts for each
- Running SLiM in parallel on your computer,
- Running SLiM on a remote computer (such as a computing cluster or HPC),
- Using Latin Hypercube Sampling to properly sample a range of genetic parameters,
- Sorting data,
    sed, grep for filtering for what you want
- and statistics for SLiM data in R.

Throughout, I'll put additional information in boxes, so those interested can learn more.

:::: {.extrabox data-latex=""}
::: {.center data-latex=""}
**Box 1.2.1**
:::
Boxes look like this!
::::

## Prerequisites

The tutorials in here assume you are at least somewhat familiar with quantitative and population genetics.
In addition, you should have completed the [SLiM Online Workshop](http://benhaller.com/workshops/workshops.html), 
or at least perused through it to be familiar with the SLiM software.

## References
[^fn1]: B. Peng, Kimmel M., simuPOP: a forward-time population genetics simulation environment, Bioinformatics, Volume 21, Issue 18, Pages 3686-3687, https://doi.org/10.1093/bioinformatics/bti584

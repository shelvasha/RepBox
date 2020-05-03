## This pre-release "cluster" branch of the code only performs sequence distance calculations and nearest-neighbor clustering at this time.

# NINJA
Nearly Infinite Neighbor Joining Application

Compute correct neighbor-joining phylogenies for inputs of more than 10,000 sequences.  This is a C++/SSE port
of the original Java code described in:

Wheeler, T.J. 2009. Large-scale neighbor-joining with NINJA. In S.L. Salzberg and T. Warnow (Eds.), 
Proceedings of the 9th Workshop on Algorithms in Bioinformatics. 
WABI 2009, pp. 375-389. Springer, Berlin. (LNCS webpage,preprint)

The Java version of NINJA was the fastest available tool computing neighbor-joining phylogenies ( 10x faster than the fastest implemenation of the canonical neighbor-joining algorithm - QuickTree ) at the time of it's release.

In addition to generating phylogenies, Ninja can be used to output pairwise distances using several
common sequence distance measures, and cluster sequences using a nearest-neighbor approach.
 
We use a "git flow" workflow. We have two active branches:
 * **master** is to become the stable NINJA release branch. 
 * **develop** is the NINJA development branch.
 * **cluster** is the "cluster_only" development branch.


To clone your own copy of NINJA source code repository for the first time:

```bash
   $ git clone https://github.com/TravisWheelerLab/NINJA
   $ cd NINJA
   $ git checkout cluster
```


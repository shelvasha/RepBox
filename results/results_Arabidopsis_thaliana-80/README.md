# README

- Summary-Repbox.txt and Summary-RepeatMaskerRepeatmodeler.txt
- Consensus consists of inputs from: RepeatModeler, RepeatMasker, EAHelitron, Sine-Scan, MITE-Tracker and MITEFinder.
- Clustered based on 80% sequence identity between repeat families during classification step.



### Notes

- Percentage of the genome masked increases from 14.43% to 21.95%
- High, possibly due to false positives from each *de novo* detection method.
- 
- Possible solutions:
  1. Cluster based on 70% sequence similarity. 
     - **Rational**: Clustering sequence with lower identity may merge sequences that are closely related. This may not be ideal, as active TEs are typically low in copy number.
  2. Using multiple tools for each TE familt, and then cluster for consensus sequence.
     - **Rational**: Multiple hits for a same sequences via different identification methods provides additional confidence in results.
GENOME=/Users/shelvasha/Documents/Dissertation/results/results_Arabidopsis_thaliana/genome/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
INDEXNAME=$(basename $GENOME | cut -f 1 -d '.')
EAHELITRON="perl /Users/shelvasha/Repbox/bin/EAHelitron/EAHelitron"
MITEFINDER=/Users/shelvasha/Repbox/bin/miteFinder/miteFinder
THREAD=8


for i in `seq 0 +1.0 5`; do
$EAHELITRON -r $i $GENOME -o "EAHeli_out_"$i"_"$INDEXNAME
printf "Fuzziness: $i" && cat EAHeli_out_$i*.bed | wc -l
bedtools getfasta -fi $GENOME -bed EAHeli_out_$i*.bed -fo $INDEXNAME$i.fa
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $INDEXNAME$i.fa -engine ncbi -pa $THREAD
python3 /Users/shelvasha/Repbox/util/parsify.py $INDEXNAME$i.fa.classified
done


for i in `seq 0.0 +0.05 1.00`; do
$MITEFINDER -input $GENOME -output $INDEXNAME.THRESHOLD_$i.mite_finder.out -pattern_scoring $REPBOX_PREFIX/bin/miteFinder/profile/pattern_scoring.txt -threshold $i
printf "Threshold: $i" && grep '>' $INDEXNAME.THRESHOLD_$i.mite_finder.out | wc -l
perl $HOMEBREW_PREFIX/opt/repeatmodeler/RepeatClassifier -consensi $INDEXNAME.THRESHOLD_$i.mite_finder.out -engine ncbi -pa $THREAD
python3 /Users/shelvasha/Repbox/util/parsify.py $INDEXNAME.THRESHOLD_$i.mite_finder.out.classified
done

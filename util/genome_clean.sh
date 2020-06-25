# Genome cleanup to remove special characters

echo "Enter full path to genome.."
read GENOME
sed '/^>/ s/|/_/' $GENOME > $GENOME_clean.fa

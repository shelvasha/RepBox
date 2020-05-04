#!/bin/bash

#Sets Repbox home directory prefix
if ! grep -q "REPBOX_PREFIX" ~/.bash_profile; then
    echo "export REPBOX_PREFIX='$HOME/Repbox'" >> ~/.bash_profile && source ~/.bash_profile
fi

if ! grep -q "HOMEBREW_PREFIX" ~/.bash_profile; then
    echo "export HOMEBREW_PREFIX='$(brew --prefix)'" >> ~/.bash_profile && source ~/.bash_profile
fi

if ! grep -q "PATH=$PATH$(find $REPBOX_PREFIX/bin -type d -exec echo ":{}" \; | tr -d '\n')" ~/.bash_profile; then
    echo "PATH=$PATH$(find $REPBOX_PREFIX/bin -type d -exec echo ":{}" \; | tr -d '\n')" >> ~/.bash_profile && source ~/.bash_profile
fi

export REPBOX_PREFIX=$HOME/Repbox
export HOMEBREW_PREFIX=$(brew --prefix)

# Checks for hombrew/linuxbrew and installs if not installed
which brew >/dev/null
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    brew update
fi

# Installs taps for Repbox dependencies from home/linuxbrew repositories
brew tap brewsci/science
brew tap brewsci/bio

### Updating brew formulas
rm $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-bio/Formula/rmblast.rb
cp $REPBOX_PREFIX/bin/brew/rmblast.rb $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-bio/Formula/

rm $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-bio/Formula/repeatmasker.rb
cp $REPBOX_PREFIX/bin/brew/repeatmasker.rb $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-bio/Formula/

rm $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-science/Formula/repeatscout.rb
cp $REPBOX_PREFIX/bin/brew/repeatscout.rb $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-science/Formula/

rm $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-science/Formula/repeatmodeler.rb
cp $REPBOX_PREFIX/bin/brew/repeatmodeler.rb $HOMEBREW_PREFIX/Homebrew/Library/Taps/brewsci/homebrew-science/Formula/

### Installs Repbox dependencies via home/linuxbrew
brew install trf emboss bowtie2 bedtools hmmer recon blast rmblast samtools repeatscout repeatmasker repeatmodeler muscle

#IF PYTHON3 IS NOT INSTALLED, RUN THE FOLLOWING
#brew install perl bioperl python3

# Setting up RepeatModeler & RepeatMasker
sudo cpan JSON File::Which URI LWP::UserAgent Readonly Log::Log4perl Bio::SeqIO

cp $REPBOX_PREFIX/bin/rmodel_dependencies/* $HOMEBREW_PREFIX/Cellar/repeatmodeler/*/
sleep 2

### MacOS check
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install Commandline Tools
    #rm -rf /Library/Developer/CommandLineTools
    #sudo xcode-select -s /Library/Developer/CommandLineTools
    #xcode-select --install

    brew install llvm libomp gcc@9 genometools
    if ! grep -q 'export PATH="/usr/local/opt/llvm/bin:$PATH"' ~/.bash_profile; then
        echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.bash_profile && source ~/.bash_profile
    fi

    #cd $REPBOX_PREFIX/bin/GenericRepeatFinder/src/grf-main
    #make clean && make

    cd $REPBOX_PREFIX/bin/cd-hit-v4.6.1/
    make clean && make

    cd $REPBOX_PREFIX/bin/gffcompare/
    make clean && make

    cd $REPBOX_PREFIX/bin/gffread/
    make clean && make

    cd $REPBOX_PREFIX/bin/miteFinder
    make clean && make

    cd $REPBOX_PREFIX/bin/SINE_Scan-v1.1.1
    bash ./SINE_Scan_Directories.sh

### Linux check
elif [[ "$OSTYPE" == "linux-gnu" ]]; then

    brew install gcc

    #cd $REPBOX_PREFIX/bin/GenericRepeatFinder/src
    #make clean && make

    cd $REPBOX_PREFIX/bin/cd-hit-v4.6.1/
    make clean && make

    cd $REPBOX_PREFIX/bin/gffcompare/
    make clean && make

    cd $REPBOX_PREFIX/bin/gffread/
    make clean && make

    cd $REPBOX_PREFIX/bin/miteFinder
    make clean && make

    cd $REPBOX_PREFIX/bin/
    git clone https://github.com/genometools/genometools.git
    cd genometools
    make -j4 cairo=no
    make install -j4

else
    echo "Operating System is not supported"
fi

#grep -rl 'LTR' $HOMEBREW_PREFIX/Cellar/repeatmodeler/*/config.txt |  xargs sed -i "" "s|LTR|$REPBOX_PREFIX/bin/LTR_retriever|g"
#grep -rl 'NINJA' $HOMEBREW_PREFIX/Cellar/repeatmodeler/*/config.txt |  xargs sed -i "" "s|NINJA|$REPBOX_PREFIX/bin/NINJA-0.95-cluster_only/NINJA/|g"

cd $HOMEBREW_PREFIX/Cellar/repeatmodeler/*/
perl ./configure <config.txt # &>/dev/null

cd $HOMEBREW_PREFIX/Cellar/repeatmasker/*/libexec
perl ./configure <config.txt # &>/dev/null


echo "Repbox setup is complete!"

# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Repeatmodeler < Formula
  desc "De-novo repeat family identification and modeling package"
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
# tag "bioinformatics"
  url "http://www.repeatmasker.org/RepeatModeler/RepeatModeler-2.0.1.tar.gz"
  sha256 "628e7e1556865a86ed9d6a644c0c5487454c99fbcac21b68eae302fae7abb7ac"
  version "2.0.1"
  revision 1

  bottle do
    cellar :any_skip_relocation
  end

  option "without-configure", "Do not run configure"

  depends_on "recon"
  depends_on "repeatmasker"
  depends_on "repeatscout"
  depends_on "rmblast"
  depends_on "trf"
  depends_on "mafft"
#  depends_on "genometools"
#  depends_on "cd-hit"


  # Configure RepeatModeler. The prompts are:
  # PRESS ENTER TO CONTINUE
  # PERL INSTALLATION PATH
  # REPEATMODELER INSTALLATION PATH
  # REPEATMASKER INSTALLATION PATH
  # RECON INSTALLATION PATH
  # RepeatScout INSTALLATION PATH
  # 1. RMBlast - NCBI Blast with RepeatMasker extensionst
  # RMBlast (rmblastn) INSTALLATION PATH
  # Do you want RMBlast to be your default search engine for Repeatmasker?
  # 3. Done

  def install
   prefix.install Dir["*"]
   bin.install_symlink %w[../BuildDatabase ../RepeatModeler]
   (prefix/"config.txt").write <<~EOS

     system "which perl"
     system "which RepeatMasker"
     #{Formula["recon"].opt_prefix/"bin"}
     system "which RepeatScout"
     system "which trf"
     1
     #{Formula["rmblast"].opt_prefix/"bin"}
     3
     y
     system "which gt"
     system "which LTR_retriever"
     #{Formula["mafft"].opt_prefix/"bin"}
     system "which NINJA"
     system "which cd-hit-est"
     EOS
 end

 def post_install
   cd prefix/Cellar/repeatmodeler/Dir["*"] do
     #system "perl ./configure <config.txt"
   end if build.with? "configure"
 end

 def caveats; <<~EOS
   To reconfigure RepeatModeler, run
     brew postinstall repeatmodeler
   or
     cd #{ENV["HOMEBREW_PREFIX"]}/Cellar/repeatmodeler/* && perl ./configure <config.txt
   EOS
 end

 test do
   assert_match version.to_s, shell_output("/usr/bin/perl #{bin}/RepeatModeler -v")
 end
end

class Repeatmasker < Formula
  desc "Nucleic and proteic repeat masking tool"
  homepage "http://www.repeatmasker.org/"
  version "4.1.0"
  url "http://www.repeatmasker.org/RepeatMasker-#{version}.tar.gz"
  sha256 "7370014c2a7bfd704f0e487cea82a42f05de100c40ea7cbb50f54e20226fe449"

  option "without-configure", "Do not run configure"

  depends_on "hmmer" # at least version 3.1 for nhmmer
  depends_on "perl" => :optional
  depends_on "rmblast"
  depends_on "trf"

  def install
    perl = system "which perl"
    libexec.install Dir["*"]
    bin.install_symlink "../libexec/RepeatMasker"

    # Configure RepeatMasker. The prompts are:
    # PRESS ENTER TO CONTINUE
    # 1. TRF PROGRAM Enter path
    # 2. Add Search Engine -
    #   - Crossmatch: [ Un-configured ]
    #   - RMBlast: [ Un-configured ]
    #   - HMMER3.1 & DFAM: [ Un-configured ]
    #   - ABBlast: [ Un-configured ]
    # 3. (NCBI) INSTALLATION PATH
    # 4.  Do you want (NCBI) to be your default search engine for Repeatmasker?
    # 5. HMMER3.1 & DFAM
    # 6. HMMER INSTALLATION PATH Enter path
    # 7. Do you want HMMER to be your default search engine for Repeatmasker?
    # 8. Done

    (libexec/"config.txt").write <<~EOS

    system "which trf"
    2
    #{HOMEBREW_PREFIX}/opt/rmblast/bin
    Y
    3
    #{HOMEBREW_PREFIX}/bin
    Y
    5
    EOS

    #system "cd #{libexec} && ./configure <config.txt" if build.with? "configure"
  end

  def caveats; <<~EOS
    Congratulations!  RepeatMasker is now ready to use.
    The program is installed with a minimal repeat library
    by default.  This library only contains simple, low-complexity,
    and common artefact ( contaminate ) sequences.  These are
    adequate for use with your own custom repeat library.  If you
    plan to search using common species specific repeats you will
    need to obtain the complete RepeatMasker repeat library from
    GIRI ( www.girinst.org ) and install it:
      cd #{HOMEBREW_PREFIX}/Cellar/repeatmasker/*/libexec
      tar zxvf repeatmaskerlibraries-20140131.tar.gz
      ./configure <config.txt
    The default aligner is RMBlast. You may reconfigure RepeatMasker
    by running
      cd #{HOMEBREW_PREFIX}/Cellar/repeatmasker/*/libexec && ./configure
    EOS
  end

  test do
    system "RepeatMasker"
  end
end

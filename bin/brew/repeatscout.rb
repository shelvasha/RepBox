class Repeatscout < Formula
  homepage "https://bix.ucsd.edu/repeatscout/"
  # doi "10.1093/bioinformatics/bti1018"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  url "http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz"
  sha256 "31a44cf648d78356aec585ee5d3baf936d01eaba43aed382d9ac2d764e55b716"

  depends_on "ensembl/external/trf" => :optional

  def install
    system "make"
    prefix.rmdir
    system *%W[make install INSTDIR=#{prefix}]
    bin.install_symlink "../RepeatScout"
  end

  test do
    system "#{bin}/RepeatScout 2>&1 |grep RepeatScout"
  end
end

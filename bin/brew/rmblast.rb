class Rmblast < Formula
  desc "RepeatMasker compatible version of the standard NCBI BLAST suite"
  homepage "http://www.repeatmasker.org/RMBlast.html"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived
  keg_only "Uses software from NCBI blast"

  version "2.10.0"
  if OS.mac?
    url "http://www.repeatmasker.org/rmblast-#{version}+-x64-macosx.tar.gz"
    sha256 "dff7e922ffb80f36571fb0b6c5f468548a04766620fccb4618eaed5d91e14015"
  elsif OS.linux?
    url "http://www.repeatmasker.org/rmblast-#{version}+-x64-linux.tar.gz"
    sha256 "e592d0601a98b9764dd55f2aa4815beb1987beb7222f0e171d4f4cd70a0d4a03"
  else
    onoe "Unknown operating system"
  end

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rmblastn -version")
  end
end

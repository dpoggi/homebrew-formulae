class Flamegraph < Formula
  desc "Visualizer for profiled code"
  homepage "http://www.brendangregg.com/flamegraphs.html"
  url "https://github.com/brendangregg/FlameGraph/archive/v1.0.tar.gz"
  sha256 "c5ba824228a4f7781336477015cb3b2d8178ffd86bccd5f51864ed52a5ad6675"

  bottle :unneeded

  depends_on "perl" => :optional

  def install
    libexec.install Dir["*"]
    %w[
      aix-perf.pl
      difffolded.pl
      files.pl
      flamegraph.pl
      jmaps
      pkgsplit-perf.pl
      range-perf.pl
      stackcollapse-aix.pl
      stackcollapse-elfutils.pl
      stackcollapse-gdb.pl
      stackcollapse-go.pl
      stackcollapse-instruments.pl
      stackcollapse-jstack.pl
      stackcollapse-ljp.awk
      stackcollapse-perf-sched.awk
      stackcollapse-perf.pl
      stackcollapse-pmc.pl
      stackcollapse-recursive.pl
      stackcollapse-sample.awk
      stackcollapse-stap.pl
      stackcollapse-vsprof.pl
      stackcollapse.pl
    ].map { |f| libexec/f }.each do |f|
      bin.install_symlink f => f.stem
    end
  end
end

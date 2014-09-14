require 'nmatrix'
require 'benchmark/ips'

class BRMatrix

  def self.mrange(start, finish, increment, precision=2)
    array = []
    (start..finish).step(increment).each do |e|
      array.push(e.round(precision))
    end
    return array
  end

end

if __FILE__ == $0

  Benchmark.ips do |x|
    x.report("generate10") {
      BRMatrix.mrange(0, 9, 1)
    }

    x.report("generate100") {
      BRMatrix.mrange(0, 99, 1)
    }

    x.report("generate1000") {
      BRMatrix.mrange(0, 999, 1)
    }
    x.report("generate10-000") {
      BRMatrix.mrange(0, 9999, 1)
    }
    x.report("generate100-000") {
      BRMatrix.mrange(0, 99999, 1)
    }
  end
end

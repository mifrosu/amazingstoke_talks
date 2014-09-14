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

def map_dbl(array)
  array.map { |e| e*2 }
end

def slow_dbl(array)
  k = []
  array.each { |e| k.push(e*2) }
  k
end

if __FILE__ == $0

  array10 = BRMatrix.mrange(1, 10, 1)
  array100 = BRMatrix.mrange(1, 100, 1)
  array1000 = BRMatrix.mrange(1, 1000, 1)
  array10_000 = BRMatrix.mrange(1, 10_000, 1)
  array100_000 = BRMatrix.mrange(1, 100_000, 1)
  array1000_000 = BRMatrix.mrange(1, 1000_000, 1)

  lin_vector10 = NVector.linspace(1,10,10).transpose
  lin_vector100 = NVector.linspace(1,100,100).transpose
  lin_vector1000 = NVector.linspace(1,1000,1000).transpose
  lin_vector10_000 = NVector.linspace(1,10000,10000).transpose
  lin_vector100_000 = NVector.linspace(1,100_000,100_000).transpose
  lin_vector1000_000 = NVector.linspace(1,1000_000,1000_000).transpose

  vector10 = NMatrix.new([10], BRMatrix.mrange(1,10,1))
  vector100 = NMatrix.new([100], BRMatrix.mrange(1,100,1))
  vector1000 = NMatrix.new([1000], BRMatrix.mrange(1,1000,1))
  vector10_000 = NMatrix.new([10_000], BRMatrix.mrange(1,10_000,1))
  vector100_000 = NMatrix.new([100_000], BRMatrix.mrange(1,100_000,1))
  vector1000_000 = NMatrix.new([1000_000], BRMatrix.mrange(1,1000_000,1))

  Benchmark.ips do |x|
      BRMatrix.mrange(0, 9999, 1)
      BRMatrix.mrange(0, 99999, 1)
    x.report("array_10") {
      map_dbl(array10)
    }

    x.report("array_100") {
      map_dbl(array100)
    }

    x.report("array_1000") {
      map_dbl(array1000)
    }

    x.report("array_10_000") {
      map_dbl(array10_000)
    }

    x.report("array_100_000") {
      map_dbl(array100_000)
    }

    x.report("array_1000_000") {
      map_dbl(array1000_000)
    }

    x.report("slow_10") {
      slow_dbl(array10)
    }

    x.report("slow_100") {
      slow_dbl(array100)
    }

    x.report("slow_1000") {
      slow_dbl(array1000)
    }

    x.report("slow_10_000") {
      slow_dbl(array10_000)
    }

    x.report("slow_100_000") {
      slow_dbl(array100_000)
    }

    x.report("slow_1000_000") {
      slow_dbl(array1000_000)
    }

    x.report("vector_10") {
      vector10 * 2
    }

    x.report("vector_100") {
      vector100 * 2
    }

    x.report("vector_1000") {
      vector1000 * 2
    }

    x.report("vector_10_000") {
      vector10_000 * 2
    }

    x.report("vector_100_000") {
      vector100_000 * 2
    }

    x.report("vector_1000_000") {
      vector1000_000 * 2
    }

  end
end

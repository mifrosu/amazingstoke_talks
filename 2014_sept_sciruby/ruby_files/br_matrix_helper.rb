require 'nmatrix'

class BRMatrix

  def self.mrange(start, finish, increment, precision=2)
    array = []
    (start..finish).step(increment).each do |e|
      array.push(e.round(precision))
    end
    return array
  end

end

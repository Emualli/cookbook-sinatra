class Primes

  @@array_of_primes = [2]

  def self.isPrime?(max)
    return false if (max.nil? == true || max < 2)
    (2..max**(0.5)).each do |t|
      return false if max%t == 0
    end
    true
  end

  def self.first(n)
    if n > @@array_of_primes.length
      num = @@array_of_primes[-1] + 1
        while n > @@array_of_primes.length
          @@array_of_primes << num if isPrime?(num)
          num += 1
        end
    else
      return @@array_of_primes.slice(0, n)
    end
   @@array_of_primes
  end
end

# p Primes.isPrime?(4)
p Primes.first(1)
p Primes.first(2)
p Primes.first(5)
p Primes.first(7)
p Primes.first(10)

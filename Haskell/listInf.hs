import Data.List


-- helper functions
fromZero :: [Integer]
fromZero = iterate (+1) 0
fromOne :: [Integer]
fromOne = iterate (+1) 1
fromTwo :: [Integer]
fromTwo = iterate (+1) 2



ones :: [Integer]
ones = cycle [1]


nats :: [Integer]
nats = iterate (+1) 0


ints :: [Integer]
ints = 0:([ y | x <- fromOne, y <- [x, -x]])
	

triangulars :: [Integer]
triangulars = 0:(scanl (+) 1 fromTwo)


factorials :: [Integer]
factorials = scanl (*) 1 fromOne


fibs :: [Integer]
fibs = map fst (iterate (\(a,b) -> (b,a+b)) (0,1))


primes :: [Integer]
primes = lprimes fromTwo
	where lprimes (x:xs) = x:(lprimes (filter (\y -> (mod y x)/=0) xs))

--hammings :: [Integer]


--lookNsay :: [Integer]


--tartaglia :: [[Integer]]

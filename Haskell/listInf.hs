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

hammings :: [Integer]
hammings = 1 : map (2*) hammings `merge` map (3*) hammings `merge` map (5*) hammings
	where merge (x:xs) (y:ys)
		| x < y = x : xs `merge` (y:ys)
		| x > y = y : (x:xs) `merge` ys
		| otherwise = x : xs `merge` ys


--say :: Integer -> Integer
--say = read.concatMap grup.group.show
	--where grup s = (show $ length s) ++ [head s]
	

--lookNsay :: [Integer]
--lookNsay = 1 : map say lookNsay


nextRow :: [Integer] -> [Integer]
nextRow row = zipWith (+) ([0] ++ row) (row ++ [0])


tartaglia :: [[Integer]]
tartaglia = iterate nextRow [1]

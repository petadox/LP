-- absValue

absValue:: Int -> Int
absValue n
  | n >= 0  	= n
  | otherwise 	= -(n)
  
-- power

power :: Int -> Int -> Int  
power x p
  | p == 0 		= 1
  | otherwise	= x * power x (p-1)

-- isPrime

isPrime :: Int -> Bool
isPrime n
  | n < 2 	= False
  | n == 2 	= True
  | otherwise = (cantdiv 1 0) == 2 
  where 
	cantdiv :: Int -> Int -> Int
	cantdiv m c
	  | n == m 		 = c+1
	  | mod n m == 0 = cantdiv (m+1) (c+1)
	  | otherwise 	 = cantdiv (m+1) c

-- slowFib

slowFib :: Int -> Int
slowFib n
  | n == 0 		= 0
  | n == 1		= 1
  | otherwise 	= slowFib(n-1) + slowFib(n-2)

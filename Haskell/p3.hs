insert :: [Int] -> Int -> [Int]
insert [] e = [e]
insert (x:l) e
	| e > x = x:(insert l e)
	| otherwise = e:x:l 


isort :: [Int] -> [Int]
isort [] = []
isort (x:l) = insert (isort l) x


remove :: [Int] -> Int -> [Int]
remove [] e = []
remove (x:l) e
	| e == x = l
	| otherwise = x:(remove l e)
	

ssort :: [Int] -> [Int]
ssort [] = []
ssort l = min:(ssort (remove l min))
	where min = minimum l
	
	
merge :: [Int] -> [Int] -> [Int]
merge [] n = n
merge m [] = m
merge (x:m) (y:n)
	| x < y = x:(merge m (y:n))
	| x > y = y:(merge (x:m) n)
	| otherwise = x:y:(merge m n)


msort :: [Int] -> [Int]
msort [] = []
msort (x:l) = merge [x] (msort l)


qsort :: [Int] -> [Int]

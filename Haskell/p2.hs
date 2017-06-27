-- myLength

myLength :: [Int] -> Int
myLength [] = 0
myLength (x:xs) = 1 + (myLength xs)

-- myMaximum

myMaximum :: [Int] -> Int
myMaximum [] = error "Maximo de una lista vacia"
myMaximum [x] = x
myMaximum (x:xs)
  | x > maxTail = x
  | otherwise   = maxTail
  where maxTail = myMaximum xs
  
-- average

average :: [Int] -> Float
average x = fromIntegral(sum x) / fromIntegral(myLength x)

-- printLista

printLista :: [Int] -> [Int]
printLista [] = []
printLista (x:xs) = [x] ++ printLista xs

-- revertLista

revertLista :: [Int] -> [Int]
revertLista [] = []
revertLista (x:xs) = revertLista xs ++ [x]

-- buildPalindrome

buildPalindrome :: [Int] -> [Int]
buildPalindrome [] = []
buildPalindrome (x) = revertLista x ++ printLista x

-- removeAux

removeAux :: Int -> [Int] -> [Int]
removeAux a [] = []
removeAux a (x:xs) 
	| a == x 	= a `removeAux` xs 
	| otherwise = [x] ++ a `removeAux` xs

-- remove

remove :: [Int] -> [Int] -> [Int]
remove a [] = a
remove a (x:xs)
	| otherwise = remove (removeAux x a) xs
	
-- flatten

flatten :: [[Int]] -> [Int]
flatten [] 	= []
flatten (x:xs) = (x) ++ flatten (xs)

-- oddsNevensAuxP

oddsNevensAuxI :: [Int] -> [Int]
oddsNevensAuxI [] = []
oddsNevensAuxI (x:xs)
	| mod x 2 == 0 = oddsNevensAuxI xs
	| otherwise = [x] ++ oddsNevensAuxI xs

-- oddsNevensAuxI

oddsNevensAuxP :: [Int] -> [Int]
oddsNevensAuxP [] = []
oddsNevensAuxP (x:xs)
	| mod x 2 == 0 = [x] ++ oddsNevensAuxP xs
	| otherwise = oddsNevensAuxP xs

-- oddsNevens

oddsNevens :: [Int] -> ([Int],[Int])
oddsNevens [] = ([],[])
oddsNevens (x) = (oddsNevensAuxI x , oddsNevensAuxP x)

-- primeDivisors

f 1 = [] 
f n = head [p : f (n / p) | p <- [2..], mod n p == 0] 

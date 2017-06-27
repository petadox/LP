myMap :: (a -> b) -> [a] -> [b]
myMap f xs = [ f x | x <- xs ] 


myFilter :: (a -> Bool) -> [a] -> [a]
myFilter f xs = [ x | x <- xs , f x]


myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith f a b = [ f x y | (x,y) <- aux ]
	where aux = zip a b


thingify :: [Int] -> [Int] -> [(Int, Int)]
thingify a b = [(x,y) | x <- a, y <- b, (mod x y == 0) ]


factors :: Int -> [Int]
factors x = [ y | y <- [1..x], (mod x y == 0) ]

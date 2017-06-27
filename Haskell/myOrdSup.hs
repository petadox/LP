myFoldl :: (a -> b -> a) -> a -> [b] -> a
myFoldl _ i [] = i
myFoldl f i (x:l) = myFoldl f aux l
	where aux = f i x
	
	
myFoldr :: (a -> b -> b) -> b -> [a] -> b
myFoldr _ i [] = i
myFoldr f i l = myFoldr f aux h
    where h = init(l)
          t = last(l)
          aux = f t i
	
	
myIterate :: (a -> a) -> a -> [a]
myIterate f i = i:(myIterate f (f i))


myUntil :: (a -> Bool) -> (a -> a) -> a -> a
myUntil cond f i
	| cond(f(i)) == False = myUntil cond f (f i)
	| otherwise = f i


myMap :: (a -> b) -> [a] -> [b]
myMap f [] 	= []
myMap f l = foldr (\e acc -> (f e):acc) [] l
    
    
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter f l = foldr (\e acc -> if (f e) == True then e:acc else acc) [] l


myAll :: (a -> Bool) -> [a] -> Bool
myAll f l = foldr (\e acc -> if not (f e) then False else acc) True l

myAny :: (a -> Bool) -> [a] -> Bool
myAny f l = foldr (\e acc -> if (f e) then True else acc) False l

myZip :: [a] -> [b] -> [(a, b)]
myZip xs [] = []
myZip [] ys = []
myZip (x:xs) (y:ys) = (x,y):(myZip xs ys)

--myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]

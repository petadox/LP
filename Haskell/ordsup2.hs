flatten :: [[Int]] -> [Int]
flatten l = foldr (++) [] l

-- myLength :: String -> Int

myReverse :: [Int] -> [Int]
myReverse l = reverse l

-- countIn :: [[Int]] -> Int -> [Int]


firstWord :: String -> String
firstWord s = takeWhile (/=' ') s


-- ORDEN SUPERIOR
-- take, takeWhile, drop, dropWhile, filter, foldr, iterate, map,

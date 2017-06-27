countIf :: (Int -> Bool) -> [Int] -> Int
countIf f l = foldr (\e acc -> if (f e) then acc+1 else acc) 0 l

pam :: [Int] -> [Int -> Int] -> [[Int]]


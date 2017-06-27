data Tree a = Node a (Tree a) (Tree a) | Empty deriving (Show)


size :: Tree a -> Int
size Empty = 0
size (Node x l r) = 1 + size l + size r


height :: Tree a -> Int
height Empty = 0
height (Node x l r) = 1 + max (height l) (height r)


equal :: Eq a => Tree a -> Tree a -> Bool
equal Empty Empty = True
equal (Node x l1 r1) Empty = False
equal Empty (Node y l2 r2) = False
equal (Node x l1 r1) (Node y l2 r2)
	| x == y = (equal l1 l2 && equal r1 r2)
	| otherwise = False


isomorphic :: Eq a => Tree a -> Tree a -> Bool
isomorphic Empty Empty = True
isomorphic _ Empty = False
isomorphic Empty _ = False
isomorphic (Node x l1 r1) (Node y l2 r2)
	| x == y = ((isomorphic l1 r2 && isomorphic r1 l2) || (isomorphic l1 r1 && isomorphic l2 r2))
	| otherwise = False


preOrder :: Tree a -> [a]
preOrder Empty = []
preOrder (Node x l r) = [x] ++ preOrder l ++ preOrder r


inOrder :: Tree a -> [a]
inOrder Empty = []
inOrder (Node x l r) = inOrder l ++ [x] ++ inOrder r


postOrder :: Tree a -> [a]
postOrder Empty = []
postOrder (Node x l r) = postOrder l ++ postOrder r ++ [x]


--funcio auxiliar per breadthfirst


bfs [] = []
bfs (Empty:xs) = bfs xs
bfs ((Node x l r):xs) = x:(bfs $ xs ++ [l,r])


breadthFirst :: Tree a -> [a]
breadthFirst t = bfs [t]


build :: Eq a => [a] -> [a] -> Tree a
build [] [] = Empty
build p@(px : pxs) i = Node px (build lp li) (build rp ri)
  where (li,_:ri) = span (/=px) i
        (lp,rp) = splitAt (length li) pxs



-- overlap
overlap :: (a -> a -> a) -> Tree a -> Tree a -> Tree a
overlap _ Empty Empty = Empty
overlap _ a Empty = a
overlap _ Empty b = b
overlap f (Node ax al ar) (Node bx bl br) = Node (f ax bx) (overlap f al bl) (overlap f ar br)

data Queue a = Queue [a] [a] deriving (Show)

create :: Queue a
create = Queue [] []

push :: a -> Queue a -> Queue a 
push x (Queue l r) = Queue l (x:r)

shift :: Queue a -> Queue a
shift (Queue l r) = Queue (reverse r) l

pop :: Queue a -> Queue a
pop q@(Queue [] []) = q
pop q@(Queue [] r) = pop $ shift q
pop (Queue (lx:lxs) r) = Queue lxs r

top :: Queue a -> a
top q@(Queue [] r) = top $ shift q
top (Queue (lx:lxs) r) = lx

empty :: Queue a -> Bool
empty (Queue [] []) = True
empty (Queue _ _) = False


instance (Eq a) => Eq (Queue a) where 
	(Queue al ar) == (Queue bl br) = (al ++ (reverse ar)) == (bl ++ (reverse br))

data Command a = 	Seq [Command a] | 
					Input String | 
					TAssign String (TExpr a) |
					CAssign String (CExpr a) |
					Split String String String |
					Copy String String |
					Print (NExpr a) |
					Draw (TExpr a) |
					Loop (BExpr a) (Command a) |
					Cond (BExpr a) (Command a) (Command a) |
					DeclareVector String (NExpr a) |
					Push String String |
					Pop String String
	deriving Show
	
instance Show Command a where
	show Input x = show Input ++ "   " ++ putStr x
	
	
data BExpr a = 	Empty String |
				Full String |
				And (BExpr a) (BExpr a) |
				Or (BExpr a) (BExpr a) |
				Not (BExpr a) |
				Gt (NExpr a) (NExpr a) |
				Lt (NExpr a) (NExpr a) |
				Eq (NExpr a) (NExpr a)
	deriving Show


data NExpr a = 	Var String | 
				Const a | 
				Plus (NExpr a) (NExpr a) | 
				Minus (NExpr a) (NExpr a) | 
				Times (NExpr a) (NExpr a) | 
				Length String | 
				Diameter String
	deriving Show
	
	
data TExpr a = 	TVar String |
				Merge (TExpr a) (CExpr a) (TExpr a) |
				Tube (NExpr a) (NExpr a)
	deriving Show
	
	
data CExpr a = 	CVar String | 
				Connector (NExpr a)
	deriving Show
	


	


--ex1:: Command Int
--ex1 = (Seq [(Input "X"),(Input "Y"),(TAssign "T1" (Tube (Var "X") (Var "Y"))),(TAssign "T2" (Tube (Const 10) (Var "Y"))),(Split "T3" "T4" "T2"),(Input "Z"),(TAssign "T6" (Tube (Var "Z") (Const 2))),(Copy "TCOP" "T6"),(CAssign "C1" (Connector (Var "Y"))),(TAssign "T5" (Merge (TVar "T3") (CVar "C1") (TVar "TCOP"))),(TAssign "T5" (Merge (TVar "T2") (CVar "C1") (TVar "TCOP"))),(TAssign "T5" (Merge (TVar "T1") (CVar "C1") (TVar "T3"))),(TAssign "TN" (Tube (Const 5) (Var "Y"))),(Print (Length "T4")),(Print (Diameter "T5")),(Split "T7" "T8" "T5"),(CAssign "C2" (Connector (Var "Y"))),(CAssign "C3" (Connector (Var "Y"))),(TAssign "T9" (Tube (Length "T7") (Diameter "T8"))),(Draw (Tube (Length "T7") (Diameter "T8"))),(TAssign "T10" (Merge (Merge (TVar "T7") (CVar "C2") (TVar "T8")) (CVar "C3") (TVar "TN"))),(Split "T1" "T2" "T10"),(CAssign "C4" (Connector (Diameter "T1"))),(Input "Y"),(CAssign "C5" (Connector (Var "Y"))),(Cond (Eq (Diameter "C4") (Diameter "C5")) (Seq [(TAssign "T11" (Merge (TVar "T1") (CVar "C4") (Merge (TVar "T4") (CVar "C5") (TVar "T2"))))]) (Seq [])),(DeclareVector "V" (Const 5)),(Loop (And (Not (Full "V")) (Or (And (Gt (Length "T11") (Const 3)) (Lt (Length "T11") (Const 30))) (Eq (Length "T11") (Const 0)))) (Seq [(Split "X" "Y" "T11"),(Draw (TVar "X")),(Push "V" "X"),(Copy "T11" "Y")])),(TAssign "FT" (Tube (Const 0) (Diameter "T11"))),(Loop (And (Not (Empty "V")) (Lt (Length "FT") (Const 8))) (Seq [(Pop "V" "TAUX"),(CAssign "CX" (Connector (Diameter "T11"))),(TAssign "FT" (Merge (TVar "FT") (CVar "CX") (TVar "TAUX")))]))])

ex1:: Command Int
ex1 = (Seq [(Input "X"),(Input "Y")])

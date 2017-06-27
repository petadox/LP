import System.Environment

main :: IO ()
main = do 
	line <- getLine
	putStrLn $ hola line


femeni [] = False
femeni (x:[]) = x=='a' || x=='A'
femeni (_:xs) = femeni xs


hola s 
	| femeni s = "Hola maca!" 
	| otherwise = "Hola maco!"

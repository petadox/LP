import System.Environment
import Control.Monad

main :: IO ()
main = do 
	line <- getLine
	if line  == "*"
		then return ()
		else do
			putStrLn $ calcul line
			main

resposta :: Float -> Float -> String
resposta m h
	| imc<18 = "magror"
	| imc>=18 && imc<25 = "corpulencia normal"
	| imc>=25 && imc<30 = "sobrepes"
	| imc>=30 && imc<40 = "obesitat"
	| otherwise = "obesitat morbida"
	where imc = m/(h^2)


calcul l = name ++ ": " ++ resposta m h
	where 	
	(name:xs) 	= words l
	[m,h] 	= map read xs
--	[m,h] 	= map read xs :: [Float]

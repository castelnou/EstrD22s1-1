--Viejo
unoSi :: Bool -> Int
unoSi True = 1
unoSi _ = 0

data Color = Azul | Rojo
data Celda = Bolita Color Celda | CeldaVacia

nroBolitas :: Color -> Celda -> Int
--Dados un color y una celda, indica la cantidad de bolitas de ese color.
nroBolitas co1 CeldaVacia = 0
nroBolitas co1 (Bolita co2 ce) = unoSi(esMismoColor co1 co2) + nroBolitas co1 ce

esMismoColor :: Color -> Color -> Bool
esMismoColor Azul Azul = True
esMismoColor Rojo Rojo = True
esMismoColor _ _ = False

poner :: Color -> Celda -> Celda
--Dado un color y una celda, agrega una bolita de dicho color a la celda.
poner co ce = (Bolita co ce)

sacar :: Color -> Celda -> Celda
--dado un color y una celda, quita una bolita de dicho color de la celda.
sacar co CeldaVacia = CeldaVacia
sacar co (Bolita co2 ce) = if(esMismoColor co co2)
                            then ce else (Bolita co2 (sacar co ce))

ponerN :: Int -> Color -> Celda -> Celda
--dado un número n, un color c, y una celda, agrega n bolitas de color c a la celda.
ponerN 0 co ce = ce
ponerN n co ce = (Bolita co (ponerN (n-1) co ce))

----Camino hacia el tesoro

data Objeto = Cacharro | Tesoro
data Camino = Fin | Cofre [Objeto] Camino | Nada Camino

unCamino = Nada (Cofre [Cacharro,Cacharro] (Nada (Cofre [Tesoro] Fin)))
unCamino2 = Fin
unCamino3 = Nada (Nada (Cofre [Tesoro] (Nada(Cofre [Tesoro] Fin))))

hayTesoro :: Camino -> Bool
--Indica si hay un cofre con un tesoro en el camino.
hayTesoro Fin = False
hayTesoro (Cofre xs c) = hayTesoroEntre xs || hayTesoro c
hayTesoro (Nada c) = hayTesoro c

hayTesoroEntre :: [Objeto] -> Bool
hayTesoroEntre [] = False
hayTesoroEntre (x:xs) = esTesoro x || hayTesoroEntre xs

esTesoro :: Objeto -> Bool
esTesoro Tesoro = True
esTesoro _ = False

pasosHastaTesoro :: Camino -> Int
--Indica la cantidad de pasos que hay que recorrer hasta llegar al primer cofre
--precon: Tiene que haber al menos un tesoro
pasosHastaTesoro Fin = error("No cumple precondicion.")
pasosHastaTesoro (Cofre xs c) = if(hayTesoroEntre xs)
                                  then 0 else 1 + pasosHastaTesoro c
pasosHastaTesoro (Nada c) = 1 + pasosHastaTesoro c

hayTesoroEn :: Int -> Camino -> Bool
--Indica si hay un tesoro en una cierta cantidad de pasos.
hayTesoroEn 0 (Cofre xs c) = hayTesoroEntre xs
hayTesoroEn 0 _ = False
hayTesoroEn n Fin = False
hayTesoroEn n (Cofre xs c) = hayTesoroEn (n-1) c
hayTesoroEn n (Nada c) = hayTesoroEn (n-1) c

alMenosNTesoros :: Int -> Camino -> Bool
--Indica si hay al menos "n" tesoros en el camino.
alMenosNTesoros n Fin = n==0
alMenosNTesoros n (Cofre xs c) = if(hayTesoroEntre xs)
                                  then n==1 || alMenosNTesoros (n-1) c
                                  else n==0 || alMenosNTesoros n c
alMenosNTesoros n (Nada c) = n==0 || alMenosNTesoros n c

cantTesorosEntre :: Int -> Int -> Camino -> Int
--Dado un rango de pasos, indica la cantidad de tesoros que hay
--en ese rango.
cantTesorosEntre n1 n2 c = cantTesorosHasta (avanzarNPasos n1 c) (n2 - n1)

avanzarNPasos :: Int -> Camino -> Camino
avanzarNPasos 0 c = c
avanzarNPasos n Fin = Fin
avanzarNPasos n (Cofre _ c) = avanzarNPasos (n-1) c
avanzarNPasos n (Nada c) = avanzarNPasos (n-1) c

cantTesorosHasta :: Camino -> Int -> Int
cantTesorosHasta (Cofre xs _) 0 = unoSi(hayTesoroEntre xs)
cantTesorosHasta _ 0 = 0
cantTesorosHasta Fin n = 0
cantTesorosHasta (Cofre xs c) n = unoSi(hayTesoroEntre xs) + cantTesorosHasta c (n-1)
cantTesorosHasta (Nada c) n = cantTesorosHasta c (n-1)

--2 Tipos arboreos
data Tree a = EmptyT | NodeT a (Tree a) (Tree a)

unArbol = NodeT 5 
            (NodeT 4 
              (NodeT 3 
                (NodeT 2 
                  EmptyT 
                  (NodeT 1 
                    EmptyT 
                    EmptyT
                  )
                )
                (NodeT 2
                  (NodeT 1
                    EmptyT
                    EmptyT
                  )
                  EmptyT
                )
              )
              EmptyT
            )
            (NodeT 4 
              (NodeT 3 
                (NodeT 2 
                  EmptyT 
                  EmptyT 
                )
                (NodeT 2
                  EmptyT
                  (NodeT 1
                    EmptyT
                    EmptyT
                  )
                )
              )
              EmptyT
            )

unArbol2 = EmptyT
unArbol3 = NodeT 4 
            EmptyT 
            (NodeT 5 
              EmptyT 
              (NodeT 2 
                (NodeT 2 
                  EmptyT 
                  EmptyT
                )
                (NodeT 1
                  EmptyT
                  EmptyT
                )
              )
            )

sumarT :: Tree Int -> Int
sumarT EmptyT = 0
sumarT (NodeT n t1 t2) = n + sumarT t1 + sumarT t2

sizeT :: Tree a -> Int
--Dado un arbol binario devuelve su cantidad de elementos
sizeT EmptyT = 0
sizeT (NodeT _ t1 t2) = 1 + sizeT t1 + sizeT t2

mapDobleT :: Tree Int -> Tree Int
mapDobleT EmptyT = EmptyT
mapDobleT (NodeT n t1 t2) = (NodeT (n*2) (mapDobleT t1) (mapDobleT t2))

perteneceT :: Eq a => a -> Tree a -> Bool
perteneceT x EmptyT = False
perteneceT x (NodeT y t1 t2) = x==y || perteneceT x t1 || perteneceT x t2

aparicionesT :: Eq a => a -> Tree a -> Int
aparicionesT x EmptyT = 0
aparicionesT x (NodeT y t1 t2) = unoSi(x==y) + aparicionesT x t1 + aparicionesT x t2

leaves :: Tree a -> [a]
--Dado un arbol devuelve los elementos que se encuentran en sus hojas
leaves EmptyT = []
leaves (NodeT x t1 t2) = x : (leaves t1 ++ leaves t2)

heightT :: Tree a -> Int
--dado un arbol devuelve su altura
heightT EmptyT = 0
heightT (NodeT x t1 t2) = 1 + (elMayor (heightT t1) (heightT t2))

elMayor :: Int -> Int -> Int
elMayor n m = if(n > m) then n else m

mirrorT :: Tree a -> Tree a
mirrorT EmptyT = EmptyT
mirrorT (NodeT x t1 t2) = (NodeT x (mirrorT t2) (mirrorT t1))

toList :: Tree a -> [a]
toList EmptyT = []
toList (NodeT x t1 t2) = (toList t1) ++ [x] ++ (toList t2)

levelN :: Int -> Tree a -> [a]
--Dado un número n y un arbol devuelve una lista con los nodos de nivel n.
levelN 0 (NodeT x t1 t2) = [x]
levelN _ EmptyT = []
levelN n (NodeT x t1 t2) = levelN (n-1) t1 ++ levelN (n-1) t2

listPerLevel :: Tree a -> [[a]]
--Dado un arbol devuelve una lista de listas en la que cada elemento repre
--senta un nivel de dicho arbol
listPerLevel EmptyT = []
listPerLevel t = [elementoDe t] : (cadaLevel (heightT t-1) t)
---                                                    ^Preguntar xq
cadaLevel :: Int -> Tree a -> [[a]]
--Precon: Hay tantos niveles como el dado.
cadaLevel 0 t = []
cadaLevel n t = (levelN n t) : cadaLevel (n-1) t

elementoDe :: Tree a -> a
--precon: el arbol dado no es emptyT.
elementoDe (NodeT x t1 t2) = x

ramaMasLarga :: Tree a -> [a]
ramaMasLarga EmptyT = []
ramaMasLarga (NodeT x t1 t2) = x : listaMasLarga (ramaMasLarga t1) (ramaMasLarga t2)

listaMasLarga :: [a] -> [a] -> [a]
listaMasLarga x y = if (length x > length y) then x else y

todosLosCaminos :: Tree a -> [[a]]
todosLosCaminos EmptyT = []
todosLosCaminos (NodeT x t1 t2) = 
    (agregarEnTodos x (todosLosCaminos t1)) ++ (agregarEnTodos x (todosLosCaminos t2))

agregarEnTodos :: a -> [[a]] -> [[a]]
agregarEnTodos x [] = [[x]]
agregarEnTodos x (ys:yss) = (x:ys) : agregarEnTodos x yss

data Pizza = Prepizza | Capa Ingrediente Pizza
data Ingrediente = Salsa | Queso | Jamon | Aceitunas Int

cantidadDeCapas :: Pizza -> Int
--Dada una pizza devuelve la cantidad de ingredientes
cantidadDeCapas Prepizza = 0
cantidadDeCapas (Capa _ p) = 1 + (cantidadDeCapas p)

armarPizza :: [Ingrediente] -> Pizza
armarPizza [] = Prepizza
armarPizza (x:xs) = Capa x (armarPizza xs)

sacarJamon :: Pizza -> Pizza
--Le saca los ingredientes que sean jamon a la pizza
sacarJamon Prepizza = Prepizza
sacarJamon (Capa x p) = if (esJamon x)
                        then sacarJamon p
                        else Capa x (sacarJamon p)

tieneSoloSalsaYQueso :: Pizza -> Bool
--Dice si una pizza tiene solo salsa y queso
tieneSoloSalsaYQueso Prepizza = True
tieneSoloSalsaYQueso (Capa x p) = (esSalsa x || esQueso x) 
                                  && tieneSoloSalsaYQueso p 

esJamon :: Ingrediente -> Bool
esJamon Jamon = True
esJamon _ = False

esSalsa :: Ingrediente -> Bool
esSalsa Salsa = True
esSalsa _ = False

esQueso :: Ingrediente -> Bool
esQueso Queso = True
esQueso _ = False

duplicarAceitunas :: Pizza -> Pizza
duplicarAceitunas Prepizza = Prepizza
duplicarAceitunas (Capa x p) = 
          Capa (duplicarSiHayAceitunas x) (duplicarAceitunas p)

duplicarSiHayAceitunas :: Ingrediente -> Ingrediente
duplicarSiHayAceitunas (Aceitunas x) = Aceitunas (x*2)
duplicarSiHayAceitunas x = x

cantCapasPorPizza :: [Pizza] -> [(Int, Pizza)]
cantCapasPorPizza [] = []
cantCapasPorPizza (x:xs) = (cantidadDeCapas x, x) : cantCapasPorPizza xs

pizza = Capa (Aceitunas 8) (Capa Salsa (Capa Queso (Capa Jamon Prepizza)))
pizza2 = Prepizza
pizza3 = Capa Salsa (Capa Queso (Capa Salsa Prepizza))

--Mapa de tesoros

data Dir = Izq | Der
data Objeto = Tesoro | Chatarra
data Cofre = Cofre [Objeto]
data Mapa = Fin Cofre
          | Bifurcacion Cofre Mapa Mapa

map = Bifurcacion (Cofre [Chatarra]) 
        (Bifurcacion (Cofre [Chatarra, Chatarra, Chatarra])
          (Bifurcacion (Cofre []) (Fin (Cofre [])) (Fin (Cofre [])))
          (Bifurcacion (Cofre [Chatarra, Tesoro, Chatarra]) (Fin (Cofre [])) (Fin (Cofre [])))
        )
        (Fin (Cofre []))

map2 = Bifurcacion (Cofre [])
        (Bifurcacion(Cofre [])
          (Bifurcacion(Cofre [])
            (Fin (Cofre []))
            (Bifurcacion (Cofre [Chatarra, Tesoro])
              (Fin (Cofre [Chatarra]))
              (Fin (Cofre [Tesoro, Tesoro, Chatarra, Tesoro]))
            )
          )
          (Fin (Cofre [Chatarra]))
        )
        (Bifurcacion(Cofre [Chatarra, Chatarra, Chatarra])
          (Fin (Cofre[]))
          (Bifurcacion (Cofre [])
            (Fin (Cofre[]))
            (Bifurcacion (Cofre [Chatarra, Tesoro, Chatarra])
              (Bifurcacion (Cofre[])
                (Fin (Cofre[]))
                (Bifurcacion (Cofre[])
                  (Fin (Cofre[]))
                  (Fin (Cofre[]))
                )
              )
              (Fin (Cofre[]))
            )
          )
        )
          
map3 = Fin(Cofre [Chatarra, Chatarra])

--1.
hayTesoro :: Mapa -> Bool
--Indica si hay un tesoro en alguna parte del mapa
hayTesoro (Fin c) = hayTesoroEnCofre c
hayTesoro (Bifurcacion c m1 m2) = (hayTesoroEnCofre c) 
                                || (hayTesoro m1) 
                                || (hayTesoro m2)

hayTesoroEnCofre :: Cofre -> Bool
hayTesoroEnCofre (Cofre os) = hayTesoroEntre os

hayTesoroEntre :: [Objeto] -> Bool
hayTesoroEntre [] = False
hayTesoroEntre (o:os) = (esTesoro o) || (hayTesoroEntre os)

esTesoro :: Objeto -> Bool
esTesoro Tesoro = True
esTesoro _ = False

--2.
hayTesoroEn :: [Dir] -> Mapa -> Bool
hayTesoroEn d m = hayTesoroEnCofre(obtenerCofreSiHayEn d m)

obtenerCofreSiHayEn :: [Dir] -> Mapa -> Cofre
--Aclaracion: Funcion absoluta, si no hay camino suficiente en el mapa devuelve un
--cofre vacio.
obtenerCofreSiHayEn [] m = cofreEn m
--Una mejor solucion seria usando el tipo just para evitar el cofre vacio
obtenerCofreSiHayEn (x:xs) (Fin c) = Cofre [] --Caso borde, no hay camino suficiente
obtenerCofreSiHayEn (x:xs) (Bifurcacion c m1 m2) = 
                          if(esIzq x) 
                            then obtenerCofreSiHayEn xs m1 
                            else obtenerCofreSiHayEn xs m2

esIzq :: Dir -> Bool
esIzq Izq = True
esIzq _ = False

cofreEn :: Mapa -> Cofre
cofreEn (Fin c) = c
cofreEn (Bifurcacion c m1 m2) = c

--Mismo ejercicio pero de manera parcial
hayTesoroEnParcial :: [Dir] -> Mapa -> Bool
--precon: Hay camino en el mapa para llegar con las direcciones dadas.
hayTesoroEnParcial d m = hayTesoroEnCofre(cofreEn(avanzarHasta d m))

avanzarHasta :: [Dir] -> Mapa -> Mapa
--precon: Hay camino en el mapa para llegar con las direcciones dadas.
avanzarHasta [] m = m
avanzarHasta (x:xs) (Fin c) = error "no cumplio precondición"
avanzarHasta (x:xs) (Bifurcacion c m1 m2) =
                       if(esIzq x) 
                        then avanzarHasta xs m1
                        else avanzarHasta xs m2

--3.
caminoAlTesoro :: Mapa -> [Dir]
--precon: Existe tesoro y es unico.
caminoAlTesoro m = snd (caminoAlTesoroConDir m)

--Entiendo que es choclodigo pero no se me ocurre otra forma
--de poder verificar si hay tesoro en esa rama para irla guardando
--de manera recursiva.
caminoAlTesoroConDir :: Mapa -> (Bool, [Dir])
caminoAlTesoroConDir (Fin c) = (hayTesoroEnCofre c, [])
caminoAlTesoroConDir (Bifurcacion c m1 m2) =
  let 
    (hayTesoroPorIzq, dirs1) = caminoAlTesoroConDir m1
    (hayTesoroPorDer, dirs2) = caminoAlTesoroConDir m2
  in
  --mira si ya alguna rama tiene el camino al tesoro
    if (hayTesoroPorIzq)
    then (hayTesoroPorIzq, Izq : dirs1)
    else if (hayTesoroPorDer)
      then (hayTesoroPorDer, Der : dirs2)
      --En caso negativo, se fija si este nodo tiene tesoro y genera la base.
      else (hayTesoroEnCofre c, [])
      
--4
caminoDeLaRamaMasLarga :: Mapa -> [Dir]
caminoDeLaRamaMasLarga m = snd(caminoMasLargoContando m)

caminoMasLargoContando :: Mapa -> (Int, [Dir])
caminoMasLargoContando (Fin c) = (1, [])
caminoMasLargoContando (Bifurcacion c m1 m2) =
	let
	  (length1, dirs1) = caminoMasLargoContando m1
	  (length2, dirs2) = caminoMasLargoContando m2
	in
	  if (length1 > length2)
	    then (length1 + 1, Izq:dirs1)
	    else (length2 + 1, Der:dirs2)

--5
tesorosPorNivel :: Mapa -> [[Objeto]]
--Devuelve los tesoros separados por nivel en el arbol.
tesorosPorNivel (Fin c) = tesorosEnCofre c : []
tesorosPorNivel (Bifurcacion c m1 m2) =
  (tesorosEnCofre c) : nivelConNivel (tesorosPorNivel m1) (tesorosPorNivel m2)

tesorosEnCofre :: Cofre -> [Objeto]
tesorosEnCofre (Cofre o) = tesorosEn o

tesorosEn :: [Objeto] -> [Objeto]
tesorosEn [] = []
tesorosEn (o:os) = singularSi(esTesoro o) o ++ tesorosEn os

singularSi :: Bool -> a -> [a]
singularSi True x = [x]
singularSi _ _ = []

nivelConNivel :: [[a]] -> [[a]] -> [[a]]
nivelConNivel [] ys = ys
nivelConNivel xs [] = xs
nivelConNivel (x:xs) (y:ys) = (x++y) : nivelConNivel xs ys

--6
todosLosCaminos :: Mapa -> [[Dir]]
todosLosCaminos (Fin c) = []
todosLosCaminos (Bifurcacion c m1 m2) =
  agregarEnTodos Izq (todosLosCaminos m1) 
  ++
  agregarEnTodos Der (todosLosCaminos m2)

agregarEnTodos :: a -> [[a]] -> [[a]]
agregarEnTodos x [] = [x] : []
--caso borde para evitar que siempre se agregue una lista con el elemento d
--si hay elementos en xs corta en el último elemento, si no va al caso base.
agregarEnTodos x [y] = (x:y) : []
agregarEnTodos x (y:ys) = (x:y) : agregarEnTodos x ys

--Nave Espacial

data Componente = LanzaTorpedos | Motor Int | Almacen [Barril]
data Barril = Comida | Oxigeno | Torpedo | Combustible

data Sector = S SectorId [Componente] [Tripulante]
type SectorId = String
type Tripulante = String

data Tree a = EmptyT | NodeT a (Tree a) (Tree a)
data Nave = N (Tree Sector)

arma = LanzaTorpedos
m1 = Motor 500
m2 = Motor 143
m3 = Motor 220
al1 = Almacen [Comida, Comida, Combustible, Torpedo]
al2 = Almacen [Oxigeno, Torpedo, Oxigeno]
al3 = Almacen [Combustible, Comida, Comida, Combustible, Comida]

s1 = S "Sector A" [arma, arma, m1, al2] ["Pepe","Jose","Josema"]
s2 = S "Sector B" [al1,al3] ["Neo"]
s3 = S "Sector C" [m2, arma, arma, al2] ["Neo"]
s4 = S "Sector D" [] []
s5 = S "Sector S" [m1,m2,m3,al1,al2,al3,arma] ["Capitan"]

n1 = N (EmptyT)
n2 = N (NodeT s1
          EmptyT
          (NodeT s4
            EmptyT
            EmptyT
          )
       )
n3 = N (NodeT s5
          (NodeT s4
            EmptyT
            (NodeT s3
              EmptyT
              EmptyT
            )
          )
          (NodeT s2
            EmptyT
            (NodeT s1
              EmptyT
              EmptyT
            )
          )
       )
--1
sectores :: Nave -> [SectorId]
--Devuelve todos los sectores de la nave
sectores (N ts) = losIdDeSectores ts

losIdDeSectores :: Tree Sector -> [SectorId]
losIdDeSectores EmptyT = []
losIdDeSectores (NodeT s ti td) =
  idDe s : (losIdDeSectores ti ++ losIdDeSectores td)

idDe :: Sector -> SectorId
idDe (S sid c t) = sid

--2
poderDePropulsion :: Nave -> Int
--Devuelve la suma de poder de propulsión de todos los motores de la nave.
poderDePropulsion (N ts) = poderDePropulsionEn ts

poderDePropulsionEn :: Tree Sector -> Int
poderDePropulsionEn EmptyT = 0
poderDePropulsionEn (NodeT s ti td) =
  (poderDePropulsionDeSector s) + poderDePropulsionEn ti + poderDePropulsionEn td

poderDePropulsionDeSector :: Sector -> Int
poderDePropulsionDeSector (S _ c _) = poderDePropulsionDeComponentes c

poderDePropulsionDeComponentes :: [Componente] -> Int
poderDePropulsionDeComponentes [] = 0
poderDePropulsionDeComponentes (x:xs) =
  (poderDePropulsionDeComponente x) + poderDePropulsionDeComponentes xs

poderDePropulsionDeComponente :: Componente -> Int
poderDePropulsionDeComponente (Motor x) = x
poderDePropulsionDeComponente _ = 0

--3
barriles :: Nave -> [Barril]
--Devuelve tdos los barriles de la nave
barriles (N ts) = barrilesEn ts

barrilesEn :: Tree Sector -> [Barril]
barrilesEn EmptyT = []
barrilesEn (NodeT s ti td) =
  barrilesEnSector s ++ barrilesEn ti ++ barrilesEn td

barrilesEnSector :: Sector -> [Barril]
barrilesEnSector (S _ c _) = barrilesEnComponentes c

barrilesEnComponentes :: [Componente] -> [Barril]
barrilesEnComponentes [] = []
barrilesEnComponentes (x:xs) =
  barrilesEnComponente x ++ barrilesEnComponentes xs

barrilesEnComponente :: Componente -> [Barril]
barrilesEnComponente (Almacen b) = b
barrilesEnComponente _ = []

--4
agregarASector :: [Componente] -> SectorId -> Nave -> Nave
agregarASector c id (N ts) = N (agregadoEnSector c id ts)

agregadoEnSector :: [Componente] -> SectorId -> Tree Sector -> Tree Sector
agregadoEnSector c id EmptyT = EmptyT
agregadoEnSector c id (NodeT s ti td) =
  if (esSector id s)
    then NodeT (agregarComponentes c s) ti td
    else NodeT s (agregadoEnSector c id ti) (agregadoEnSector c id td)

agregarComponentes :: [Componente] -> Sector -> Sector
agregarComponentes c (S id sc t) = S id (c++sc) t

esSector :: SectorId -> Sector -> Bool
esSector id (S sid _ _) = id == sid

--5
asignarTripulanteA :: Tripulante -> [SectorId] -> Nave -> Nave
--Incorpora un tripulante a una lista de sectores de la nave.
asignarTripulanteA t id (N ts) = N (asignarEn t id ts)

asignarEn :: Tripulante -> [SectorId] -> Tree Sector -> Tree Sector
asignarEn t ids EmptyT = EmptyT
asignarEn t ids (NodeT s ti td) =
  if (haySector ids s)
    then NodeT (asignarAca t s) (asignarEn t ids ti) (asignarEn t ids td)
    else NodeT s (asignarEn t ids ti) (asignarEn t ids td)

haySector :: [SectorId] -> Sector -> Bool
haySector [] s = False
haySector (x:xs) s = esSector x s || haySector xs s

asignarAca :: Tripulante -> Sector -> Sector
asignarAca t (S id c st) = S id c (t:st)

--6
sectoresAsignados :: Tripulante -> Nave -> [SectorId]
sectoresAsignados t (N ts) = sectoresDondeEsta t ts

sectoresDondeEsta :: Tripulante -> Tree Sector -> [SectorId]
sectoresDondeEsta t EmptyT = []
sectoresDondeEsta t (NodeT s ti td) =
  singularSi(esTripulanteEn t s) (idDe s) ++ sectoresDondeEsta t ti ++ sectoresDondeEsta t td

esTripulanteEn :: Tripulante -> Sector -> Bool
esTripulanteEn t (S _ _ ts) = elem t ts

--7
tripulantes :: Nave -> [Tripulante]
tripulantes (N ts) = sinRepetidos(tripulantesEn ts)

sinRepetidos :: Eq a => [a] -> [a]
sinRepetidos [] = []
sinRepetidos (x:xs) =
  if(elem x xs)
    then sinRepetidos xs
    else x : sinRepetidos xs

tripulantesEn :: Tree Sector -> [Tripulante]
tripulantesEn EmptyT = []
tripulantesEn (NodeT s t1 t2) =
  (tripulantesEnSector s) ++ (tripulantesEn t1) ++ (tripulantesEn t2)

tripulantesEnSector :: Sector -> [Tripulante]
tripulantesEnSector (S _ _ t) = t

--Manada de lobos

type Presa = String --nombre de presa
type Territorio = String --nombre de territorio
type Nombre = String --nombre de lobo
data Lobo = Cazador Nombre [Presa] Lobo Lobo Lobo
          | Explorador Nombre [Territorio] Lobo Lobo
          | Cria Nombre
data Manada = M Lobo

--1
ma = M (Cazador "Alfa" ["Conejo","Conejo"]
        (Explorador "Beta" ["Norte"]
          (Cria "hija")
          (Cria "otra")
        )
        (Cria "algo")
        (Cria "bebe")
      )

ma2 = M (Cazador "Alfa" ["Conejo","Conejo", "Ciervo", "Ardilla", "Ardilla"]
        (Explorador "Beta" ["Norte"]
          (Cria "hija")
          (Cria "otra")
        )
        (Cria "algo")
        (Explorador "zeta" ["Norte","Sur"]
          (Explorador "otro" ["Sur"]
            (Cria "a")
            (Cria "b")
          )
          (Cria "c")
        )
      )

ma3 = M (Explorador "wolfy" []
          (Cria "una")
          (Cria "otra")
        )
--2
buenaCaza :: Manada -> Bool
--dada una manada, indica si la cant de alimento cazado es mayor a la cant
--de cris
buenaCaza (M ls) = cantidadCazada ls > cantidadCrias ls

cantidadCazada :: Lobo -> Int
cantidadCazada (Cria _) = 0
cantidadCazada (Explorador _ _ l1 l2) =
  cantidadCazada l1 + cantidadCazada l2
cantidadCazada (Cazador _ p l1 l2 l3) =
  length p + cantidadCazada l1 + cantidadCazada l2 + cantidadCazada l3

cantidadCrias :: Lobo -> Int
cantidadCrias (Cria _) = 1
cantidadCrias (Explorador _ _ l1 l2) =
  cantidadCrias l1 + cantidadCrias l2
cantidadCrias (Cazador _ _ l1 l2 l3) =
  cantidadCrias l1 + cantidadCrias l2 + cantidadCrias l3

--3
elAlfa :: Manada -> (Nombre, Int)
elAlfa (M ls) = alfaEntre ls

alfaEntre :: Lobo -> (Nombre, Int)
alfaEntre (Cria n) = (n, 0)
alfaEntre (Explorador n _ l1 l2) =
    elQueMasCazo (n, 0)(elQueMasCazo(alfaEntre l1)(alfaEntre l2))
alfaEntre (Cazador n c l1 l2 l3) =
    elQueMasCazo (n, length c)
                 (elQueMasCazo (alfaEntre l1)
                               (elQueMasCazo (alfaEntre l2) (alfaEntre l3))
                 )

elQueMasCazo :: (Nombre, Int) -> (Nombre, Int) -> (Nombre, Int)
elQueMasCazo (n,i) (n2,i2) =
  if (i2 > i) then (n2, i2) else (n, i)

--4
losQueExploraron :: Territorio -> Manada -> [Nombre]
--Dado un territorio y una manada, devuelve los nombres de los exploradores
--que pasaron por dicho territorio
losQueExploraron t (M ls) = lobosQueExploraron t ls

lobosQueExploraron :: Territorio -> Lobo -> [Nombre]
lobosQueExploraron t (Cria n) = []
lobosQueExploraron t (Explorador n tl l1 l2) =
  singularSi(elem t tl) n ++
  lobosQueExploraron t l1 ++
  lobosQueExploraron t l2
lobosQueExploraron t (Cazador _ _ l1 l2 l3) =
  lobosQueExploraron t l1 ++
  lobosQueExploraron t l2 ++
  lobosQueExploraron t l3



%Solución recomendada por ChatGPT
% Declaramos que las cláusulas de los predicados father/2 y mother/2 pueden no estar juntas en el archivo.
% Esto es necesario para evitar advertencias sobre la definición de los mismos.
%Esos predicados aparecen varias veces en diferentes lugares del código, y 
%Prolog genera advertencias si las definiciones no están agrupadas juntas. 
%Para evitar esas advertencias, usamos la directiva discontiguous.

:- discontiguous father/2.
:- discontiguous mother/2.
%------------------------------------------------------------------------------
% Hechos que definen las relaciones familiares.
father(marcus, lucius).    % Marcus es el padre de Lucius
mother(livia, lucius).     % Livia es la madre de Lucius
father(lucius, quintus).   % Lucius es el padre de Quintus
mother(cornelia, quintus). % Cornelia es la madre de Quintus
father(marcus, julia).     % Marcus es el padre de Julia
mother(livia, julia).      % Livia es la madre de Julia

% Definimos que Lucius y Julia son hermanos.
sibling(lucius, julia).    % Lucius y Julia son hermanos
sibling(julia, lucius).    % Julia y Lucius son hermanos (relación simétrica)

% Definimos relaciones de tíos y primos.
uncle(lucius, gaius).      % Lucius es el tío de Gaius
cousin(quintus, gaius).    % Quintus y Gaius son primos

% Definimos relaciones de abuelos y abuelas.
grandfather(marcus, quintus).  % Marcus es el abuelo de Quintus
grandmother(livia, quintus).   % Livia es la abuela de Quintus

% Definimos el nivel de consanguinidad entre dos personas.
% El nivel 1 es para padres.
levelConsanguinity(X, Y, 1) :- father(X, Y).  % Si X es padre de Y
levelConsanguinity(X, Y, 1) :- mother(X, Y).  % Si X es madre de Y

% El nivel 2 es para hermanos y abuelos.
levelConsanguinity(X, Y, 2) :- sibling(X, Y).  % Si X y Y son hermanos
levelConsanguinity(X, Y, 2) :- grandfather(X, Y).  % Si X es abuelo de Y
levelConsanguinity(X, Y, 2) :- grandmother(X, Y).  % Si X es abuela de Y

% El nivel 3 es para tíos y primos.
levelConsanguinity(X, Y, 3) :- uncle(X, Y).  % Si X es tío de Y
levelConsanguinity(X, Y, 3) :- cousin(X, Y).  % Si X y Y son primos

% Predicado para encontrar todas las personas con un cierto nivel de consanguinidad respecto a una persona X.
findAllAtLevel(X, Level, List) :-
    findall(Y, levelConsanguinity(X, Y, Level), List).  % Encuentra todos Y que están al nivel de consanguinidad con X.

% Distribución de la herencia.
distributeInheritance(InheritanceTotal, Distribution) :-
    findAllAtLevel(lucius, 1, Level1),  % Encuentra todos los herederos de nivel 1 (hijos) de Lucius
    findAllAtLevel(lucius, 2, Level2),  % Encuentra todos los herederos de nivel 2 (hermanos y abuelos) de Lucius
    findAllAtLevel(lucius, 3, Level3),  % Encuentra todos los herederos de nivel 3 (tíos y primos) de Lucius
    
    length(Level1, Count1),  % Cuenta el número de herederos de nivel 1
    length(Level2, Count2),  % Cuenta el número de herederos de nivel 2
    length(Level3, Count3),  % Cuenta el número de herederos de nivel 3

    % Calcula la suma de los porcentajes teóricos.
    TotalPercentage is Count1 * 30 + Count2 * 20 + Count3 * 10,

    % Si el total excede 100%, se ajusta proporcionalmente.
    (TotalPercentage > 100 ->
        Ratio is 100 / TotalPercentage;  % Calcula un ratio para ajustar los porcentajes
        Ratio is 1),  % Si no excede 100, no se necesita ajuste.

    % Calcular la distribución ajustada.
    Distribute1 is 30 * Ratio,  % Porcentaje ajustado para nivel 1
    Distribute2 is 20 * Ratio,  % Porcentaje ajustado para nivel 2
    Distribute3 is 10 * Ratio,  % Porcentaje ajustado para nivel 3

    % Calcular la cantidad de herencia para cada persona, manejando la división por cero.
    (Count1 > 0 -> 
        InheritancePerPerson1 is (Distribute1 / 100) * InheritanceTotal / Count1;  % Herencia por persona en nivel 1
        InheritancePerPerson1 is 0),  % Si no hay herederos, se asigna 0

    (Count2 > 0 -> 
        InheritancePerPerson2 is (Distribute2 / 100) * InheritanceTotal / Count2;  % Herencia por persona en nivel 2
        InheritancePerPerson2 is 0),  % Si no hay herederos, se asigna 0

    (Count3 > 0 -> 
        InheritancePerPerson3 is (Distribute3 / 100) * InheritanceTotal / Count3;  % Herencia por persona en nivel 3
        InheritancePerPerson3 is 0),  % Si no hay herederos, se asigna 0

    % Crear la lista final de distribución con la herencia asignada.
    Distribution = [
        level(1, Level1, InheritancePerPerson1),  % Nivel 1 con los herederos y su herencia
        level(2, Level2, InheritancePerPerson2),  % Nivel 2 con los herederos y su herencia
        level(3, Level3, InheritancePerPerson3)   % Nivel 3 con los herederos y su herencia
    ].

% Casos de prueba para verificar la correcta distribución de la herencia.
test_case_1(Distribution) :- distributeInheritance(100000, Distribution).  % Distribuir 100,000
test_case_2(Distribution) :- distributeInheritance(250000, Distribution).  % Distribuir 250,000
test_case_3(Distribution) :- distributeInheritance(150000, Distribution).  % Distribuir 150,000

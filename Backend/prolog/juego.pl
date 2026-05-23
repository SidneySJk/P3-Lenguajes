:- use_module('hechos.pl').
:- use_module('auxiliares.pl').


% Construir conexiones logicas del mapa

construir_mapa(Inicio, Mapa) :-
    construir_mapa(Inicio, [], Mapa).

construir_mapa(Punto, Visitados, mapa(Punto, SubCaminos)) :-
    findall(
        Subcamino,
        (
            conexion(Punto, Siguiente),
            \+ member(Siguiente, Visitados),
            construir_mapa(Siguiente, [Punto|Visitados], Subcamino)
        ),
        SubCaminos
    ).

% Mostrar lugares del mapa

mostrar_lugares :-
    modulo(Nombre, Descripcion),
    write('Lugar: '),
    write(Nombre),
    nl,
    write('Descripcion: '),
    write(Descripcion),
    nl,
    nl,
    fail.

mostrar_lugares.


% Mostrar lugares bloqueados en el mapa

lugar_bloqueado(Lugar) :-
    necesita(Lugar, Objeto),
    usado(Usados),
    \+ member(Objeto, Usados).


% Validar si un lugar ya fue visitado

visita_requerida(LugarDestino) :-
    pasoPrevio(LugarDestino, LugarVisitado),
    lugares(Lugares),
    member(LugarVisitado, Lugares).

visita_requerida(LugarDestino) :-
    \+ pasoPrevio(LugarDestino, _).


% Predicados

 /**************
 *  conexion   *
 ***************/
% Asegura la conectividad bidireccional de los enlaces
conexion(A, B) :- enlace(A, B).
conexion(A, B) :- enlace(B, A).

 /************
 *   tomar   *
 *************/
% Tomar un objeto y guardarlo en inventario
% Restriccion: El jugador debe estar en el mismo sitio del objeto
tomar(Objeto) :-
    jugador(Lugar),
    artefacto(Objeto, Lugar),
    artefactosLogrados(Inventario),
    \+ member(Objeto, Inventario),

    retract(artefactosLogrados(Inventario)),
    assertz(artefactosLogrados([Objeto|Inventario])),

    write('Tomas el objeto '),
    write(Objeto),
    write(' y sigues tú camino.'),
    nl.

tomar(Objeto) :-
    jugador(Lugar),
    \+ artefacto(Objeto, Lugar),
    write('Ese objeto no esta en este lugar...'),
    nl,
    fail.

usar(Objeto) :-
    artefactosLogrados(Inventario),
    member(Objeto, Inventario),

    jugador(Lugar),
    conexion(Lugar, Destino),
    necesita(Objeto, Destino),

    usado(Usados),
    \+ member(Objeto, Usados),

    retract(usado(Usados)),
    assertz(usado([Objeto|Usados])),

    write('Haz usado el objeto '),
    write(Objeto),
    write(' y desbloqueaste '),
    write(Destino),
    nl.

usar(Objeto) :-
    write('No puedes usar el objeto '),
    write(Objeto),
    write(' aqui.'),
    nl,
    fail.

 /***************
 *   puedo_ir   *
 ****************/
% Tomar un objeto y guardarlo en inventario
% Restriccion: El jugador no puede moverse a un sitio que no este enlazado a su ubicación.
% Restriccion: Debe poseer los artefactos requeridos.
% Restriccion: Debe haber recorrido las secciones previas requeridas.

puedo_ir(Hacia) :-
    jugador(Actual),

    conexion(Actual, Hacia),

    visita_requerida(Hacia),

    (
        necesita(Hacia, Objeto)
        ->
        (
            usado(Usados),
            member(Objeto, Usados)
        )
        ;
        true
    ),

    write('Puedes avanzar hacia '),
    write(Hacia),
    nl.


puedo_ir(Hacia) :-
    write('No puedes avanzar hacia '),
    write(Hacia),
    nl,
    fail.

 /***************
 *   mover   *
 ****************/
% Mueve al jugador de un sitio a otro
% Restriccion: Debe actualizar: ubicación actual, historial de modulos visitados.
% Restriccion: Debe validar todas las condiciones definidas en puedo_ir

 /***************
 *  donde_esta   *
 ****************/
% Indica la ubicacion de un artefacto

 /************************
 *   modulos_visitados   *
 ************************/
% Indica modulos previos visitados por el jugador

 /***********
 *   ruta   *
 ************/
% Indica todas una posible ruta dado un punto y otro 

 /**************
 *  como_gano  *
 ***************/
% Indica las condiciones de gane del juego tomando en cuenta: 
% rutas disponibles, artefactos requeridos, reparaciones necesarias,
% rescates pendientes, y restricciones lógicas.

 /*********************
 *   verificar gane   *
 **********************/
% Verifica si el jugador ha cumplido todas las condiciones de victoria.




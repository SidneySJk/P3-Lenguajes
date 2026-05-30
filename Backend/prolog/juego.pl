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
% Tomar un objeto y guardarlo en inventario.
% Restriccion: El jugador debe estar en el mismo sitio del objeto.

tomar(Objeto) :-
    jugador(Lugar),
    artefacto(Objeto, Lugar),
    artefactosLogrados(Inventario),
    \+ member(Objeto, Inventario),
    retract(artefactosLogrados(Inventario)),
    assertz(artefactosLogrados([Objeto|Inventario])),
    write('Tomas el objeto '),
    write(Objeto),
    write(' y sigues tu camino.'),
    nl.

tomar(Objeto) :-
    jugador(Lugar),
    \+ artefacto(Objeto, Lugar),
    write('Ese objeto no esta en este lugar...'),
    nl,
    fail.

/**********
 *  usar   *
 ***********/
% Registra el uso de un artefacto para desbloquear modulos que lo requieran.
% Restriccion: El jugador debe tener el objeto en su inventario.
% Restriccion: El objeto no debe haber sido usado ya.

usar(Objeto) :-
    artefactosLogrados(Inventario),
    member(Objeto, Inventario),
    jugador(Lugar),
    conexion(Lugar, Destino),
    necesita(Destino, Objeto),
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
 *  reparar    *
 ****************/
% Permite restaurar sistemas criticos de la estacion espacial.
% Restriccion: El jugador debe poseer los artefactos requeridos.
% Restriccion: El jugador debe estar en la seccion correcta.
% Restriccion: El sistema no debe haber sido reparado previamente.

reparar(Sistema) :-
    jugador(Lugar),
    artefactosLogrados(Inventario),
    reparados(Registro),
    sistema(Lugar, Sistema, ListaArtefactosParaReparar, fallo),
    \+ member(Sistema, Registro),
    coincidencias(Inventario, ListaArtefactosParaReparar),
    retract(reparados(Registro)),
    assertz(reparados([Sistema|Registro])),
    retract(sistema(Lugar, Sistema, ListaArtefactosParaReparar, fallo)),
    assertz(sistema(Lugar, Sistema, ListaArtefactosParaReparar, restaurado)),
    write('El sistema '),
    write(Sistema),
    write(' ha sido restaurado.'),
    nl.

reparar(_) :-
    write('No pudiste reparar el sistema.'),
    nl,
    fail.

/***************
 *  rescatar   *
 ****************/
% Permite rescatar un miembro de la tripulacion.
% Restriccion: El jugador debe estar en la misma seccion que el tripulante.
% Restriccion: El tripulante no debe haber sido rescatado previamente.
% Restriccion: Todos los sistemas requeridos por el tripulante deben estar reparados.

rescatar(Nombre) :-
    jugador(Lugar),
    tripulante(Nombre, Lugar, ListaSistemaFuncionando, atrapado),
    reparados(Registro),
    coincidencias(Registro, ListaSistemaFuncionando),
    rescatados(RescatadosActual),
    \+ member(Nombre, RescatadosActual),
    retract(tripulante(Nombre, Lugar, ListaSistemaFuncionando, atrapado)),
    assertz(tripulante(Nombre, Lugar, ListaSistemaFuncionando, rescatado)),
    retract(rescatados(RescatadosActual)),
    assertz(rescatados([Nombre|RescatadosActual])),
    write('Acabas de salvar al tripulante'),
    write(Nombre),
    nl.

rescatar(Nombre) :-
    write('No puedes rescatar a '),
    write(Nombre),
    write(' en este momento.'),
    nl,
    fail.

/***************
 *   puedo_ir   *
 ****************/
% Determina si el jugador puede moverse hacia un destino.
% Restriccion: Debe existir enlace entre secciones.
% Restriccion: Debe poseer y haber usado los artefactos requeridos.
% Restriccion: Debe haber recorrido las secciones previas requeridas.
% Restriccion: Los sistemas requeridos por necesitaEstado deben estar restaurados.

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
    (
        necesitaEstado(Hacia, Servicio, EstadoNecesario)
        ->
        (
            reparados(Registro),
            sistema(_, Servicio, _, EstadoNecesario),
            member(Servicio, Registro)
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

/****************
 *     mover     *
 *****************/
% Mueve al jugador de un sitio a otro.
% Restriccion: Actualiza ubicacion actual e historial de modulos visitados.
% Restriccion: Valida todas las condiciones de puedo_ir/1.

mover(Lugar) :-
    jugador(Actual),
    conexion(Actual, Lugar),
    visita_requerida(Lugar),
    (
        lugar_bloqueado(Lugar)
        ->
        (
            write('El lugar esta bloqueado.'),
            nl,
            fail
        )
        ;
        true
    ),
    (
        necesitaEstado(Lugar, Servicio, EstadoNecesario)
        ->
        (
            reparados(Registro),
            sistema(_, Servicio, _, EstadoNecesario),
            member(Servicio, Registro)
        )
        ;
        true
    ),
    retractall(jugador(_)),
    assertz(jugador(Lugar)),
    lugares(LugaresVisitados),
    (
        member(Lugar, LugaresVisitados)
        ->
        true
        ;
        (
            retract(lugares(LugaresVisitados)),
            assertz(lugares([Lugar|LugaresVisitados]))
        )
    ),
    write('Te moviste hacia '),
    write(Lugar),
    nl.

mover(Lugar) :-
    write('El camino hacia '),
    write(Lugar),
    write(' esta bloqueado.'),
    nl,
    fail.

/***************
 *  donde_esta  *
 ****************/
% Indica la ubicacion de un artefacto.

donde_esta(Objeto) :-
    artefactosLogrados(Inventario),
    member(Objeto, Inventario),
    write('Encuentras el artefacto '),
    write(Objeto),
    write(' en tu inventario.'),
    nl.

donde_esta(Objeto) :-
    artefacto(Objeto, Lugar),
    write('El artefacto '),
    write(Objeto),
    write(' esta en '),
    write(Lugar),
    nl.

donde_esta(_) :-
    write('Objeto no identificado.'),
    nl.

/***************
 *  que_tengo  *
 ****************/
% Indica la lista de artefactos logrados por el jugador.

que_tengo :-
    artefactosLogrados(Inventario),
    write('Encuentras en tu inventario los artefactos:'),
    nl,
    leer_(Inventario).

/************************
 *   modulos_visitados   *
 ************************/
% Indica modulos previos visitados por el jugador.

modulos_visitados :-
    lugares(LugaresVisitados),
    write('Lugares visitados:'),
    nl,
    leer_(LugaresVisitados).

/***********
 *   ruta   *
 ************/
% Indica una posible ruta dado un punto de inicio y uno de fin.

ruta(Inicio, Fin, Camino) :-
    subRutas(Inicio, Fin, [Inicio], Camino).

subRutas(Fin, Fin, Camino, Camino).

subRutas(Inicio, Fin, Visitados, Camino) :-
    conexion(Inicio, Siguiente),
    \+ member(Siguiente, Visitados),
    append(Visitados, [Siguiente], NuevosVisitados),
    subRutas(Siguiente, Fin, NuevosVisitados, Camino).

/**************
 *  como_gano  *
 ***************/
% Indica las condiciones de gane del juego tomando en cuenta:
% rutas disponibles, artefactos requeridos, reparaciones necesarias,
% rescates pendientes y restricciones logicas.

como_gano :-
    jugador(Inicio),
    write('+. ¿Como Gano? .+'),
    nl,
    nl,
    % Sistemas a reparar
    write('Sistemas a restaurar:'),
    nl,
    forall(
        objetivoS(Sistema, restaurado),
        (
            (
                sistema(ModuloSistema, Sistema, Artefactos, Estado),
                (Estado = fallo -> write('  [PENDIENTE] ') ; write('  [LISTO] ')),
                write(Sistema),
                write(' en '),
                write(ModuloSistema),
                write(' (requiere: '),
                write(Artefactos),
                write(')'),
                nl
            )
        )
    ),
    nl,
    write('Tripulantes a rescatar:'),
    nl,
    forall(
        objetivoT(Nombre, rescatado),
        (
            tripulante(Nombre, ModuloTrip, Sistemas, Estado),
            (Estado = atrapado -> write('  [PENDIENTE] ') ; write('  [RESCATADO] ')),
            write(Nombre),
            write(' en '),
            write(ModuloTrip),
            write(' (necesita sistemas: '),
            write(Sistemas),
            write(')'),
            nl
        )
    ),
    nl,
    write('Rutas desde posicion actual:'),
    nl,
    forall(
        objetivoT(Nombre, _),
        (
            tripulante(Nombre, Destino, _, _),
            (
                ruta(Inicio, Destino, Camino)
                ->
                (
                    write('  Hacia '),
                    write(Nombre),
                    write(': '),
                    write(Camino),
                    nl
                )
                ;
                (
                    write('  Sin ruta disponible hacia '),
                    write(Nombre),
                    nl
                )
            )
        )
    ).

como_gano.

/*********************
 *   verifica_gane   *
 **********************/
% Verifica si el jugador ha cumplido todas las condiciones de victoria.
% En caso de gane muestra: ruta realizada, artefactos, sistemas reparados,
% tripulacion rescatada y condicion de victoria.

verifica_gane :-
    forall(
        objetivoS(Sistema, restaurado),
        (reparados(R), member(Sistema, R))
    ),
    forall(
        objetivoT(Nombre, rescatado),
        (rescatados(Rs), member(Nombre, Rs))
    ),
    lugares(LugaresVisitados),
    artefactosLogrados(Inventario),
    reparados(Reparados),
    rescatados(Rescatados),
    nl,
    write('*+. OPERACION ATLAS COMPLETADA! .+*'),
    nl, nl,
    write('Ruta realizada:'),
    nl,
    leer_(LugaresVisitados),
    nl,
    write('Artefactos logrados:'),
    nl,
    leer_(Inventario),
    nl,
    write('Sistemas reparados:'),
    nl,
    leer_(Reparados),
    nl,
    write('Tripulacion rescatada:'),
    nl,
    leer_(Rescatados),
    nl,
    write('Condicion de victoria: TODOS LOS OBJETIVOS CUMPLIDOS'),
    nl.

verifica_gane :-
    write('Aun no cumples todas las condiciones de gane.'),
    nl,
    fail.

:- module(auxiliares, [usado/1, lugares/1, rescatados/1, reparados/1, leer_/1, coincidencias/2, eliminar/3]).

:- dynamic usado/1.
:- dynamic lugares/1.
:- dynamic rescatados/1.
:- dynamic reparados/1.


% Estado auxiliares
usado([]).
lugares([puente_mando]).
rescatados([]).
reparados([]).

% Predicados auxilires

leer_([]).

leer_([Cabeza|Cola]) :-
    write('- '),
    write(Cabeza),
    nl,
    leer_(Cola).

eliminar(_, [], []).

eliminar(X, [X|T], T).

eliminar(X, [C|T], [C|R]) :-
    X \= C,
    eliminar(X, T, R).

coincidencias(_, []).
coincidencias(L, [H|T]) :-
    member(H, L),
    coincidencias(L, T).
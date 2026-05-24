:- module(auxiliares, [usado/1, lugares/1, leer_/1, eliminar/3]).
:- dynamic usado/1.
:- dynamic lugares/1.

% Estado auxiliares
usado([]).
lugares([puente_mando]).

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


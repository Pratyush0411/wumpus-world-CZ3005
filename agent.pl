:-abolish(current/3).
:-abolish(moveforward/2).
:-abolish(visited/2).
:-abolish(action/1).
:-abolish(safe/2).
:-abolish(wumpus/2).
:-abolish(dummycurrent/3).



:- dynamic(
    [
    action/1,
    current/3,
    moveforward/2,
    safe/2,
    visited/2,
    hasarrow/0,
    tingle/2,
    glitter/2,
    confundus/2,
    wumpus/2,
    dummycurrent/3
    ]
).

% KB
visited(0,0).
current(0,0,rsouth).
dummycurrent(0,0,rsouth).

hasarrow:-
    true.

% Safe position

safe(0,0).
safe(X,Y):-
    \+ wumpus(X,Y),
    \+ confundus(X,Y),
    !.

% Get position
getforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==rnorth,
    X = Xi,
    Y is Yi+1,
    !.

getforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==rsouth,
    X = Xi,
    Y is Yi-1,
    !.

getforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==reast,
    X is Xi+1,
    Y = Yi,
    !.

getforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==rwest,
    X is Xi-1,
    Y = Yi,
    !.

% Get Direction
getrightdir(D):-
    current(_,_,Di),
    Di == rnorth,
    D = reast,
    !.

getrightdir(D):-
    current(_,_,Di),
    Di == reast,
    D = rsouth,
    !.

getrightdir(D):-
    current(_,_,Di),
    Di == rsouth,
    D = rwest,
    !.

getrightdir(D):-
    current(_,_,Di),
    Di == rwest,
    D = rnorth,
    !.

getleftdir(D):-
    current(_,_,Di),
    Di == rnorth,
    D = rwest,
    !.

getleftdir(D):-
    current(_,_,Di),
    Di == rwest,
    D = rsouth,
    !.

getleftdir(D):-
    current(_,_,Di),
    Di == rsouth,
    D = reast,
    !.

getleftdir(D):-
    current(_,_,Di),
    Di == reast,
    D = rnorth,
    !.

%change direction
changedir(D):-
    current(X,Y,_),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)),
    !.

changedummydir(D):-
    dummycurrent(X,Y,_),
    retractall(dummycurrent(_,_,_)),
    assertz(dummycurrent(X,Y,D)),
    !.

% change position
changepos(X,Y):-
    current(_,_,D),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)),
    assertz(visited(X,Y)),
    !.

% change dummy position
changedummypos(X,Y):-
    dummycurrent(_,_,D),
    retractall(dummycurrent(_,_,_)),
    assertz(dummycurrent(X,Y,D)),
    !.

% move forward
action(forward,X,Y,D):-
    getforwardpos(X,Y),
    current(_,_,D).

% turn right
action(turnright,X,Y,D):-
    getrightdir(D),
    current(X,Y,_).

%turn left
action(turnleft,X,Y,D):-
    getleftdir(D),
    current(X,Y,_).

% action(turnleft).
% action(turnright).
% action(forward).


explore([]).
explore([A|R]):-
    current(X,Y,D),
    retractall(dummycurrent(_,_,_)),
    assertz(dummycurrent(X,Y,D)),
    explore(R),
    action(A,X,Y,D),
    safe(X,Y),
    changedummypos(X,Y),
    changedummydir(D).



    




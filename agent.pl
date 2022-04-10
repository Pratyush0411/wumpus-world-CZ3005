:-abolish(current/3).
:-abolish(moveforward/2).
:-abolish(visited/2).



:- dynamic(
    [
    current/3,
    moveforward/2,
    visited/2
    ]
).

% KB
visited(0,0).
current(0,0,rsouth).

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
    current(Xi,Yi,Di),
    Di == rnorth,
    Di is reast
    !.

getrightdir(D):-
    current(Xi,Yi,Di),
    Di == reast,
    Di is rsouth
    !.

getrightdir(D):-
    current(Xi,Yi,Di),
    Di == rsouth,
    Di is rwest
    !.

getrightdir(D):-
    current(Xi,Yi,Di),
    Di == rwest,
    Di is rnorth
    !.

getleftdir(D):-
    current(Xi,Yi,Di),
    Di == rnorth,
    Di is rwest
    !.

getleftdir(D):-
    current(Xi,Yi,Di),
    Di == rwest,
    Di is rsouth
    !.

getleftdir(D):-
    current(Xi,Yi,Di),
    Di == rsouth,
    Di is reast
    !.

getleftdir(D):-
    current(Xi,Yi,Di),
    Di == reast,
    Di is rnorth
    !.

%change direction
changedir(D):-
    current(X,Y,_),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D))
    !.

% change position
changepos(X,Y):-
    current(_,_,D),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)),
    assertz(visited(X,Y)),
    !.

% move forward
action(forward):-
    getforwardpos(X,Y),
    changepos(X,Y),
    !.

% turn right
action(turnright):-
    getrightdir(D),
    changedir(D),
    !.

%turn left
action(turnleft):-
    getleftdir(D),
    changedir(D),
    !.





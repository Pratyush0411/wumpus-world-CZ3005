:-abolish(current/3).
:-abolish(moveforward/2).
:-abolish(visited/2).
:-abolish(action/1).
:-abolish(safe/2).
:-abolish(wumpus/2).
:-abolish(dummycurrent/3).



:- dynamic(
    [
    action/4,
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

% if len(l) < 1:
%   dummy = original
%   safe(X,Y)
% elif len(l) > 1:
%   safe(dummy)

list_length([],0).
list_length([_|TAIL],N) :- list_length(TAIL,N1), N is N1 + 1.

resetdummy:-
    current(X,Y,D),
    retractall(dummycurrent),
    dummycurrent(X,Y,D).

% explore([]).
% explore([A|R]):-
%     % list_length(R, len),
%     % len < 1,
%     % resetdummy,
%     explore(R),
%     action(A,X,Y,D),
%     safe(X,Y),
%     changedummypos(X,Y),
%     changedummydir(D).

explore(L):-
    current(X,Y,D),
    D == rnorth,
    safe(X,Y+1),
    L = [forward].

explore(L):-
    current(X,Y,D),
    D == rsouth,
    safe(X,Y-1),
    L = [forward].

explore(L):-
    current(X,Y,D),
    D == reast,
    safe(X+1,Y),
    L = [forward],
    !.

explore(L):-
    current(X,Y,D),
    D == rwest,
    safe(X-1,Y),
    L = [forward].

explore(L):-
    current(X,Y,D),
    D == rsouth,
    safe(X+1,Y),
    L = [turnleft,forward].

explore(L):-
    current(X,Y,D),
    D == rnorth,
    safe(X+1,Y),
    L = [turnright,forward].

explore(L):-
    current(X,Y,D),
    D == rwest,
    safe(X+1,Y),
    L = [turnright,turnright,forward].
    

explore(L):-
    current(X,Y,D),
    D == rnorth,
    safe(X-1,Y),
    L = [turnleft,forward].
   

explore(L):-
    current(X,Y,D),
    D == rsouth,
    safe(X-1,Y),
    L = [turnright,forward].

explore(L):-
    current(X,Y,D),
    D == reast,
    safe(X-1,Y),
    L = [turnleft, turnleft, forward].

explore(L):-
    current(X,Y,D),
    D == reast,
    safe(X,Y+1),
    L = [turnleft, forward].

explore(L):-
    current(X,Y,D),
    D == rsouth,
    safe(X,Y+1),
    L = [turnleft, turnleft, forward].

explore(L):-
    current(X,Y,D),
    D == rwest,
    safe(X,Y+1),
    L = [turnright, forward].

explore(L):-
    current(X,Y,D),
    D == rnorth,
    safe(X,Y-1),
    L = [turnright, turnright, forward].

explore(L):-
    current(X,Y,D),
    D == reast,
    safe(X,Y-1),
    L = [turnright, forward].

explore(L):-
    current(X,Y,D),
    D == rwest,
    safe(X,Y-1),
    L = [turnleft, forward].


:-abolish(current/3).
:-abolish(visited/2).
:-abolish(action/1).
:-abolish(safe/2).
:-abolish(wumpus/2).
:-abolish(dummycurrent/3).
:-abolish(hasarrow/0).
:-abolish(tingle/2).
:-abolish(glitter/2).
:-abolish(confundus/2).
:-abolish(explore_loop/4).
:-abolish(tree_visited/3).

:- dynamic(
    [
    action/4,
    current/3,
    safe/2,
    visited/2,
    hasarrow/0,
    tingle/2,
    glitter/2,
    confundus/2,
    wumpus/2,
    dummycurrent/3,
    tree_visited/3
    ]
).

% visited
visited(0,0).
visited(0,1).


% current position

current(0,0,rsouth).

% dummy current position
dummycurrent(0,0,rsouth).

% has arrow
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
    dummycurrent(Xi,Yi,Di),
    Di==rnorth,
    X = Xi,
    Y is Yi+1,
    !.

getforwardpos(X,Y):-
    dummycurrent(Xi,Yi,Di),
    Di==rsouth,
    X = Xi,
    Y is Yi-1,
    !.

getforwardpos(X,Y):-
    dummycurrent(Xi,Yi,Di),
    Di==reast,
    X is Xi+1,
    Y = Yi,
    !.

getforwardpos(X,Y):-
    dummycurrent(Xi,Yi,Di),
    Di==rwest,
    X is Xi-1,
    Y = Yi,
    !.

% Get Direction
getrightdir(D):-
    dummycurrent(_,_,Di),
    Di == rnorth,
    D = reast,
    !.

getrightdir(D):-
    dummycurrent(_,_,Di),
    Di == reast,
    D = rsouth,
    !.

getrightdir(D):-
    dummycurrent(_,_,Di),
    Di == rsouth,
    D = rwest,
    !.

getrightdir(D):-
    dummycurrent(_,_,Di),
    Di == rwest,
    D = rnorth,
    !.

getleftdir(D):-
    dummycurrent(_,_,Di),
    Di == rnorth,
    D = rwest,
    !.

getleftdir(D):-
    dummycurrent(_,_,Di),
    Di == rwest,
    D = rsouth,
    !.

getleftdir(D):-
    dummycurrent(_,_,Di),
    Di == rsouth,
    D = reast,
    !.

getleftdir(D):-
    dummycurrent(_,_,Di),
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
    dummycurrent(_,_,D).

% turn right
action(turnright,X,Y,D):-
    getrightdir(D),
    dummycurrent(X,Y,_).

%turn left
action(turnleft,X,Y,D):-
    getleftdir(D),
    dummycurrent(X,Y,_).

resetdummy:-
    current(X,Y,D),
    retractall(dummycurrent(_,_,_)),
    assertz(dummycurrent(X,Y,D)).


% explore([A|R]):-
%     length(R,0),
%     action(A,X,Y,D),
%     safe(X,Y),
%     \+ visited(X,Y).

% explore([A|R]):-
%     length(R,0),
%     action(A,X,Y,D),
%     safe(X,Y),
%     visited(X,Y),
%     X==0,
%     Y==0.

% explore([A|R]):-
%     \+ length(R,0),
%     dummycurrent(Xi,Yi,Di),
%     action(A,X,Y,D),
%     safe(X,Y),
%     assert(dummycurrent(X,Y,D)),
%     explore(R),
%     retractall(dummycurrent(_,_,_)),
%     assert(dummycurrent(Xi,Yi,Di)).


arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rnorth,
    A == forward,
    X = Xi,
    Y is Yi+1,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rsouth,
    A == forward,
    X = Xi,
    Y is Yi-1,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rwest,
    A == forward,
    X is Xi-1,
    Y = Yi,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == reast,
    A == forward,
    X is Xi+1,
    Y = Yi,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rnorth,
    A == turnright,
    X = Xi,
    Y = Yi,
    D = reast.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rsouth,
    A == turnright,
    X = Xi,
    Y = Yi,
    D = rwest.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == reast,
    A == turnright,
    X = Xi,
    Y = Yi,
    D = rsouth.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rwest,
    A == turnright,
    X = Xi,
    Y = Yi,
    D = rnorth.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rnorth,
    A == turnleft,
    X = Xi,
    Y = Yi,
    D = rwest.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rsouth,
    A == turnleft,
    X = Xi,
    Y = Yi,
    D = reast.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == reast,
    A == turnleft,
    X = Xi,
    Y = Yi,
    D = rnorth.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rwest,
    A == turnleft,
    X = Xi,
    Y = Yi,
    D = rsouth.


explore_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[forward,turnleft,turnright]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    \+ tree_visited(X,Y,D),
    \+ visited(X,Y),
    L = [A].

explore_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[forward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    visited(X,Y),
    \+ tree_visited(X,Y,D),
    explore_loop(Lr,X,Y,D),
    append([A],Lr,L).

return_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[forward,turnleft,turnright]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    \+ tree_visited(X,Y,D),
    visited(X,Y),
    X==0,
    Y==0,
    L = [A].

return_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[forward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    visited(X,Y),
    \+ tree_visited(X,Y,D),
    return_loop(Lr,X,Y,D),
    append([A],Lr,L).


explore(L):-

    retractall(tree_visited(_,_,_)),
    current(Xi,Yi,Di),
    explore_loop(Lf,Xi,Yi,Di),
    L = Lf.

explore(L):-

    retractall(tree_visited(_,_,_)),
    current(Xi,Yi,Di),
    \+ explore_loop(_,Xi,Yi,Di),
    retractall(tree_visited(_,_,_)),
    return_loop(Lf,Xi,Yi,Di),
    L=Lf.





    

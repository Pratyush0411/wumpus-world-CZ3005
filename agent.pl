:-abolish(current/3).
:-abolish(visited/2).
:-abolish(action/4).
:-abolish(safe/2).
:-abolish(wumpus/2).
:-abolish(hasarrow/0).
:-abolish(tingle/2).
:-abolish(glitter/2).
:-abolish(confundus/2).
:-abolish(explore_loop/4).
:-abolish(tree_visited/3).
:-abolish(return_loop/4).
:-abolish(arc/7).
:-abolish(wall/2).
:-abolish(stench/2).

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
    tree_visited/3,
    arc/7,
    wall/2,
    stench/2
    ]
).

% visited
visited(0,0).
visited(0,1).


% current position

current(0,0,rsouth).

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
getmoveforwardpos(X,Y):-
    dummycurrent(Xi,Yi,Di),
    Di==rnorth,
    X = Xi,
    Y is Yi+1,
    !.

getmoveforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==rsouth,
    X = Xi,
    Y is Yi-1,
    !.

getmoveforwardpos(X,Y):-
    current(Xi,Yi,Di),
    Di==reast,
    X is Xi+1,
    Y = Yi,
    !.

getmoveforwardpos(X,Y):-
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

% move moveforward
action(moveforward):-
    getmoveforwardpos(X,Y),
    current(_,_,D),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)),
    assertz(visited(X,Y)).

% turn right
action(turnright):-
    getrightdir(D),
    current(X,Y,_),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)).

%turn left
action(turnleft):-
    getleftdir(D),
    current(X,Y,_),
    retractall(current(_,_,_)),
    assertz(current(X,Y,D)).

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
    A == moveforward,
    X = Xi,
    Y is Yi+1,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rsouth,
    A == moveforward,
    X = Xi,
    Y is Yi-1,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == rwest,
    A == moveforward,
    X is Xi-1,
    Y = Yi,
    D = Di.

arc(A,X,Y,D,Xi,Yi,Di):-
    Di == reast,
    A == moveforward,
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

adj(Xa,Ya,Xi,Yi):-
    Xa is Xi+1,
    Ya = Yi.

adj(Xa,Ya,Xi,Yi):-
    Xa is Xi-1,
    Ya = Yi.

adj(Xa,Ya,Xi,Yi):-
    Xa = Xi,
    Ya is Yi+1.

adj(Xa,Ya,Xi,Yi):-
    Xa = Xi,
    Ya is Yi-1.

explore_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[moveforward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    \+ tree_visited(X,Y,D),
    \+ visited(X,Y),
    L = [A].

explore_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[moveforward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    visited(X,Y),
    \+ tree_visited(X,Y,D),
    \+ wall(X,Y),
    explore_loop(Lr,X,Y,D),
    append([A],Lr,L).

return_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[moveforward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
    \+ tree_visited(X,Y,D),
    X==0,
    Y==0,
    D == rnorth,
    L = [A].

return_loop(L,Xi,Yi,Di):-
    assertz(tree_visited(Xi,Yi,Di)),
    member(A,[moveforward,turnright,turnleft]),
    arc(A,X,Y,D,Xi,Yi,Di),
    safe(X,Y),
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
    return_loop(Lj,Xi,Yi,Di),
    L=Lj.

wumpus(X,Y):-
    adj(Xa,Ya,X,Y),
    stench(Xa,Ya),
    \+ visited(Xa,Ya).

confundus(X,Y):-
    adj(Xa,Ya,X,Y),
    tingle(Xa,Ya),
    \+ visited(Xa,Ya).

move(moveforward, [_,on,_,_,_,_]):-
    action(moveforward),
    current(X,Y,_),
    stench(X,Y).

move(moveforward, [_,_,on,_,_,_]):-
    action(moveforward),
    current(X,Y,_),
    tingle(X,Y).

move(moveforward,[_,_,_,on,_,_]):-
    action(moveforward),
    current(X,Y,_),
    glitter(X,Y).

move(moveforward,[_,_,_,_,on,_]):-
    current(Xi,Yi,Di),
    action(moveforward),
    current(X,Y,_),
    wall(X,Y),
    retractall(current(_,_,_)),
    assertz(current(Xi,Yi,Di)).

move(shoot,[_,_,_,_,_,on]):-
    retractall(stench(_,_,_)),
    retractall(wumpus(_,_,_)),
    retractall(hasarrow).

move(shoot,[_,_,_,_,_,off]):-
    retractall(hasarrow).

















    

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
:-abolish(coinexist/0).
:-abolish(iswumpusalive/0).
:-abolish(adj/4).

% abolishAll:-
%     abolish(current/3),
%     abolish(visited/2),
%     abolish(action/4),
%     abolish(safe/2),
%     abolish(wumpus/2),
%     abolish(hasarrow/0),
%     abolish(tingle/2),
%     abolish(glitter/2),
%     abolish(confundus/2),
%     abolish(explore_loop/4),
%     abolish(tree_visited/3),
%     abolish(return_loop/4),
%     abolish(arc/7),
%     abolish(wall/2),
%     abolish(stench/2),
%     abolish(coinexist/0),
%     abolish(iswumpusalive/0).


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
    stench/2,
    adj/4,
    iswumpusalive/0,
    coinexist/0
    ]
).

% visited
visited(0,0).
iswumpusalive:-
    true.

% current position
wumpus(X,Y):-
    stench(Xa,Ya),
    adj(Xa,Ya,X,Y),
    \+ visited(X,Y).

current(0,0,rsouth).

% has arrow
hasarrow:-
    true.

coinexist:- 
    true.

% Safe position

safe(0,0).
safe(X,Y):-
    \+ wumpus(X,Y),
    \+ confundus(X,Y),
    !.

% Get position
getmoveforwardpos(X,Y):-
    current(Xi,Yi,Di),
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

% shoot 
action(shoot):-
    hasarrow,
    retractall(hasarrow).

action(pickup):-
    current(Xi,Yi,_),
    glitter(Xi,Yi),
    retract(glitter(Xi,Yi)).

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

% adj(Xa,Ya,Xi,Yi):-
%     Xa is Xi+1,
%     Ya = Yi.

% adj(Xa,Ya,Xi,Yi):-
%     Xa is Xi-1,
%     Ya = Yi.

% adj(Xa,Ya,Xi,Yi):-
%     Xa = Xi,
%     Ya is Yi+1.

% adj(Xa,Ya,Xi,Yi):-
%     Xa = Xi,
%     Ya is Yi-1.

adj(Xa,Ya,Xi,Yi):-
    Xi = Xa,
    Yi is Ya-1.

adj(Xa,Ya,Xi,Yi):-
    Xi is Xa+1,
    Yi = Ya.

adj(Xa,Ya,Xi,Yi):-
    Xi is Xa-1,
    Yi = Ya.

adj(Xa,Ya,Xi,Yi):-
    Xi = Xa,
    Yi is Ya+1.


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


confundus(X,Y):-
    tingle(Xa,Ya),
    adj(Xa,Ya,X,Y),
    \+ visited(X,Y).

confundusResetPercept:-
    retractall(current(_,_,_)),
    retractall(visited(_,_)),
    retractall(safe(_,_)),
    retractall(tingle(_,_)),
    retractall(glitter(_,_)),
    retractall(tree_visited(_,_,_)),
    retractall(wall(_,_)),
    retractall(stench(_,_)).

percept(0).
percept(I):-
    I == 1,
    current(X,Y,_),
    assertz(stench(X,Y)).

percept(I):-
    I == 2,
    current(X,Y,_),
    assertz(tingle(X,Y)).

percept(I):-
    I == 3,
    current(X,Y,_),
    assertz(glitter(X,Y)).

percept(I):-
    I == 4,
    current(X,Y,_),
    assertz(wall(X,Y)).

percept(I):-
    I == 5,
    retractall(stench(_,_)),
    retractall(iswumpusalive).

move_loop(L,I):-
    nth0(I,L,on),
    percept(I),
    I < 5,
    C is I+1,
    move_loop(L,C).

move_loop(L,I):-
    nth0(I,L,off),
    I < 5,
    C is I+1,
    move_loop(L,C).

move_loop(L,I):-
    I == 5,
    nth0(I,L,off).

move_loop(L,I):-
    I == 5,
    nth0(I,L,on),
    percept(I).

move(A,L):-
    nth0(0,L,off),
    nth0(4,L,on),
    current(Xi,Yi,Di),
    action(A),
    move_loop(L,0),
    retractall(current(_,_,_)),
    assertz(current(Xi,Yi,Di)).

move(A,L):-
    nth0(0,L,off),
    nth0(4,L,off),
    action(A),
    move_loop(L,0).

move(_,L):-
    nth0(0,L,on),
    reposition(L).

reposition_loop(L,I):-
    nth0(I,L,on),
    percept(I),
    I < 5,
    C is I+1,
    reposition_loop(L,C).

reposition_loop(L,I):-
    nth0(I,L,off),
    I < 5,
    C is I+1,
    reposition_loop(L,C).

reposition_loop(_,5).

reposition(L):-
    nth0(0,L,on),
    nth0(5,L,off),
    confundusResetPercept,
    assertz(current(0,0,rnorth)),
    assertz(visited(0,0)),
    reposition_loop(L,0).

reborn:-
    confundusResetPercept,
    assertz(iswumpusalive),
    assertz(hasarrow),
    assertz(coinexist).















    
